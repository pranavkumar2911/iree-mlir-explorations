# Experiment 07 — Working toy_npu dialect + linalg.matmul lowering pass in IREE

## Goal

Move from "I sketched a dialect design" (Experiment 06) to "I built one and wired it into a real compiler lowering path." Fork IREE, add a working `ToyNPU` dialect with a custom type and three operations, write a conversion pattern that lowers `linalg.matmul` into tiled `toy_npu` sequences for arbitrary 16-divisible shapes, register it as a callable pass in `iree-opt`, and verify the full path end-to-end.

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
- **`--toynpu-lower-linalg-matmul`** — a pass registered in `iree-opt` that finds `linalg.matmul` operations and rewrites them into tiled `toy_npu` sequences
- Pattern implemented as an `OpRewritePattern<linalg::MatmulOp>` in C++
- Handles arbitrary matmul sizes where M, N, K are all positive multiples of 16
- Generates nested `scf.for` loops with tile-size stride, and emits `tile_load`/`tile_matmul`/`tile_store` inside using the loop induction variables as tile offsets
- The K loop uses an accumulator carried via `iter_args`/`scf.yield`, so the C tile is loaded once and stored once per (i,j), with matmul accumulation across K

Result: `iree-opt --toynpu-lower-linalg-matmul` takes a program written in standard MLIR (linalg + memref) with any 16-divisible matmul shape, tiles the computation into the hardware tile size, and rewrites it into `toy_npu` primitives.

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

### Conversion pass — single-tile case (16×16×16)

Input file `test_conversion.mlir` has a plain `linalg.matmul` at exactly hardware tile size:

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
    %c16 = arith.constant 16 : index
    scf.for %arg3 = %c0 to %c16 step %c16 {
      scf.for %arg4 = %c0 to %c16 step %c16 {
        %0 = toy_npu.tile_load %arg2[%arg3, %arg4] : memref<16x16xf32> -> !toy_npu.tile
        %1 = scf.for %arg5 = %c0 to %c16 step %c16 iter_args(%arg6 = %0) -> (!toy_npu.tile) {
          %2 = toy_npu.tile_load %arg0[%arg3, %arg5] : memref<16x16xf32> -> !toy_npu.tile
          %3 = toy_npu.tile_load %arg1[%arg5, %arg4] : memref<16x16xf32> -> !toy_npu.tile
          %4 = toy_npu.tile_matmul %2, %3, %arg6 : (!toy_npu.tile, !toy_npu.tile, !toy_npu.tile) -> !toy_npu.tile
          scf.yield %4 : !toy_npu.tile
        }
        toy_npu.tile_store %1, %arg2[%arg3, %arg4] : !toy_npu.tile, memref<16x16xf32>
      }
    }
    return
  }
}
```

The `linalg.matmul` is gone. In its place: three nested `scf.for` loops (i, j, k) that each iterate exactly once for this shape, wrapping a `tile_load`/`tile_matmul`/`tile_store` sequence. The K loop threads an accumulator through `iter_args` and `scf.yield`.

For 16×16×16 the loops iterate once so the runtime behavior is the same as an unrolled tile op, but the structure is generic — the same emitted code handles any 16-divisible shape.

### Conversion pass — tiled larger case (32×32×32)

Input file `test_32x32.mlir` has a `linalg.matmul` on 32×32 memrefs:

```mlir
func.func @big_matmul(%A: memref<32x32xf32>, %B: memref<32x32xf32>, %C: memref<32x32xf32>) {
  linalg.matmul ins(%A, %B : memref<32x32xf32>, memref<32x32xf32>) outs(%C : memref<32x32xf32>)
  return
}
```

Running `iree-opt --toynpu-lower-linalg-matmul test_32x32.mlir` produces `proof/conversion_32x32_output.mlir`:

```mlir
module {
  func.func @big_matmul(%arg0: memref<32x32xf32>, %arg1: memref<32x32xf32>, %arg2: memref<32x32xf32>) {
    %c0 = arith.constant 0 : index
    %c32 = arith.constant 32 : index
    %c16 = arith.constant 16 : index
    scf.for %arg3 = %c0 to %c32 step %c16 {
      scf.for %arg4 = %c0 to %c32 step %c16 {
        %0 = toy_npu.tile_load %arg2[%arg3, %arg4] : memref<32x32xf32> -> !toy_npu.tile
        %1 = scf.for %arg5 = %c0 to %c32 step %c16 iter_args(%arg6 = %0) -> (!toy_npu.tile) {
          %2 = toy_npu.tile_load %arg0[%arg3, %arg5] : memref<32x32xf32> -> !toy_npu.tile
          %3 = toy_npu.tile_load %arg1[%arg5, %arg4] : memref<32x32xf32> -> !toy_npu.tile
          %4 = toy_npu.tile_matmul %2, %3, %arg6 : (!toy_npu.tile, !toy_npu.tile, !toy_npu.tile) -> !toy_npu.tile
          scf.yield %4 : !toy_npu.tile
        }
        toy_npu.tile_store %1, %arg2[%arg3, %arg4] : !toy_npu.tile, memref<32x32xf32>
      }
    }
    return
  }
}
```

Now the loops iterate — i and j each iterate 2 times (0, 16), and the inner K loop iterates 2 times per (i,j). That produces 8 `tile_matmul` executions total (2×2×2), with each output C tile loaded once, accumulated across the K loop, then stored once. This is textbook tiled matmul on tile-register hardware.

The same lowering scales to any 16-divisible size — 64×64×64 produces 64 tile_matmuls (4×4×4), 128×128×128 produces 512 (8×8×8) — without code changes. The tiling logic is emitted by the pass; no external tiling pipeline is needed.

This is the shape of vendor backend lowering work: finding a high-level op in the input IR, emitting the hardware-specific loop structure, and expressing the inner computation in the accelerator dialect.

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
- `Patterns.cpp` — the `OpRewritePattern<linalg::MatmulOp>` implementation plus the pass driver, including tiling logic for arbitrary 16-divisible shapes
- `CMakeLists.txt` — build rules for the conversion library
- `Conversion_CMakeLists.txt` — parent CMake for the `Conversion/` subdirectory

### `integration/` — modifications to IREE's own source
- `init_iree_dialects.h` — modified to `#include` the ToyNPU dialect and `registry.insert<>` it alongside HAL/Flow/Stream/etc.
- `init_iree_passes.h` — modified to `#include` the LinalgToToyNPU pass header and call `registerLinalgMatmulToToyNPUPass()` alongside the other dialect pass registrations
- `Tools_CMakeLists.txt` — modified to add both `iree::compiler::Dialect::ToyNPU::IR` and `iree::compiler::Dialect::ToyNPU::Conversion::LinalgToToyNPU::LinalgToToyNPU` as link dependencies of `init_iree_passes_and_dialects`

