#!/usr/bin/env bash
# Benchmarks for MobileNetV2 across compile-flag variants.

set -euo pipefail

RESULTS_DIR="results"
mkdir -p "$RESULTS_DIR"

# Discover function name from the original MLIR
# (you'll need to confirm this matches what's in mobilenetv2.mlir)
FUNCTION_NAME="torch-jit-export"

run_benchmark() {
    local name=$1
    local module=$2
    echo "=== $name ==="
    if [ ! -f "$module" ]; then
        echo "  SKIP — $module does not exist"
        echo ""
        return
    fi
    iree-benchmark-module \
        --module="$module" \
        --function="$FUNCTION_NAME" \
        --input=1x3x224x224xf32=@input.bin \
        --benchmark_min_time=2.0s \
        --benchmark_repetitions=10 \
        --benchmark_format=json \
        > "$RESULTS_DIR/${name}.json" 2>&1 || true
    echo "  wrote $RESULTS_DIR/${name}.json"
    echo ""
}

run_benchmark "baseline_O2"  "../02-mobilenet-onnx/mobilenetv2.vmfb"
run_benchmark "O0"           "mobilenetv2_O0.vmfb"
run_benchmark "O3"           "mobilenetv2_O3.vmfb"
run_benchmark "avx512"       "mobilenetv2_avx512.vmfb"
run_benchmark "avx2"         "mobilenetv2_avx2.vmfb"

# Summary — parse the JSON files in a separate Python script
echo "=== Summary ==="
python summarize.py