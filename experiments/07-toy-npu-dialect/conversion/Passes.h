// Copyright 2026 The IREE Authors
//
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

#ifndef IREE_COMPILER_DIALECT_TOYNPU_CONVERSION_LINALGTOTOYNPU_PASSES_H_
#define IREE_COMPILER_DIALECT_TOYNPU_CONVERSION_LINALGTOTOYNPU_PASSES_H_

#include "mlir/Pass/Pass.h"

namespace mlir::iree_compiler::IREE::ToyNPU {

// Creates the LinalgMatmulToToyNPU pass.
std::unique_ptr<Pass> createLinalgMatmulToToyNPUPass();

// Registers the pass with MLIR's global pass registry.
void registerLinalgMatmulToToyNPUPass();

}  // namespace mlir::iree_compiler::IREE::ToyNPU

#endif  // IREE_COMPILER_DIALECT_TOYNPU_CONVERSION_LINALGTOTOYNPU_PASSES_H_