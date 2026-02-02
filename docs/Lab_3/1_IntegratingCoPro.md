# Integrating the Coprocessor

Try out [Coprocessor Packaging](2_PackagingIP.md) and [Integration using AXI Stream FIFO](3_FIFO.md) using the original template coprocessor provided in Lab 1 first, before using your version of the Lab 1 coprocessor.

Once you have gotten it to work, please attempt the assignment below.

## Assignment 3

The assignment essentially involves combining Lab 1 and Lab 2, such that the data can be streamed from RealTerm to the C code running on ARM Cortex A53, the processing is done in hardware using the coprocessor, and the results are sent back to RealTerm. You can optionally do the processing in software (C) and compare the results, but the results have to be sent back to the console.

All the required files are [here](https://github.com/NUS-EE4218/labs/tree/main/docs/Lab_3/Lab_3_Files)

Please follow the following procedure.

- Change your Lab 1 HDL code to accommodate the bigger matrix sizes for A, B, and RES (64x8, 8x1, and 64x1 respectively).
- Test it thoroughly (behavioral simulation as well as *post-synthesis functional simulation*) using a well-designed testbench. You will have to modify the .mem files and the testbench to deal with the bigger matrix. Some other cases were not tested by the Lab 1 testbench, such as the non-continuous assertion of S_AXIS_TVALID and M_AXIS_TREADY. Hopefully, these should be fine in your design. AXI FIFO is unlikely to do a non-continuous assertion of these signals, whereas some other peripherals such as AXI DMA are likely to.
- Now, integrate this coprocessor using the same procedure you had followed for the original Lab 1 template coprocessor.  You might want to have a look at the Modifying the Coprocessor page to see how to re-package your modified coprocessor. You will have to modify test_fifo_myip_v1_0.cfile as appropriate. You will need to have either the Transmit FIFO Depth of AXI Stream FIFO set to 1024 (in Vivado), or send it over two transmit operations in C code to send more than 512 words. The first approach will take more hardware but takes less time to send the full data over.
  - Initially, hard code the test cases.
  - Later, you should modify it to deal with the data streamed from RealTerm, just as you did for Lab 2.
- An even better way to wait until the coprocessor responds would be to use interrupts. This requires the AXI FIFO interrupt output to be connected appropriately, with appropriate changes to the program.
- Use the Vitis built-in debugger (TCF-based) to step through your software code, and inspect what is happening at each step, to ensure that the data sent to the co-processor is correct, as well as to inspect the value received from the coprocessor.
- Implementation using AXI DMA is NOT a requirement. However, it is strongly suggested that you try it out. Even if you are not trying it out, you are expected to understand how it works and how it is done.

### Submission Info

Assignment 3 (7 marks)

Demonstrate in **week 7**.

**Upload**

Upload an archive containing only the files you have created/modified such as

- .xsa file
- .c/.h
- .v/.vhd scaled up RTL and testbench
- .xdc file (only if you manually inserted/modified any constraints)
- input/output test files - the .mem files as well as the files sent/received from/by RealTerm (if you modified them)

exactly as used for the demo to Canvas within 1 hour of your demo.

It should be as a .zip archive, with the filename Wed/Fri_GroupNum_Lab3.zip.

Please **DO NOT** upload the whole project - include only the files mentioned above!

### Tips

- Debugging in Lab 3 is hard. It is your hardware, interacting with your software. It is hard to identify and isolate issues.
  - You can check the software functionality by setting breakpoints just before sending data to the coprocessor / just after receiving the data from the coprocessor.
  - If the software appears to be ok, then it is likely your hardware. This can be
    - A missing connection in the block diagram -  'Validate Design' running ok does not guarantee everything is ok. It only checks for some very essential stuff, which might not be good enough for proper functionality.
    - The IP not being updated. Changing the HDL code alone is not sufficient. You need to repackage the IP (see the last part of Packaging the Coprocessor as an IP page to know how to do this). Then try regenerating sources. Worst come to the worst, package the IP afresh.
    - A functional issue with your co-processor. This typically involves not asserting M_AXIS_TLAST and M_AXIS_TVALID correctly, and not dealing with M_AXIS_TREADY properly. Some possible reasons:
      - If you don't get a response from the co-processor, check if M_AXIS_TLAST is asserted properly.
      - If it doesn't respond with the correct amount of data, it could be M_AXIS_TLAST getting asserted at the wrong time.
      - If it responds with incorrect data, check the correspondence between M_AXIS_TVALID and M_AXIS_TDATA.
      - Verify these using **post-synthesis functional simulation**, not just using behavioral simulation.
- You will possibly get a critical warning: "[Timing 38-282] The design failed to meet the timing requirements. Please see the timing summary report for details on the timing violations.".
  - This is not a warning that you should normally ignore. The timing analysis tool is complaining that the design may not work at 100 MHz, i.e. has a critical path greater than 10 ns (possibly in multiplication). You can look at the timing summary and figure out which path causes it to fail the timing. You can then see how this can be fixed, which will involve some design modifications.
