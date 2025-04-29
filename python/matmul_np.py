import numpy as np

def matmul(A, B):
    return np.dot(A, B)

if __name__ == '__main__':
    A = np.random.rand(64, 64)
    B = np.random.rand(64, 64)

    C = matmul(A, B)
    print(C)
