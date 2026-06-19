# Observations: Experiment 03

## Goal recap

Pekka asked in our call whether I could try compiling something to use AVX/AMX-style hardware via compiler flags and see what changes. This experiment compiles a naive square matmul (N=64, FP32, ijk loop order) for five targets: SSE2 scalar baseline, AVX2, AVX-512, an AMX attempt, and ARM SVE (cross-compiled).

## Setup

- Source: `src/matmul.c` — naive triple-loop matmul, no intrinsics, no pragmas
- Build: `compile.sh` — `gcc -O3 -S` with various `-march`/`-m*` flags
- Assembly inspection only; ARM binary not executed (no SVE hardware on hand)

## Results

### Scalar baseline (SSE2)

Inner loop:
movss   (%rdx), %xmm0       # load A[i][k]
mulss   (%rax), %xmm0       # multiply by B[k][j]
addss   %xmm0, %xmm1        # add to sum

Three instructions per arithmetic step. One float at a time. This is the modern baseline — what plain `gcc -O3` without AVX would produce on any x86 chip.

### AVX2 and AVX-512: FMA wins on instruction count, no SIMD packing

Both AVX2 and AVX-512 produced essentially the same inner loop:
vmovss  (%rdx), %xmm2
vfmadd231ss -256(%rax), %xmm2, %xmm0

The fused multiply-add (`vfmadd231ss`) does load+multiply+accumulate in one instruction. This is a real win — 2 ops vs 3 ops per iteration — but **no packed vectorization happened**. The compiler used scalar (`ss`) ops on `xmm` registers, not packed (`ps`) ops on `ymm` or `zmm`.

**Why:** the inner loop accesses `B[k][j]` with `k` varying — a column traversal. With N=64 (256-byte rows), each successive `B[k][j]` load is 256 bytes apart. SIMD loads want 8-16 contiguous floats; column-strided access defeats them. GCC tried and concluded packed vectorization wasn't profitable.

This is a real-world lesson about naive matmul: **the textbook ijk ordering doesn't auto-vectorize.** Getting real SIMD use requires loop transformations (tile + interchange), data layout changes (transpose B), or compiler infrastructure that understands matmul as a known pattern.

### AMX attempt: tiles not emitted

Inner loop: identical to AVX2/AVX-512.
The `-mamx-tile -mamx-int8 -mamx-bf16` flags **enable** AMX (let GCC use it if it wants) but don't make GCC auto-generate tile instructions from plain C. To use AMX you need:
- Intrinsics (`_tile_loadd`, `_tile_dpbssd`, etc.)
- A library that knows about AMX
- A compiler stack that lowers matmul patterns to AMX — exactly what an MLIR-based stack like IREE provides via dialect lowering

Plain C → AMX is a missing piece because plain C is too unstructured for the compiler to recognize "this is a matmul, use the tile unit."

### ARM SVE: actual vectorization, via gather load

This is the only target that genuinely vectorized:
ld1w    z2.s, p0/z, [x3, x0, lsl 2]    # vector load from A (contiguous)
ld1w    z0.s, p0/z, [x1, z3.s, uxtw]   # GATHER load from B (strided)
fmul    z0.s, z0.s, z2.s               # vector multiply
fadda   s1, p0, s1, z0.s               # accumulating reduction
whilelo p0.s, w0, w2                   # VLA loop predicate

Key things:
- `z0`, `z2`, `z3` are SVE vector registers. Width is implementation-defined (128 to 2048 bits) — same binary runs efficiently at any width
- The **gather load** `ld1w z0.s, p0/z, [x1, z3.s, uxtw]` uses a vector of indices to gather strided memory. This is what unlocked vectorization where AVX-512 didn't reach for it
- `whilelo` is the VLA loop predicate — the loop condition without knowing vector width at compile time

ARM SVE has a hardware gather instruction; AVX-512 also has gather (`vgatherdps`), but GCC's cost model didn't choose it for this case. Possibly because AVX-512 gather is microcode-heavy on Intel hardware; SVE's is more uniformly fast.

The VLA structure is independently interesting: **this is the same design philosophy as RISC-V Vector (RVV)** — vector-length-agnostic, predicated, gather-capable. Studying SVE codegen builds intuition for RVV directly.

## What this means for the role

Three takeaways for compiler work on the MIPS NPU stack:

1. **Plain C → accelerator codegen via auto-vectorization is brittle.** AVX-512 didn't vectorize naive matmul; AMX won't be reached at all from C. Real ML compilation can't rely on this path.

2. **The lowering-pattern approach (MLIR linalg → vendor dialect → vendor instructions) bypasses the problem.** Instead of hoping the C compiler recognizes matmul, you express matmul *as* matmul at the IR level and lower it directly to vendor instructions. This is structurally why an MLIR-based stack is the right tool for hardware like the S8200 — the compiler sees the high-level operation, not just an inscrutable triple loop.

3. **SVE-style VLA is RISC-V-relevant.** RVV uses the same model: vector-length-agnostic, predicate-driven, gather-capable. The matrix extension MIPS is contributing to RISC-V will likely follow SME's pattern of tile registers + outer-product instructions. The mental model from SVE transfers.

## Open questions

- For an NPU with fixed-function blocks, what does the "auto-vectorization" analog look like? Pattern matching on linalg ops, or higher-level matching on whole subgraphs?
- Does IREE's CPU codegen currently target AMX or SME? If so, what does the conversion pattern look like at the dialect level — pre-fused tile primitives, or building up from vector dialect ops?
- Why did GCC's AVX-512 not use gather here while SVE did? Cost model difference, or the SVE backend having more aggressive transformations?

## Files

- `src/matmul.c` — the source
- `compile.sh` — reproducible build
- `assembly/*.s` — all five generated assembly files