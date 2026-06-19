#!/usr/bin/env bash
# Compiles matmul.c with various ISA targets and saves assembly for inspection.
#
# x86 targets: scalar, AVX2, AVX-512, AMX attempt
# ARM target: SVE (cross-compiled, not run)

set -euo pipefail

SRC=src/matmul.c
OUT=assembly

mkdir -p "$OUT"

echo "=== Compiling for x86-64 ==="

echo "[1/4] Scalar baseline (SSE2 scalar, no AVX)..."
gcc -O3 -S -fverbose-asm \
    -msse2 -mno-avx -mno-avx2 -mno-avx512f \
    "$SRC" -o "$OUT/matmul_scalar.s"

echo "[2/4] AVX2..."
gcc -O3 -S -fverbose-asm \
    -mavx2 -mfma \
    "$SRC" -o "$OUT/matmul_avx2.s"

echo "[3/4] AVX-512..."
gcc -O3 -S -fverbose-asm \
    -mavx512f -mavx512dq \
    "$SRC" -o "$OUT/matmul_avx512.s"

echo "[4/4] AMX attempt..."
gcc -O3 -S -fverbose-asm \
    -mavx512f -mamx-tile -mamx-int8 -mamx-bf16 \
    "$SRC" -o "$OUT/matmul_amx_attempt.s"

echo ""
echo "=== Cross-compiling for ARM64 with SVE ==="

echo "[5/5] ARM SVE..."
aarch64-linux-gnu-gcc -O3 -S -fverbose-asm \
    -march=armv8.2-a+sve \
    "$SRC" -o "$OUT/matmul_arm_sve.s"

echo ""
echo "=== Done ==="
ls -lh "$OUT/"
echo ""
echo "Quick line counts:"
wc -l "$OUT/"*.s