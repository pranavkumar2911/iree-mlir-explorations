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

//===----------------------------------------------------------------------===//
// toy_npu.tile_load
//===----------------------------------------------------------------------===//

def ToyNPU_TileLoadOp : ToyNPU_Op<"tile_load"> {
  let summary = "Load a tile from memory into a tile register";
  let description = [{
    Loads a 16x16 tile from a memref into a tile register.
    Represents a hardware tile_load instruction on the toy NPU.

    Example:
```mlir
    %tile = toy_npu.tile_load %memref[%row, %col]
        : memref<64x64xf32> -> !toy_npu.tile
```
  }];

  let arguments = (ins
    AnyMemRef:$source,
    Index:$row,
    Index:$col
  );

  let results = (outs ToyNPU_TileType:$result);

  let assemblyFormat = [{
    $source `[` $row `,` $col `]` attr-dict `:` type($source) `->` type($result)
  }];
}

//===----------------------------------------------------------------------===//
// toy_npu.tile_store
//===----------------------------------------------------------------------===//

def ToyNPU_TileStoreOp : ToyNPU_Op<"tile_store"> {
  let summary = "Store a tile register back to memory";
  let description = [{
    Stores a 16x16 tile register back to a memref location.
    Represents a hardware tile_store instruction on the toy NPU.

    Example:
```mlir
    toy_npu.tile_store %tile, %memref[%row, %col]
        : !toy_npu.tile, memref<64x64xf32>
```
  }];

  let arguments = (ins
    ToyNPU_TileType:$tile,
    AnyMemRef:$dest,
    Index:$row,
    Index:$col
  );

  let assemblyFormat = [{
    $tile `,` $dest `[` $row `,` $col `]` attr-dict `:` type($tile) `,` type($dest)
  }];
}

#endif  // IREE_DIALECT_TOYNPU_OPS