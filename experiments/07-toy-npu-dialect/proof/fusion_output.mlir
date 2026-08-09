#map = affine_map<(d0, d1) -> (d0, d1)>
module {
  func.func @matmul_bias_relu(%arg0: memref<16x16xf32>, %arg1: memref<16x16xf32>, %arg2: memref<16x16xf32>, %arg3: memref<16x16xf32>) {
    %c16 = arith.constant 16 : index
    %c0 = arith.constant 0 : index
    %cst = arith.constant 0.000000e+00 : f32
    %alloc = memref.alloc() : memref<16x16xf32>
    %alloc_0 = memref.alloc() : memref<16x16xf32>
    scf.for %arg4 = %c0 to %c16 step %c16 {
      scf.for %arg5 = %c0 to %c16 step %c16 {
        %0 = toy_npu.tile_load %alloc[%arg4, %arg5] : memref<16x16xf32> -> !toy_npu.tile
        %1 = scf.for %arg6 = %c0 to %c16 step %c16 iter_args(%arg7 = %0) -> (!toy_npu.tile) {
          %2 = toy_npu.tile_load %arg0[%arg4, %arg6] : memref<16x16xf32> -> !toy_npu.tile
          %3 = toy_npu.tile_load %arg1[%arg6, %arg5] : memref<16x16xf32> -> !toy_npu.tile
          %4 = toy_npu.tile_matmul %2, %3, %arg7 : (!toy_npu.tile, !toy_npu.tile, !toy_npu.tile) -> !toy_npu.tile
          scf.yield %4 : !toy_npu.tile
        }
        toy_npu.tile_store %1, %alloc[%arg4, %arg5] : !toy_npu.tile, memref<16x16xf32>
      }
    }
    linalg.add ins(%alloc, %arg2 : memref<16x16xf32>, memref<16x16xf32>) outs(%alloc_0 : memref<16x16xf32>)
    linalg.generic {indexing_maps = [#map, #map], iterator_types = ["parallel", "parallel"]} ins(%alloc_0 : memref<16x16xf32>) outs(%arg3 : memref<16x16xf32>) {
    ^bb0(%in: f32, %out: f32):
      %0 = arith.maximumf %in, %cst : f32
      linalg.yield %0 : f32
    }
    memref.dealloc %alloc : memref<16x16xf32>
    memref.dealloc %alloc_0 : memref<16x16xf32>
    return
  }
}