### Test inputs
- `test_toy_npu.mlir` — smallest test (tile_matmul only, hand-written IR)
- `test_all_ops.mlir` — full load/matmul/store cycle (hand-written IR)
- `test_conversion.mlir` — 16×16×16 `linalg.matmul` input to feed the lowering pass
- `test_32x32.mlir` — 32×32×32 `linalg.matmul` input exercising the tiled lowering path

### `proof/` — verification outputs
- `dialects_registered.txt` — full output of `iree-opt --show-dialects` showing `toy_npu` in the list
- `parse_test_output.mlir` — round-trip parse output for tile_matmul alone
- `all_ops_test_output.mlir` — round-trip for the full load/matmul/store composition
- `conversion_output.mlir` — the 16×16×16 lowering output showing the tiled structure at tile-size
- `conversion_32x32_output.mlir` — the 32×32×32 lowering output showing multi-tile iteration

## Hardware model

The dialect models a hypothetical NPU with:
- 8 tile registers, each holding a 16×16 matrix of FP32
- Tile-level primitives (load, store, matmul)
- Manual scratchpad memory management
- An accumulator that lives in a tile register across a K-reduction, so C is read from and written to memory once per (i,j) output tile rather than once per inner matmul

The lowering pass emits the outer loop structure (i, j, k) directly, so no separate tiling pipeline is required. This is a simpler model than production compilers (which would use MLIR's tiling infrastructure or IREE's Codegen dialects for real hardware), but it produces the same shape of IR — nested loops with tile-register-typed accumulators inside.

## What this required

Beyond the dialect files themselves, the work touched:

