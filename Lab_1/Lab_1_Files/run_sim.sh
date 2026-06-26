#!/bin/bash
cd /home/rajesh/GitHub/EE4218/labs/docs/Lab_1/Lab_1_Files

# Compile
iverilog -o tb_myip_v1_0.out tb_myip_v1_0.v myip_v1_0.v memory_RAM.v matrix_multiply.v

# Run with VCD dump and timeout
timeout 60 vvp tb_myip_v1_0.out -vcd 2>&1
echo "Exit code: $?"