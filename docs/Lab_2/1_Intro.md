# Introduction to Hardware/Software Co-Design

!!! success "Usable"
    This lab description is complete. There could still be minor updates, which will be <span style="color: brown;">highlighted</span>. 

## Introduction

This manual contains step-by-step instructions on how to create a hardware platform that utilizes the ARM Cortex A53 processor in the Kria board (there are four of them; we will be using only one through) and to execute simple C programs on it. The following 4 pages have the details you will need in the process.

[Creating the hardware platform](2_HW_Platform.md) - This page describes how to use Vivado to create a hardware platform using IP Integrator, and to synthesize the hardware into a bitstream. The bitstream is used to configure the FPGA to become the hardware platform that we have created. The bitstream and other hardware info are exported as a .xsa file.

[Software development using Vitis](3_Using_Vitis.md) - This page describes how to use Vitis IDE to create a C program to run on the Cortex A53 processor and interacting with the peripherals we have integrated in the step above. If you are using Vitis version <= 2023.2, please follow the instructions for [Software development using Vitis Classic](3_Using_Vitis_Classic.md) instead.

[Serial Console - RealTerm](4_Serial_Console.md) - This page describes how to use RealTerm, the recommended console program (you are free to use other serial terminal programs or even have your own program for the purpose, e.g., a custom Python code using PySerial library) to send and receive information to the program running on the Cortex A53 processor through UART.

[Performance analysis](5_Performance_Analysis.md) - This page describes some general approaches to performance analysis, as well as the specific approach followed in the assignment, which is using an AXI Timer peripheral as well as (optionally) using TCF-profiler.

## Assignment 2

Assignment #2 is a homework exercise and carries 7 marks.

The template/data files are [here](https://github.com/NUS-EE4218/labs/tree/main/docs/Lab_2/Lab_2_Files).

The matrix **A** is a 64 x 8 matrix given in A.csv (CSV = comma-separated values). The elements of A are in the corresponding ASCII form in A.csv - this is essentially a text file and can be opened using a text editor\*. You can also open it with Excel, which will show it as a table. 

The matrix **B** is an 8 x 1 matrix given in B.csv, encoded in a similar manner as A.csv. 

These two files should be sent from RealTerm (or another terminal program) to your C program running on board. Your C program should 

* **receive matrices A and B** into a local array/arrays (either a single array for A and B together or separate arrays);
* pass it through the AXI Stream FIFO configured in **loopback** mode - no processing done in hardware/PL, for now;
* **compute** the result matrix, **RES** = **A**\***B**/**256**;
* **send RES back** from the board to the PC (RealTerm).

The received result should be **captured into a file** via RealTerm. The name of the file has to be “RES.csv”. You can compare the RES.csv with Labels.csv on your PC using an Excel-like program (i.e., Labels.csv should not be sent to the board). Do you observe any pattern?

Further, you should integrate an **AXI Timer** into your block design, and modify your software C code to report

* the time taken for sending all the data matrices **A** and **B** through the AXI Stream FIFO, and
* the time taken for matrix multiplication (**A**\***B**/**256**).

Some hints on how this can be done is given on the [Performance analysis](5_Performance_Analysis.md) page.

You should do all computations in C on the board using integers. Do not use [floating-point](https://en.wikipedia.org/wiki/Floating-point_error_mitigation) (i.e., variables should not be declared as float).

## Submission Info

Upload the (only those files you have created/modified, not the entire project folder)

* .xsa file
* .c/.h files
* input/output test files
* a text file that mentions the time taken in cycles or milliseconds (you should be able to convert between the two easily anyway) - this info can be copy-pasted from the realterm console to a text file
* a screenshot of the profiling output <span style="color: brown;">(optional, if you have done profiling)</span>
to Canvas by 11:59 PM, **21 Feb 2026**.
You will also be required to do a demonstration in **Week 7** based on what you submitted at the point of the assignment deadline, not the version you may have improved after the deadline.

It should be as a single .zip archive, with the filename GroupNum_Lab2.zip.

## Dataset Description (Optional Read)

Here, we use a modified version of the Wine dataset from [https://archive.ics.uci.edu/ml/datasets/wine](https://archive.ics.uci.edu/ml/datasets/wine). You can read up the description and more if you are interested.

* The original 3-class problem is reduced to a 2-class problem by removing the cases with label 3.
* Some features are also removed, to reduce the feature dimensionality from 13 to 8.
* The original features are normalized to be between \[0, 1), represented using the 0.8-bit fixed point representation we had used in Lab 1.
* You can visualize the data using some easy-to-use programming language such as Python or Matlab ([https://octave-online.net/](https://octave-online.net/) is pretty cool), or even Excel.
* What we do in this lab is essentially the prediction/inference step in machine learning/classification. The classifier is trained using [Fisher's linear discriminant](https://en.wikipedia.org/wiki/Linear_discriminant_analysis) method (matrix **B** in the description above is the weight vector), with some modifications to accommodate the 8-bit format.