1. **IREE source build from scratch** — `git submodule update --init --recursive`, cmake configure, ninja build (9642 objects, ~1 hour)
2. **TableGen setup** — three `.td` files declaring the dialect, type, and three ops
3. **MLIR header dependencies** — needed `Builders.h`, `BuiltinOps.h`, `BuiltinTypes.h`, `DialectImplementation.h`, `OpImplementation.h`, `Operation.h`, `SideEffectInterfaces.h` in the dialect header
4. **CMake library dependencies** — needed `MLIRInferTypeOpInterface`, `MLIRSideEffectInterfaces`, and `MLIRSCFDialect` beyond the obvious `MLIRIR`
5. **Dialect registration wiring** — one include line + one `registry.insert<>` entry + one CMakeLists dependency line in `Tools/`
6. **The lowering pattern** — an `OpRewritePattern<linalg::MatmulOp>` doing shape validation, emitting `scf.for` loops with tile-size stride and `iter_args` accumulators, and inserting `tile_load` / `tile_matmul` / `tile_store` at the correct nesting level
7. **Pass driver** — a `PassWrapper<...>` subclass wrapping the pattern, giving it a command-line-visible name (`--toynpu-lower-linalg-matmul`) and `runOnOperation()` using `applyPatternsGreedily`
8. **Pass registration** — added the include + call to `registerLinalgMatmulToToyNPUPass()` in `init_iree_passes.h`, added the conversion library as a link dep in `Tools/CMakeLists.txt`
9. **Rebuild cycles** — the ToyNPU library, then iree-opt (with the dialect linked in), then iree-opt again (with the conversion pass linked in), then iree-opt again (after extending the pass to handle arbitrary shapes)

Each of these had a debugging step along the way (parser errors on macro-based `addTypes<>`, missing types on incomplete includes, `PassWrapper` needing explicit `mlir::` qualification, etc.). All resolved and documented in the source.

## What's next

Natural extensions from here:

- **Handle non-16-divisible inputs** via padding or peeling. Currently the pass requires M, N, K to be exact multiples of 16. Real workloads don't; a production version would pad to the tile boundary or generate a scalar epilogue for the remainder.
- **Add `tile_zero` and `tile_relu`** for fused conv+bias+ReLU patterns. Fusion is the topic that matters most for real accelerators.
- **Add a HAL driver stub** so a `.vmfb` containing toy_npu ops could actually "execute" (print what it would do).
- **INT8 variant** for quantized inference, since real NPUs care about INT8 throughput.
- **Cost model** driving tile-size selection decisions rather than hard-coding 16.

None of these change the architectural pattern established here. They're extensions in scale, not in shape.

## Why this matters

The daily work of an NPU compiler engineer at a company building custom accelerators looks like this at higher fidelity: define a dialect modeling the hardware primitives, write conversion patterns from upstream dialects (linalg, vector) to the hardware dialect, emit the loop structure that matches the hardware's memory hierarchy, register the passes so they can be invoked from the compiler driver, iterate based on workload characterization.

Getting the small version working — 3 ops, 1 conversion pattern with tiling for arbitrary 16-divisible shapes — exercises the same code paths as the production version. The architectural understanding transfers directly; only the scope grows.

## How to reproduce

Requires: IREE source clone with all submodules initialized, cmake ≥ 3.26, clang, ninja, pyright.

1. Clone IREE and copy the `dialect/` files into `compiler/src/iree/compiler/Dialect/ToyNPU/IR/`
2. Copy the `conversion/` files into `compiler/src/iree/compiler/Dialect/ToyNPU/Conversion/LinalgToToyNPU/`. Use `Conversion_CMakeLists.txt` as the parent `Conversion/CMakeLists.txt`.
3. Apply the changes in `integration/init_iree_dialects.h` to your IREE tree's version of that file
4. Apply the changes in `integration/init_iree_passes.h` to your IREE tree's version of that file
5. Apply the changes in `integration/Tools_CMakeLists.txt` to your IREE tree's `compiler/src/iree/compiler/Tools/CMakeLists.txt`
6. Reconfigure and build: `cmake -B build -G Ninja ...` then `cmake --build build -j 1 --target iree-opt` (use `-j 1` on machines with less than 32 GB RAM to avoid clang OOM during linking)
7. Verify dialect: `./build/tools/iree-opt --show-dialects | grep toy_npu`
8. Verify pass on 16×16×16: `./build/tools/iree-opt --toynpu-lower-linalg-matmul test_conversion.mlir`
9. Verify pass on 32×32×32: `./build/tools/iree-opt --toynpu-lower-linalg-matmul test_32x32.mlir`

The final two commands should produce nested `scf.for` loops with `toy_npu` operations inside — one iteration each for 16×16×16, two iterations per dim for 32×32×32.