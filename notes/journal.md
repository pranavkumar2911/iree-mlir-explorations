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
