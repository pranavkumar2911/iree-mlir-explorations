module {
  func.func @simple_matmul(%arg0: memref<16x16xf32>, %arg1: memref<16x16xf32>, %arg2: memref<16x16xf32>) {
    %c0 = arith.constant 0 : index
    %0 = toy_npu.tile_load %arg0[%c0, %c0] : memref<16x16xf32> -> !toy_npu.tile
    %1 = toy_npu.tile_load %arg1[%c0, %c0] : memref<16x16xf32> -> !toy_npu.tile
    %2 = toy_npu.tile_load %arg2[%c0, %c0] : memref<16x16xf32> -> !toy_npu.tile
    %3 = toy_npu.tile_matmul %0, %1, %2 : (!toy_npu.tile, !toy_npu.tile, !toy_npu.tile) -> !toy_npu.tile
    toy_npu.tile_store %3, %arg2[%c0, %c0] : !toy_npu.tile, memref<16x16xf32>
    return
  }
}

