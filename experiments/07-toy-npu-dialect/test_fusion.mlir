func.func @matmul_bias_relu(
    %A: memref<16x16xf32>,
    %B: memref<16x16xf32>,
    %bias: memref<16x16xf32>,
    %out: memref<16x16xf32>
) {
  %c_buf = memref.alloc() : memref<16x16xf32>
  %d_buf = memref.alloc() : memref<16x16xf32>
  %zero = arith.constant 0.0 : f32

  linalg.matmul
    ins(%A, %B : memref<16x16xf32>, memref<16x16xf32>)
    outs(%c_buf : memref<16x16xf32>)

  linalg.add
    ins(%c_buf, %bias : memref<16x16xf32>, memref<16x16xf32>)
    outs(%d_buf : memref<16x16xf32>)

  linalg.generic {
    indexing_maps = [
      affine_map<(d0, d1) -> (d0, d1)>,
      affine_map<(d0, d1) -> (d0, d1)>
    ],
    iterator_types = ["parallel", "parallel"]
  } ins(%d_buf : memref<16x16xf32>) outs(%out : memref<16x16xf32>) {
    ^bb0(%in: f32, %o: f32):
      %relu = arith.maximumf %in, %zero : f32
      linalg.yield %relu : f32
  }

  memref.dealloc %c_buf : memref<16x16xf32>
  memref.dealloc %d_buf : memref<16x16xf32>
  return
}
