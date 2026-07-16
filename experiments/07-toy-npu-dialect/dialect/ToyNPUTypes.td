//===- ToyNPUTypes.td - ToyNPU dialect types --------------*- tablegen -*---===//

#ifndef IREE_DIALECT_TOYNPU_TYPES
#define IREE_DIALECT_TOYNPU_TYPES

include "iree/compiler/Dialect/ToyNPU/IR/ToyNPUBase.td"

//===----------------------------------------------------------------------===//
// ToyNPU tile type
//===----------------------------------------------------------------------===//

def ToyNPU_TileType : ToyNPU_Type<"Tile", "tile"> {
  let summary = "A tile register holding a small matrix";
  let description = [{
    A `!toy_npu.tile` value represents one of the 8 tile registers
    in the toy NPU. Each tile holds a 16x16 FP32 matrix.

    In IR: `!toy_npu.tile`
  }];
  let assemblyFormat = "";
}

#endif  // IREE_DIALECT_TOYNPU_TYPES