#!/usr/bin/env bash
# Downloads MobileNetV2 ONNX, imports to MLIR, compiles to IREE bytecode.
# Also dumps every compilation phase into dumps/ for inspection.

set -euo pipefail

# Step 1: download model if not present
if [ ! -f mobilenetv2-10.onnx ]; then
    echo "Downloading MobileNetV2..."
    wget https://github.com/onnx/models/raw/refs/heads/main/validated/vision/classification/mobilenet/model/mobilenetv2-10.onnx
fi

# Step 2: ONNX -> MLIR
iree-import-onnx mobilenetv2-10.onnx --opset-version 17 -o mobilenetv2.mlir

# Step 3: MLIR -> vmfb
iree-compile mobilenetv2.mlir \
    --iree-hal-target-device=local \
    --iree-hal-local-target-device-backends=llvm-cpu \
    --iree-llvmcpu-target-cpu=host \
    --iree-opt-level=O2 \
    --dump-compilation-phases-to=dumps \
    -o mobilenetv2.vmfb

echo "Built mobilenetv2.vmfb:"
ls -lh mobilenetv2.vmfb
echo "Phase dumps:"
ls dumps/