// Copyright 2026 The IREE Authors
//
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

#ifndef IREE_COMPILER_DIALECT_TOYNPU_IR_TOYNPUDIALECT_H_
#define IREE_COMPILER_DIALECT_TOYNPU_IR_TOYNPUDIALECT_H_

#include "mlir/IR/Builders.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/DialectImplementation.h"
#include "mlir/IR/OpDefinition.h"
#include "mlir/IR/OpImplementation.h"
#include "mlir/IR/Operation.h"
#include "mlir/IR/Types.h"
#include "mlir/Interfaces/SideEffectInterfaces.h"

// Generated dialect declaration.
#include "iree/compiler/Dialect/ToyNPU/IR/ToyNPUDialect.h.inc"

// Generated type declarations.
#define GET_TYPEDEF_CLASSES
#include "iree/compiler/Dialect/ToyNPU/IR/ToyNPUTypes.h.inc"

// Generated op declarations.
#define GET_OP_CLASSES
#include "iree/compiler/Dialect/ToyNPU/IR/ToyNPUOps.h.inc"

#endif  // IREE_COMPILER_DIALECT_TOYNPU_IR_TOYNPUDIALECT_H_