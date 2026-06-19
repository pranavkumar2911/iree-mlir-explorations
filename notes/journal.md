# Learning Journal

A running, cross-cutting log. Experiment-specific observations live in each
experiment's `observations.md`.

## Day 1 — first compile

Set up WSL2 + Ubuntu + VS Code + Python venv + IREE. Got my first MLIR
program through the compiler and runtime end-to-end. See
`experiments/01-first-compile/` for the full details.

Things I still don't fully understand:
- The HAL abstraction — I see what it does but not why it's split exactly
  the way it is (devices, executables, command buffers, fences).
- The `flow` vs `stream` vs `hal` dialect distinction. They all seem to be
  about execution scheduling at different levels.

## Day 2 — reading + git setup

- Initialized git, pushed to GitHub at https://github.com/YourUsername/pranav-iree-notes
- Read MLIR home page and Toy tutorial chapter 1.
- Skimmed the dialect index. Looked at arm_neon and linalg specifically.

What clicked:
- The idea of dialects as namespaces of operations and types
- That progressive lowering means walking down a stack of dialects until
  you're at LLVM-IR level

What's still fuzzy:
- TableGen — the language used to define dialects. I get that it's a
  description language but haven't tried writing any.
- The exact set of optimization passes that run between dialects.

What I want to look at next:
- Compile a real ONNX model and see how the higher-level dialects appear
  in the phase dumps.