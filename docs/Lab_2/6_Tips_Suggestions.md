# Tips and Suggestions

Embedded system tools and boards have a relatively short lifespan - so you need to be able to pick up things on your own as and when required, often based on partial documentation and self-exploration. The manuals have purposely left out detailed step-by-step instructions (esp. on the software part) - to let you explore the various options, think, search and find out things on your own. If you know precisely how to do it (that is, if we give you detailed steps), doing it shouldn’t take you much time and is not worth 10% of you grades :D. Some tips are given below.

You can do most of the testing of your C program logic without accessing the FPGA board. You can run it locally using a C/C++ IDE of your choice such as [Visual Studio Code](https://code.visualstudio.com/docs/languages/cpp) or using an online compiler like [onlinegdb](https://www.onlinegdb.com/online_c_compiler). Since the typical console (interface) you get cannot send files (such as A.csv and B.csv), you can copy-paste the file contents on the console, line by line, with the enter key pressed at the end of each line. If the console of the IDE you are using does not support copy-pasting, you will have to type it out. You can experiment with smaller matrices first to avoid wasting time doing too many copy-pastes.

Sending data from RealTerm/Serial console every time can be time-consuming during the debug process. It is a good idea to have the required data (CSV file contents) hard-coded as an array in your C program, and use it during debugging. You could make use of #ifdef to conditionally use the hardcoded value or the live data streamed in from the serial console so that you can switch between them easily.

There are 2 programs with interact with each other – the RealTerm program which runs on the PC, and your C program running on the board.

RealTerm is a serial terminal / console program running on PC. It can send and receive characters, send and receive text files (text files are nothing but long strings) through the serial port (COM/tty) as well as network interfaces (TCP/IP sockets).

The program running on the board (Cortex A53) receives the sequence of characters sent from the PC (you can use the send file option in RealTerm), does some computations, and sends it back to the PC (you can capture it into a file). Since this is running on the board which does not have direct access to the files on the PC, usual file related functions such as fopen() and fprintf() will not work!. You can only capture the stream of characters sent by the RealTerm, process it, and send back.

Now the question on how to receive data sent from RealTerm in your C program - there are 2 approaches :

Using stdin / stdout (The high-level way - easier but limited control)

* stdin and stdout are interfaces through which console-oriented functions such as printf(), scanf(), getchar(), gets(), putchar(), puts() send data to be isplayed on the console and receive data from the console.
* Since we have directed stdin and stdout to the console (where did we do that? - I leave it as an exercise for you to find out), you can use these functions to end and receive data from the PC/RealTerm.
* If the underlying physical layer is UART, the functions mentioned above such as printf() and scanf() makes use of UART driver functions under the hood, in addition to formatting/parsing the ASCII characters sent/received via UART. For example, the bytes 0x31, 0x32, 0x33, 0x0d if received via UART, scanf with a format specifier of "%d" will convert it to an integer 123.
* All the functions block until a LF (linefeed - \\n) or CR(carriage return - \\r) is received. So you can't receive anything which is not properly terminated. When you send a file, make sure that it has a \\r or \\n character at the end of it. This is automatically inserted when you press 'enter' in a text file or console (Most Windows programs treat the press of 'enter' as \\r\\n, whereas in Linux, it is usually just \\n. For most console programs, it is '\\r' by default. These characters come from the typewriter era and mostly serve the same purpose on a computer).

Using UART driver functions (The low-level way - great power, great responsibility)

* Gives you full control over what is sent and what is received to/from the console.
* You need to initialize the UART driver before you can use functions such as XUartPs\_Send() and XUartPs\_Recv() or the lower level XUartPs\_SendByte() and XUartPs\_RecvByte().
* These are non-blocking functions (so you need to check the return value to see how many characters you have received) which give you full control (no need for \\r or \\n).
* The basic procedure to deal with all hardware in the Xilinx toolchain is the same, as exemplified below through XUartPs. You can go to your\_bsp>system.mss and see the driver documentation and examples.
* XUartPs Uart\_Ps //Declare a driver instance (not a pointer to this instance) as a global variable. All UART-related functions use a pointer to this instance.
* XUartPs\_LookupConfig(DeviceId); // Looks up hardware instance info such as base address etc. DeviceId is usually XPAR\_XUARTPS\_0\_DEVICE\_ID, defined in xparameters.h.
* XUartPs\_CfgInitialize(&Uart\_Ps,...) // Initializes the hardware and driver instance
* XUartPs\_SetBaudRate(&Uart\_Ps,...) // Additional hardware specific settings/initializations. Following this, you can use the Send and Recv functions.
* Instead of starting from scratch, start with the examples from system.mss entry for the hardware you are looking at. For UART, you can probably start with xuartps\_hello\_world\_example and modify it to suit your needs.
