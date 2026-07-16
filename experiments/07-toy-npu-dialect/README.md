# Experiment 07: Working toy_npu dialect in IREE

## Goal

Move from "I sketched a dialect design" (Experiment 06) to "I built one." Fork IREE, add a working `ToyNPU` dialect with a custom type and operation in TableGen, wire it into IREE's build and dialect registration, and verify that `iree-opt` parses, verifies, and prints code using the new dialect end-to-end.

## What was built

A fully functional custom MLIR dialect integrated into IREE:

- **`!toy_npu.tile`** — custom type representing a hardware tile register (16×16 FP32)
- **`toy_npu.tile_matmul`** — operation computing `c_out = a * b + c_in` on tiles
- **Registration** in IREE's dialect init so `iree-opt --show-dialects` includes `toy_npu`
- **CMake integration** so the dialect compiles into IREE's static library set and links into `iree-opt`

Result: `iree-opt` can parse, verify, and print MLIR programs using `toy_npu.tile_matmul` operations.

## Proof

**Dialect registered in iree-opt** (`proof/dialects_registered.txt`):
...tosa,toy_npu,transform,...
`toy_npu` sits in the alphabetical dialect list between `tosa` and `transform`, alongside every IREE-provided dialect (`flow`, `hal`, `stream`, `iree_gpu`, `iree_codegen`, etc.).

**End-to-end parse test** (`proof/parse_test_output.mlir`):

Input file `test_toy_npu.mlir`:
```mlir
func.func @test(%a: !toy_npu.tile, %b: !toy_npu.tile, %c: !toy_npu.tile) -> !toy_npu.tile {
  %result = toy_npu.tile_matmul %a, %b, %c : (!toy_npu.tile, !toy_npu.tile, !toy_npu.tile) -> !toy_npu.tile
  return %result : !toy_npu.tile
}
```

`iree-opt` output (parsed, verified, re-printed):
```mlir
module {
  func.func @test(%arg0: !toy_npu.tile, %arg1: !toy_npu.tile, %arg2: !toy_npu.tile) -> !toy_npu.tile {
    %0 = toy_npu.tile_matmul %arg0, %arg1, %arg2 : (!toy_npu.tile, !toy_npu.tile, !toy_npu.tile) -> !toy_npu.tile
    return %0 : !toy_npu.tile
  }
}
```

This means the parser accepts the custom syntax, the verifier accepts the operand types, and the printer emits the dialect back out cleanly. Standard MLIR round-trip.

## Files

### `dialect/` — the dialect implementation
- `ToyNPUBase.td` — dialect declaration (name, C++ namespace)
- `ToyNPUTypes.td` — the `!toy_npu.tile` type in TableGen
- `ToyNPUOps.td` — the `toy_npu.tile_matmul` op in TableGen
- `ToyNPUDialect.h` — C++ header including MLIR infrastructure + generated code
- `ToyNPUDialect.cpp` — C++ implementation registering the type and op
- `CMakeLists.txt` — build rules (TableGen invocations + iree_cc_library)

### `integration/` — modifications to IREE's own source
- `init_iree_dialects.h` — modified to `#include` the ToyNPU dialect and `registry.insert<>` it alongside HAL/Flow/Stream/etc.
- `Tools_CMakeLists.txt` — modified to add `iree::compiler::Dialect::ToyNPU::IR` as a link dependency of `init_iree_passes_and_dialects`

### `proof/` — verification outputs
- `dialects_registered.txt` — full output of `iree-opt --show-dialects` showing `toy_npu` in the list
- `parse_test_output.mlir` — round-trip parse output confirming the dialect works end-to-end

## Hardware model

The dialect models a hypothetical NPU with:
- 8 tile registers, each holding a 16×16 matrix of FP32
- Tile-level primitives (load, store, matmul)
- Manual scratchpad memory management

Only `tile_matmul` is implemented in this first iteration. `tile_load` and `tile_store` are the natural next additions.

## What this required

Beyond the dialect files themselves, the work touched:

1. **IREE source build from scratch** — `git submodule update --init --recursive`, cmake configure, ninja build (9642 objects, ~1 hour)
2. **TableGen setup** — three `.td` files declaring the dialect, type, and op
3. **MLIR header dependencies** — needed `Builders.h`, `BuiltinOps.h`, `BuiltinTypes.h`, `DialectImplementation.h`, `OpImplementation.h`, `Operation.h`, `SideEffectInterfaces.h` in the dialect header
4. **CMake library dependencies** — needed `MLIRInferTypeOpInterface` and `MLIRSideEffectInterfaces` beyond the obvious `MLIRIR`
5. **Registration wiring** — one include line + one `registry.insert<>` entry + one CMakeLists dependency line, all in `Tools/`
6. **iree-opt relink** — after registration changes

Each of these had a debugging step (parser errors on macro-based `addTypes<>`, missing types on incomplete includes, etc.). All resolved and documented in the source above.

## What's next

The natural next step: a conversion pattern from `linalg.matmul` to `toy_npu.tile_matmul` for the case where all three dims are exactly 16. That would demonstrate the full "upstream MLIR → custom dialect" lowering that a real vendor backend performs.

Beyond that:
- Add `tile_load` and `tile_store` ops
- Extend conversion pattern to handle non-16 dimensions via tiling
- Add a HAL driver stub for runtime execution
- INT8 quantized variant (`tile_matmul_int8`)

## Why this matters

The pattern in this experiment — define a dialect, register it in a compiler's infrastructure, verify end-to-end parse/verify/print — is the foundation of vendor backend work for any accelerator built on top of IREE. Every custom accelerator IREE backend starts with this shape.

Building this at hobby scale (one type, one op) exercises the same code paths as building it at production scale (dozens of ops, cost models, HAL drivers). Getting the small version working first is how the large version becomes tractable.

## How to reproduce

Requires: IREE source clone with all submodules initialized, cmake ≥ 3.26, clang, ninja, pyright.

1. Clone IREE and copy the `dialect/` files into `compiler/src/iree/compiler/Dialect/ToyNPU/IR/`
2. Apply the changes in `integration/init_iree_dialects.h` to your IREE tree's version of that file
3. Apply the changes in `integration/Tools_CMakeLists.txt` to your IREE tree's `compiler/src/iree/compiler/Tools/CMakeLists.txt`
4. Reconfigure and build: `cmake -B build -G Ninja ...` then `cmake --build build -j 2 --target iree-opt`
5. Verify: `./build/tools/iree-opt --show-dialects | grep toy_npu`
6. Test parse: `./build/tools/iree-opt test_toy_npu.mlir`