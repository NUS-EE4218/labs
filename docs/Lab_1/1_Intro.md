# Introduction to Hardware Design



## Introduction

The purpose of Lab 1 is to introduce you to systematic hardware design. The lab has a refresher of the hardware design flow from EE2026. **Lab 1 can be done on any version of Vivado/Vitis without issues. Lab 1 does not require the FGPA board - it is pure simulation.**

To learn further, you will be doing an assignment that involves creating a coprocessor for matrix multiplication. Testing on real hardware will require a complete computer system (hardware-software co-design framework), which will be introduced in Lab 2. The actual integration will be done in Lab 3. When integrated into the system, the main processor can just stream the data to be processed to the coprocessor, which will do the computations and stream the results back to the main processor.

## Creating and Simulating HDL Sources and Programming FPGA

Those who are already familiar with Vivado and FPGA implementation can skip this step and go straight to the assignment problem. Others can refer to the [CS2100DE Lab 1](https://nus-cs2100de.github.io/labs/manuals/01/lab_01/) manual, which contains step-by-step instructions for the creation of HDL files, simulation, and FPGA implementation. The FPGA used in this course is different from that used in CS2100DE, so the input/output pin numbers to be used in the .xdc file are different.

## Assignment 1

Assignment #1 is a homework exercise and carries 7 marks. It involves the creation of an accelerator IP for matrix multiplication.

The accelerator IP that we create needs to be interfaced with the rest of the system for the processor to make it act as a coprocessor. The interface of an accelerator can be

- Register-based: The processor can read and write the registers within the coprocessor to write inputs/read outputs - each register has an address within the address space of the processor. The parameters and return values are mapped to these registers/addresses. For example, A is in the offset range 0xx to 0xyy - the actual address range is the base address of the coprocessor peripheral (assigned in Vivado under the address tab) + the offset. The coprocessor in this case has an AXI or AXI Lite interface which can be connected to the AXI bus of the system as a slave.
- Stream-based: There are separate input and output streams through which the data is streamed in/out. There is no concept of addresses, and the meaning of the data is derived from the order of the data (and possibly some 'tags'). For example, the first 512 words correspond to A, the next 64 correspond to B, and so on. Please read the Introduction to AXI Stream below.
- Memory-based: The co-processor reads inputs from / writes output to memory directly.

For now, we will start with Stream-based which is perhaps the easiest to get started.

### Introduction to AXI Stream

The hardware we are going to develop makes use of the Advanced eXtensible Interface (AXI) Stream interface to simplify the data receiving and sending processes. The AXI-Stream (AXIS) channels are 32-bit synchronous, master-slave, simplex (uni-directional flow of data per channel), point-to-point (only 2 devices are involved - no addressing needed) communication interfaces. A typical coprocessor needs one AXIS channel for inputs (AXIS Slave) and one AXIS channel for outputs (AXIS Master).

To see more on AXIS: <http://www.xilinx.com/support/documentation/ip_documentation/ug761_axi_reference_guide.pdf>

![image.png](Intro/AXIS_waveform.png)

The AXIS bus protocol is illustrated below (taken from the document in the link above).

Data transfer is always from a Master interface to a Slave interface. This means a hardware block will receive data (input) through its slave interface (let's call it S_AXIS), and send data (output) through its master interface (let's call it M_AXIS).

**TVALID** is an indication from the master to the slave that the data placed by the master on **TDATA** is valid.

**TREADY** is an indication from slave to master that the slave is willing to accept data. The slave should capture the data at the very next active clock edge if TVALID and TREADY are both true. However, the master is not obliged to send any data simply because TREADY is asserted by the slave.

**TLAST** is an indication from the master to slave that the current data word is the last. TLAST is considered a sideband signal and is optional for AXIS. All the other signals mentioned above are essential signals for AXIS. It is useful in scenarios where the slave doesn't know exactly how many data words are sent by the master and is required if the slave is AXI Stream FIFO or AXI DMA, as these IPs (we will see in Lab 3) expect it.

### AXIS Matrix Multiplication Coprocessor

Let **A** be an *m* × *n* matrix of your choice, containing elements between 0 and 127, each value represented as an 8-bit unsigned number. The coprocessor receives the elements of **A** as 32-bit numbers, of which the most significant 24-bits are 0sᶿ, one element per clock cycle through S_AXIS_DATA following the AXIS  bus protocol. You can assume a [row-major order](https://en.wikipedia.org/wiki/Row-_and_column-major_order), i.e., the first *n* values received are elements of the first row, the next *n* values elements of the second row, and so on. For now, let us assume that *m* = 2 and *n* = 4.

Let **B** be an *n* × *1* matrix of your choice, received through S_AXIS_DATA in a similar manner as **A**, after all the elements of **A** have been received. In other words, the first *m*\**n* elements belong to matrix **A**, and the next *n* elements belong to matrix **B**.

The coprocessor needs to find the product of **A** and **B** and divide it by 256. i.e **RES** =**(A** \* **B) / 256**. Naturally, **RES** has to be an *m* × 1 matrix.

The elements of **RES** should be sent out of the coprocessor through M_AXIS_DATA following the AXIS  bus protocol, one element per clock.

The system should be able to operate continuously. Soon after (doesn't necessarily mean the very next clock cycle; within 2-4 clock cycles is ok), the coprocessor should be able to receive the next set of inputs, i.e., the next **A** and **B** without the need to assert an external reset.

ᶿIn fact, the most significant 25 bits are 0s since the number is between 0 and 127. However, let us just stick to the principle that we are dealing with an 8-bit unsigned number. Think of the values you send as representing the fractional part alone in unsigned fixed-point notation (0.8 - 0 bits for the integer part and 8 bits for the fractional part), i.e., using an implicit scale factor of 256. This requires us to adjust the position of the point by dividing by the scale factor after multiplication. This adjustment is unnecessary for addition and subtraction. Does this ring a bell? In EE/CG2028 Assignment #1, you used a scale factor to avoid dealing with fractions. Same story here; the scale factor is 256 instead of a power of 10.

### Coprocessor Logic

- You need to have two RAMs - one each for **A** and **B**, and one element of either **A** or **B** can be populated with the incoming element through S_AXIS_TDATA in the 'Read_Inputs' state. You can also split the 'Read_Inputs' state into two separate states for storing A and B.
- Once all the values have been stored into **A** and **B** RAM(s), you will need to assert the 'Start' signal to the Matrix_Multiply unit.
- The Matrix_Multiply unit reads **A** and **B** RAMs and computes the product/256, element by element. Each element of the result is written into the appropriate location in the **RES** RAM. Matrix_Multiply will assert a 'Done' signal when the computation has finished.
- You will need to populate the 'Compute' state during which your coprocessor waits for the 'Done' signal from the Matrix_Multiply unit.
- Once the 'Done' is received from Matrix_Multiply unit, the contents of **RES** RAM should be sent out through M_AXIS_TDATA in 'Write_Outputs' state.
- After this, the system goes back to 'Idle' state. Note that you do not have to reset the RAM contents. However, other counters, etc might need to be reset.
- 'Start' and 'Done' can be implemented /assumed to last for exactly one cycle.

### Design Considerations

- There is no need to implement your own multiplier, you can use the * operator.
- Division by 256 is easy and does not require a division operation. Say you want to divide a 16-bit number P by 256 to get an 8-bit result Q. It is as simple as Q = P[15:8]. This wouldn't have been possible if the scale factor was a power of 10 - humans like decimal number system as we have 10 fingers and it is easier for us to do math modulo 10, computers don't.
- There could be potential advantages in using matrix dimensions which are powers of two. Using powers of two makes certain indexing-related multiplications (and divisions, as noted in the point above) easier - it can be done using shifts. Multiplication by 2*^k^* is shifting left by *k* positions. Shifting by a constant amount (i.e., when *k* is a constant) does not require any hardware - it is just a matter of wiring / connecting appropriately (hint: the idea is similar to how it was done for division by the 256 above). Shifting by a variable amount (i.e., when *k* is a variable) will require hardware shifters - shifters are still much faster and take less hardware than multiplication/division.
- You are allowed to make reasonable changes to the RAM, but the RAM reading should not be made asynchronous.
- You can choose to have a single RAM to store both **A** and **B**, read the appropriate elements later, one at a time, and then operate on them. This will be slower (our current implementation of the RAM allows reading of only one value at a time). However, it is possible to change the RAM design by giving it the ability to read two values simultaneously (dual port).
- You can also Google Block RAMs (also called Dedicated RAMs), Distributed RAMs, and Registers in Xilinx/AMD FPGAs (it is also explained in the [synthesis manual](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_2/ug901-vivado-synthesis.pdf)), and how they can be used in your design. It is recommended to use synchronous read for most applications, as it gives you good timing performance.
  - Registers - Can read multiple values asynchronously, that is, we get the data in the specified address location without waiting for a clock edge. High synthesis time, poor timing performance (adds significantly to the critical path), and overall hardware utilization. A number of CLBs are required even for relatively small registers.
  - Block RAM - Can be read only synchronously, that is, we need to give address, and wait for a clock edge before we can read data. Very good timing performance and does not use up CLBs. Up to 2 values can be read in a cycle. Ultra RAM is quite similar in functionality to Block RAMs
  - Distributed RAM - A Xilinx special way of implementing RAM using LUTs. Can be read asynchronously, up to 2 values. Uses up LUTs and timing performance is average. Small synchronous-read memories also may infer BRAMs, with registered outputs. 
- Writes are always synchronous, irrespective of the type of storage used.
- Read up about instantiation vs inference!
- Think about the implications of having a single Read_Inputs state vs splitting it into two states (hint: as is with many things in hardware, it is not easy to tell, but the implications are likely not very big)!
- Implement your system in a modular, systematic manner. Do not write a C-like code. You should be able to justify all your design choices.
- How many cycles does it take for your hardware to complete the operation? Note: You should be able to calculate this based on your design (since you know the exact sequence of operations, i.e., what happens in each cycle), without having to look at your simulation result (you look at the simulation results to *verify* it).
- A well-designed **testbench is expected** (not only for this lab but for all hardware parts you implement for EE4218). For the most part, slight modifications to the provided testbench should do.
- Your design should be able to synthesize without any unavoidable warnings. You will need to inspect the resource usage details such as the number of slices/LUTs etc. Note that the estimates we get post-synthesis are preliminary estimates, the ones we get post-implementation are accurate figures. We need to do only synthesis for now.
- **You should do both behavioral simulation as well as post-synthesis functional simulation**. The former runs faster and aids you in debugging functional aspects. The latter simulates the synthesized design, which is slower and harder to debug but is a good indication of whether your design will work on actual hardware. The good news is that post-synthesis functional simulation can be done with no extra effort - the testbench used is the same.
- Your design should be such that it is easy to change matrix dimensions (*m* and *n*) with minimal effort. Ideally, it should be parameterized, but at the least should be designed in a flexible enough manner. The second dimension for B can be fixed to 1 for simplicity.
- Having a separate Matrix_Multiply unit is inefficient with respect to performance as well as hardware usage, in comparison with doing everything in the top-level module. That would have allowed you to start computations earlier, and send out the elements of RES as soon as they were computed. However, in practical designs, such inefficiencies are generally tolerated in favor of modularity. Modularity allows for different parts of the hardware to be independently designed, debugged, tested, and improved, possibly by different people or teams. It also allows for modules to be reused across designs, allowing for faster time to market.
- For a coprocessor to be useful in practice, the overhead associated with sending the data from the main memory (system DDR RAM) to the coprocessor local RAM and receiving the results back should be more than compensated by the acceleration provided by the coprocessor. We will do a comparison when we do the project.
- Elements of the input matrices being between 0 and 127 will guarantee that the result will not exceed the representation range possible with 8-bits. *n*\*127\*127/256, where *n* = 4 is less than 255. In terms of decimal numbers, each number is less than 1/2, so each element of the result will be less than 1. An element being 1 or more will be troublesome, as we have 0 bits to represent the integer part.
- An 8-bit (or any #bit) binary pattern can be used to represent a lot of things, not just integers. For example, it could be an integer between -128 to 127 (signed 8-bit integer), 0 to 255 (unsigned 8-bit integer), 0 to 255/256 (unsigned 0.8 fixed-point format), 0 to 1+127/128 (unsigned 1.7 fixed-point format), -1 to 127/128 (signed 0.7 fixed-point format), a [mini floating-point number](https://en.wikipedia.org/wiki/Minifloat) (in floating-point representation, the position of the point is explicitly encoded as an 'exponent', unlike fixed point where the position of the point is fixed/implicit), a character (ASCII or UTF-8), 2 digits to be displayed on 7-segment LEDs (BCD format), or even the on/off status of 8 lights in a room. As a designer (hardware and/or software), we have to make sure that the operations we perform, the adjustments we make, and the interpretation of results should all be consistent with the representation system we use.

### Files / Templates

You can find all lab 1 files [here](https://github.com/NUS-EE4218/labs/tree/main/Lab_1)

- myip_v1_0.v / myip_v1_0.vhd - top-level module implementing the AXIS coprocessor. Currently, it simply takes in 4 words over 4 cycles and returns their sum, sum+1, sum+2, and sum+3 over 4 cycles. You need to modify this appropriately to interact with RAMs and Matrix_Multiply unit. You should not modify the inputs/outputs of myip_v1_0.v / myip_v1_0.vhd, as they should follow the AXIS standard. Synthesizing this will yield 56 warnings (could change slightly depending on the version of the tool) which are expected since memory and matrix multiply units are not used in the template code.

- memory_RAM.v / memory_RAM.vhd - memory to implement **A**, **B,** and **RES**. There is no need to modify this. It should be used as a component (you will need one instance for each RAM, with appropriate parameters used for width and depth) in myip_v1_0.v. It is fine to modify it if you really want to, as long as the read is synchronous.

- matrix_multiply.v /  matrix_multiply.vhd - a skeleton template for the actual matrix multiplication. Upon receiving the 'Start' signal, it reads from **A** and **B** RAMs, performs the fixed point multiplication, writes the result to **RES** RAM, and then asserts the 'Done' signal. This needs to be implemented properly and should be used as a component in myip_v1_0.v.

- test_input.mem - test vector input to the coprocessor; used by the testbench (tb_myip_v1_0.v). The numbers in the file should be in hex (2 hex digits = 8 bits).

- test_result_expected.mem - expected output to validate the output given by the coprocessor; used by the testbench (tb_myip_v1_0.v/vhd). The numbers in the file should be in hex (2 hex digits = 8 bits).

- tb_myip_v1_0.v / tb_myip_v1_0.vhd - a self-checking testbench for the coprocessor (myip_v1_0). It tests the addition functionality as mentioned in the description for the original myip_v1_0.v/vhd above.

It reads in an input vector from test_input.mem and passes it to the coprocessor, gets the result vector from the coprocessor, and compares it with the expected result vector in the file test_result_expected.mem. The testbench does this for two different test vectors (cases). If the actual result vector tallies with the expected result vector for both the test vectors (cases), it will print a message 'Test Passed', else, it prints 'Test Failed'. Note that in this example, the input vector, result vector, and expected result vector are all having 4 elements per test case.

You can add the .mem files to the project and Vivado will automatically recognize it as a memory file and will add it under Simulation Sources > Memory File. Alternatively (i.e., instead of adding it to the project), you can specify the full path to the files in the testbench - use forward slashes for the path to the test files, even on Windows, kind of like URLs.​

The testbench can be modified very easily to test the matrix multiplication coprocessor. You will also need to change the input and output .mem files appropriately. For each test case, you need to have a vector of 12 elements (8 for A and 4 for B) for input, and the expected result vector will have 2 elements (RES).

Verilog and VHDL files can be freely mixed. For example, you can use memory_RAM.v instead of memory_RAM.vhd as a component of myip_v1_0.vhd.

## General Tips

- As a general rule, DO NOT use spaces in the paths for any of your projects / workspaces. This is a good practice not only for Vitis/Vivado, but for a number of hardware and software development tools.
- Understand the given templates and testbenches very well. Run the testbench and see the example (addition) functionality. If you don't understand it and if you are trying to modify it, you are flying blind.
- Go to Tools > Settings > Tool Settings > Text Editor > Tabs and check .use tab character'. This will help keep your code properly indented. There are only two types of people in this world - those who indent their code with tabs, and those who do not know how to indent.
- Read Lecture notes thoroughly and make sure your code is synthesizable. Your design is ideally an interconnection of templates for the various digital building blocks, rather than a direct expression of your logic. <https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_2/ug901-vivado-synthesis.pdf> provides a number of templates. In Vivado, Help>Design Hubs>Synthesis, as well as Tools>Language Templates>Verilog/VHDL>Synthesis Constructs could be useful too.
- See the elaborated design (under RTL Analysis) to see if the schematic matches your intended design. Look into the components inferred, inputs and outputs of each block, bit widths, etc.
- Inspect the synthesis report to see if the 'Detailed RTL Component Info' (basic digital building blocks inferred) makes sense.
- Explore other reports too (such as utilization - number of LUTs used etc, timing).
- Synthesize submodules separately to see if they are ok. The synthesis tool is more intelligent than the simulation tool, and the synthesis warnings usually give you very good clues regarding potential issues with your design such as possible wrong connections  (I generally look for synthesis warnings even before I simulate). You should also test the relevant submodules using testbenches if need be (though unnecessary in this particular case unless you modularize further).
- Being familiar with debugging properly, such as running until a breakpoint, running for a specified time, stepping 1 clock at a time (running in 100 ns increments), inspecting the results as well as internal variable values at each instant (using 'Scope' and 'Objects' tabs), etc can save you A LOT of time. Don't try changing one or two lines here and there and try running over and over.
- You might want to change the radix to hexadecimal or decimal as appropriate in the waveform window. You can save the .wcfg file by pressing Ctrl+S when the waveform window is highlighted. Add it to the project when it prompts you. This will allow the radix changes etc to be saved. You can also drag specific objects (variable values, from Scope > Objects, even for internal modules) to the waveform window to inspect them. You will have to press the *Restart* button (Ctrl+Shift+F5), and then *Run for a specified time* (Shift+F2) to see the waveform of the newly added object. There is no need to *Relaunch simulation*.
- It might take a bit of time, effort, and frustration before you can write good synthesizable code. Sometimes, you can't get a better teacher than experience, especially so when it comes to writing good HDL code. Just hang in there and you will be ok soon. The best bet is to go through the notes and have the hardware in mind while writing the code.
- When simulating a system with a clock divider / enable, either bypass the clock divider or set the modulus (number of bits for the counter) to a very small value. Otherwise, you might have to wait for 2^26 cycles (for a 1Hz clock) before you can see the effect of 1 clock edge! This is not applicable to this lab, as you don't have any reason to have a clock divider / enable.
- Vivado (and most EDA tools) allow scripting and automation using Tcl. You can save the various commands from the Tcl Console as a .tcl file and run it! This may be useful for later labs.
- Antivirus programs can mess with simulation as the simulation creates .exe files that Antivurs might view as suspicious.
- Sometimes, the executables run during simulation might not quit cleanly, creating issues with simulation. Closing Vivado and killing all related processes from the Task Manager (Ctrl+Shift+Esc) can help. Worst case, try rebooting your system.
- If it still doesn't work, delete all the files/folders in the project folder *except* <project_name>.xpr, <testbenchname_behav>.wcfg , <project_name>.srcs (assuming that is where your design/simulation sources are, which is the case if you had checked the option 'copy to the project folder' when you added the file).

## Submission Info

Demonstrate during your designated slot in **Week 5**.
Upload a very short (<=2 pages) report explaining your system architecture, FSM, resource usage details such as the number of slices/LUTs, etc., as well as the relevant .v/.vhd (RTL and testbenches) and .txt/.mem files (i.e., only those files you have created/modified, not the entire project folder) **used for the demo** (not modified to fix issues that became apparent during the demo) to Canvas within 1 hour of your demo. It should be as a .zip archive, with the filename Wed/Fri_GroupNum_Lab1.zip.
