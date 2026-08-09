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

//===----------------------------------------------------------------------===//
// Helper: check that a value is a 2D memref of the given shape and fp32
//===----------------------------------------------------------------------===//

static bool is2DMemrefF32Shape(Value v, int64_t rows, int64_t cols) {
  auto t = dyn_cast<MemRefType>(v.getType());
  if (!t) return false;
  if (!t.getElementType().isF32()) return false;
  if (t.getShape().size() != 2) return false;
  return t.getShape()[0] == rows && t.getShape()[1] == cols;
}

//===----------------------------------------------------------------------===//
// Helper: check that a linalg.generic body is `arith.maximumf(x, 0.0)` — a ReLU
//===----------------------------------------------------------------------===//

static bool isReluGenericBody(linalg::GenericOp genericOp) {
  Block &body = genericOp.getRegion().front();
  // Expect: %0 = arith.maximumf %in, %zero
  //         linalg.yield %0
  if (body.getOperations().size() != 2) return false;

  auto maxOp = dyn_cast<arith::MaximumFOp>(body.front());
  if (!maxOp) return false;

  // One of the operands must be the block argument (input),
  // the other must be a constant 0.0.
  Value blockArg = body.getArgument(0);
  Value lhs = maxOp.getLhs();
  Value rhs = maxOp.getRhs();
  Value maybeConst;
  if (lhs == blockArg) {
    maybeConst = rhs;
  } else if (rhs == blockArg) {
    maybeConst = lhs;
  } else {
    return false;
  }

  // Check it's a constant zero.
  auto constOp = maybeConst.getDefiningOp<arith::ConstantOp>();
  if (!constOp) return false;
  auto floatAttr = dyn_cast<FloatAttr>(constOp.getValue());
  if (!floatAttr) return false;
  return floatAttr.getValueAsDouble() == 0.0;
}

//===----------------------------------------------------------------------===//
// Pattern 1: fused linalg.matmul + linalg.add + linalg.generic(relu)
//===----------------------------------------------------------------------===//

class ConvertMatmulBiasReluToToyNPU
    : public OpRewritePattern<linalg::MatmulOp> {
public:
  using OpRewritePattern::OpRewritePattern;

  LogicalResult matchAndRewrite(linalg::MatmulOp matmulOp,
                                 PatternRewriter &rewriter) const override {
    Location loc = matmulOp.getLoc();

    // --- Step 1: verify matmul shape (16x16x16 fp32 memrefs) ---
    if (matmulOp.getInputs().size() != 2 || matmulOp.getOutputs().size() != 1) {
      return failure();
    }
    Value A = matmulOp.getInputs()[0];
    Value B = matmulOp.getInputs()[1];
    Value cBuf = matmulOp.getOutputs()[0];

    if (!is2DMemrefF32Shape(A, kTileSize, kTileSize) ||
        !is2DMemrefF32Shape(B, kTileSize, kTileSize) ||
        !is2DMemrefF32Shape(cBuf, kTileSize, kTileSize)) {
      return failure();
    }

    // --- Step 2: find the unique linalg.add that reads cBuf ---
    linalg::AddOp addOp;
    for (Operation *user : cBuf.getUsers()) {
      if (user == matmulOp) continue;
      if (auto a = dyn_cast<linalg::AddOp>(user)) {
        if (addOp) return failure();  // more than one; can't fuse
        addOp = a;
      } else {
        return failure();  // cBuf used by something we don't understand
      }
    }
    if (!addOp) return failure();

    // Verify add has 2 inputs and 1 output; one of the inputs is cBuf.
    if (addOp.getInputs().size() != 2 || addOp.getOutputs().size() != 1) {
      return failure();
    }
    Value addIn0 = addOp.getInputs()[0];
    Value addIn1 = addOp.getInputs()[1];
    Value biasBuf;
    if (addIn0 == cBuf) {
      biasBuf = addIn1;
    } else if (addIn1 == cBuf) {
      biasBuf = addIn0;
    } else {
      return failure();
    }
    Value dBuf = addOp.getOutputs()[0];

    if (!is2DMemrefF32Shape(biasBuf, kTileSize, kTileSize) ||
        !is2DMemrefF32Shape(dBuf, kTileSize, kTileSize)) {
      return failure();
    }

    // --- Step 3: find the unique linalg.generic(relu) that reads dBuf ---
    linalg::GenericOp reluOp;
    for (Operation *user : dBuf.getUsers()) {
      if (user == addOp) continue;
      if (auto g = dyn_cast<linalg::GenericOp>(user)) {
        if (reluOp) return failure();
        reluOp = g;
      } else {
        return failure();
      }
    }
    if (!reluOp) return failure();

    // Verify: 1 input, 1 output, both dBuf-derived and 16x16 fp32, and body is ReLU.
    if (reluOp.getInputs().size() != 1 || reluOp.getOutputs().size() != 1) {
      return failure();
    }
    if (reluOp.getInputs()[0] != dBuf) return failure();

    Value outBuf = reluOp.getOutputs()[0];
    if (!is2DMemrefF32Shape(outBuf, kTileSize, kTileSize)) return failure();

    if (!isReluGenericBody(reluOp)) return failure();

    // --- Step 4: emit the fused toy_npu sequence ---
    Value c0 = rewriter.create<arith::ConstantIndexOp>(loc, 0);
    Type tileType = TileType::get(rewriter.getContext());

    // Load A, B and use tile_zero as the matmul accumulator start.
    Value aTile = rewriter.create<TileLoadOp>(loc, tileType, A, c0, c0);
    Value bTile = rewriter.create<TileLoadOp>(loc, tileType, B, c0, c0);
    Value zeroTile = rewriter.create<TileZeroOp>(loc, tileType);

    // matmul: acc = A * B + 0
    Value acc = rewriter.create<TileMatmulOp>(
        loc, tileType, aTile, bTile, zeroTile);

    // Load bias and add
    Value biasTile = rewriter.create<TileLoadOp>(loc, tileType, biasBuf, c0, c0);
    Value biased = rewriter.create<TileAddOp>(loc, tileType, acc, biasTile);

    // relu
    Value activated = rewriter.create<TileReluOp>(loc, tileType, biased);

    // store to outBuf
    rewriter.create<TileStoreOp>(loc, activated, outBuf, c0, c0);

    // --- Step 5: erase in reverse dependency order ---
    rewriter.eraseOp(reluOp);
    rewriter.eraseOp(addOp);
    rewriter.eraseOp(matmulOp);

    return success();
  }
};

