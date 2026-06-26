# Observations: Experiment 06

## What I did

Read IREE's actual vendor backend code (CUDA, Local, and the TargetBackend contract) to understand how vendor extensions plug into IREE. Then sketched what a hypothetical NPU backend (`toy_npu`) would look like — its plugin file, device class, dialect, conversion patterns, and HAL driver.

This is a design study, not a working implementation. Building a real backend is months of engineering.

## Key things I learned from reading the source

1. **The plugin layer is tiny.** The Local backend's entire plugin file is 39 lines. The vendor backend pattern is heavily reusable — the plugin is just registration glue; the substance lives in the Device class and the Dialect.

2. **Three clean layers.** Plugin file → Device class → Dialect. Each layer has a different role and lifecycle. A vendor adding a new accelerator writes a small plugin, a substantive device class, and a custom dialect modeling their hardware.

3. **TargetBackend is the contract.** The header file documents exactly what every backend must implement — `getDefaultExecutableTargets`, `getSupportedTypes`, `buildConfigurationPassPipeline`, `buildTranslationPassPipeline`, etc. There's no magic. A new backend implements these methods.

4. **CUDA inlines what Local separates.** CUDA's plugin file is hundreds of lines because it inlines the device class logic. Local's is 39 lines because it delegates to a reusable LocalDevice. The structure isn't dictated — different vendors make different decisions about what to inline vs separate.

5. **The dialect is independent of the backend.** Operations like `gpu.*` or hypothetical `toy_npu.*` are defined separately from the backend plugin. The same dialect could be targeted by multiple backends (simulator, FPGA prototype, ASIC). This is a real architectural strength for HW/SW co-design.

## What I sketched vs what would be real engineering

**Sketched:** dialect operations (tile_load, tile_matmul, tile_store), the conversion pattern shape, the three-layer architecture, the rough pass pipeline structure.

**Real engineering required:** working TableGen and C++ that actually compiles into IREE's build system, a cost model, DMA scheduling, quantization-aware lowering, fusion-aware lowering, HAL driver implementation, simulator integration, validation against real workloads.

The gap between "I can sketch this" and "I can build this" is large — probably months of focused engineering for one engineer. But the *structure* of what would need to be built is now concrete, not abstract.

## What this connects to from earlier experiments

- **Experiment 04** showed that structured IR (linalg.matmul) enables vectorization where raw C didn't. The same logic applies here at higher stakes: linalg.matmul gives the toy_npu lowering a clean structural entry point. Without it, generating NPU code from inscrutable loops would be much harder.
- **Experiment 05** showed how to measure where time goes on real models. For a real NPU backend, this measurement loop is essential — you can't tune the lowering without knowing which workloads matter.
- **Experiment 02** showed IREE's fusion in action (conv+bias+ReLU6 → one dispatch). For an NPU with fixed-function units, the fusion *policy* may need to be different than for CPUs. This is one of the open questions a real NPU backend would have to answer.

## What I'd do next if continuing

1. Read one more existing backend deeply — probably LLVMCPU since it's mature and well-commented — to see how a full production backend handles edge cases
2. Build a minimal TableGen dialect definition (toy_npu) and confirm it compiles
3. Write one conversion pattern (the inner-tile matmul rewrite) and test it on a small example
4. Iterate on the HAL driver stub
5. Eventually — actually wire it into IREE and produce a .vmfb that uses toy_npu ops

Each of these is a real engineering investment. The design study tells me where to start; building it out is the next several weeks of work.

## What this tells me about NPU compiler engineering at MIPS

The role is exactly this pattern at higher fidelity with real hardware. Reading the source confirmed that adding a backend to IREE is structurally well-defined: there's a contract (TargetBackend), there's a plugin model (compiler/plugins/target/), and there's a clean three-layer separation. A vendor's job is to fill in those layers for their hardware, not to invent a new compiler architecture.

This is good news for tractability. It's not good news for difficulty — filling in those layers correctly, with good performance, for real workloads, is still a substantial engineering challenge. But the framework is sound.