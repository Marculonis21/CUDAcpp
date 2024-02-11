#include <cstdlib>
#include <vector>
#include <iostream>

__global__ void VecAdd(float* A, float* B, float* C)
{
    int x = threadIdx.x;
    int y = threadIdx.y;

    C[x+y*32] = x*y;
}

int main()
{
    int N = 32;
    float *a, *b, *c;
    float *a_gpu, *b_gpu, *c_gpu;

    a = (float *) malloc(sizeof(float) * N);
    b = (float *) malloc(sizeof(float) * N);
    c = (float *) malloc(sizeof(float) * N * N);

    for (int i = 0; i < N; ++i) 
    {
        a[i] = i; 
        b[i] = i; 
    }


    cudaMalloc((void **) &a_gpu, sizeof(float) * N);
    cudaMalloc((void **) &b_gpu, sizeof(float) * N);
    cudaMalloc((void **) &c_gpu, sizeof(float) * N * N);

    cudaMemcpy(a_gpu, a, sizeof(float) * N, cudaMemcpyHostToDevice);
    cudaMemcpy(b_gpu, b, sizeof(float) * N, cudaMemcpyHostToDevice);

    dim3 gridDim;
    dim3 blockDim(32,32);
    VecAdd<<<gridDim, blockDim>>>(a_gpu, b_gpu, c_gpu);

    cudaMemcpy(c, c_gpu, sizeof(float) * N * N, cudaMemcpyDeviceToHost);

    for (int y = 0; y < N; ++y) 
    {
        for (int x = 0; x < N; ++x) 
        {
            std::cout << c[x+y*32] << "|";
        }
        std::cout << std::endl;
    }

    free(a);
    free(b);
    free(c);

    cudaFree(a_gpu);
    cudaFree(b_gpu);
    cudaFree(c_gpu);
}

