//===- ToyNPUBase.td - ToyNPU dialect base definitions ---*- tablegen -*---===//
//
// ToyNPU dialect for a hypothetical NPU accelerator.
// Provides tile-level primitives (load, store, matmul) modeling a small
// NPU with tile registers.
//
//===----------------------------------------------------------------------===//

#ifndef IREE_DIALECT_TOYNPU_BASE
#define IREE_DIALECT_TOYNPU_BASE

include "mlir/IR/OpBase.td"

//===----------------------------------------------------------------------===//
// ToyNPU dialect definition
//===----------------------------------------------------------------------===//

def ToyNPU_Dialect : Dialect {
  let name = "toy_npu";
  let summary = "Toy NPU dialect for a hypothetical tile-based accelerator";
  let description = [{
    The toy_npu dialect models a small NPU with:
    - 8 tile registers (each holding a 16x16 FP32 matrix)
    - Tile-level load/store/matmul primitives
    - Manual scratchpad memory management

    This is a design study, not production hardware.
  }];
  let cppNamespace = "::mlir::iree_compiler::IREE::ToyNPU";
  let useDefaultTypePrinterParser = 1;
}

//===----------------------------------------------------------------------===//
// Base classes for operations and types
//===----------------------------------------------------------------------===//

class ToyNPU_Op<string mnemonic, list<Trait> traits = []>
    : Op<ToyNPU_Dialect, mnemonic, traits>;

class ToyNPU_Type<string name, string typeMnemonic>
    : TypeDef<ToyNPU_Dialect, name> {
  let mnemonic = typeMnemonic;
}

#endif  // IREE_DIALECT_TOYNPU_BASE