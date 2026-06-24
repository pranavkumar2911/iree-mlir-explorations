#!/usr/bin/env bash
# Compile MobileNetV2 with various flag/target combinations.

set -euo pipefail

MODEL_DIR="../02-mobilenet-onnx"
SRC="$MODEL_DIR/mobilenetv2.mlir"

if [ ! -f "$SRC" ]; then
    echo "ERROR: $SRC not found. Re-run experiment 02's compile.sh first."
    exit 1
fi

echo "[1/4] O0 — minimal optimization"
iree-compile "$SRC" \
    --iree-hal-target-device=local \
    --iree-hal-local-target-device-backends=llvm-cpu \
    --iree-llvmcpu-target-cpu=host \
    --iree-opt-level=O0 \
    -o mobilenetv2_O0.vmfb

echo "[2/4] O3 — aggressive optimization"
iree-compile "$SRC" \
    --iree-hal-target-device=local \
    --iree-hal-local-target-device-backends=llvm-cpu \
    --iree-llvmcpu-target-cpu=host \
    --iree-opt-level=O3 \
    -o mobilenetv2_O3.vmfb

echo "[3/4] O2 with explicit AVX-512 (skylake-avx512)"
iree-compile "$SRC" \
    --iree-hal-target-device=local \
    --iree-hal-local-target-device-backends=llvm-cpu \
    --iree-llvmcpu-target-triple=x86_64-unknown-linux-gnu \
    --iree-llvmcpu-target-cpu=skylake-avx512 \
    --iree-opt-level=O2 \
    -o mobilenetv2_avx512.vmfb

echo "[4/4] O2 with AVX2-only (haswell)"
iree-compile "$SRC" \
    --iree-hal-target-device=local \
    --iree-hal-local-target-device-backends=llvm-cpu \
    --iree-llvmcpu-target-triple=x86_64-unknown-linux-gnu \
    --iree-llvmcpu-target-cpu=haswell \
    --iree-opt-level=O2 \
    -o mobilenetv2_avx2.vmfb

echo ""
echo "=== Sizes ==="
ls -lh *.vmfb