func.func @big_matmul(%A: memref<32x32xf32>, %B: memref<32x32xf32>, %C: memref<32x32xf32>) {
  linalg.matmul ins(%A, %B : memref<32x32xf32>, memref<32x32xf32>) outs(%C : memref<32x32xf32>)
  return
}
