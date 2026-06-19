# Observations — Experiment 04

## Goal

Test the central claim that came out of Experiment 03: that structured IR (linalg.matmul) lets compilers do what raw C cannot. Compile the same fp32 64×64 matmul through IREE for two targets — the host CPU defaults and an explicit AVX-512 target — and see what kind of code IREE produces, compared to what GCC produced for raw C in Experiment 03.

## Setup

- Source: `matmul.mlir` — a `linalg.matmul` at the linalg dialect level
- Build 1: `--iree-llvmcpu-target-cpu=host` — uses my Tigerlake's full feature set
- Build 2: `--iree-llvmcpu-target-cpu=skylake-avx512` — explicit AVX-512 server CPU profile
- Same `--iree-opt-level=O2` in both cases
- Both produce 12-phase compilation dumps

## What I found

### IREE vectorized where GCC didn't

In Experiment 03 (GCC compiling raw C with -O3 -mavx512f), the inner loop emitted:
vmovss  (%rdx), %xmm2
vfmadd231ss -256(%rax), %xmm2, %xmm0

Scalar `xmm` register, scalar FMA, one float per iteration. No SIMD packing happened.

In Experiment 04 (IREE compiling the same matmul expressed as `linalg.matmul`), Phase 10 (executable-targets, just before LLVM codegen) contains:

vector<16xf32>
!llvm.array<8 x vector<16xf32>>
%19 = llvm.mlir.constant(dense<0.000000e+00> : vector<8x16xf32>)

`vector<16xf32>` is exactly an AVX-512 zmm register (16 floats × 32 bits = 512 bits). The 8×16 accumulator pattern is a classic register-tiled matmul: the inner loop builds up an 8×16 result tile in vector registers, doing FMA against pre-loaded chunks of A. This is the form a compiler engineer would hand-write for AVX-512.

### Why the difference?

GCC saw three nested for loops. To vectorize, it would have had to:
1. Recognize the loop pattern as matmul
2. Decide that vectorization was profitable given the column-stride access on B
3. Generate the tiled vector code

GCC chose not to do this for naive ijk matmul because the column-stride access defeats simple vectorization heuristics.

IREE saw `linalg.matmul ins(%A, %B) outs(%init)`. It knew immediately:
- This is matmul
- Apply the tiled matmul lowering pattern
- Choose tile sizes based on the target vector width (16 for AVX-512)
- Emit vector<16xf32> ops directly

**The information in the IR made the difference, not the optimizer's cleverness.**

### Comparison between the two IREE builds

The host build (Tigerlake, full features) and the explicit AVX-512 build produced essentially identical IR at Phase 10 — both used `vector<16xf32>` and the 8×16 tile pattern. The host build's CPU feature string includes `+avx512f`, so IREE selected AVX-512 codegen for both cases.

Mildly interesting: the AVX-512 binary is 1KB smaller than the host build (11K vs 12K). The host target descriptor carries more feature flags (including disabled ones marked with `-`) which adds metadata overhead.

## What this tells me about the role

This experiment is the **practical answer** to "why use IREE/MLIR for NPU compilation rather than relying on LLVM's auto-vectorization":

1. **Structure is the multiplier.** Raw C loops require the compiler to reverse-engineer the operation, which often fails. Structured ML IR (`linalg.matmul`, `linalg.conv_2d`, etc.) gives the compiler the operation as a first-class entity. Lowering patterns can then map directly to hardware primitives.

2. **The same argument scales to NPUs.** Just as IREE knew to use `vector<16xf32>` for AVX-512, a hypothetical MIPS NPU backend could lower `linalg.matmul` to tile-MAC instructions or systolic array invocations. The high-level IR is hardware-agnostic; the lowering patterns are hardware-specific.

3. **Auto-vectorization from C → hardware-specific instructions is a dead-end for ML.** The structural mismatch is too large. Even mature compilers like GCC can't always recover the structure. ML compilers like IREE work by *not throwing the structure away in the first place*.

## Open questions

- What controls IREE's choice of tile size? Cost model? Configured per target?
- For a hypothetical MIPS NPU backend, would the lowering target `linalg.matmul` directly to NPU intrinsics, or go through `vector` dialect first?
- How does this picture change when the workload is dynamic-shape (unknown matmul dimensions at compile time)?

## Files

- `matmul.mlir` — the source
- `compile.sh` — reproducible build for both targets
- `dumps_cpu/` and `dumps_avx512/` — 12 phase MLIR dumps each
- Two `.vmfb` binaries (gitignored — regeneratable)