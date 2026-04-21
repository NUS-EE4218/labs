// matmul_coalescing.c
// Compare coalesced vs non-coalesced GPU memory access + OpenMP CPU fallback

#define CL_TARGET_OPENCL_VERSION 120
#include <CL/cl.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#ifdef _OPENMP
#include <omp.h>
#endif

static const char *kernelSource =
"__kernel void matmul_coalesced(const int N, __global const float* A, __global const float* B, __global float* C) {\n"
"    int row = get_global_id(1);\n"
"    int col = get_global_id(0);\n"
"    if(row >= N || col >= N) return;\n"
"    float sum = 0.0f;\n"
"    for(int k=0; k<N; k++) sum += A[row*N + k] * B[k*N + col];\n"
"    C[row*N + col] = sum;\n"
"}\n"
"__kernel void matmul_noncoalesced(const int N, __global const float* A, __global const float* B, __global float* C) {\n"
"    int row = get_global_id(1);\n"
"    int col = get_global_id(0);\n"
"    if(row >= N || col >= N) return;\n"
"    float sum = 0.0f;\n"
"    for(int k=0; k<N; k++) sum += A[k*N + row] * B[col*N + k];\n"
"    C[row*N + col] = sum;\n"
"}\n";

static double time_diff_ms(struct timespec a, struct timespec b) {
    return (a.tv_sec - b.tv_sec) * 1000.0 + (a.tv_nsec - b.tv_nsec) / 1.0e6;
}

void fill_rand(float *M, int N) {
    for(int i=0;i<N*N;i++) M[i] = (float)(rand()%100)/10.0f;
}

void matmul_cpu_omp(const float *A, const float *B, float *C, int N){
#ifdef _OPENMP
    #pragma omp parallel for collapse(2)
#endif
    for(int i=0;i<N;i++)
        for(int j=0;j<N;j++){
            float sum=0.0f;
            for(int k=0;k<N;k++) sum+=A[i*N+k]*B[k*N+j];
            C[i*N+j]=sum;
        }
}

// Run a single kernel and return kernel execution time
double run_kernel(cl_device_id dev, const char *kernel_name, int N, float *A, float *B, float *C){
    cl_int err;
    cl_context context = clCreateContext(NULL,1,&dev,NULL,NULL,&err);
    cl_command_queue queue = clCreateCommandQueue(context, dev, CL_QUEUE_PROFILING_ENABLE, &err);
    cl_program program = clCreateProgramWithSource(context,1,&kernelSource,NULL,&err);
    clBuildProgram(program,1,&dev,"",NULL,NULL);
    cl_kernel kernel = clCreateKernel(program, kernel_name, &err);

    size_t bytes = (size_t)N*N*sizeof(float);
    cl_mem bufA = clCreateBuffer(context,CL_MEM_READ_ONLY,bytes,NULL,&err);
    cl_mem bufB = clCreateBuffer(context,CL_MEM_READ_ONLY,bytes,NULL,&err);
    cl_mem bufC = clCreateBuffer(context,CL_MEM_WRITE_ONLY,bytes,NULL,&err);

    clEnqueueWriteBuffer(queue,bufA,CL_TRUE,0,bytes,A,0,NULL,NULL);
    clEnqueueWriteBuffer(queue,bufB,CL_TRUE,0,bytes,B,0,NULL,NULL);

    clSetKernelArg(kernel,0,sizeof(int),&N);
    clSetKernelArg(kernel,1,sizeof(cl_mem),&bufA);
    clSetKernelArg(kernel,2,sizeof(cl_mem),&bufB);
    clSetKernelArg(kernel,3,sizeof(cl_mem),&bufC);

    size_t global[2] = { (size_t)N, (size_t)N };
    size_t local[2] = { 16,16 }; // simple fixed local size
    cl_event k_event;

    clEnqueueNDRangeKernel(queue,kernel,2,NULL,global,local,0,NULL,&k_event);
    clFinish(queue);
    clEnqueueReadBuffer(queue,bufC,CL_TRUE,0,bytes,C,0,NULL,NULL);

    cl_ulong start,end;
    clGetEventProfilingInfo(k_event,CL_PROFILING_COMMAND_START,sizeof(start),&start,NULL);
    clGetEventProfilingInfo(k_event,CL_PROFILING_COMMAND_END,sizeof(end),&end,NULL);
    double kernel_ms = (end-start)*1.0e-6;

    clReleaseMemObject(bufA); clReleaseMemObject(bufB); clReleaseMemObject(bufC);
    clReleaseKernel(kernel); clReleaseProgram(program); clReleaseCommandQueue(queue); clReleaseContext(context); clReleaseEvent(k_event);

    return kernel_ms;
}

// Find first GPU device
cl_device_id find_gpu(){
    cl_uint numPlatforms=0;
    clGetPlatformIDs(0,NULL,&numPlatforms);
    if(numPlatforms==0) return NULL;
    cl_platform_id *platforms=(cl_platform_id*)malloc(sizeof(cl_platform_id)*numPlatforms);
    clGetPlatformIDs(numPlatforms,platforms,NULL);

    cl_device_id dev=NULL;
    for(cl_uint p=0;p<numPlatforms && !dev;p++){
        cl_uint numDevices=0;
        if(clGetDeviceIDs(platforms[p],CL_DEVICE_TYPE_GPU,0,NULL,&numDevices)!=CL_SUCCESS || numDevices==0) continue;
        cl_device_id *devices=(cl_device_id*)malloc(sizeof(cl_device_id)*numDevices);
        clGetDeviceIDs(platforms[p],CL_DEVICE_TYPE_GPU,numDevices,devices,NULL);
        dev=devices[0]; free(devices);
    }
    free(platforms);
    return dev;
}

int main(int argc,char **argv){
    int N=1024;
    if(argc>=2) N=atoi(argv[1]);
    printf("Matrix multiply N=%d\n",N);

    float *A=(float*)malloc(N*N*sizeof(float));
    float *B=(float*)malloc(N*N*sizeof(float));
    float *C=(float*)malloc(N*N*sizeof(float));
    srand(12345); fill_rand(A,N); fill_rand(B,N);

    cl_device_id dev = find_gpu();
    if(dev){
        printf("GPU found. Running coalesced and non-coalesced kernels...\n");
        double t_co = run_kernel(dev,"matmul_coalesced",N,A,B,C);
        double t_non = run_kernel(dev,"matmul_noncoalesced",N,A,B,C);
        printf("Coalesced kernel time: %.3f ms\n",t_co);
        printf("Non-coalesced kernel time: %.3f ms\n",t_non);
        printf("Speedup due to coalescing: %.2fx\n", t_non / t_co);
    } else {
        printf("No GPU found. Running plain C CPU (OpenMP)...\n");
        struct timespec t0,t1;
        clock_gettime(CLOCK_MONOTONIC,&t0);
        matmul_cpu_omp(A,B,C,N);
        clock_gettime(CLOCK_MONOTONIC,&t1);
        double cpu_ms = (t1.tv_sec-t0.tv_sec)*1000.0 + (t1.tv_nsec-t0.tv_nsec)/1.0e6;
        printf("CPU (OpenMP) time: %.3f ms\n",cpu_ms);
    }

    free(A); free(B); free(C);
    return 0;
}

