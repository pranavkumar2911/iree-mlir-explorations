#!/usr/bin/env bash
# Compile the linalg matmul twice: once for host CPU (whatever Tigerlake supports),
# once with explicit AVX-512 features turned on. Dump all phases for inspection.

set -euo pipefail

echo "=== Build 1: host CPU defaults ==="
iree-compile matmul.mlir \
    --iree-hal-target-device=local \
    --iree-hal-local-target-device-backends=llvm-cpu \
    --iree-llvmcpu-target-cpu=host \
    --iree-opt-level=O2 \
    --dump-compilation-phases-to=dumps_cpu \
    -o matmul_cpu.vmfb

echo ""
echo "=== Build 2: AVX-512 explicit ==="
iree-compile matmul.mlir \
    --iree-hal-target-device=local \
    --iree-hal-local-target-device-backends=llvm-cpu \
    --iree-llvmcpu-target-triple=x86_64-unknown-linux-gnu \
    --iree-llvmcpu-target-cpu=skylake-avx512 \
    --iree-opt-level=O2 \
    --dump-compilation-phases-to=dumps_avx512 \
    -o matmul_avx512.vmfb

echo ""
echo "=== Sizes ==="
ls -lh matmul_cpu.vmfb matmul_avx512.vmfb
echo ""
echo "=== Phase counts ==="
ls dumps_cpu/ | wc -l
ls dumps_avx512/ | wc -l