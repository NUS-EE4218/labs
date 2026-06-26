#define N 2048

void sum_halves(int a[N], int out[1024]) {
#pragma HLS INTERFACE bram port=a
#pragma HLS INTERFACE bram port=out
// #pragma HLS ARRAY_PARTITION variable=a ? factor=?

    for (int i = 0; i < 1024; i++) {
#pragma HLS PIPELINE
        out[i] = (a[i] + a[i + 1024]) / 2;
        // out[i] = (a[i] + a[i + 512] + a[i + 1024]) / 3;
    }
}