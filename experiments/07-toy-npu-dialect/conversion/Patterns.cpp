// Copyright 2026 The IREE Authors
//
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

#include "iree/compiler/Dialect/ToyNPU/Conversion/LinalgToToyNPU/Passes.h"

#include "iree/compiler/Dialect/ToyNPU/IR/ToyNPUDialect.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Pass/PassRegistry.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"

namespace mlir::iree_compiler::IREE::ToyNPU {

namespace {

//===----------------------------------------------------------------------===//
// linalg.matmul -> toy_npu sequence
//===----------------------------------------------------------------------===//

class ConvertLinalgMatmulToToyNPU
    : public OpRewritePattern<linalg::MatmulOp> {
public:
  using OpRewritePattern::OpRewritePattern;

  LogicalResult matchAndRewrite(linalg::MatmulOp op,
                                 PatternRewriter &rewriter) const override {
    Location loc = op.getLoc();

    // Get inputs (A, B) and output (C) memrefs from the linalg.matmul.
    // linalg.matmul takes 2 inputs and 1 "output" (which is really an
    // input-output for the accumulator).
    if (op.getInputs().size() != 2 || op.getOutputs().size() != 1) {
      return rewriter.notifyMatchFailure(
          op, "expected 2 inputs and 1 output for linalg.matmul");
    }

    Value A = op.getInputs()[0];
    Value B = op.getInputs()[1];
    Value C = op.getOutputs()[0];

    // Check that all three operands are memrefs of shape 16x16xf32.
    // This is a scope restriction: we only handle the exact tile size for now.
    auto checkShape = [&](Value v) -> bool {
      auto memrefType = dyn_cast<MemRefType>(v.getType());
      if (!memrefType) return false;
      if (!memrefType.getElementType().isF32()) return false;
      auto shape = memrefType.getShape();
      return shape.size() == 2 && shape[0] == 16 && shape[1] == 16;
    };

    if (!checkShape(A) || !checkShape(B) || !checkShape(C)) {
      return rewriter.notifyMatchFailure(
          op, "only handling 16x16xf32 memrefs for now");
    }

    // Emit index constants.
    Value c0 = rewriter.create<arith::ConstantIndexOp>(loc, 0);

    // Build the toy_npu tile type.
    Type tileType = TileType::get(rewriter.getContext());

    // Emit tile_loads for A, B, and C (accumulator).
    Value aTile = rewriter.create<TileLoadOp>(loc, tileType, A, c0, c0);
    Value bTile = rewriter.create<TileLoadOp>(loc, tileType, B, c0, c0);
    Value cTile = rewriter.create<TileLoadOp>(loc, tileType, C, c0, c0);

    // Emit tile_matmul: c_out = a * b + c_in
    Value result = rewriter.create<TileMatmulOp>(
        loc, tileType, aTile, bTile, cTile);

    // Emit tile_store to write the result back into C.
    rewriter.create<TileStoreOp>(loc, result, C, c0, c0);

    // Erase the original linalg.matmul.
    rewriter.eraseOp(op);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// Pass driver
//===----------------------------------------------------------------------===//

class LinalgMatmulToToyNPUPass
    : public ::mlir::PassWrapper<LinalgMatmulToToyNPUPass,
                                  ::mlir::OperationPass<>> {
public:
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(LinalgMatmulToToyNPUPass)

  StringRef getArgument() const override {
    return "toynpu-lower-linalg-matmul";
  }

  StringRef getDescription() const override {
    return "Lower linalg.matmul into a toy_npu tile_load / tile_matmul / "
           "tile_store sequence (16x16xf32 only).";
  }

  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<linalg::LinalgDialect,
                    arith::ArithDialect,
                    memref::MemRefDialect,
                    ToyNPUDialect>();
  }

  void runOnOperation() override {
    RewritePatternSet patterns(&getContext());
    patterns.add<ConvertLinalgMatmulToToyNPU>(&getContext());

    if (failed(applyPatternsGreedily(getOperation(), std::move(patterns)))) {
      signalPassFailure();
    }
  }
};

}  // namespace

std::unique_ptr<Pass> createLinalgMatmulToToyNPUPass() {
  return std::make_unique<LinalgMatmulToToyNPUPass>();
}

void registerLinalgMatmulToToyNPUPass() {
  PassRegistration<LinalgMatmulToToyNPUPass>();
}

}  // namespace mlir::iree_compiler::IREE::ToyNPU