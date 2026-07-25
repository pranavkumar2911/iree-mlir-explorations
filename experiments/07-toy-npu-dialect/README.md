# Experiment 07 — Working toy_npu dialect + linalg.matmul lowering pass in IREE

## Goal

Move from "I sketched a dialect design" (Experiment 06) to "I built one and wired it into a real compiler lowering path." Fork IREE, add a working `ToyNPU` dialect with a custom type and three operations, write a conversion pattern that lowers `linalg.matmul` into a `toy_npu` tile sequence, register it as a callable pass in `iree-opt`, and verify the full path end-to-end.

## What was built

A complete custom MLIR dialect + lowering pass integrated into IREE:

### The dialect
- **`!toy_npu.tile`** — custom type representing a hardware tile register (16×16 FP32)
- **`toy_npu.tile_load`** — load a 16×16 tile from a memref into a tile register
- **`toy_npu.tile_matmul`** — compute `c_out = a * b + c_in` on three tiles
- **`toy_npu.tile_store`** — write a tile register back to a memref
- **Registration** in IREE's dialect init so `iree-opt --show-dialects` includes `toy_npu`
- **CMake integration** so the dialect compiles into IREE's static library set and links into `iree-opt`

### The conversion pass
- **`--toynpu-lower-linalg-matmul`** — a new pass registered in `iree-opt` that finds `linalg.matmul` operations and rewrites them into `toy_npu` tile sequences
- Pattern implemented as an `OpRewritePattern<linalg::MatmulOp>` in C++
- Currently scoped to 16×16 FP32 memrefs (the tile size); the extension to arbitrary sizes via outer-loop tiling is the natural next step

Result: `iree-opt --toynpu-lower-linalg-matmul` takes a program written in standard MLIR (linalg + memref), finds the matmul operations, and rewrites them into a full `tile_load → tile_matmul → tile_store` sequence targeting the toy NPU dialect.

## Proof

### The dialect is registered

Full output of `iree-opt --show-dialects` in `proof/dialects_registered.txt`:
...tosa,toy_npu,transform,...

`toy_npu` slots into the alphabetical dialect list alongside every IREE-provided dialect (`flow`, `hal`, `stream`, `iree_gpu`, `iree_codegen`, etc.).

### Dialect ops parse, verify, and print

`proof/all_ops_test_output.mlir` — a program that loads three tiles, matmuls them, and stores the result, round-tripped through `iree-opt`:

```mlir
%c0 = arith.constant 0 : index
%0 = toy_npu.tile_load %arg0[%c0, %c0] : memref<16x16xf32> -> !toy_npu.tile
%1 = toy_npu.tile_load %arg1[%c0, %c0] : memref<16x16xf32> -> !toy_npu.tile
%2 = toy_npu.tile_load %arg2[%c0, %c0] : memref<16x16xf32> -> !toy_npu.tile
%3 = toy_npu.tile_matmul %0, %1, %2 : (!toy_npu.tile, !toy_npu.tile, !toy_npu.tile) -> !toy_npu.tile
toy_npu.tile_store %3, %arg2[%c0, %c0] : !toy_npu.tile, memref<16x16xf32>
```

The three ops compose — `tile_load` outputs feed `tile_matmul`, whose output feeds `tile_store`. Standard MLIR round-trip.

### The conversion pass works end-to-end

Input file `test_conversion.mlir` has a plain `linalg.matmul`:

```mlir
func.func @simple_matmul(
    %A: memref<16x16xf32>,
    %B: memref<16x16xf32>,
    %C: memref<16x16xf32>
) {
  linalg.matmul
    ins(%A, %B : memref<16x16xf32>, memref<16x16xf32>)
    outs(%C : memref<16x16xf32>)
  return
}
```

Running `iree-opt --toynpu-lower-linalg-matmul test_conversion.mlir` produces `proof/conversion_output.mlir`:

```mlir
module {
  func.func @simple_matmul(%arg0: memref<16x16xf32>, %arg1: memref<16x16xf32>, %arg2: memref<16x16xf32>) {
    %c0 = arith.constant 0 : index
    %0 = toy_npu.tile_load %arg0[%c0, %c0] : memref<16x16xf32> -> !toy_npu.tile
    %1 = toy_npu.tile_load %arg1[%c0, %c0] : memref<16x16xf32> -> !toy_npu.tile
    %2 = toy_npu.tile_load %arg2[%c0, %c0] : memref<16x16xf32> -> !toy_npu.tile
    %3 = toy_npu.tile_matmul %0, %1, %2 : (!toy_npu.tile, !toy_npu.tile, !toy_npu.tile) -> !toy_npu.tile
    toy_npu.tile_store %3, %arg2[%c0, %c0] : !toy_npu.tile, memref<16x16xf32>
    return
  }
}
```

The `linalg.matmul` is gone. In its place: three `toy_npu.tile_load` ops for A, B, and C, a `toy_npu.tile_matmul`, and a `toy_npu.tile_store` writing the result back into C. Same computation, expressed in the target dialect's primitives.

This is the shape of vendor backend lowering work — finding a high-level op in the input IR and rewriting it into hardware-specific primitives.

## Files

