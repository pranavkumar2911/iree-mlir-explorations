#config = #iree_cpu.lowering_config<vector_common_parallel = [8, 16]>
#config1 = #iree_cpu.lowering_config<distribution = [8, 64, 0], vector_common_parallel = [8, 16, 0], vector_reduction = [0, 0, 16]>
#executable_target_embedded_elf_x86_64 = #hal.executable.target<"llvm-cpu", "embedded-elf-x86_64", {cpu = "tigerlake", cpu_features = "+64bit,+adx,+aes,-amx-avx512,-amx-bf16,-amx-complex,-amx-fp16,-amx-fp8,-amx-int8,-amx-movrs,-amx-tf32,-amx-tile,+avx,-avx10.1,-avx10.2,+avx2,-avx512bf16,+avx512bitalg,+avx512bw,+avx512cd,+avx512dq,+avx512f,-avx512fp16,+avx512ifma,+avx512vbmi,+avx512vbmi2,+avx512vl,+avx512vnni,+avx512vp2intersect,+avx512vpopcntdq,-avxifma,-avxneconvert,-avxvnni,-avxvnniint16,-avxvnniint8,+bmi,+bmi2,-ccmp,-cf,-cldemote,+clflushopt,+clwb,-clzero,+cmov,-cmpccxadd,+crc32,+cx16,+cx8,-egpr,-enqcmd,+f16c,+fma,-fma4,+fsgsbase,+fxsr,+gfni,-hreset,+invpcid,-kl,-lwp,+lzcnt,+mmx,+movbe,+movdir64b,+movdiri,-movrs,-mwaitx,-ndd,-nf,+pclmul,-pconfig,-pku,+popcnt,-ppx,-prefetchi,+prfchw,-ptwrite,-push2pop2,-raoint,+rdpid,-rdpru,+rdrnd,+rdseed,-rtm,+sahf,-serialize,-sgx,+sha,-sha512,+shstk,-sm3,-sm4,+sse,+sse2,+sse3,+sse4.1,+sse4.2,-sse4a,+ssse3,-tbm,-tsxldtrk,-uintr,-usermsr,+vaes,+vpclmulqdq,-waitpkg,-wbnoinvd,-widekl,-xop,+xsave,+xsavec,+xsaveopt,+xsaves,-zu", data_layout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128", iree.encoding.resolver = #iree_cpu.cpu_encoding_resolver<>, max_stack_allocation_size = 32768 : i64, native_vector_size = 64 : i64, target_triple = "x86_64-unknown-unknown-eabi-elf"}>
#map = affine_map<(d0, d1, d2) -> (d0, d2)>
#map1 = affine_map<(d0, d1, d2) -> (d2, d1)>
#map2 = affine_map<(d0, d1, d2) -> (d0, d1)>
#pipeline_layout = #hal.pipeline.layout<bindings = [#hal.pipeline.binding<storage_buffer, "ReadOnly|Indirect">, #hal.pipeline.binding<storage_buffer, "ReadOnly|Indirect">, #hal.pipeline.binding<storage_buffer, Indirect>], flags = Indirect>
#translation = #iree_codegen.translation_info<pipeline = CPUDoubleTilingExpert>
#device_target_local = #hal.device.target<"local", [#executable_target_embedded_elf_x86_64]> : !hal.device
module attributes {stream.affinity.default = #hal.device.affinity<@__device_0>} {
  util.global private @__device_0 = #device_target_local
  hal.executable private @matmul_dispatch_0 {
    hal.executable.variant public @embedded_elf_x86_64 target(#executable_target_embedded_elf_x86_64) {
      hal.executable.export public @matmul_dispatch_0_matmul_like_64x64x64_f32 ordinal(0) layout(#pipeline_layout) count(%arg0: !hal.device) -> (index, index, index) {
        %x, %y, %z = iree_tensor_ext.dispatch.workgroup_count_from_slice()
        hal.return %x, %y, %z : index, index, index
      }
      builtin.module {
        func.func @matmul_dispatch_0_matmul_like_64x64x64_f32() attributes {translation_info = #translation} {
          %cst = arith.constant 0.000000e+00 : f32
          %c0 = arith.constant 0 : index
          %0 = hal.interface.binding.subspan layout(#pipeline_layout) binding(0) alignment(64) offset(%c0) flags("ReadOnly|Indirect") : !iree_tensor_ext.dispatch.tensor<readonly:tensor<64x64xf32>>
          %1 = hal.interface.binding.subspan layout(#pipeline_layout) binding(1) alignment(64) offset(%c0) flags("ReadOnly|Indirect") : !iree_tensor_ext.dispatch.tensor<readonly:tensor<64x64xf32>>
          %2 = hal.interface.binding.subspan layout(#pipeline_layout) binding(2) alignment(64) offset(%c0) flags(Indirect) : !iree_tensor_ext.dispatch.tensor<writeonly:tensor<64x64xf32>>
          %3 = iree_tensor_ext.dispatch.tensor.load %0, offsets = [0, 0], sizes = [64, 64], strides = [1, 1] : !iree_tensor_ext.dispatch.tensor<readonly:tensor<64x64xf32>> -> tensor<64x64xf32>
          %4 = iree_tensor_ext.dispatch.tensor.load %1, offsets = [0, 0], sizes = [64, 64], strides = [1, 1] : !iree_tensor_ext.dispatch.tensor<readonly:tensor<64x64xf32>> -> tensor<64x64xf32>
          %5 = tensor.empty() : tensor<64x64xf32>
          %6 = linalg.fill {lowering_config = #config} ins(%cst : f32) outs(%5 : tensor<64x64xf32>) -> tensor<64x64xf32>
          %7 = linalg.generic {indexing_maps = [#map, #map1, #map2], iterator_types = ["parallel", "parallel", "reduction"]} ins(%3, %4 : tensor<64x64xf32>, tensor<64x64xf32>) outs(%6 : tensor<64x64xf32>) attrs =  {lowering_config = #config1} {
          ^bb0(%in: f32, %in_0: f32, %out: f32):
            %8 = arith.mulf %in, %in_0 : f32
            %9 = arith.addf %out, %8 : f32
            linalg.yield %9 : f32
          } -> tensor<64x64xf32>
          iree_tensor_ext.dispatch.tensor.store %7, %2, offsets = [0, 0], sizes = [64, 64], strides = [1, 1] : tensor<64x64xf32> -> !iree_tensor_ext.dispatch.tensor<writeonly:tensor<64x64xf32>>
          return
        }
      }
    }
  }
  util.func public @matmul(%arg0: !hal.buffer_view, %arg1: !hal.buffer_view) -> !hal.buffer_view attributes {iree.abi.stub, iree.reflection = {iree.abi.declaration = "sync func @matmul(%input0: tensor<64x64xf32>, %input1: tensor<64x64xf32>) -> (%output0: tensor<64x64xf32>)"}} {
    %c0 = arith.constant 0 : index
    %c16384 = arith.constant 16384 : index
    %c64 = arith.constant 64 : index
    %element_type_f32 = hal.element_type<f32> : i32
    %dense_row_major = hal.encoding_type<dense_row_major> : i32
    hal.buffer_view.assert<%arg0 : !hal.buffer_view> message("input0") shape([%c64, %c64]) type(%element_type_f32) encoding(%dense_row_major)
    %0 = stream.tensor.import on(#hal.device.affinity<@__device_0>) %arg0 : !hal.buffer_view -> tensor<64x64xf32> in !stream.resource<external>{%c16384}
    hal.buffer_view.assert<%arg1 : !hal.buffer_view> message("input1") shape([%c64, %c64]) type(%element_type_f32) encoding(%dense_row_major)
    %1 = stream.tensor.import on(#hal.device.affinity<@__device_0>) %arg1 : !hal.buffer_view -> tensor<64x64xf32> in !stream.resource<external>{%c16384}
    %result, %result_timepoint = stream.resource.alloca uninitialized on(#hal.device.affinity<@__device_0>) : !stream.resource<external>{%c16384} => !stream.timepoint
    %2 = stream.cmd.execute on(#hal.device.affinity<@__device_0>) await(%result_timepoint) => with(%0 as %arg2: !stream.resource<external>{%c16384}, %1 as %arg3: !stream.resource<external>{%c16384}, %result as %arg4: !stream.resource<external>{%c16384}) {
      stream.cmd.dispatch @matmul_dispatch_0::@embedded_elf_x86_64::@matmul_dispatch_0_matmul_like_64x64x64_f32 {
        ro %arg2[%c0 for %c16384] : !stream.resource<external>{%c16384},
        ro %arg3[%c0 for %c16384] : !stream.resource<external>{%c16384},
        wo %arg4[%c0 for %c16384] : !stream.resource<external>{%c16384}
      }
    } => !stream.timepoint
    %3 = stream.timepoint.await %2 => %result : !stream.resource<external>{%c16384}
    %4 = stream.tensor.export on(#hal.device.affinity<@__device_0>) %3 : tensor<64x64xf32> in !stream.resource<external>{%c16384} -> !hal.buffer_view
    util.return %4 : !hal.buffer_view
  }
}
