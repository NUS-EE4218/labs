# Design Considerations and Tips

Read Lecture notes thoroughly and make sure your code is synthesizable. Your design is ideally an interconnection of templates for the various digital building blocks, rather than a direct expression of your logic. The synthesis manual (UG901) provides a number of templates. In Vivado, Help>Design Hubs>Synthesis, as well as Tools>Language Templates>Verilog/VHDL>Synthesis Constructs could be useful too.

Understand the given templates and testbenches very well. Run the testbench and see the example (addition) functionality. If you don't understand it and if you are trying to modify it, you are flying blind.

Implement your system in a modular, systematic manner. Do not write a C-like code. You should be able to justify all your design choices.

You should be able to tell many cycles it takes for your hardware to complete the operation even before you start writing your code. This is a part of your design, and should be easy to calculate since you know the exact sequence of operations, i.e., what happens in each cycle. You look at the simulation results to *verify* your answer, not to find out the answer.

It might take a bit of time, effort, and frustration before you can come up with good designs and write good synthesizable code. Sometimes, you can't get a better teacher than experience, especially so when it comes to hardware design and HDL coding. Just hang in there, and you will be ok soon. The best bet is to go through the notes and have the hardware in mind while writing the code.

## Design Considerations

### Simulation and Synthesis

- A well-designed **testbench is expected** (not only for this lab but for all hardware parts you implement for EE4218). For the most part, slight modifications to the provided testbench should do.
- **You should do both behavioral simulation as well as post-synthesis functional simulation**. The former runs faster and aids you in debugging functional aspects. The latter simulates the synthesized design, which is slower and harder to debug but is a good indication of whether your design will work on actual hardware. The good news is that post-synthesis functional simulation can be done with no extra effort - the testbench used is the same.
- Your design should be able to synthesize without any unavoidable warnings. You will need to inspect the resource usage details such as the number of slices/LUTs etc. Note that the estimates we get post-synthesis are preliminary estimates, the ones we get post-implementation are accurate figures. We need to do only synthesis for now.

### Arithmetic