### `dialect/` — the dialect implementation
- `ToyNPUBase.td` — dialect declaration (name, C++ namespace)
- `ToyNPUTypes.td` — the `!toy_npu.tile` type in TableGen
- `ToyNPUOps.td` — the three operations (`tile_load`, `tile_matmul`, `tile_store`) in TableGen
- `ToyNPUDialect.h` — C++ header including MLIR infrastructure + generated code
- `ToyNPUDialect.cpp` — C++ implementation registering the type and operations
- `CMakeLists.txt` — build rules (TableGen invocations + iree_cc_library)

### `conversion/` — the lowering pass
- `Passes.h` — pass declaration (`createLinalgMatmulToToyNPUPass`, `registerLinalgMatmulToToyNPUPass`)
- `Patterns.cpp` — the `OpRewritePattern<linalg::MatmulOp>` implementation plus the pass driver
- `CMakeLists.txt` — build rules for the conversion library
- `Conversion_CMakeLists.txt` — parent CMake for the `Conversion/` subdirectory

### `integration/` — modifications to IREE's own source
- `init_iree_dialects.h` — modified to `#include` the ToyNPU dialect and `registry.insert<>` it alongside HAL/Flow/Stream/etc.
- `init_iree_passes.h` — modified to `#include` the LinalgToToyNPU pass header and call `registerLinalgMatmulToToyNPUPass()` alongside the other dialect pass registrations.
- `Tools_CMakeLists.txt` — modified to add both `iree::compiler::Dialect::ToyNPU::IR` and `iree::compiler::Dialect::ToyNPU::Conversion::LinalgToToyNPU::LinalgToToyNPU` as link dependencies of `init_iree_passes_and_dialects`

### Test inputs
- `test_toy_npu.mlir` — smallest test (tile_matmul only)
- `test_all_ops.mlir` — full load/matmul/store cycle
- `test_conversion.mlir` — a `linalg.matmul` input to feed the lowering pass

### `proof/` — verification outputs
- `dialects_registered.txt` — full output of `iree-opt --show-dialects` showing `toy_npu` in the list
- `parse_test_output.mlir` — round-trip parse output for tile_matmul alone
- `all_ops_test_output.mlir` — round-trip for the full load/matmul/store composition
- `conversion_output.mlir` — the linalg.matmul → toy_npu rewrite from the pass

## Hardware model

The dialect models a hypothetical NPU with:
- 8 tile registers, each holding a 16×16 matrix of FP32
- Tile-level primitives (load, store, matmul)
- Manual scratchpad memory management

Only the 16×16 tile-size case is handled by the lowering pass. Real work would extend this to arbitrary shapes via outer-loop tiling before the pattern match.

## What this required

Beyond the dialect files themselves, the work touched:

1. **IREE source build from scratch** — `git submodule update --init --recursive`, cmake configure, ninja build (9642 objects, ~1 hour)
2. **TableGen setup** — three `.td` files declaring the dialect, type, and three ops
3. **MLIR header dependencies** — needed `Builders.h`, `BuiltinOps.h`, `BuiltinTypes.h`, `DialectImplementation.h`, `OpImplementation.h`, `Operation.h`, `SideEffectInterfaces.h` in the dialect header
4. **CMake library dependencies** — needed `MLIRInferTypeOpInterface` and `MLIRSideEffectInterfaces` beyond the obvious `MLIRIR`
5. **Dialect registration wiring** — one include line + one `registry.insert<>` entry + one CMakeLists dependency line in `Tools/`
6. **The lowering pattern** — an `OpRewritePattern<linalg::MatmulOp>` doing shape validation, then emitting three tile_load / one tile_matmul / one tile_store using `rewriter.create<>`
7. **Pass driver** — a `PassWrapper<...>` subclass wrapping the pattern, giving it a command-line-visible name and `runOnOperation()` using `applyPatternsGreedily`
8. **Pass registration** — added the include + call to `registerLinalgMatmulToToyNPUPass()` in `init_iree_passes.h`, added the conversion library as a link dep in `Tools/CMakeLists.txt`
9. **Rebuild cycles** — the ToyNPU library, then iree-opt (with the dialect linked in), then iree-opt again (with the conversion pass linked in)

Each of these had a debugging step along the way (parser errors on macro-based `addTypes<>`, missing types on incomplete includes, `PassWrapper` needing explicit `mlir::` qualification, etc.). All resolved and documented in the source.

## What's next

Now that the toy path is working, the natural extensions:

- **Handle non-16-sized inputs** via outer-loop tiling. Real workloads don't come pre-tiled at hardware tile size; the pass would need to first tile linalg.matmul via IREE's existing tiling infrastructure, then match the inner tile-sized matmul.
- **Add `tile_zero` and `tile_relu`** for fused conv+bias+ReLU patterns.
- **Add a HAL driver stub** so a `.vmfb` containing toy_npu ops could actually "execute" (print what it would do).
- **INT8 variant** for quantized inference, since real NPUs care about INT8 throughput.
- **Cost model** driving tile-size selection decisions.

None of these change the architectural pattern established here. They're extensions in scale, not in shape.

## Why this matters

The daily work of an NPU compiler engineer at a company building custom accelerators looks like this at higher fidelity: define a dialect modeling the hardware primitives, write conversion patterns from upstream dialects (linalg, vector) to the hardware dialect, register the passes so they can be invoked from the compiler driver, iterate based on workload characterization.

Getting the small version working — 3 ops, 1 conversion pattern, 16x16 fixed size — exercises the same code paths as the production version. The architectural understanding transfers directly; only the scope grows.