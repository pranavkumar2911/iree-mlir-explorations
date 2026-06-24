"""Generate a deterministic input tensor for MobileNetV2 benchmarking."""
import numpy as np
# MobileNetV2 expects 1x3x224x224 fp32 normalized to ImageNet statistics
rng = np.random.default_rng(seed=42)
data = rng.standard_normal((1, 3, 224, 224)).astype(np.float32)
# Save in IREE's expected format — raw fp32 bytes
data.tofile("input.bin")
print(f"Wrote input.bin: {data.size * 4} bytes")
print(f"Shape: {data.shape}, dtype: {data.dtype}")
print(f"Mean: {data.mean():.4f}, std: {data.std():.4f}")