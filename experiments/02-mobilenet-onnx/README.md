# Experiment 02 — MobileNetV2 ONNX through IREE

## Goal

Move from a 5-line toy example (experiment 01) to a real, production-grade neural network. Verify the IREE compilation flow works on a real CNN, and observe what kernel-fusion decisions the compiler makes.

## Hardware / environment

- Intel i7-1165G7 (Tigerlake), 4C/8T, AVX-512 capable
- WSL2 Ubuntu 22.04 on Windows 11
- Python venv (~/IREE-env) with iree-base-compiler, iree-base-runtime

## Files

| File | Purpose |
|---|---|
| `compile.sh` | Reproducible build script — downloads model and compiles it |
| `observations.md` | What I noticed comparing this to experiment 01 |

Large build artifacts are gitignored because they can be regenerated:
- `mobilenetv2-10.onnx` (14 MB source model)
- `mobilenetv2.mlir` (27 MB imported MLIR)
- `mobilenetv2.vmfb` (14 MB compiled binary)
- `dumps/` (328 MB of intermediate phase MLIR)

## How to reproduce
source ~/IREE-env/bin/activate
./compile.sh

The script downloads MobileNetV2 from the ONNX model zoo, imports it to MLIR, and compiles for the local CPU with all phase dumps written to `dumps/`.

## Outcome

Compiled successfully. 36 dispatches in the flow dialect from roughly 150-180 raw ONNX ops — about a 5x reduction in kernel count from fusion. See `observations.md` for details on what got fused.