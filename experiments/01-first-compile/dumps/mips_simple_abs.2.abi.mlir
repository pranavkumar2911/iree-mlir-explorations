module {
  util.func public @abs(%arg0: !hal.buffer_view) -> !hal.buffer_view attributes {iree.abi.stub, iree.reflection = {iree.abi.declaration = "sync func @abs(%input0: tensor<f32>) -> (%output0: tensor<f32>)"}} {
    %0 = hal.tensor.import %arg0 "input0" : !hal.buffer_view -> tensor<f32>
    %1 = math.absf %0 : tensor<f32>
    %2 = hal.tensor.export %1 "output0" : tensor<f32> -> !hal.buffer_view
    util.return %2 : !hal.buffer_view
  }
}
