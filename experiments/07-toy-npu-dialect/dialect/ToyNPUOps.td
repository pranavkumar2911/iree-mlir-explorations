//===- ToyNPUOps.td - ToyNPU dialect operations ----------*- tablegen -*---===//

#ifndef IREE_DIALECT_TOYNPU_OPS
#define IREE_DIALECT_TOYNPU_OPS

include "iree/compiler/Dialect/ToyNPU/IR/ToyNPUBase.td"
include "iree/compiler/Dialect/ToyNPU/IR/ToyNPUTypes.td"
include "mlir/Interfaces/SideEffectInterfaces.td"

//===----------------------------------------------------------------------===//
// toy_npu.tile_matmul
//===----------------------------------------------------------------------===//

def ToyNPU_TileMatmulOp : ToyNPU_Op<"tile_matmul", [Pure]> {
  let summary = "Tile-level matrix multiply-accumulate";
  let description = [{
    Computes `c_out = a * b + c_in` where all operands are 16x16 tiles.
    Represents a single hardware tile_matmul instruction on the toy NPU.

    Example:
```mlir
    %c_out = toy_npu.tile_matmul %a, %b, %c_in
        : (!toy_npu.tile, !toy_npu.tile, !toy_npu.tile) -> !toy_npu.tile
```
  }];

  let arguments = (ins
    ToyNPU_TileType:$a,
    ToyNPU_TileType:$b,
    ToyNPU_TileType:$c_in
  );

  let results = (outs ToyNPU_TileType:$c_out);

  let assemblyFormat = [{
    $a `,` $b `,` $c_in attr-dict `:`
    functional-type(operands, results)
  }];
}

#endif  // IREE_DIALECT_TOYNPU_OPS