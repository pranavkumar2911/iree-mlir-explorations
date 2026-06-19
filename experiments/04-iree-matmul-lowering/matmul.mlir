// A 64x64 fp32 matmul expressed at the linalg dialect level.
// This is the *structured* form: the compiler sees "matmul",
// not an inscrutable triple loop.

func.func @matmul(%A: tensor<64x64xf32>,
                  %B: tensor<64x64xf32>) -> tensor<64x64xf32> {
    %cst = arith.constant 0.0 : f32
    %init = tensor.empty() : tensor<64x64xf32>
    %zeroed = linalg.fill ins(%cst : f32) outs(%init : tensor<64x64xf32>) -> tensor<64x64xf32>
    %result = linalg.matmul
        ins(%A, %B : tensor<64x64xf32>, tensor<64x64xf32>)
        outs(%zeroed : tensor<64x64xf32>) -> tensor<64x64xf32>
    return %result : tensor<64x64xf32>
}