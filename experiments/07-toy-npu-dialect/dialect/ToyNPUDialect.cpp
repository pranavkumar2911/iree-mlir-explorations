// Copyright 2026 The IREE Authors
//
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

#include "iree/compiler/Dialect/ToyNPU/IR/ToyNPUDialect.h"

#include "mlir/IR/DialectImplementation.h"
#include "llvm/ADT/TypeSwitch.h"

// Include generated dialect implementation.
#include "iree/compiler/Dialect/ToyNPU/IR/ToyNPUDialect.cpp.inc"

// Include generated type implementations.
#define GET_TYPEDEF_CLASSES
#include "iree/compiler/Dialect/ToyNPU/IR/ToyNPUTypes.cpp.inc"

// Include generated op implementations.
#define GET_OP_CLASSES
#include "iree/compiler/Dialect/ToyNPU/IR/ToyNPUOps.cpp.inc"

namespace mlir::iree_compiler::IREE::ToyNPU {

void ToyNPUDialect::initialize() {
  addTypes<TileType>();
  addOperations<TileMatmulOp, TileLoadOp, TileStoreOp, TileZeroOp, TileReluOp, TileAddOp>();
}

}  // namespace mlir::iree_compiler::IREE::ToyNPU