#include <cuda_runtime.h>
#include <stdio.h>
#include <stdlib.h>

#define TILE_SIZE 16

inline void gpuAssert(cudaError_t code, const char *file, int line, bool abort = true) {
    if (code != cudaSuccess) {
        fprintf(stderr, "CUDA error: %s %s %d\n", cudaGetErrorString(code), file, line);
        if (abort) exit(code);
    }
}

__global__ void matrixMulKernel(float *A, float *B, float *C, int N) {
    __shared__ float sharedA[TILE_SIZE][TILE_SIZE];
    __shared__ float sharedB[TILE_SIZE][TILE_SIZE];

    int tx = threadIdx.x, ty = threadIdx.y;
    int row = blockIdx.y * TILE_SIZE + ty;
    int col = blockIdx.x * TILE_SIZE + tx;
    float sum = 0.0f;

    for (int t = 0; t < (N + TILE_SIZE - 1) / TILE_SIZE; t++) {
        if (row < N && t * TILE_SIZE + tx < N)
            sharedA[ty][tx] = A[row * N + t * TILE_SIZE + tx];
        else
            sharedA[ty][tx] = 0.0f;

        if (col < N && t * TILE_SIZE + ty < N)
            sharedB[ty][tx] = B[(t * TILE_SIZE + ty) * N + col];
        else
            sharedB[ty][tx] = 0.0f;

        __syncthreads();

        for (int k = 0; k < TILE_SIZE; k++) {
            sum += sharedA[ty][k] * sharedB[k][tx];
        }

        __syncthreads();
    }

    if (row < N && col < N)
        C[row * N + col] = sum;
}

void matrixMultiply(float *h_A, float *h_B, float *h_C, int N) {
    float *d_A, *d_B, *d_C;
    size_t size = N * N * sizeof(float);

    cudaMalloc(&d_A, size);
    cudaMalloc(&d_B, size);
    cudaMalloc(&d_C, size);

    cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);

    dim3 blockSize(TILE_SIZE, TILE_SIZE);
    dim3 gridSize((N + TILE_SIZE - 1) / TILE_SIZE, (N + TILE_SIZE - 1) / TILE_SIZE);

    matrixMulKernel<<<gridSize, blockSize>>>(d_A, d_B, d_C, N);

    cudaDeviceSynchronize();
    gpuAssert(cudaGetLastError(), __FILE__, __LINE__);

    cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);

    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);
}

int main() {
    int N = 64; // Matrix size
    size_t size = N * N * sizeof(float);

    float *h_A = (float *)malloc(size);
    float *h_B = (float *)malloc(size);
    float *h_C = (float *)malloc(size);

    for (int i = 0; i < N * N; i++) {
        h_A[i] = rand() % 10;
        h_B[i] = rand() % 10;
    }

    matrixMultiply(h_A, h_B, h_C, N);

    printf("Result matrix:\n");
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            printf("%0.1f ", h_C[i * N + j]);
        }
        printf("\n");
    }

    free(h_A);
    free(h_B);
    free(h_C);

    return 0;
}
