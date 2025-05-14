#include <stdio.h>
#include <stdlib.h>

#define N 64
#define M 64
#define K 64

int main() {
    double A[N][K];
    double B[K][M];
    double C[N][M];
    
    // Init
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < K; j++) {
            A[i][j] = (double)rand()/(double)RAND_MAX;
        }
    }
    for (int i = 0; i < K; i++) {
        for (int j = 0; j < M; j++) {
            B[i][j] = (double)rand()/(double)RAND_MAX;
        }
    }
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < M; j++) {
            C[i][j] = 0.0;
        }
    }

    // Matmul
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < M; j++) {
            for (int k = 0; k < K; k++) {
                C[i][j] += A[i][k] * B[k][j];
            }
        }
    }
    
    // Print
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < M; j++) {
            printf("%f ", C[i][j]);
        }
        printf("\n");
    }

    return 0;
}
