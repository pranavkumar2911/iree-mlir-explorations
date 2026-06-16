# MIPS-IREE Exploration

Personal study notes and small experiments while learning IREE and MLIR
for ML accelerator compilation. Started June 2026 while preparing for
work on the MIPS S8200 NPU compilation stack.

## Layout

- **`experiments/`** — discrete, reproducible experiments. Each has its
  own README explaining the goal, files, and how to reproduce.
- **`notes/`** — cross-cutting notes and learning journal.

## What I've worked through so far

**Experiment 01 — first IREE compile + run.** Got the full pipeline
working end-to-end on my laptop: hand-authored a 5-line MLIR program,
compiled it for the local CPU backend, ran it from Python, and
inspected all 12 intermediate compilation phases. The final IR
contains a 3.5KB embedded x86-64 ELF binary along with the VM
orchestration code that loads and dispatches it. See
[`experiments/01-first-compile/`](experiments/01-first-compile/).

More to come.

## Background

Recent MS in Computer Engineering from ASU. Prior work relevant to
this stack:

- hls4ml + QAT CNN accelerator on Xilinx PYNQ-Z2 — full HW/SW
  co-design flow from QKeras model down to FPGA bitstream
- TFLite Micro speech recognition on nRF52840 Cortex-M4 with
  CMSIS-NN
- GSelect branch predictor in gem5 with XOR-folded global history
