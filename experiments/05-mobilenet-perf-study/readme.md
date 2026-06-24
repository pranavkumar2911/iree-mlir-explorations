# Experiment 05 — MobileNetV2 performance study

## Goal

Move from "I compiled it" (Experiment 02) to "I understand where the time goes." Measure end-to-end inference latency for MobileNetV2 across compile-flag and target-architecture variants, calibrate the noise floor, and draw conclusions about what kind of compiler decisions actually move the needle.

## What I built

A reproducible benchmark harness:
- `make_input.py` — generates a deterministic input tensor (seed=42)
- `compile.sh` — compiles MobileNetV2 with 4 different flag combinations + uses Experiment 02's baseline
- `benchmark.sh` — runs `iree-benchmark-module` across all variants
- `summarize.py` — prints a comparison table
- `analyze.py` — generates a chart

## Headline finding

**Compiling for AVX-512 vs AVX2 is 4.6× faster on this workload.** Median 46.6 ms vs 219.3 ms. The gap is far outside the noise floor (~5 ms). The wider SIMD + larger register file + per-target tuning compound.

**Optimization level (O0/O2/O3) is within noise on this workload.** Once the right SIMD codegen is selected, additional LLVM optimization tweaks are not the bottleneck.

See `observations.md` for full analysis including noise calibration, hypotheses for further investigation, and what these findings imply for NPU compiler work.

## Reproducing
source ~/IREE-env/bin/activate
python make_input.py
./compile.sh
./benchmark.sh
python analyze.py

Each step takes 1-2 minutes. The full benchmark run (5 variants × 10 reps × 2 sec) takes ~3 minutes.

## Honest caveats

- WSL2 + consumer laptop = ~10% CV noise floor. Inter-variant differences below 5 ms cannot be claimed as real.
- AVX-512 vs AVX2 comparison bundles SIMD width, register count, and per-target tuning. It is NOT a clean isolation of "AVX-512 instructions in isolation."
- Single-threaded; no Tracy-level per-dispatch timing. Both are noted as next-step investigations.