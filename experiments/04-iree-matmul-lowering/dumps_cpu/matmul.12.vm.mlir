module attributes {vm.toplevel} {
  vm.module public @module {
    vm.global.ref private mutable @__device_0 : !vm.ref<!hal.device>
    vm.global.ref private mutable @__device_0_executable_0_matmul_dispatch_0 : !vm.ref<!hal.executable>
    vm.global.ref private mutable @__matmul_memoize_result_0_device_0 : !vm.ref<!hal.command_buffer>
    vm.rodata private @_utf8_hal_device_id_C6650FF277232B5A {alignment = 1 : i64} "hal.device.id"
    vm.rodata private @_utf8_local_1A8FF0278D7661D8 {alignment = 1 : i64} "local*"
    vm.rodata private @_utf8_hal_executable_format_E03EECB63A2AAF52 {alignment = 1 : i64} "hal.executable.format"
    vm.rodata private @_utf8_embedded_elf_x86_64_FF16E34B4A5F9C83 {alignment = 1 : i64} "embedded-elf-x86_64"
    vm.rodata private @matmul_dispatch_0_embedded_elf_x86_64 {alignment = 16 : i64, mime_type = "application/x-elf"} dense<"0x7F454C4602010100000000000000000003003E000100000000000000000000004000000000000000E80E000000000000000000004000380007004000150013000600000004000000400000000000000040000000000000004000000000000000880100000000000088010000000000000800000000000000010000000400000000000000000000000000000000000000000000000000000048040000000000004804000000000000001000000000000001000000050000005004000000000000501400000000000050140000000000004106000000000000410600000000000000100000000000000100000006000000A00A000000000000A02A000000000000A02A000000000000A001000000000000600500000000000000100000000000000200000006000000800B000000000000802B000000000000802B000000000000C000000000000000C000000000000000080000000000000052E5746404000000A00A000000000000A02A000000000000A02A000000000000A0010000000000006005000000000000010000000000000051E57464060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000012000700801A000000000000110000000000000002000000020000000000000001000000000000000000000000697265655F68616C5F65786563757461626C655F6C6962726172795F7175657279000000000000A82A00000000000008000000000000006003000000000000B82A00000000000008000000000000005014000000000000C02A0000000000000800000000000000C003000000000000D02A0000000000000800000000000000EB03000000000000E82A0000000000000800000000000000F803000000000000F02A0000000000000800000000000000F803000000000000002B0000000000000800000000000000A02A000000000000202B0000000000000800000000000000B82A000000000000282B00000000000008000000000000008003000000000000402B0000000000000800000000000000C02A000000000000582B0000000000000800000000000000C82A000000000000602B0000000000000800000000000000E02A00000000000000000000000000006D61746D756C5F64697370617463685F30000000000000000000000000000000000000000000000000000003010000000100000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000006D61746D756C5F64697370617463685F305F6D61746D756C5F6C696B655F36347836347836345F663332006D61746D756C2E6D6C697200001400000000000000017A5200017810011B0C0708900100001C0000001C000000381000002C06000000410E108602430D060324060C070800100000003C000000481600001100000000000000000000000000000000000000554889E5488B7620488B0E8B0248C1E00B488D8C083C07000048034610BA000F00004803560831F60F1F840000000000C5F857C048C7C7F0FFFFFF4989D0C5F057C9C5E857D2C5E057DBC5D857E4C5D057EDC5C857F6C5C057FF660F1F44000062C17C482868C462C17C482870C862C17C482878CC62C17C482860D062C17C482858D462C17C482850D862C17C482848DC62C17C482840E062517C482878E462517C482870E862517C482868EC62517C482860F062517C482858F462517C482850F862517C482848FC62517C48280062F25550B884B904F9FFFF62F25550B88CB904FAFFFF62F25550B894B904FBFFFF62F25550B89CB904FCFFFF62F25550B8A4B904FDFFFF62F25550B86CB98162F25550B874B9C162F25550B87CB90162F24D50B884B908F9FFFF62F24D50B88CB908FAFFFF62F24D50B894B908FBFFFF62F24D50B89CB908FCFFFF62F24D50B8A4B908FDFFFF62F24D50B86CB98262F24D50B874B9C262F24D50B87CB90262F24550B884B90CF9FFFF62F24550B88CB90CFAFFFF62F24550B894B90CFBFFFF62F24550B89CB90CFCFFFF62F24550B8A4B90CFDFFFF62F24550B86CB98362F24550B874B9C362F24550B87CB90362F25D50B884B910F9FFFF62F25D50B88CB910FAFFFF62F25D50B894B910FBFFFF62F25D50B89CB910FCFFFF62F25D50B8A4B910FDFFFF62F25D50B86CB98462F25D50B874B9C462F25D50B87CB90462F26550B884B914F9FFFF62F26550B88CB914FAFFFF62F26550B894B914FBFFFF62F26550B89CB914FCFFFF62F26550B8A4B914FDFFFF62F26550B86CB98562F26550B874B9C562F26550B87CB90562F26D50B884B918F9FFFF62F26D50B88CB918FAFFFF62F26D50B894B918FBFFFF62F26D50B89CB918FCFFFF62F26D50B8A4B918FDFFFF62F26D50B86CB98662F26D50B874B9C662F26D50B87CB90662F27550B884B91CF9FFFF62F27550B88CB91CFAFFFF62F27550B894B91CFBFFFF62F27550B89CB91CFCFFFF62F27550B8A4B91CFDFFFF62F27550B86CB98762F27550B874B9C762F27550B87CB90762F27D50B884B920F9FFFF62F27D50B88CB920FAFFFF62F27D50B894B920FBFFFF62F27D50B89CB920FCFFFF62F27D50B8A4B920FDFFFF62F27D50B86CB98862F27D50B874B9C862F27D50B87CB90862F20558B884B924F9FFFF62F20558B88CB924FAFFFF62F20558B894B924FBFFFF62F20558B89CB924FCFFFF62F20558B8A4B924FDFFFF62F20558B86CB98962F20558B874B9C962F20558B87CB90962F20D58B884B928F9FFFF62F20D58B88CB928FAFFFF62F20D58B894B928FBFFFF62F20D58B89CB928FCFFFF62F20D58B8A4B928FDFFFF62F20D58B86CB98A62F20D58B874B9CA62F20D58B87CB90A62F21558B884B92CF9FFFF62F21558B88CB92CFAFFFF62F21558B894B92CFBFFFF62F21558B89CB92CFCFFFF62F21558B8A4B92CFDFFFF62F21558B86CB98B62F21558B874B9CB62F21558B87CB90B62F21D58B884B930F9FFFF62F21D58B88CB930FAFFFF62F21D58B894B930FBFFFF62F21D58B89CB930FCFFFF62F21D58B8A4B930FDFFFF62F21D58B86CB98C62F21D58B874B9CC62F21D58B87CB90C62F22558B884B934F9FFFF62F22558B88CB934FAFFFF62F22558B894B934FBFFFF62F22558B89CB934FCFFFF62F22558B8A4B934FDFFFF62F22558B86CB98D62F22558B874B9CD62F22558B87CB90D62F22D58B884B938F9FFFF62F22D58B88CB938FAFFFF62F22D58B894B938FBFFFF62F22D58B89CB938FCFFFF62F22D58B8A4B938FDFFFF62F22D58B86CB98E62F22D58B874B9CE62F22D58B87CB90E62F23558B884B93CF9FFFF62F23558B88CB93CFAFFFF62F23558B894B93CFBFFFF62F23558B89CB93CFCFFFF62F23558B8A4B93CFDFFFF62F23558B86CB98F62F23558B874B9CF62F23558B87CB90F62F23D58B884B940F9FFFF62F23D58B88CB940FAFFFF62F23D58B894B940FBFFFF62F23D58B89CB940FCFFFF62F23D58B8A4B940FDFFFF62F23D58B86CB99062F23D58B874B9D062F23D58B87CB9104883C7104981C0001000004883FF300F828CFAFFFF62F17C482904B062F17C48294CB00462F17C482954B00862F17C48295CB00C62F17C482964B01062F17C48296CB01462F17C482974B01862F17C48297CB01C4883C2404883FE30488D76100F820BFAFFFF31C05DC5F877C3CCCCCCCC31C083FF06488D0D74100000480F44C1C300000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000050000000B00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001E000000000000000800000000000000FBFFFF6F000000000100000000000000070000000000000038020000000000000800000000000000200100000000000009000000000000001800000000000000F9FFFF6F000000000C000000000000000600000000000000C8010000000000000B000000000000001800000000000000050000000000000010020000000000000A0000000000000023000000000000000400000000000000F80100000000000000000000000000000000000000000000011101250E1305030E1017B44219110112060000022E001101120640186E0E030E3A0B3B0B49133F190000032400030E3E0B0B0B000000470000000400000000000801310000002C00040000000000000050140000000000002C0600000250140000000000002C060000015606000000060000000101430000000300000000050400696E74002D006D61746D756C5F64697370617463685F305F6D61746D756C5F6C696B655F36347836347836345F6633320049524545003D0000000200000000004B000000260000006D61746D756C5F64697370617463685F305F6D61746D756C5F6C696B655F36347836347836345F6633320000000000160000000200000000004B00000043000000696E74000000000042000000040019000000010101FB0E0D000101010100000001000001002D000000000000090250140000000000000105010A4E0602240D06023817060B02C70B120205000101495245450000000000000000000000000000000000000000000000000000002300000000020900802B00000000000000000000000000000100000012000700801A0000000000001100000000000000002E64796E73796D002E68617368002E64796E737472002E72656C612E64796E002E726F64617461002E65685F6672616D65002E74657874002E646174612E72656C2E726F002E64796E616D6963002E72656C726F5F70616464696E67002E64656275675F616262726576002E64656275675F696E666F002E64656275675F737472002E64656275675F7075626E616D6573002E64656275675F7075627479706573002E64656275675F6C696E65002E636F6D6D656E74002E73796D746162002E7368737472746162002E7374727461620000697265655F68616C5F65786563757461626C655F6C6962726172795F7175657279005F44594E414D494300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000B0000000200000000000000C801000000000000C801000000000000300000000000000003000000010000000800000000000000180000000000000009000000050000000200000000000000F801000000000000F80100000000000018000000000000000100000000000000040000000000000004000000000000000F000000030000000200000000000000100200000000000010020000000000002300000000000000000000000000000001000000000000000000000000000000170000000400000002000000000000003802000000000000380200000000000020010000000000000100000000000000080000000000000018000000000000002100000001000000020000000000000060030000000000006003000000000000980000000000000000000000000000001000000000000000000000000000000029000000010000000200000000000000F803000000000000F80300000000000050000000000000000000000000000000080000000000000000000000000000003300000001000000060000000000000050140000000000005004000000000000410600000000000000000000000000001000000000000000000000000000000039000000010000000300000000000000A02A000000000000A00A000000000000E00000000000000000000000000000001000000000000000000000000000000046000000060000000300000000000000802B000000000000800B000000000000C0000000000000000300000000000000080000000000000010000000000000004F000000080000000300000000000000402C000000000000400C000000000000C0030000000000000000000000000000010000000000000000000000000000005E0000000100000000000000000000000000000000000000400C00000000000037000000000000000000000000000000010000000000000000000000000000006C0000000100000000000000000000000000000000000000770C0000000000004B00000000000000000000000000000001000000000000000000000000000000780000000100000030000000000000000000000000000000C20C0000000000003600000000000000000000000000000001000000000000000100000000000000830000000100000000000000000000000000000000000000F80C0000000000004100000000000000000000000000000001000000000000000000000000000000930000000100000000000000000000000000000000000000390D0000000000001A00000000000000000000000000000001000000000000000000000000000000A30000000100000000000000000000000000000000000000530D0000000000004600000000000000000000000000000001000000000000000000000000000000AF0000000100000030000000000000000000000000000000990D0000000000000500000000000000000000000000000001000000000000000100000000000000B80000000200000000000000000000000000000000000000A00D0000000000004800000000000000140000000200000008000000000000001800000000000000C00000000300000000000000000000000000000000000000E80D000000000000D200000000000000000000000000000001000000000000000000000000000000CA0000000300000000000000000000000000000000000000BA0E0000000000002C00000000000000000000000000000001000000000000000000000000000000"> : vector<5160xi8>
    vm.func private @__matmul_memoize_apply() -> !vm.ref<!hal.command_buffer> attributes {inlining_policy = #util.inline.never, vm.unwind} {
      %c13 = vm.const.i32 13
      %c28 = vm.const.i32 28
      %c2 = vm.const.i32 2
      %null = vm.const.ref.zero : !vm.ref<!hal.buffer>
      %c1 = vm.const.i32 1
      %c8 = vm.const.i32 8
      %c3 = vm.const.i32 3
      %zero = vm.const.i32.zero
      %c16384 = vm.const.i64 16384
      %zero_0 = vm.const.i64.zero
      %c-1 = vm.const.i64 -1
      %__device_0 = vm.global.load.ref @__device_0 : !vm.ref<!hal.device>
      %__device_0_executable_0_matmul_dispatch_0 = vm.global.load.ref @__device_0_executable_0_matmul_dispatch_0 : !vm.ref<!hal.executable>
      %ref = vm.call @hal.command_buffer.create(%__device_0, %zero, %c3, %c-1, %c3) : (!vm.ref<!hal.device>, i32, i32, i64, i32) -> !vm.ref<!hal.command_buffer>
      vm.call.variadic @hal.command_buffer.dispatch(%ref, %__device_0_executable_0_matmul_dispatch_0, %zero, %c8, %c1, %c1, %zero_0, [], [(%zero, %zero, %null, %zero_0, %c16384), (%zero, %c1, %null, %zero_0, %c16384), (%zero, %c2, %null, %zero_0, %c16384)]) : (!vm.ref<!hal.command_buffer>, !vm.ref<!hal.executable>, i32, i32, i32, i32, i64, i32 ..., tuple<i32, i32, !vm.ref<!hal.buffer>, i64, i64> ...)
      vm.call @hal.command_buffer.execution_barrier(%ref, %c28, %c13, %zero_0) : (!vm.ref<!hal.command_buffer>, i32, i32, i64) -> ()
      vm.call @hal.command_buffer.finalize(%ref) : (!vm.ref<!hal.command_buffer>) -> ()
      vm.return %ref : !vm.ref<!hal.command_buffer>
    }
    vm.import private @hal.buffer.assert(%buffer : !vm.ref<!hal.buffer>, %message : !vm.buffer, %allocator : !vm.ref<!hal.allocator>, %minimum_length : i64, %memory_types : i32, %buffer_usage : i32)
    vm.import private @hal.buffer_view.create(%buffer : !vm.ref<!hal.buffer>, %source_offset : i64, %source_length : i64, %element_type : i32, %encoding_type : i32, %shape : i64 ...) -> !vm.ref<!hal.buffer_view> attributes {nosideeffects}
    vm.import private @hal.buffer_view.assert(%buffer_view : !vm.ref<!hal.buffer_view>, %message : !vm.buffer, %element_type : i32, %encoding_type : i32, %shape : i64 ...)
    vm.import private @hal.buffer_view.buffer(%buffer_view : !vm.ref<!hal.buffer_view>) -> !vm.ref<!hal.buffer> attributes {nosideeffects}
    vm.import private @hal.command_buffer.create(%device : !vm.ref<!hal.device>, %modes : i32, %command_categories : i32, %queue_affinity : i64, %binding_capacity : i32) -> !vm.ref<!hal.command_buffer> attributes {minimum_version = 6 : i32}
    vm.import private @hal.command_buffer.finalize(%command_buffer : !vm.ref<!hal.command_buffer>)
    vm.import private @hal.command_buffer.execution_barrier(%command_buffer : !vm.ref<!hal.command_buffer>, %source_stage_mask : i32, %target_stage_mask : i32, %flags : i64)
    vm.import private @hal.command_buffer.dispatch(%command_buffer : !vm.ref<!hal.command_buffer>, %executable : !vm.ref<!hal.executable>, %entry_point : i32, %workgroup_x : i32, %workgroup_y : i32, %workgroup_z : i32, %flags : i64, %constants : i32 ..., %bindings : tuple<i32, i32, !vm.ref<!hal.buffer>, i64, i64> ...)
    vm.import private @hal.device.allocator(%device : !vm.ref<!hal.device>) -> !vm.ref<!hal.allocator> attributes {nosideeffects}
    vm.import private @hal.device.query.i64(%device : !vm.ref<!hal.device>, %category : !vm.buffer, %key : !vm.buffer) -> (i32, i64) attributes {nosideeffects}
    vm.import private @hal.device.queue.alloca(%device : !vm.ref<!hal.device>, %queue_affinity : i64, %wait_fence : !vm.ref<!hal.fence>, %signal_fence : !vm.ref<!hal.fence>, %pool : i64, %memory_types : i32, %buffer_usage : i32, %allocation_size : i64, %flags : i64) -> !vm.ref<!hal.buffer>
    vm.import private @hal.device.queue.execute.indirect(%device : !vm.ref<!hal.device>, %queue_affinity : i64, %wait_fence : !vm.ref<!hal.fence>, %signal_fence : !vm.ref<!hal.fence>, %command_buffer : !vm.ref<!hal.command_buffer>, %flags : i64, %binding_table : tuple<!vm.ref<!hal.buffer>, i64, i64> ...)
    vm.import private @hal.devices.count() -> i32 attributes {nosideeffects}
    vm.import private @hal.devices.get(%index : i32) -> !vm.ref<!hal.device> attributes {nosideeffects}
    vm.import private @hal.executable.create(%device : !vm.ref<!hal.device>, %queue_affinity : i64, %executable_format : !vm.buffer, %executable_data : !vm.buffer, %constants : !vm.buffer) -> !vm.ref<!hal.executable> attributes {nosideeffects}
    vm.import private @hal.fence.create(%device : !vm.ref<!hal.device>, %flags : i64) -> !vm.ref<!hal.fence>
    vm.import private @hal.fence.await(%timeout_millis : i32, %flags : i64, %fences : !vm.ref<!hal.fence> ...) -> i32 attributes {vm.yield}
    vm.rodata private @_utf8_input0_DCE99660CEB3F6B {alignment = 1 : i64} "input0"
    vm.rodata private @_utf8_tensor_FC1814BC4A58F22A {alignment = 1 : i64} "tensor"
    vm.rodata private @_utf8_input1_B898B726583C85DA {alignment = 1 : i64} "input1"
    vm.func private @matmul(%arg0: !vm.ref<!hal.buffer_view>, %arg1: !vm.ref<!hal.buffer_view>) -> !vm.ref<!hal.buffer_view> attributes {iree.reflection = {iree.abi.declaration = "sync func @matmul(%input0: tensor<64x64xf32>, %input1: tensor<64x64xf32>) -> (%output0: tensor<64x64xf32>)"}, vm.unwind, vm.yield} {
      %c16 = vm.const.i32 16
      %c1 = vm.const.i32 1
      %c553648160 = vm.const.i32 553648160
      %c3075 = vm.const.i32 3075
      %c48 = vm.const.i32 48
      %c64 = vm.const.i64 64
      %c16384 = vm.const.i64 16384
      %zero = vm.const.i64.zero
      %c-1 = vm.const.i64 -1
      %null = vm.const.ref.zero : !vm.ref<!hal.fence>
      %c-1_0 = vm.const.i32 -1
      %__device_0 = vm.global.load.ref @__device_0 : !vm.ref<!hal.device>
      %__matmul_memoize_result_0_device_0 = vm.global.load.ref @__matmul_memoize_result_0_device_0 : !vm.ref<!hal.command_buffer>
      %_utf8_input0_DCE99660CEB3F6B = vm.const.ref.rodata @_utf8_input0_DCE99660CEB3F6B : !vm.buffer
      vm.call.variadic @hal.buffer_view.assert(%arg0, %_utf8_input0_DCE99660CEB3F6B, %c553648160, %c1, [%c64, %c64]) : (!vm.ref<!hal.buffer_view>, !vm.buffer, i32, i32, i64 ...)
      %ref = vm.call @hal.buffer_view.buffer(%arg0) {nosideeffects} : (!vm.ref<!hal.buffer_view>) -> !vm.ref<!hal.buffer>
      %ref_1 = vm.call @hal.device.allocator(%__device_0) {nosideeffects} : (!vm.ref<!hal.device>) -> !vm.ref<!hal.allocator>
      %_utf8_tensor_FC1814BC4A58F22A = vm.const.ref.rodata @_utf8_tensor_FC1814BC4A58F22A : !vm.buffer
      vm.call @hal.buffer.assert(%ref, %_utf8_tensor_FC1814BC4A58F22A, %ref_1, %c16384, %c16, %c3075) : (!vm.ref<!hal.buffer>, !vm.buffer, !vm.ref<!hal.allocator>, i64, i32, i32) -> ()
      %_utf8_input1_B898B726583C85DA = vm.const.ref.rodata @_utf8_input1_B898B726583C85DA : !vm.buffer
      vm.call.variadic @hal.buffer_view.assert(%arg1, %_utf8_input1_B898B726583C85DA, %c553648160, %c1, [%c64, %c64]) : (!vm.ref<!hal.buffer_view>, !vm.buffer, i32, i32, i64 ...)
      %ref_2 = vm.call @hal.buffer_view.buffer(%arg1) {nosideeffects} : (!vm.ref<!hal.buffer_view>) -> !vm.ref<!hal.buffer>
      vm.call @hal.buffer.assert(%ref_2, %_utf8_tensor_FC1814BC4A58F22A, %ref_1, %c16384, %c16, %c3075) : (!vm.ref<!hal.buffer>, !vm.buffer, !vm.ref<!hal.allocator>, i64, i32, i32) -> ()
      %ref_3 = vm.call @hal.fence.create(%__device_0, %zero) : (!vm.ref<!hal.device>, i64) -> !vm.ref<!hal.fence>
      %ref_4 = vm.call @hal.device.queue.alloca(%__device_0, %c-1, %null, %ref_3, %zero, %c48, %c3075, %c16384, %zero) : (!vm.ref<!hal.device>, i64, !vm.ref<!hal.fence>, !vm.ref<!hal.fence>, i64, i32, i32, i64, i64) -> !vm.ref<!hal.buffer>
      %ref_5 = vm.call @hal.fence.create(%__device_0, %zero) : (!vm.ref<!hal.device>, i64) -> !vm.ref<!hal.fence>
      vm.call.variadic @hal.device.queue.execute.indirect(%__device_0, %c-1, %ref_3, %ref_5, %__matmul_memoize_result_0_device_0, %zero, [(%ref, %zero, %c16384), (%ref_2, %zero, %c16384), (%ref_4, %zero, %c16384)]) : (!vm.ref<!hal.device>, i64, !vm.ref<!hal.fence>, !vm.ref<!hal.fence>, !vm.ref<!hal.command_buffer>, i64, tuple<!vm.ref<!hal.buffer>, i64, i64> ...)
      vm.call.variadic.yieldable @hal.fence.await(%c-1_0, %zero, %ref_5) {segment_sizes = dense<[-1, -1, 1]> : vector<3xi16>, segment_types = [i32, i64, !vm.ref<!hal.fence>]} : (i32, i64, !vm.ref<!hal.fence>) -> ^bb1 (i32)
    ^bb1(%0: i32):  // pred: ^bb0
      vm.cond_br %0, ^bb3, ^bb2
    ^bb2:  // pred: ^bb1
      %ref_6 = vm.call.variadic @hal.buffer_view.create(%ref_4, %zero, %c16384, %c553648160, %c1, [%c64, %c64]) {nosideeffects} : (!vm.ref<!hal.buffer>, i64, i64, i32, i32, i64 ...) -> !vm.ref<!hal.buffer_view>
      vm.return %ref_6 : !vm.ref<!hal.buffer_view>
    ^bb3:  // pred: ^bb1
      vm.discard.refs %ref_4 : !vm.ref<!hal.buffer>
      vm.fail %0, "failed to wait on timepoint"
    }
    vm.export @matmul attributes {iree.abi.stub, iree.reflection = {iree.abi.declaration = "sync func @matmul(%input0: tensor<64x64xf32>, %input1: tensor<64x64xf32>) -> (%output0: tensor<64x64xf32>)"}}
    vm.export @__init
    vm.func private @__init() attributes {vm.unwind} {
      %c1 = vm.const.i32 1
      %null = vm.const.ref.zero : !vm.buffer
      %c14 = vm.const.i32 14
      %c-1 = vm.const.i64 -1
      %c18 = vm.const.i32 18
      %zero = vm.const.i32.zero
      %zero_0 = vm.const.i64.zero
      %c1_1 = vm.const.i64 1
      %null_2 = vm.const.ref.zero : !vm.ref<!hal.device>
      %0 = vm.call @hal.devices.count() {nosideeffects} : () -> i32
      %1 = vm.ext.i32.i64.s %0 : i32 -> i64
      vm.br ^bb1(%zero_0, %zero_0, %null_2 : i64, i64, !vm.ref<!hal.device>)
    ^bb1(%2: i64, %3: i64, %4: !vm.ref<!hal.device>):  // 2 preds: ^bb0, ^bb4
      %rnz = vm.cmp.nz.ref %4 : !vm.ref<!hal.device>
      %5 = vm.xor.i32 %rnz, %c1 : i32
      %slt = vm.cmp.lt.i64.s %2, %1 : i64
      %6 = vm.and.i32 %5, %slt : i32
      vm.cond_br %6, ^bb2, ^bb5
    ^bb2:  // pred: ^bb1
      vm.discard.refs %4 : !vm.ref<!hal.device>
      %7 = vm.trunc.i64.i32 %2 : i64 -> i32
      %ref = vm.call @hal.devices.get(%7) {nosideeffects} : (i32) -> !vm.ref<!hal.device>
      %_utf8_hal_device_id_C6650FF277232B5A = vm.const.ref.rodata @_utf8_hal_device_id_C6650FF277232B5A : !vm.buffer
      %_utf8_local_1A8FF0278D7661D8 = vm.const.ref.rodata @_utf8_local_1A8FF0278D7661D8 : !vm.buffer
      %8:2 = vm.call @hal.device.query.i64(%ref, %_utf8_hal_device_id_C6650FF277232B5A, %_utf8_local_1A8FF0278D7661D8) {nosideeffects} : (!vm.ref<!hal.device>, !vm.buffer, !vm.buffer) -> (i32, i64)
      %nz = vm.cmp.nz.i64 %8#1 : i64
      %9 = vm.select.i32 %8#0, %nz, %zero : i32
      vm.cond_br %9, ^bb3, ^bb4(%zero : i32)
    ^bb3:  // pred: ^bb2
      %_utf8_hal_executable_format_E03EECB63A2AAF52 = vm.const.ref.rodata @_utf8_hal_executable_format_E03EECB63A2AAF52 : !vm.buffer
      %_utf8_embedded_elf_x86_64_FF16E34B4A5F9C83 = vm.const.ref.rodata @_utf8_embedded_elf_x86_64_FF16E34B4A5F9C83 : !vm.buffer
      %10:2 = vm.call @hal.device.query.i64(%ref, %_utf8_hal_executable_format_E03EECB63A2AAF52, %_utf8_embedded_elf_x86_64_FF16E34B4A5F9C83) {nosideeffects} : (!vm.ref<!hal.device>, !vm.buffer, !vm.buffer) -> (i32, i64)
      %nz_3 = vm.cmp.nz.i64 %10#1 : i64
      %11 = vm.select.i32 %10#0, %nz_3, %zero : i32
      vm.br ^bb4(%11 : i32)
    ^bb4(%12: i32):  // 2 preds: ^bb2, ^bb3
      %eq = vm.cmp.eq.i64 %3, %zero_0 : i64
      %13 = vm.select.i64 %12, %c1_1, %zero_0 : i64
      %14 = vm.add.i64 %3, %13 : i64
      %15 = vm.and.i32 %12, %eq : i32
      %ref_4 = vm.select.ref %15, %ref, %null_2 : !vm.ref<!hal.device>
      %16 = vm.add.i64 %2, %c1_1 : i64
      vm.br ^bb1(%16, %14, %ref_4 : i64, i64, !vm.ref<!hal.device>)
    ^bb5:  // pred: ^bb1
      vm.discard.refs %null_2 : !vm.ref<!hal.device>
      vm.cond_br %5, ^bb6, ^bb7
    ^bb6:  // pred: ^bb5
      vm.discard.refs %null, %4 : !vm.buffer, !vm.ref<!hal.device>
      vm.fail %c18, "HAL device `__device_0` not found or unavailable: #hal.device.target<\22local\22, [#hal.executable.target<\22llvm-cpu\22, \22embedded-elf-x86_64\22, {cpu = \22tigerlake\22, cpu_features = \22+64bit,+adx,+aes,-amx-avx512,-amx-bf16,-amx-complex,-amx-fp16,-amx-fp8,-amx-int8,-amx-movrs,-amx-tf32,-amx-tile,+avx,-avx10.1,-avx10.2,+avx2,-avx512bf16,+avx512bitalg,+avx512bw,+avx512cd,+avx512dq,+avx512f,-avx512fp16,+avx512ifma,+avx512vbmi,+avx512vbmi2,+avx512vl,+avx512vnni,+avx512vp2intersect,+avx512vpopcntdq,-avxifma,-avxneconvert,-avxvnni,-avxvnniint16,-avxvnniint8,+bmi,+bmi2,-ccmp,-cf,-cldemote,+clflushopt,+clwb,-clzero,+cmov,-cmpccxadd,+crc32,+cx16,+cx8,-egpr,-enqcmd,+f16c,+fma,-fma4,+fsgsbase,+fxsr,+gfni,-hreset,+invpcid,-kl,-lwp,+lzcnt,+mmx,+movbe,+movdir64b,+movdiri,-movrs,-mwaitx,-ndd,-nf,+pclmul,-pconfig,-pku,+popcnt,-ppx,-prefetchi,+prfchw,-ptwrite,-push2pop2,-raoint,+rdpid,-rdpru,+rdrnd,+rdseed,-rtm,+sahf,-serialize,-sgx,+sha,-sha512,+shstk,-sm3,-sm4,+sse,+sse2,+sse3,+sse4.1,+sse4.2,-sse4a,+ssse3,-tbm,-tsxldtrk,-uintr,-usermsr,+vaes,+vpclmulqdq,-waitpkg,-wbnoinvd,-widekl,-xop,+xsave,+xsavec,+xsaveopt,+xsaves,-zu\22, data_layout = \22e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128\22, iree.encoding.resolver = #iree_cpu.cpu_encoding_resolver<>, max_stack_allocation_size = 32768 : i64, native_vector_size = 64 : i64, target_triple = \22x86_64-unknown-unknown-eabi-elf\22}>]>"
    ^bb7:  // pred: ^bb5
      %_utf8_hal_executable_format_E03EECB63A2AAF52_5 = vm.const.ref.rodata @_utf8_hal_executable_format_E03EECB63A2AAF52 : !vm.buffer
      %_utf8_embedded_elf_x86_64_FF16E34B4A5F9C83_6 = vm.const.ref.rodata @_utf8_embedded_elf_x86_64_FF16E34B4A5F9C83 : !vm.buffer
      %17:2 = vm.call @hal.device.query.i64(%4, %_utf8_hal_executable_format_E03EECB63A2AAF52_5, %_utf8_embedded_elf_x86_64_FF16E34B4A5F9C83_6) {nosideeffects} : (!vm.ref<!hal.device>, !vm.buffer, !vm.buffer) -> (i32, i64)
      %nz_7 = vm.cmp.nz.i64 %17#1 : i64
      %18 = vm.select.i32 %17#0, %nz_7, %zero : i32
      %19 = vm.select.i64 %18, %zero_0, %c-1 : i64
      %eq_8 = vm.cmp.eq.i64 %19, %zero_0 : i64
      vm.global.store.ref %4, @__device_0 : !vm.ref<!hal.device>
      vm.cond_br %eq_8, ^bb8, ^bb9
    ^bb8:  // pred: ^bb7
      %matmul_dispatch_0_embedded_elf_x86_64 = vm.const.ref.rodata @matmul_dispatch_0_embedded_elf_x86_64 : !vm.buffer
      %ref_9 = vm.call @hal.executable.create(%4, %c-1, %_utf8_embedded_elf_x86_64_FF16E34B4A5F9C83_6, %matmul_dispatch_0_embedded_elf_x86_64, %null) {nosideeffects} : (!vm.ref<!hal.device>, i64, !vm.buffer, !vm.buffer, !vm.buffer) -> !vm.ref<!hal.executable>
      vm.global.store.ref %ref_9, @__device_0_executable_0_matmul_dispatch_0 : !vm.ref<!hal.executable>
      %ref_10 = vm.call @__matmul_memoize_apply() : () -> !vm.ref<!hal.command_buffer>
      vm.global.store.ref %ref_10, @__matmul_memoize_result_0_device_0 : !vm.ref<!hal.command_buffer>
      vm.return
    ^bb9:  // pred: ^bb7
      vm.discard.refs %null, %4, %_utf8_embedded_elf_x86_64_FF16E34B4A5F9C83_6 : !vm.buffer, !vm.ref<!hal.device>, !vm.buffer
      vm.fail %c14, "HAL device `__device_0` does not support any variant of executable `matmul_dispatch_0`; available formats: [embedded-elf-x86_64]"
    }
  }
}
