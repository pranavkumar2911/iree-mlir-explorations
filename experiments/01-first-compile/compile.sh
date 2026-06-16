#!/usr/bin/env bash
# Compiles mips_simple_abs.mlir for the local CPU and produces .vmfb
# Also dumps every compilation phase into dumps/ for inspection.

set -euo pipefail

iree-compile mips_simple_abs.mlir \
    --iree-hal-target-device=local \
    --iree-hal-local-target-device-backends=llvm-cpu \
    --iree-llvmcpu-target-cpu=host \
    --dump-compilation-phases-to=dumps \
    -o mips_simple_abs.vmfb

echo "Built mips_simple_abs.vmfb"
echo "Phase dumps:"
ls dumps/
