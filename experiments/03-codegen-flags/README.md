# Experiment 03: Codegen flags across x86 ISAs + ARM SVE

## Goal

Take a naive matrix multiplication in C and compile it for five targets with SSE2 scalar (baseline), AVX2, AVX-512, an AMX attempt, and ARM SVE, to see what auto-vectorization the compiler does for each. Directly addresses Pekka's question in our call about whether I could try compiling something to use AVX/AMX-style hardware via compiler flags.

## Hardware / environment

- Intel i7-1165G7 (Tigerlake): AVX2 + AVX-512 supported, no AMX hardware
- Cross-compile to AArch64 with SVE via `gcc-aarch64-linux-gnu`
- All builds are assembly-only (`-S`); ARM binary not run on this machine

## Files

| File | Purpose |
|---|---|
| `src/matmul.c` | Naive ijk matmul, N=64, fp32 |
| `compile.sh` | Reproducible build script — 5 targets |
| `assembly/*.s` | Generated assembly outputs for each target |
| `observations.md` | What I noticed |

## How to reproduce
./compile.sh

Requires `gcc` and `gcc-aarch64-linux-gnu` (install via `sudo apt install gcc gcc-aarch64-linux-gnu`).

## Outcome

Five distinct assembly outputs produced. Key finding: naive matmul does not auto-vectorize on x86 due to column-stride access on B, even with AVX-512. ARM SVE is the only target that vectorized — it has a gather load instruction that AVX-512 doesn't reach for here. See `observations.md`.