#executable_target_embedded_elf_x86_64 = #hal.executable.target<"llvm-cpu", "embedded-elf-x86_64", {cpu = "skylake-avx512", cpu_features = "+cmov,+mmx,+popcnt,+sse,+sse2,+sse3,+ssse3,+sse4.1,+sse4.2,+avx,+avx2,+fma,+avx512f,+bmi,+bmi2,+aes,+pclmul,+avx512vl,+avx512bw,+avx512dq,+avx512cd,+adx,+clflushopt,+clwb,+cx16,+f16c,+fsgsbase,+sahf,+lzcnt,+movbe,+pku,+prfchw,+rdrnd,+rdseed,+xsave,+xsavec,+xsaveopt,+xsaves,+cx8,+crc32,+invpcid,+x87,+fxsr", data_layout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128", iree.encoding.resolver = #iree_cpu.cpu_encoding_resolver<>, max_stack_allocation_size = 32768 : i64, native_vector_size = 64 : i64, target_triple = "x86_64-unknown-unknown-eabi-elf"}>
#map = affine_map<(d0, d1, d2) -> (d0, d2)>
#map1 = affine_map<(d0, d1, d2) -> (d2, d1)>
#map2 = affine_map<(d0, d1, d2) -> (d0, d1)>
#device_target_local = #hal.device.target<"local", [#executable_target_embedded_elf_x86_64]> : !hal.device
module attributes {stream.affinity.default = #hal.device.affinity<@__device_0>} {
  util.global private @__device_0 = #device_target_local
  util.func public @matmul(%arg0: !hal.buffer_view, %arg1: !hal.buffer_view) -> !hal.buffer_view attributes {iree.abi.stub, iree.reflection = {iree.abi.declaration = "sync func @matmul(%input0: tensor<64x64xf32>, %input1: tensor<64x64xf32>) -> (%output0: tensor<64x64xf32>)"}} {
    %cst = arith.constant 0.000000e+00 : f32
    %0 = hal.tensor.import %arg0 "input0" : !hal.buffer_view -> tensor<64x64xf32>
    %1 = iree_tensor_ext.compute_barrier.start %0 : tensor<64x64xf32> -> tensor<64x64xf32>
    %2 = hal.tensor.import %arg1 "input1" : !hal.buffer_view -> tensor<64x64xf32>
    %3 = iree_tensor_ext.compute_barrier.start %2 : tensor<64x64xf32> -> tensor<64x64xf32>
    %4 = tensor.empty() : tensor<64x64xf32>
    %5 = linalg.fill ins(%cst : f32) outs(%4 : tensor<64x64xf32>) -> tensor<64x64xf32>
    %6 = linalg.generic {indexing_maps = [#map, #map1, #map2], iterator_types = ["parallel", "parallel", "reduction"]} ins(%1, %3 : tensor<64x64xf32>, tensor<64x64xf32>) outs(%5 : tensor<64x64xf32>) {
    ^bb0(%in: f32, %in_0: f32, %out: f32):
      %9 = arith.mulf %in, %in_0 : f32
      %10 = arith.addf %out, %9 : f32
      linalg.yield %10 : f32
    } -> tensor<64x64xf32>
    %7 = iree_tensor_ext.compute_barrier.end %6 : tensor<64x64xf32> -> tensor<64x64xf32>
    %8 = hal.tensor.export %7 "output0" : tensor<64x64xf32> -> !hal.buffer_view
    util.return %8 : !hal.buffer_view
  }
}
