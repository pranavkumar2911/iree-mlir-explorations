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
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Pass/PassRegistry.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"

namespace mlir::iree_compiler::IREE::ToyNPU {

namespace {

constexpr int64_t kTileSize = 16;

class ConvertLinalgMatmulToToyNPU
    : public OpRewritePattern<linalg::MatmulOp> {
public:
  using OpRewritePattern::OpRewritePattern;

  LogicalResult matchAndRewrite(linalg::MatmulOp op,
                                 PatternRewriter &rewriter) const override {
    Location loc = op.getLoc();

    if (op.getInputs().size() != 2 || op.getOutputs().size() != 1) {
      return rewriter.notifyMatchFailure(op, "expected 2 inputs and 1 output");
    }

    Value A = op.getInputs()[0];
    Value B = op.getInputs()[1];
    Value C = op.getOutputs()[0];

    auto aType = dyn_cast<MemRefType>(A.getType());
    auto bType = dyn_cast<MemRefType>(B.getType());
    auto cType = dyn_cast<MemRefType>(C.getType());

    if (!aType || !bType || !cType) {
      return rewriter.notifyMatchFailure(op, "operands must be memrefs");
    }

    if (!aType.getElementType().isF32() ||
        !bType.getElementType().isF32() ||
        !cType.getElementType().isF32()) {
      return rewriter.notifyMatchFailure(op, "operands must be fp32");
    }

    if (aType.getShape().size() != 2 ||
        bType.getShape().size() != 2 ||
        cType.getShape().size() != 2) {
      return rewriter.notifyMatchFailure(op, "operands must be 2D");
    }

    int64_t M = aType.getShape()[0];
    int64_t K = aType.getShape()[1];
    int64_t Kb = bType.getShape()[0];
    int64_t N = bType.getShape()[1];
    int64_t Mc = cType.getShape()[0];
    int64_t Nc = cType.getShape()[1];

    if (K != Kb || M != Mc || N != Nc) {
      return rewriter.notifyMatchFailure(op, "dim mismatch");
    }

    if (M <= 0 || N <= 0 || K <= 0 ||
        M % kTileSize != 0 ||
        N % kTileSize != 0 ||
        K % kTileSize != 0) {
      return rewriter.notifyMatchFailure(
          op, "all dims must be positive and divisible by 16");
    }

    Value c0 = rewriter.create<arith::ConstantIndexOp>(loc, 0);
    Value cM = rewriter.create<arith::ConstantIndexOp>(loc, M);
    Value cN = rewriter.create<arith::ConstantIndexOp>(loc, N);
    Value cK = rewriter.create<arith::ConstantIndexOp>(loc, K);
    Value cTile = rewriter.create<arith::ConstantIndexOp>(loc, kTileSize);

    Type tileType = TileType::get(rewriter.getContext());

    auto iLoop = rewriter.create<scf::ForOp>(loc, c0, cM, cTile);
    rewriter.setInsertionPointToStart(iLoop.getBody());
    Value i = iLoop.getInductionVar();

    auto jLoop = rewriter.create<scf::ForOp>(loc, c0, cN, cTile);
    rewriter.setInsertionPointToStart(jLoop.getBody());
    Value j = jLoop.getInductionVar();

    Value cTileVal = rewriter.create<TileLoadOp>(loc, tileType, C, i, j);

    auto kLoop = rewriter.create<scf::ForOp>(
        loc, c0, cK, cTile, ValueRange{cTileVal});
    rewriter.setInsertionPointToStart(kLoop.getBody());
    Value k = kLoop.getInductionVar();
    Value accIn = kLoop.getRegionIterArgs()[0];

    Value aTileVal = rewriter.create<TileLoadOp>(loc, tileType, A, i, k);
    Value bTileVal = rewriter.create<TileLoadOp>(loc, tileType, B, k, j);

    Value accOut = rewriter.create<TileMatmulOp>(
        loc, tileType, aTileVal, bTileVal, accIn);

    rewriter.create<scf::YieldOp>(loc, ValueRange{accOut});

    rewriter.setInsertionPointAfter(kLoop);
    Value finalAcc = kLoop.getResult(0);
    rewriter.create<TileStoreOp>(loc, finalAcc, C, i, j);

    rewriter.setInsertionPointAfter(iLoop);
    rewriter.eraseOp(op);
    return success();
  }
};

class LinalgMatmulToToyNPUPass
    : public ::mlir::PassWrapper<LinalgMatmulToToyNPUPass,
                                  ::mlir::OperationPass<>> {
public:
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(LinalgMatmulToToyNPUPass)

  StringRef getArgument() const override {
    return "toynpu-lower-linalg-matmul";
  }

  StringRef getDescription() const override {
    return "Lower linalg.matmul (any 16-divisible size) into tiled "
           "toy_npu tile_load / tile_matmul / tile_store sequences.";
  }

  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<linalg::LinalgDialect,
                    arith::ArithDialect,
                    memref::MemRefDialect,
                    scf::SCFDialect,
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