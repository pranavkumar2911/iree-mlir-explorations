// Test all three toy_npu ops: tile_load, tile_matmul, tile_store

func.func @full_matmul(
    %A: memref<16x16xf32>,
    %B: memref<16x16xf32>,
    %C: memref<16x16xf32>
) {
  %c0 = arith.constant 0 : index

  // Load the three tiles
  %a_tile = toy_npu.tile_load %A[%c0, %c0]
      : memref<16x16xf32> -> !toy_npu.tile
  %b_tile = toy_npu.tile_load %B[%c0, %c0]
      : memref<16x16xf32> -> !toy_npu.tile
  %c_tile = toy_npu.tile_load %C[%c0, %c0]
      : memref<16x16xf32> -> !toy_npu.tile

  // Compute: c_out = a * b + c_in
  %result = toy_npu.tile_matmul %a_tile, %b_tile, %c_tile
      : (!toy_npu.tile, !toy_npu.tile, !toy_npu.tile) -> !toy_npu.tile

  // Store back
  toy_npu.tile_store %result, %C[%c0, %c0]
      : !toy_npu.tile, memref<16x16xf32>

  return
}
