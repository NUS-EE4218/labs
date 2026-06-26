#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N 3000  // Adjust for your system (2000–5000 gives clear results)

// Measure elapsed time in seconds
double elapsed(struct timespec start, struct timespec end) {
    return (end.tv_sec - start.tv_sec) +
           (end.tv_nsec - start.tv_nsec) / 1e9;
}

int main() {
    double **A;
    A = malloc(N * sizeof(double *));
    for (int i = 0; i < N; i++) {
        A[i] = malloc(N * sizeof(double));
        for (int j = 0; j < N; j++)
            A[i][j] = (double)(i + j);
    }

    struct timespec start, end;
    double sum = 0.0;

    // Row-major traversal
    clock_gettime(CLOCK_MONOTONIC, &start);
    for (int i = 0; i < N; i++)
        for (int j = 0; j < N; j++)
            sum += A[i][j];
    clock_gettime(CLOCK_MONOTONIC, &end);
    printf("Row-major time: %.3f sec (sum = %.2f)\n", elapsed(start, end), sum);

    // Column-major traversal
    sum = 0.0;
    clock_gettime(CLOCK_MONOTONIC, &start);
    for (int j = 0; j < N; j++)
        for (int i = 0; i < N; i++)
            sum += A[i][j];
    clock_gettime(CLOCK_MONOTONIC, &end);
    printf("Column-major time: %.3f sec (sum = %.2f)\n", elapsed(start, end), sum);

    // Clean up
    for (int i = 0; i < N; i++) free(A[i]);
    free(A);
    return 0;
}

