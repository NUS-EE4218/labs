# Introduction to Hardware/Software Co-Design

## Introduction

This manual contains step-by-step instructions on how to create a hardware platform that utilizes the ARM Cortex A53 processor in the Kria board (there are four of them; we will be using only one through) and to execute simple C programs on it. The following 3 pages have the details you will need in the process.

[Creating the hardware platform](2_HW_Platform.md) - This page describes how to use Vivado to create a hardware platform using IP Integrator, and to synthesize the hardware into a bitstream. The bitstream is used to configure the FPGA to become the hardware platform that we have created. The bitstream and other hardware info are exported as a .xsa file.

[Software development using Vitis Classic](3_Using_Vitis_Classic.md) - This page describes how to use Vitis - Eclipse-based IDEs to create a C program to run on the Cortex A53 processor and interacting with the peripherals we have integrated in the step above.

[Serial Console - RealTerm](4_Serial_Console.md) - This page describes how to use RealTerm, the recommended console program (you are free to use other serial terminal programs or even have your own program for the purpose, e.g., a custom Python code using PySerial library) to send and receive information to the program running on the Cortex A53 processor through UART.

## Assignment 2

Assignment #2 is a homework exercise and carries 7 marks.

All the required files are [here](https://github.com/NUS-EE4218/labs/tree/main/docs/Lab_2/Lab_2_Files)

The matrix **A** is a 64 x 8 matrix given in A.csv (CSV = comma-separated values). The elements of A are in the corresponding ASCII form in A.csv - this is essentially a text file and can be opened using a text editor\*. You can also open it with Excel, which will show it as a table. 

The matrix **B** is an 8 x 1 matrix given in B.csv, encoded in a similar manner as A.csv. 

These two files should be sent from RealTerm (or another terminal program) to your C program running on board. Your C program should receive it and compute the result matrix, **RES** = **A**\***B**/**256**. This should be sent back from the board to the PC (RealTerm), where it should be captured into a file. The name of the file has to be “RES.csv”.  

You can compare the RES.csv with Labels.csv on your PC using an Excel-like program (i.e., Labels.csv should not be sent to the board). Do you observe any pattern?

You should do all computations in C on the board using integers. Do not use [floating-point](https://en.wikipedia.org/wiki/Floating-point_error_mitigation) (i.e., variables should not be declared as float).


## Submission Info

Assignment 2 (7 marks)

Demonstrate during **Week 6** lab session.

**Upload**

Upload the .xsa file, C/H, and input/output test files (i.e., only those files you have created/modified, not the entire project folder) **used for the demo** (not modified to fix issues that became apparent during the demo) to Canvas within 1 hour of your demo. It should be as a .zip archive, with the filename Wed/Fri_GroupNum_Lab2.zip.

Please **DO NOT** upload the whole project!

## Dataset Description (Optional Read)

Here, we use a modified version of the Wine dataset from [https://archive.ics.uci.edu/ml/datasets/wine](https://archive.ics.uci.edu/ml/datasets/wine). You can read up the description and more if you are interested.

* The original 3-class problem is reduced to a 2-class problem by removing the cases with label 3.
* Some features are also removed, to reduce the feature dimensionality from 13 to 8.
* The original features are normalized to be between \[0, 1), represented using the 0.8-bit fixed point representation we had used in Lab 1.
* You can visualize the data using some easy-to-use programming language such as Python or Matlab ([https://octave-online.net/](https://octave-online.net/) is pretty cool), or even Excel.
* What we do in this lab is essentially the prediction/inference step in machine learning/classification. The classifier is trained using [Fisher's linear discriminant](https://en.wikipedia.org/wiki/Linear_discriminant_analysis) method (matrix **B** in the description above is the weight vector), with some modifications to accommodate the 8-bit format.

## Tips and Suggestions


You can do most of the testing of your C program logic without accessing the FPGA board. You can run it locally using a C/C++ IDE of your choice (such as  [Visual Studio Code](https://code.visualstudio.com/docs/languages/cpp)) or using an online compiler like [https://www.onlinegdb.com/online\_c\_compiler](https://www.onlinegdb.com/online_c_compiler). Since the typical console (interface) you get cannot send files (such as A.csv and B.csv), you can copy-paste the file contents on the console, line by line, with the enter key pressed at the end of each line. If the console of the IDE you are using does not support copy-pasting, you will have to type it out. You can experiment with smaller matrices first to avoid wasting time doing too many copy-pastes.

\*An editor such as Notepad++ can show you all characters, including non-printable characters such as \\r (CR-carriage return) and \\n (LF-linefeed). You can view it by going to View>Show Symbol>Show All Characters. When sending using the 'Send ASCII' option in RealTerm, make sure you append \\r or \\n.

Embedded system tools and boards have a relatively short lifespan - so you need to be able to pick up things on your own as and when required, often based on partial documentation and self-exploration. Lab 2 manuals have purposely left out detailed step-by-step instructions (esp. on the software part) - to let you explore the various options, think, search and find out things on your own. If you know precisely how to do it (that is, if we give you detailed steps), doing it shouldn’t take you much time and is not worth 10% of you grades :D. Some tips are given below.

If your program is inhibiting unpredictable behavior when dealing with large data, it could be due to stack or heap size limitations. You can increase the heap or stack size by editing the linker script (.ld file) which you can find in the project sources.

* There are 2 programs with interact with each other – the RealTerm program which runs on the PC, and your C program running on the board.
* RealTerm is a serial terminal / console program\* running on PC. It can send and receive characters, send and receive text files (text files are nothing but long strings) through the serial port (COM/tty) as well as network interfaces (TCP/IP sockets).
* The program running on the board (Cortex A53) receives the sequence of characters sent from the PC (you can use the send file option in RealTerm), does some computations, and sends it back to the PC (you can capture it into a file). Since this is running on the board which does not have direct access to the files on the PC, usual file related functions such as fopen() and fprintf() will not work!. You can only capture the stream of characters sent by the RealTerm, process it, and send back.
* Now the question on how to receive data sent from RealTerm in your C program - there are 2 approaches :
  * The high-level way using stdin / stdout.
    * stdin and stdout are interfaces through which console-oriented functions such as printf(), scanf(), getchar(), gets(), putchar(), puts() send data to be displayed on the console and receive data from the console.
    * Since we have directed stdin and stdout to the console (where did we do that? - I leave it as an exercise for you to find out), you can use these functions to send and receive data from the PC/RealTerm.
    * If the underlying physical layer is UART, the functions mentioned above such as printf() and scanf() makes use of UART driver functions under the hood, in addition to formatting/parsing the ASCII characters sent/received via UART. For example, the bytes 0x31, 0x32, 0x33, 0x0d if received via UART, scanf with a format specifier of "%d" will convert it to an integer 123.
    * All the functions block until a LF (linefeed - \\n) or CR(carriage return - \\r) is received. So you can't receive anything which is not properly terminated. When you send a file, make sure that it has a \\r or \\n character at the end of it. This is automatically inserted when you press 'enter' in a text file or console (Most Windows programs treat the press of 'enter' as \\r\\n, whereas in Linux, it is usually just \\n. For most console programs, it is '\\r' by default. These characters come from the typewriter era and mostly serve the same purpose on a computer).
  * The low-level way using UART driver functions
    * Gives you full control over what is sent and what is received to/from the console.
    * You need to initialize the UART driver before you can use functions such as XUartPs\_Send() and XUartPs\_Recv() or the lower level XUartPs\_SendByte() and XUartPs\_RecvByte().
    * These are non-blocking functions (so you need to check the return value to see how many characters you have received) which give you full control (no need for \\r or \\n).
    * The basic procedure to deal with all hardware in the Xilinx toolchain is the same, as exemplified below through XUartPs. You can go to $your\_Bsp$>system.mss and see the driver documentation and examples.
      * XUartPs Uart\_Ps //Declare a driver instance (not a pointer to this instance) as a global variable. All UART-related functions use a pointer to this instance.
      * XUartPs\_LookupConfig(DeviceId); // Looks up hardware instance info such as base address etc. DeviceId is usually XPAR\_XUARTPS\_0\_DEVICE\_ID, defined in xparameters.h.
      * XUartPs\_CfgInitialize(&Uart\_Ps,...) // Initializes the hardware and driver instance
      * XUartPs\_SetBaudRate(&Uart\_Ps,...) // Additional hardware specific settings/initializations. Following this, you can use the Send and Recv functions.
    * Instead of starting from scratch, start with the examples from system.mss entry for the hardware you are looking at. For UART, you can probably start with xuartps\_hello\_world\_example and modify it to suit your needs.
* Instead of just clicking 'Run' in the Vitis, you can click 'Debug' and do debugging just like how you do on any IDE. To change your perspective back to normal (after debugging), click Window>Debug Perspective in Vitis. This will allow you to inspect what is happening in each line, send something from RealTerm and see what is received, etc.
* \*RealTerm is a very feature-rich terminal/console program. Don't be afraid to try out the various options in the tabs 'Display', 'Capture', Send'. Most importantly, the settings on Port has to be correct for things to work. Generally, I uncheck 'Direct Capture' and check 'Half Duplex' and 'newLine mode' so that I can see everything that is sent and received on the console.
* If you see strange-looking characters on your console, your baud rate setting in RealTerm is likely wrong.
* As a general rule, DO NOT use spaces in the paths for any of your projects/workspaces. This is a good practice not only for Vitis/Vivado but for a number of hardware and software development tools.
* Sending data from RealTerm/Serial console everytime can be time-consuming during the debug process. It is a good idea to have the required data (CSV file contents) hard-coded as an array in your C program, and use it during debugging. You could make use of #ifdef to conditionally use the hardcoded value or the live data streamed in from the serial console so that you can switch between them easily.
