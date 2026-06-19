// matmul.c is a naive square matrix multiplication.
// Compiling with various ISA flags and inspect the generated assembly
// to see how the compiler vectorizes (or doesn't) for each target.

#include <stddef.h>
#define N 64

void matmul(float A[N][N], float B[N][N], float C[N][N]){
    for(size_t i = 0; i < N; i++){
        for(size_t j = 0; j < N; j++){
            float sum = 0.0f;
            for(size_t k = 0; k < N; k++){
                sum += A[i][k] * B[k][j];
            }
            C[i][j] = sum;
        }
    }
}