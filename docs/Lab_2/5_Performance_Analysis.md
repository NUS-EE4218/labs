# Measuring Performance

## AXI Timer

How do we measure the exact time taken to execute a specific segment of software code?

If the application is running on top of an OS (e.g. FreeRTOS), the OS typically provides some sort of system call / software timers. You could use this to log the timestamps at various points in your software code, which allows you to measure the execution times for various segments of your software code. You won't need specialized software tools or hardware (apart from the hardware timer that the OS needs) for this. However, the time resolution you get is typically not very high.

We can also use a dedicated hardware timer to get the precise number of cycles required to execute a segment of software code. The difference between the counter readings before and after the segment of software code you want to analyze will give you the number of cycles, and hence the time taken. It is left entirely to you as a self-learning exercise.  This will require you to integrate an AXI Timer in your hardware (Vivado) and use the appropriate driver functions in Vitis. By now, you should have a hang of things and it should be easy enough as the timer/counter is a pretty simple peripheral. 

Make sure that you do not have any unnecessary code between the two points where you read the counter. For example, printing the first reading of the counter immediately after reading it would be a bad idea.

A couple of hints:

You need only one counter, whereas the timer IP block incorporates 2 counters by default. You can double-click the block in Vivado and uncheck the second one to reduce the hardware usage and synthesis time.
You can get started with the xtmrctr_polled_example project for axis_timer_0 (tmrctr). You can get this from hardware_1_wrapper>platform.spr> Peripheral Drivers section of the Board Support Package. Try running this first, and later integrate the relevant parts into your software C code.

## Profiling

**Optional**

The process of collecting information about a program dynamically (i.e., during runtime) is called profiling. Many IDEs come with some sort of profiling tool.  There are a lot of different approaches to profiling.

A typical way of doing profiling is to sample the program counter through the debug interface, which is supported by Xilinx/AMD tools - the [TCF profiler](https://docs.amd.com/r/en-US/ug1400-vitis-embedded/TCF-Profiling) is very easy to use - please try it out. Based on this, the profiler gives you statistics regarding what fraction (percentage) of time your program spends in each function. Profiling gives you clues regarding which function might be a good candidate for you to spend your time and money on - you wouldn't want to bother much about a function that is not a performance bottleneck. These improvements could be through algorithmic optimizations and/or hardware acceleration. Note: You need to do 'Debug' rather than 'Run' at least once for the profile option to be active. 

Note that you may need to loop the contents of each function (say, loopback_FIFO() vs matrix_multiply()) a huge number of times (after receiving the data just one time via the serial console\*) to get a statistically meaningful comparison between these two when profiling using the TCF profiler.

\* It is a better idea to hardcode the arrays A and B in your program purely for performance analysis. This is so that the time required for receiving the data via serial console (UART) does not dominate. Comment out all printfs or other time-consuming functions that are not relevant to performance analysis - you can do so efficiently via `#define`-`#ifdef`-`#endif`.
