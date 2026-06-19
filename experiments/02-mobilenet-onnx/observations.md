# Observations — Experiment 02

## Scale comparison vs Experiment 01

| | Experiment 01 (simple_abs) | Experiment 02 (MobileNetV2) |
|---|---|---|
| Input ops | 1 | hundreds (full CNN) |
| .vmfb output | ~5 KB | 14 MB |
| flow.executables | 1 | 36 |
| Compile time | <1 sec | ~30-60 sec |

Same 12-phase pipeline, dramatically different scale. The compiler infrastructure I wrote a 5-line program through is the same one that took an entire production CNN end-to-end.

## Reading flow.mlir — what IREE actually decided

The flow dialect is where IREE chops the model into separate dispatches, each of which will become its own compiled kernel later. MobileNetV2 has roughly 150-180 ops in the raw ONNX graph; IREE fused this down to 36 dispatches. That's a ~5x reduction in kernel count.

### Fusion patterns

Every conv dispatch fuses three operations into a single kernel:

1. The convolution itself (as `linalg.generic` with reduction loops)
2. Bias addition
3. ReLU6 activation (clamp to [0, 6])

In dispatch 9, IREE goes further and fuses the residual connection — the output is added to a tensor from a previous block all within the same dispatch. This is the inverted-residual pattern that defines MobileNetV2.

Without fusion: 3-4 separate kernels per block, each round-tripping activations through DRAM. With fusion: one kernel sweeps through the data once. For a real CNN at 30 fps, this is the difference between roughly 4,500 kernel launches per second and roughly 1,080 — and a much smaller memory bandwidth footprint.

### Convolutions lowered to linalg.generic

Notable: the conv2d ops are not represented as a dedicated "conv" operation — they're represented as `linalg.generic` with affine indexing maps and an inner mul-add body. The `affine_map` declarations at the top of the file (`#map`, `#map1`, ..., `#map21`) are the dimension transformations that specialize a generic loop nest into a specific shape pattern (strided conv, depthwise, matmul, etc.).

Why this matters: downstream passes don't need special cases for conv vs matmul vs depthwise — they share the same lowering machinery driven by the indexing maps. For a hardware vendor backend, this is significant: teaching IREE about a new accelerator becomes "lower linalg.generic to my hardware," not "implement separate paths for every ML op."

### Hardware-specific target attribute

The file starts with a massive executable_target attribute listing the exact CPU features for my Tigerlake i7: `+avx512f`, `+avx2`, `+bmi2`, `-amx-tile`, etc. This is what the lowering passes key off of when generating code. The mechanism is generic — the same attribute structure would carry NPU capability info for a MIPS target.

## What this tells me about MIPS work

The IREE compiler stack appears well-designed for the kind of vendor extension Pekka described:

- Vendor adds a dialect modeling their NPU's operations
- Vendor writes lowering patterns from `linalg.generic` (and similar) into their dialect
- Vendor configures the target descriptor with NPU capability info
- They inherit fusion, the host/device split, the runtime, ABI, command buffer model — all the upstream infrastructure

The work isn't building a compiler from scratch — it's plugging into mature compiler infrastructure at the right points.

## Open questions

- Where in the 12-phase pipeline does fusion actually happen? Phase 5 (dispatch-creation) seems to be where the boundaries are decided, but the actual fusion patterns might be earlier or later.
- How does IREE choose what to fuse? Is it a heuristic ("fuse if consumer is element-wise"), a cost model, or pattern-matched rules?
- For an NPU with fixed-function units, would IREE still want to fuse this aggressively, or would the NPU prefer to see separate ops it can map to dedicated hardware blocks? My intuition says the latter — if there's a dedicated conv engine, you want the compiler to NOT fuse the conv with following ops so the engine sees a clean conv to accelerate. But I don't know for sure.