# Experiment 01 — First IREE compile + run

## Goal
Verify the full IREE pipeline works end-to-end on this machine:
- Hand-author a trivial MLIR program
- Compile it for the local CPU backend
- Run the compiled module from Python
- Inspect the intermediate compilation phases to see what IREE actually did

## Hardware / environment
- Intel i7-1165G7 (Tigerlake), 4C/8T, AVX-512 capable
- WSL2 Ubuntu 22.04 on Windows 11
- Python venv (~/IREE-env) with iree-base-compiler, iree-base-runtime

## Files
File --> Purpose
`mips_simple_abs.mlir` --> Source — a 5-line MLIR function computing absolute value 
`compile.sh` --> Reproducible build script 
`mips_simple_abs.vmfb` --> Compiled artifact (VM FlatBuffer with embedded x86-64 ELF) 
`run.py` --> Python runner that loads the .vmfb and invokes abs(-3.5) 
`dumps/` --> 12 intermediate MLIR snapshots from each compilation phase 
`observations.md` --> What I noticed 

## How to reproduce
```bash
source ~/IREE-env/bin/activate
./compile.sh
python run.py
# Expected output: abs(-3.5) = 3.5
```

## Outcome
Pipeline works. `abs(-3.5)` returns `3.5` as expected. See `observations.md`
for what I learned from inspecting the compilation phases.