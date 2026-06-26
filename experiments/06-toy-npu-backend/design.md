# toy_npu — design sketch for a custom IREE backend

## Goal

Sketch the architecture of a hypothetical NPU backend for IREE, grounded in how IREE's existing vendor backends are actually structured. This is a design document, not a working implementation — but it's a design that I could iteratively build out, knowing the structure is correct.

## Hypothetical hardware

A small NPU with these properties:

- **8 tile registers**, each holding a 16×16 matrix of FP32 (or 32×32 of INT8)
- **128 KB on-chip scratchpad** memory (no cache, manually managed)
- **DMA engine** that overlaps memory loads with compute
- Native instructions:
  - `tile_load tile, addr, stride` — load a tile from memory
  - `tile_store addr, stride, tile` — store a tile to memory
  - `tile_matmul tile_c, tile_a, tile_b` — FP32 accumulation, `tile_c += tile_a × tile_b`
  - `tile_zero tile` — clear a tile to zero
  - `tile_relu tile` — element-wise ReLU on a tile

Hypothetical peak performance: 1 tile_matmul per cycle × 4096 FMA ops per tile_matmul × 1 GHz = 4 TFLOPS FP32.

This is loosely inspired by published accelerator architectures (AMX, SME, various ML-focused NPUs). The exact instructions aren't the point — the point is to model a hardware shape that has matmul-tile primitives, which is the dominant class of ML accelerator IP.

## Architecture overview

Based on reading IREE's existing vendor backends (LLVMCPU, CUDA, Local), a toy_npu backend has three layers:

### Layer 1 — Plugin file (small)

Location: `compiler/plugins/target/ToyNPU/ToyNPUTarget.cpp`

Structurally identical to `LocalTarget.cpp` (39 lines). Just plugin registration glue:

```cpp
struct ToyNPUSession : PluginSession<ToyNPUSession, ToyNPUDevice::Options, ...> {
  void populateHALTargetDevices(TargetDeviceList &targets) {
    targets.add("toy-npu", [this]() {
      return std::make_shared<ToyNPUDevice>(options);
    });
  }
};

extern "C" bool iree_register_compiler_plugin_hal_target_toy_npu(...) {
  registrar->registerPlugin<ToyNPUSession>("hal_target_toy_npu");
  return true;
}
```

The plugin tells IREE: "I provide a device called 'toy-npu'. Here's how to construct it."

### Layer 2 — Device class (the substantive part)

Location: `compiler/src/iree/compiler/Dialect/HAL/Target/Devices/ToyNPUDevice.{h,cpp}`

Implements the `TargetBackend` contract (from `TargetBackend.h`). Key methods to implement:

- **`getLegacyDefaultDeviceID()`** — returns `"toy-npu"`
- **`getDefaultExecutableTargets()`** — declares an executable target attribute with `cpu = "toy-npu-v1"` and feature flags for the hardware
- **`getSupportedTypes()`** — returns FP32 (and INT8 if quantization is supported)
- **`getDependentDialects()`** — registers the toy_npu dialect so IREE loads it
- **`buildConfigurationPassPipeline()`** — adds passes that annotate executables with toy_npu-specific metadata (tile shapes, scratchpad sizes)
- **`buildTranslationPassPipeline()`** — adds passes that lower from upstream IR (linalg, vector) into toy_npu dialect ops, then serialize the result

The pass pipelines are where the actual lowering work happens.

### Layer 3 — Dialect (the operations)

Location: `compiler/src/iree/compiler/Dialect/ToyNPU/IR/`

A new MLIR dialect with operations matching the hardware. Defined in TableGen:

```tablegen
def ToyNPU_TileType : ToyNPU_Type<"Tile", "tile"> {
  let summary = "A 16x16 tile register holding FP32 values";
  let parameters = (ins "Type":$elementType, "int64_t":$rows, "int64_t":$cols);
}

def ToyNPU_TileLoadOp : ToyNPU_Op<"tile_load"> {
  let arguments = (ins MemRefOf<[F32]>:$source, Index:$row_stride);
  let results = (outs ToyNPU_TileType:$result);
  let assemblyFormat = "$source `,` $row_stride attr-dict `:` type($source) `->` type($result)";
}

def ToyNPU_TileMatmulOp : ToyNPU_Op<"tile_matmul"> {
  let arguments = (ins ToyNPU_TileType:$a, ToyNPU_TileType:$b, ToyNPU_TileType:$c_in);
  let results = (outs ToyNPU_TileType:$c_out);
  let assemblyFormat = "$a `,` $b `,` $c_in attr-dict `:` functional-type(operands, results)";
}

def ToyNPU_TileStoreOp : ToyNPU_Op<"tile_store"> {
  let arguments = (ins MemRefOf<[F32]>:$dest, ToyNPU_TileType:$tile, Index:$row_stride);
}
```

The dialect lives separately from the backend plugin. This is important — the same dialect could be used by multiple plugins (CPU simulation backend, FPGA backend, ASIC backend) all targeting the same conceptual hardware.

## Conversion: linalg.matmul → toy_npu

The core compilation flow for a matmul of size M×N×K (assume M, N, K all divisible by 16 for now):