//===----------------------------------------------------------------------===//
// Pattern 2: tiled linalg.matmul -> toy_npu (existing, unchanged behavior)
//===----------------------------------------------------------------------===//

class ConvertLinalgMatmulToToyNPU
    : public OpRewritePattern<linalg::MatmulOp> {
public:
  using OpRewritePattern::OpRewritePattern;

  LogicalResult matchAndRewrite(linalg::MatmulOp op,
                                 PatternRewriter &rewriter) const override {
    Location loc = op.getLoc();

    if (op.getInputs().size() != 2 || op.getOutputs().size() != 1) {
      return failure();
    }

    Value A = op.getInputs()[0];
    Value B = op.getInputs()[1];
    Value C = op.getOutputs()[0];

    auto aType = dyn_cast<MemRefType>(A.getType());
    auto bType = dyn_cast<MemRefType>(B.getType());
    auto cType = dyn_cast<MemRefType>(C.getType());

    if (!aType || !bType || !cType) return failure();
    if (!aType.getElementType().isF32() ||
        !bType.getElementType().isF32() ||
        !cType.getElementType().isF32()) {
      return failure();
    }
    if (aType.getShape().size() != 2 ||
        bType.getShape().size() != 2 ||
        cType.getShape().size() != 2) {
      return failure();
    }

    int64_t M = aType.getShape()[0];
    int64_t K = aType.getShape()[1];
    int64_t Kb = bType.getShape()[0];
    int64_t N = bType.getShape()[1];
    int64_t Mc = cType.getShape()[0];
    int64_t Nc = cType.getShape()[1];

    if (K != Kb || M != Mc || N != Nc) return failure();

    if (M <= 0 || N <= 0 || K <= 0 ||
        M % kTileSize != 0 ||
        N % kTileSize != 0 ||
        K % kTileSize != 0) {
      return failure();
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
    return "Lower linalg.matmul (any 16-divisible size) into tiled toy_npu "
           "sequences. Also fuses matmul + bias-add + ReLU when found on "
           "16x16 memrefs.";
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
    // Add the fusion pattern with higher benefit so it tries first.
    patterns.add<ConvertMatmulBiasReluToToyNPU>(&getContext(), /*benefit=*/2);
    patterns.add<ConvertLinalgMatmulToToyNPU>(&getContext(), /*benefit=*/1);

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