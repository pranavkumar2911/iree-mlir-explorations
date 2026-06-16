module {
  util.func public @abs(%arg0: tensor<f32>) -> tensor<f32> {
    %0 = math.absf %arg0 : tensor<f32>
    util.return %0 : tensor<f32>
  }
}
