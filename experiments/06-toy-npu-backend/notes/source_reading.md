## Local backend — the simplest example (39 lines total!)

File: `compiler/plugins/target/Local/LocalTarget.cpp`

This is the *minimal* shape of a vendor backend plugin in IREE. The entire file is:

1. Includes — pulls in `LocalDevice.h` (the actual device class) and plugin/registry infrastructure
2. A `LocalSession` struct that extends `PluginSession` and overrides `populateHALTargetDevices` — that single method registers a device with the HAL
3. An `extern "C"` registration function that the IREE plugin loader calls

The pattern:
```cpp
struct LocalSession : PluginSession<LocalSession, LocalDevice::Options, ...> {
  void populateHALTargetDevices(TargetDeviceList &targets) {
    targets.add("local", [this]() {
      return std::make_shared<LocalDevice>(options);
    });
  }
};

extern "C" bool iree_register_compiler_plugin_hal_target_local(...) {
  registrar->registerPlugin<LocalSession>("hal_target_local");
  return true;
}
```

## Architectural insight: 3-layer separation

What I learned by comparing CUDA (hundreds of lines) and Local (39 lines):

The IREE backend architecture has 3 layers, cleanly separated:

1. **Plugin file** — the small thing under `compiler/plugins/target/Xxx/`. Just registration glue. ~40 lines.
2. **Device class** — implements the actual TargetBackend / TargetDevice contract. Contains pass pipelines, code generation, serialization. Lives in `Dialect/HAL/Target/Devices/`.
3. **Dialect** — the actual MLIR operations the backend uses (e.g., `gpu`, `vector`, vendor-specific ones). Lives in `Dialect/`.

The CUDA file looked large because it inlines the device class logic. The Local file is small because LocalDevice is defined separately and is reusable across CPU-targeting plugins.

## What this means for toy_npu design

A toy_npu backend would be:
- **Plugin file (small, ~40 lines):** `compiler/plugins/target/ToyNPU/ToyNPUTarget.cpp` — just registration glue, mirrors LocalTarget.cpp structure
- **Device class (substantial):** `compiler/src/iree/compiler/Dialect/HAL/Target/Devices/ToyNPUDevice.{h,cpp}` — implements TargetBackend, defines pass pipelines for lowering linalg → toy_npu dialect, serializes the binary
- **Dialect (substantial):** `compiler/src/iree/compiler/Dialect/ToyNPU/IR/ToyNPUOps.td` — defines tile_load, tile_matmul, tile_store operations in TableGen

The plugin is the simplest of the three. Most of the engineering happens in the device class and the dialect.