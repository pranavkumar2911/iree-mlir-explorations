#executable_target_embedded_elf_x86_64 = #hal.executable.target<"llvm-cpu", "embedded-elf-x86_64", {cpu = "skylake-avx512", cpu_features = "+cmov,+mmx,+popcnt,+sse,+sse2,+sse3,+ssse3,+sse4.1,+sse4.2,+avx,+avx2,+fma,+avx512f,+bmi,+bmi2,+aes,+pclmul,+avx512vl,+avx512bw,+avx512dq,+avx512cd,+adx,+clflushopt,+clwb,+cx16,+f16c,+fsgsbase,+sahf,+lzcnt,+movbe,+pku,+prfchw,+rdrnd,+rdseed,+xsave,+xsavec,+xsaveopt,+xsaves,+cx8,+crc32,+invpcid,+x87,+fxsr", data_layout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128", iree.encoding.resolver = #iree_cpu.cpu_encoding_resolver<>, max_stack_allocation_size = 32768 : i64, native_vector_size = 64 : i64, target_triple = "x86_64-unknown-unknown-eabi-elf"}>
#map = affine_map<(d0, d1, d2) -> (d0, d2)>
#map1 = affine_map<(d0, d1, d2) -> (d2, d1)>
#map2 = affine_map<(d0, d1, d2) -> (d0, d1)>
#device_target_local = #hal.device.target<"local", [#executable_target_embedded_elf_x86_64]> : !hal.device
module attributes {stream.affinity.default = #hal.device.affinity<@__device_0>} {
  util.global private @__device_0 = #device_target_local
  flow.executable private @matmul_dispatch_0 {
    flow.executable.export public @matmul_dispatch_0_matmul_like_64x64x64_f32 workgroups() -> (index, index, index) {
      %x, %y, %z = iree_tensor_ext.dispatch.workgroup_count_from_slice()
      flow.return %x, %y, %z : index, index, index
    }
    builtin.module {
      func.func @matmul_dispatch_0_matmul_like_64x64x64_f32(%arg0: !iree_tensor_ext.dispatch.tensor<readonly:tensor<64x64xf32>>, %arg1: !iree_tensor_ext.dispatch.tensor<readonly:tensor<64x64xf32>>, %arg2: !iree_tensor_ext.dispatch.tensor<writeonly:tensor<64x64xf32>>) {
        %cst = arith.constant 0.000000e+00 : f32
        %0 = iree_tensor_ext.dispatch.tensor.load %arg0, offsets = [0, 0], sizes = [64, 64], strides = [1, 1] : !iree_tensor_ext.dispatch.tensor<readonly:tensor<64x64xf32>> -> tensor<64x64xf32>
        %1 = iree_tensor_ext.dispatch.tensor.load %arg1, offsets = [0, 0], sizes = [64, 64], strides = [1, 1] : !iree_tensor_ext.dispatch.tensor<readonly:tensor<64x64xf32>> -> tensor<64x64xf32>
        %2 = tensor.empty() : tensor<64x64xf32>
        %3 = linalg.fill ins(%cst : f32) outs(%2 : tensor<64x64xf32>) -> tensor<64x64xf32>
        %4 = linalg.generic {indexing_maps = [#map, #map1, #map2], iterator_types = ["parallel", "parallel", "reduction"]} ins(%0, %1 : tensor<64x64xf32>, tensor<64x64xf32>) outs(%3 : tensor<64x64xf32>) {
        ^bb0(%in: f32, %in_0: f32, %out: f32):
          %5 = arith.mulf %in, %in_0 : f32
          %6 = arith.addf %out, %5 : f32
          linalg.yield %6 : f32
        } -> tensor<64x64xf32>
        iree_tensor_ext.dispatch.tensor.store %4, %arg2, offsets = [0, 0], sizes = [64, 64], strides = [1, 1] : tensor<64x64xf32> -> !iree_tensor_ext.dispatch.tensor<writeonly:tensor<64x64xf32>>
        return
      }
    }
  }
  util.func public @matmul(%arg0: !hal.buffer_view, %arg1: !hal.buffer_view) -> !hal.buffer_view attributes {iree.abi.stub, iree.reflection = {iree.abi.declaration = "sync func @matmul(%input0: tensor<64x64xf32>, %input1: tensor<64x64xf32>) -> (%output0: tensor<64x64xf32>)"}} {
    %0 = hal.tensor.import %arg0 "input0" : !hal.buffer_view -> tensor<64x64xf32>
    %1 = hal.tensor.import %arg1 "input1" : !hal.buffer_view -> tensor<64x64xf32>
    %2 = flow.dispatch @matmul_dispatch_0::@matmul_dispatch_0_matmul_like_64x64x64_f32(%0, %1) : (tensor<64x64xf32>, tensor<64x64xf32>) -> tensor<64x64xf32>
    %3 = hal.tensor.export %2 "output0" : tensor<64x64xf32> -> !hal.buffer_view
    util.return %3 : !hal.buffer_view
  }
}
