# Experiment 04: IREE matmul lowering vs raw C codegen

## Goal

Test whether structured IR (linalg.matmul) lets the compiler vectorize where raw C loops did not. Direct follow-up to Experiment 03.

## How to reproduce
source ~/IREE-env/bin/activate
./compile.sh

This compiles `matmul.mlir` twice — once for host CPU defaults, once with explicit AVX-512 target — and dumps all 12 compilation phases per build.

## Outcome

IREE vectorized the matmul to `vector<16xf32>` (AVX-512 zmm registers) with classic 8×16 register tiling. GCC compiling the same matmul as raw C with `-O3 -mavx512f` produced only scalar FMA. The IR structure was the multiplier, not the optimizer's cleverness. See `observations.md`.