- There is no need to implement your own multiplier, you can use the * operator.
- Division by 256 is easy and does not require a division operation. Say you want to divide a 16-bit number P by 256 to get an 8-bit result Q. It is as simple as Q = P[15:8]. This wouldn't have been possible if the scale factor was a power of 10 - humans like decimal number system as we have 10 fingers and it is easier for us to do math modulo 10, computers don't.
- There could be potential advantages in using matrix dimensions which are powers of two. Using powers of two makes certain indexing-related multiplications (and divisions, as noted in the point above) easier - it can be done using shifts. Multiplication by 2^*k*^ is shifting left by *k* positions. Shifting by a constant amount (i.e., when *k* is a constant) does not require any hardware - it is just a matter of wiring / connecting appropriately (hint: the idea is similar to how it was done for division by the 256 above). Shifting by a variable amount (i.e., when *k* is a variable) will require hardware shifters - shifters are still much faster and take less hardware than multiplication/division.
- Elements of the input matrices being between 0 and 127 will guarantee that the result will not exceed the representation range possible with 8-bits. *n*\*127\*127/256, where *n* = 4 is less than 255. In terms of decimal numbers, each number is less than 1/2, so each element of the result will be less than 1. An element being 1 or more will be troublesome, as we have 0 bits to represent the integer part.
- An 8-bit (or any #bit) binary pattern can be used to represent a lot of things, not just integers. For example, it could be an integer between -128 to 127 (signed 8-bit integer), 0 to 255 (unsigned 8-bit integer), 0 to 255/256 (unsigned 0.8 fixed-point format), 0 to 1+127/128 (unsigned 1.7 fixed-point format), -1 to 127/128 (signed 0.7 fixed-point format), a [mini floating-point number](https://en.wikipedia.org/wiki/Minifloat) (in floating-point representation, the position of the point is explicitly encoded as an 'exponent', unlike fixed point where the position of the point is fixed/implicit), a character (ASCII or UTF-8), 2 digits to be displayed on 7-segment LEDs (BCD format), or even the on/off status of 8 lights in a room. As a designer (hardware and/or software), we have to make sure that the operations we perform, the adjustments we make, and the interpretation of results should all be consistent with the representation system we use.

### Memories

- You are allowed to make reasonable changes to the RAM, but the RAM reading should not be made asynchronous.
- You can choose to have a single RAM to store both **A** and **B**, read the appropriate elements later, one at a time, and then operate on them. This will be slower (our current implementation of the RAM allows reading of only one value at a time). However, it is possible to change the RAM design by giving it the ability to read two values simultaneously (dual port).
- You can also Google Block RAMs (also called Dedicated RAMs), Distributed RAMs, and Registers in Xilinx/AMD FPGAs (it is also explained in the [synthesis manual](https://docs.amd.com/r/en-US/ug901-vivado-synthesis)), and how they can be used in your design. It is recommended to use synchronous read for most applications, as it gives you good timing performance.
  - Registers - Can read multiple values asynchronously, that is, we get the data in the specified address location without waiting for a clock edge. High synthesis time, poor timing performance (adds significantly to the critical path), and overall hardware utilization. A number of CLBs are required even for relatively small registers.
  - Block RAM - Can be read only synchronously, that is, we need to give address, and wait for a clock edge before we can read data. Very good timing performance and does not use up CLBs. Up to 2 values can be read in a cycle. Ultra RAM is quite similar in functionality to Block RAMs
  - Distributed RAM - A Xilinx special way of implementing RAM using LUTs. Can be read asynchronously, up to 2 values. Uses up LUTs and timing performance is average. Small synchronous-read memories also may infer BRAMs, with registered outputs. 
- Writes are always synchronous, irrespective of the type of storage used.
- Read up about instantiation vs inference!

### State Machine

- Think about the implications of having a single Read_Inputs state vs splitting it into two states (hint: as is with many things in hardware, it is not easy to tell, but the implications are likely not very big)!
- Having a separate Matrix_Multiply unit is inefficient with respect to performance as well as hardware usage, in comparison with doing everything in the top-level module. That would have allowed you to start computations earlier, and send out the elements of RES as soon as they were computed. However, in practical designs, such inefficiencies are generally tolerated in favor of modularity. Modularity allows for different parts of the hardware to be independently designed, debugged, tested, and improved, possibly by different people or teams. It also allows for modules to be reused across designs, allowing for faster time to market.
- For a coprocessor to be useful in practice, the overhead associated with sending the data from the main memory (system DDR RAM) to the coprocessor local RAM and receiving the results back should be more than compensated by the acceleration provided by the coprocessor. We will do a comparison when we do the project.

## Vivado Simulation, Synthesis, and Debugging Tips

- As a general rule, DO NOT use spaces in the paths for any of your projects / workspaces. This is a good practice not only for Vitis/Vivado, but for a number of hardware and software development tools.
- Go to Tools > Settings > Tool Settings > Text Editor > Tabs and check .use tab character'. This will help keep your code properly indented. There are only two types of people in this world - those who indent their code with tabs, and those who do not know how to indent.
- See the elaborated design (under RTL Analysis) to see if the schematic matches your intended design. Look into the components inferred, inputs and outputs of each block, bit widths, etc.
- Inspect the synthesis report to see if the 'Detailed RTL Component Info' (basic digital building blocks inferred) makes sense.
- Explore other reports too (such as utilization - number of LUTs used etc, timing).
- Synthesize submodules separately to see if they are ok. The synthesis tool is more intelligent than the simulation tool, and the synthesis warnings usually give you very good clues regarding potential issues with your design such as possible wrong connections  (I generally look for synthesis warnings even before I simulate). You should also test the relevant submodules using testbenches if need be (though unnecessary in this particular case unless you modularize further).
- Being familiar with debugging properly, such as running until a breakpoint, running for a specified time, stepping 1 clock at a time (running in 100 ns increments), inspecting the results as well as internal variable values at each instant (using 'Scope' and 'Objects' tabs), etc can save you A LOT of time. Don't try changing one or two lines here and there and try running over and over.
- You can also drag specific objects (variable values, from Scope > Objects, even for internal modules) to the waveform window to inspect them. You will have to press the *Restart* button (Ctrl+Shift+F5), and then *Run for a specified time* (Shift+F2) to see the waveform of the newly added object. There is no need to *Relaunch simulation*.
- You might want to change the radix to hexadecimal or decimal as appropriate in the waveform window. You can also change specific signal to colours other than green which can make it easier to identify.
- You can save the .wcfg file by pressing Ctrl+S when the waveform window is highlighted. Add it to the project when it prompts you. This will allow the radix changes etc. to be saved. 
- When simulating a system with a clock divider / enable, either bypass the clock divider or set the modulus (number of bits for the counter) to a very small value. Otherwise, you might have to wait for 2^26^ cycles (for a 1Hz clock) before you can see the effect of 1 clock edge! This is not applicable to this lab, as you don't have any reason to have a clock divider / enable.
- Vivado (and most EDA tools) allow scripting and automation using Tcl. You can save the various commands from the Tcl Console as a .tcl file and run it! This may be useful for later labs.
- Antivirus programs can mess with simulation as the simulation creates .exe files that Antivirus might view as suspicious.
- Sometimes, the executables run during simulation might not quit cleanly, creating issues with simulation. Closing Vivado and killing all related processes from the Task Manager (Ctrl+Shift+Esc) can help. Worst case, try rebooting your system.
- If it still doesn't work, delete all the files/folders in the project folder *except* <project_name>.xpr, <testbenchname_behav>.wcfg , <project_name>.srcs (assuming that is where your design/simulation sources are, which is the case if you had checked the option 'copy to the project folder' when you added the file).
