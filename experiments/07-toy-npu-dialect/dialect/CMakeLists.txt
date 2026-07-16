# Copyright 2026 The IREE Authors
#
# Licensed under the Apache License v2.0 with LLVM Exceptions.
# See https://llvm.org/LICENSE.txt for license information.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

iree_add_all_subdirs()

iree_cc_library(
  NAME
    IR
  HDRS
    "ToyNPUDialect.h"
  TEXTUAL_HDRS
    "ToyNPUDialect.cpp.inc"
    "ToyNPUDialect.h.inc"
    "ToyNPUOps.cpp.inc"
    "ToyNPUOps.h.inc"
    "ToyNPUTypes.cpp.inc"
    "ToyNPUTypes.h.inc"
  SRCS
    "ToyNPUDialect.cpp"
  DEPS
    LLVMSupport
    MLIRIR
    MLIRInferTypeOpInterface
    MLIRParser
    MLIRSideEffectInterfaces
    MLIRSupport
  PUBLIC
)

iree_tablegen_library(
  NAME
    ToyNPUOpsGen
  TD_FILE
    "ToyNPUOps.td"
  OUTS
    --gen-op-decls ToyNPUOps.h.inc
    --gen-op-defs ToyNPUOps.cpp.inc
)

iree_tablegen_library(
  NAME
    ToyNPUTypesGen
  TD_FILE
    "ToyNPUTypes.td"
  OUTS
    --gen-typedef-decls ToyNPUTypes.h.inc
    --gen-typedef-defs ToyNPUTypes.cpp.inc
)

iree_tablegen_library(
  NAME
    ToyNPUDialectGen
  TD_FILE
    "ToyNPUBase.td"
  OUTS
    --gen-dialect-decls ToyNPUDialect.h.inc
    --gen-dialect-defs ToyNPUDialect.cpp.inc
)