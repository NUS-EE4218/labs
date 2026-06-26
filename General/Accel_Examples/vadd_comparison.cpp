#include <iostream>
#include <chrono>
#include <cstdlib>

// Dummy definitions for HLS headers to enable CPU compilation
#define ap_int int
#define hls_stream int
#pragma HLS INTERFACE
#pragma HLS PIPELINE
#pragma HLS ARRAY_PARTITION

// =============================================
// Original Simple Kernel (Non-burst version)
// =============================================
extern "C" {
void vadd_simple(const int *A, const int *B, int *C, int size) {
#pragma HLS INTERFACE m_axi port=A offset=slave bundle=gmem
#pragma HLS INTERFACE m_axi port=B offset=slave bundle=gmem
#pragma HLS INTERFACE m_axi port=C offset=slave bundle=gmem

#pragma HLS INTERFACE s_axilite port=A bundle=control
#pragma HLS INTERFACE s_axilite port=B bundle=control
#pragma HLS INTERFACE s_axilite port=C bundle=control
#pragma HLS INTERFACE s_axilite port=size bundle=control
#pragma HLS INTERFACE s_axilite port=return bundle=control

    // Main loop
    for (int i = 0; i < size; i++) {
    #pragma HLS PIPELINE II=1
        C[i] = A[i] + B[i];
    }
}
}

// =============================================
// Optimized Burst Kernel
// =============================================
#define MAX_SIZE 1024
#define BURST_LEN 64

void vadd_burst(volatile int* A, volatile int* B, volatile int* C, int N) {
#pragma HLS INTERFACE m_axi port=A offset=slave bundle=gmem0 depth=1024
#pragma HLS INTERFACE m_axi port=B offset=slave bundle=gmem1 depth=1024
#pragma HLS INTERFACE m_axi port=C offset=slave bundle=gmem2 depth=1024
#pragma HLS INTERFACE s_axilite port=N
#pragma HLS INTERFACE s_axilite port=return

    // Local buffers for burst transfers
    int buffer_A[BURST_LEN];
    int buffer_B[BURST_LEN];
    int buffer_C[BURST_LEN];
    
#pragma HLS ARRAY_PARTITION variable=buffer_A complete
#pragma HLS ARRAY_PARTITION variable=buffer_B complete
#pragma HLS ARRAY_PARTITION variable=buffer_C complete

    // Process data in bursts
    burst_loop: for (int base = 0; base < N; base += BURST_LEN) {
        int chunk_size = (base + BURST_LEN > N) ? N - base : BURST_LEN;
        
        // Burst read from A and B
        read_loop: for (int i = 0; i < chunk_size; i++) {
#pragma HLS PIPELINE II=1
            buffer_A[i] = A[base + i];
            buffer_B[i] = B[base + i];
        }
        
        // Compute vector addition
        compute_loop: for (int i = 0; i < chunk_size; i++) {
#pragma HLS PIPELINE II=1
            buffer_C[i] = buffer_A[i] + buffer_B[i];
        }
        
        // Burst write to C
        write_loop: for (int i = 0; i < chunk_size; i++) {
#pragma HLS PIPELINE II=1
            C[base + i] = buffer_C[i];
        }
    }
}

// =============================================
// Main test program with performance comparison
// =============================================
int main() {
    const int TEST_SIZE = 1024;
    
    // Allocate memory
    int* A = new int[TEST_SIZE];
    int* B = new int[TEST_SIZE];
    int* C_simple = new int[TEST_SIZE];
    int* C_burst = new int[TEST_SIZE];
    
    // Initialize test data
    for (int i = 0; i < TEST_SIZE; i++) {
        A[i] = rand() % 1000;
        B[i] = rand() % 1000;
    }
    
    std::cout << "==================================================" << std::endl;
    std::cout << "Vector Addition Performance Comparison" << std::endl;
    std::cout << "Test Size: " << TEST_SIZE << " elements" << std::endl;
    std::cout << "Burst Length: " << BURST_LEN << std::endl;
    std::cout << "==================================================" << std::endl;
    
    // ---------------------------
    // Run SIMPLE kernel
    // ---------------------------
    auto start_simple = std::chrono::high_resolution_clock::now();
    
    vadd_simple(A, B, C_simple, TEST_SIZE);
    
    auto end_simple = std::chrono::high_resolution_clock::now();
    auto duration_simple = std::chrono::duration_cast<std::chrono::nanoseconds>(end_simple - start_simple);
    
    // ---------------------------
    // Run BURST kernel
    // ---------------------------
    auto start_burst = std::chrono::high_resolution_clock::now();
    
    vadd_burst(A, B, C_burst, TEST_SIZE);
    
    auto end_burst = std::chrono::high_resolution_clock::now();
    auto duration_burst = std::chrono::duration_cast<std::chrono::nanoseconds>(end_burst - start_burst);
    
    // ---------------------------
    // Verify results match
    // ---------------------------
    bool match = true;
    for (int i = 0; i < TEST_SIZE; i++) {
        if (C_simple[i] != C_burst[i]) {
            match = false;
            std::cout << "Mismatch at index " << i << ": " << C_simple[i] << " vs " << C_burst[i] << std::endl;
            break;
        }
    }
    
    // ---------------------------
    // Print performance results
    // ---------------------------
    std::cout << std::endl;
    std::cout << "Results Verification: " << (match ? "✅ PASS (both kernels produce identical output)" : "❌ FAIL") << std::endl;
    std::cout << std::endl;
    
    std::cout << "1. Simple Kernel (Single element access):" << std::endl;
    std::cout << "   Execution Time: " << duration_simple.count() << " ns" << std::endl;
    std::cout << "   Throughput: " << (TEST_SIZE * 1000.0 / duration_simple.count()) << " Mops/s" << std::endl;
    std::cout << std::endl;
    
    std::cout << "2. Burst Optimized Kernel:" << std::endl;
    std::cout << "   Execution Time: " << duration_burst.count() << " ns" << std::endl;
    std::cout << "   Throughput: " << (TEST_SIZE * 1000.0 / duration_burst.count()) << " Mops/s" << std::endl;
    std::cout << std::endl;
    
    double speedup = (double)duration_simple.count() / duration_burst.count();
    std::cout << "Performance Speedup: " << speedup << "x" << std::endl;
    std::cout << "==================================================" << std::endl;
    
    // Cleanup
    delete[] A;
    delete[] B;
    delete[] C_simple;
    delete[] C_burst;
    
    return 0;
}