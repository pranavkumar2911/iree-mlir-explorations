module {
  func.func @test(%arg0: !toy_npu.tile, %arg1: !toy_npu.tile, %arg2: !toy_npu.tile) -> !toy_npu.tile {
    %0 = toy_npu.tile_matmul %arg0, %arg1, %arg2 : (!toy_npu.tile, !toy_npu.tile, !toy_npu.tile) -> !toy_npu.tile
    return %0 : !toy_npu.tile
  }
}

