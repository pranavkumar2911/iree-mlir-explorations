module {
  func.func @simple_matmul(%arg0: memref<16x16xf32>, %arg1: memref<16x16xf32>, %arg2: memref<16x16xf32>) {
    %c0 = arith.constant 0 : index
    %c16 = arith.constant 16 : index
    scf.for %arg3 = %c0 to %c16 step %c16 {
      scf.for %arg4 = %c0 to %c16 step %c16 {
        %0 = toy_npu.tile_load %arg2[%arg3, %arg4] : memref<16x16xf32> -> !toy_npu.tile
        %1 = scf.for %arg5 = %c0 to %c16 step %c16 iter_args(%arg6 = %0) -> (!toy_npu.tile) {
          %2 = toy_npu.tile_load %arg0[%arg3, %arg5] : memref<16x16xf32> -> !toy_npu.tile
          %3 = toy_npu.tile_load %arg1[%arg5, %arg4] : memref<16x16xf32> -> !toy_npu.tile
          %4 = toy_npu.tile_matmul %2, %3, %arg6 : (!toy_npu.tile, !toy_npu.tile, !toy_npu.tile) -> !toy_npu.tile
          scf.yield %4 : !toy_npu.tile
        }
        toy_npu.tile_store %1, %arg2[%arg3, %arg4] : !toy_npu.tile, memref<16x16xf32>
      }
    }
    return
  }
}

