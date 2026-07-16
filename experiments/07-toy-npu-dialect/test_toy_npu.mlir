// Test that iree-opt can parse code using the toy_npu dialect.

func.func @test(%a: !toy_npu.tile, %b: !toy_npu.tile, %c: !toy_npu.tile) -> !toy_npu.tile {
  %result = toy_npu.tile_matmul %a, %b, %c : (!toy_npu.tile, !toy_npu.tile, !toy_npu.tile) -> !toy_npu.tile
  return %result : !toy_npu.tile
}
