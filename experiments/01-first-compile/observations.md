# Observations — Experiment 01

## What I observed comparing phase 1 vs phase 12

Phase 1 (`mips_simple_abs.1.input.mlir`): 5 lines. `math.absf` on a
`tensor<f32>`. Pure intent.

Phase 12 (`mips_simple_abs.12.vm.mlir`): ~140 lines of IR plus a 3.5KB
embedded x86-64 ELF binary. The ELF starts with `0x7F454C46` magic bytes
and contains native machine code for my CPU. IREE introspected my hardware
and recorded the feature set: `+avx512f,+avx2,+bmi2,...` — confirming this
was compiled for my Tigerlake i7-1165G7 specifically.

The VM module wraps the binary with:
- Device discovery (`__init` enumerates HAL devices)
- Executable loading (`hal.executable.create` with the ELF blob)
- Command buffer recording (memoized, built once at module init)
- The user-facing `@abs` function that validates inputs, allocates outputs,
  submits the command buffer, and awaits a fence

So my 3-line MLIR became a full self-contained module: native machine code
+ orchestration logic + device abstraction + ABI handling.

## What this tells me about how MIPS would plug into IREE

For MIPS specifically, the picture would be the same shape — except the
embedded blob would be S8200 binary code, the HAL backend would be a MIPS
driver, and there'd be a `mips_npu` dialect feeding into the lowering.
Everything else (VM, command buffers, fences, ABI) inherits from upstream.

## Open questions

- Where exactly in the 12-phase pipeline would a custom backend hook in?
  My guess: phase 8 (executable-sources) is where target-specific codegen
  begins, so a MIPS backend would register itself there.
- How does IREE choose between multiple available backends at runtime?
  Looks like the `__init` function probes available devices and picks the
  first match.
- For an NPU like the S8200, what does the equivalent of "ELF binary" look
  like? Is it a flat binary, a custom format, something else?