### Pass 1: Tile to NPU tile size

Use IREE's existing tiling infrastructure (linalg.tile) to split the matmul into 16×16×16 inner tiles. Output:

```mlir
// Before
%result = linalg.matmul ins(%A, %B) outs(%C)

// After (sketch — actual MLIR is more verbose)
scf.for %i = 0 to M step 16 {
  scf.for %j = 0 to N step 16 {
    scf.for %k = 0 to K step 16 {
      %a_tile = tensor.extract_slice %A[%i, %k]
      %b_tile = tensor.extract_slice %B[%k, %j]
      %c_tile = tensor.extract_slice %C[%i, %j]
      %res = linalg.matmul ins(%a_tile, %b_tile) outs(%c_tile)  // small inner matmul
      ...
    }
  }
}
```

### Pass 2: Pattern-match inner matmuls → toy_npu ops

A rewrite pattern that matches small 16×16×16 linalg.matmuls and replaces them with toy_npu sequences. Based on the OpRewritePattern shape I saw in IREE source:

```cpp
class InnerMatmulToToyNPU : public OpRewritePattern<linalg::MatmulOp> {
  LogicalResult matchAndRewrite(linalg::MatmulOp op, PatternRewriter &rewriter) const override {
    // 1. Check that this is a 16x16x16 matmul (the inner-tile size)
    if (!isInnerTileMatmul(op)) return failure();
    
    // 2. Get operand memrefs (after bufferization)
    auto a_memref = ...;
    auto b_memref = ...;
    auto c_memref = ...;
    
    // 3. Emit tile_load for A and B
    auto a_tile = rewriter.create<ToyNPU::TileLoadOp>(loc, a_memref, row_stride);
    auto b_tile = rewriter.create<ToyNPU::TileLoadOp>(loc, b_memref, row_stride);
    auto c_tile = rewriter.create<ToyNPU::TileLoadOp>(loc, c_memref, row_stride);
    
    // 4. Emit tile_matmul: c_tile += a_tile * b_tile
    auto result = rewriter.create<ToyNPU::TileMatmulOp>(loc, a_tile, b_tile, c_tile);
    
    // 5. Emit tile_store to write back to C
    rewriter.create<ToyNPU::TileStoreOp>(loc, c_memref, result, row_stride);
    
    // 6. Replace the original op
    rewriter.eraseOp(op);
    return success();
  }
};
```

### Pass 3: Serialization

The toy_npu ops are translated to whatever binary format the toy NPU's hardware loader expects. For a real NPU, this might be a custom command stream. For the design study, FlatBuffer (the same format IREE uses elsewhere) is fine.

## HAL driver — the runtime side

The compiler produces a `.vmfb` containing toy_npu instructions. The runtime needs a HAL driver to actually execute them on (simulated or real) hardware.

Following the structure of existing drivers in `runtime/src/iree/hal/drivers/`:

- **Driver registration** — tells IREE about the toy_npu device
- **Device init/cleanup** — sets up command queues, scratchpad allocator
- **Command buffer encoding** — translates dispatch requests into toy_npu instruction sequences
- **Execution** — for the stub: print the instructions and return. For real hardware: program the NPU's command queue, wait for interrupt
- **Fences/semaphores** — synchronization with the host

For this design study, the HAL driver is a stub — it prints what it would do without actually executing. This validates that the compiler-side lowering is producing sensible output without requiring real hardware.

## What's NOT in this sketch but would be needed for a real implementation

This is a deliberate honesty section. The real backend would also need:

- **Real hardware or a cycle-accurate simulator** to validate that the lowering is correct and performant
- **A cost model** for tile_matmul (cycles, energy, scratchpad usage) to drive tiling decisions when the workload doesn't divide evenly by 16
- **DMA scheduling and double-buffering** to overlap memory transfers with compute — currently the design loads each tile sequentially before tile_matmul, which would leave compute idle
- **Quantization-aware lowering** — for INT8, the tile_matmul would have different precision semantics (INT32 accumulation, requantization), and quantize/dequantize ops would need to be lowered to NPU-aware sequences
- **Fusion-aware lowering** — recognize conv+bias+ReLU patterns and lower them as a single fused dispatch using tile_relu instead of separate kernels
- **Multi-tile orchestration** — if the workload has multiple parallel matmuls, schedule them across the 8 tile registers efficiently
- **Proper error handling, validation, debugging support** — the things that make a backend usable, not just demonstrable

## Why this matters for MIPS NPU work

The MIPS S8200 NPU compiler engineering role is, in significant part, what this sketch describes — at a higher fidelity with real hardware. The pattern is:

1. Define the MIPS NPU dialect — operations matching real hardware primitives
2. Implement the device class — pass pipelines that lower from linalg/vector into MIPS NPU ops
3. Write the HAL driver — real C code that programs the NPU
4. Tune the lowerings based on workload characterization (like Experiment 05 did for CPU)
5. Iterate as hardware design changes

The toy version is small. The real version is months of engineering. But the structure is the same — the IREE plugin architecture (Local backend = 39 lines) shows how cleanly extensible the framework is. The substance is in the device class, the dialect, and the runtime driver.