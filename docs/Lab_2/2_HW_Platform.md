# Creating the Hardware Platform

This page describes how to use Vivado to create a hardware platform using IP Integrator, and to synthesize the hardware into a bitstream. The bitstream is used to configure the FPGA to become the hardware platform that we have created. The bitstream and other hardware info are exported as a .xsa file.

Open Vivado.

File>Project>New

Next> Specify a project name and location>Next>Next>Next>Next> Select the board - go to the boards tab and select _Kria KV260 Vision AI Starter Kit SOM_ >Next>Finish.

![](2_HW_Platform/image-53f27b35-da1e-4401-94f4-e1e6f0a6cd42.png)

Vivado Project manager will now open up.

Under IP Integrator, click Create Block Design.

![](2_HW_Platform/image-8b6fc968-dc4a-4a11-98e3-8709db5aea21.png)

Accept the default name and options, and click OK.

In the IP Integrator canvas that opens up, click the Add IP button ![](2_HW_Platform/image-720b68f3-683f-4172-8913-11078bf51624.png){: style="height:150px;width:150px"}.

Search for and add Zynq UltraScale+ MPSoC

![](2_HW_Platform/image-7e95ae81-c815-451a-b2a4-bd3e08512409.png)

Click on Run Block Automation. This will apply some preset settings for the chip/board. We will be changing this substantially later though.

![](2_HW_Platform/image-e3e81235-19d2-4727-93fd-ea15b0648f94.png)

Accept the defaults and press ok.

Now double-click on the Zynq Ultrascale+ block. You can now see the ultrascale+ block diagram. Have a good look.

No, under I/O configuration, enable UART and you can safely disable everything else. Here, we are configuring the multiplexed IOs, and MIO pins 36 is TX, 37 is RX. We need only those for now.

![](2_HW_Platform/image-1097b849-a084-4b21-beab-b69250623575.png)

In the Clock configuration, you can uncheck PL1. PS generates clock(s) for PL. We can have multiple clocks with the same or different frequencies. We need only one 100 MHz clock for PL, at least for now.

![](2_HW_Platform/image-51d05426-f83f-4968-9b88-77e1a381d58e.png)

In the PS-PL configuration, we can choose AXI HPM0 FPD and uncheck AXI HPM1 FPD. Using AXI HPM0 LPD is also ok (FPD = full power domain. LPD = low power domain). This is the master AXI interface, to which the slaves created in PL will be connected. Select the data width as 32.

![](2_HW_Platform/image-60ea203c-df1d-4b46-b97a-efed3e345936.png)

You should now see the block below. Click and drag from pl\_clk0 to make a connection to maxihpm0\_fpg\_aclk.

![](2_HW_Platform/image-92ca3ac3-516b-40af-8107-e9be6e077eca.png)

![](2_HW_Platform/image-29389a4d-2e5d-42f5-9cdc-8cf97d034d91.png)

At any point, if you want to beautify the layout, you can click ![](2_HW_Platform/image-f275af6d-6f12-4ca3-8dc8-3019a45c0fd3.png)

The validate your design, i.e., to check if there are incompatible connections / essential connections that are not made, click ![](2_HW_Platform/image-0f244179-cc3c-47cc-ac5f-3931d45460fc.png). If no error or critical warning, we have completed the basic block design.

While this is good enough to do the basic requirements for this lab, let us push ourselves a bit more and get readier for future labs.

Click the + button on the IP Integrator canvas to add an IP. Select AXI-Stream FIFO. ![](2_HW_Platform/image-7bf91aa5-2f4d-4cf5-ab81-a80f8805119e.png) . This IP acts as a bridge between AXI (the bus-based, addressable bus system) to AXI-Stream (point-to-point, non-addressable link). This will be used to integrate our coprocessor into the rest of the system in future labs so that the main processor can send/receive data via AXI. 

While the IP Integrator shows the option for running connection automation, do not do this as yet. Instead, double-click on the AXI Stream FIFO that we added to customize it.

Change the settings as follows, and click OK. Choosing AXI (full AXI) instead of AXI Lite (default) allows the data transfer to be potentially faster, as full AXI can do burst transfers (slave auto-increments addresses so that multiple data can be transferred with a single address). We can disable 'Enable Transmit Control' as we will be doing all the data transfer continuously. Make sure that the Data Width is 32. Increase the Transmit FIFO depth to 1024, as we will be sending more than 512 words later. Similarly, increase the Receive FIFO depth to 1024 as well - this is necessary only in loopback mode - in the next assignment, we will be connecting a coprocessor instead, which return as result less than 512 words.

![](2_HW_Platform/image-0eedde7a-d9bc-4c68-8686-509eaf919f54.png)

Now, click on ![](2_HW_Platform/image-0becaecd-02b6-4c5b-9082-9509979e895f.png)

Select both the automations and click OK. 

![](2_HW_Platform/image-202fd728-8df7-444b-be4f-b245ac9e0b98.png)

It will add two blocks - Processor System Reset (to reset peripherals as appropriate - more useful in designs using Microblaze, a soft processor), and an AXI Interconnect - since AXI Stream FIFO has 2 slave interfaces, both of which need to be connected to the same master interface of PS.

Finally, make a loopback connection - connect the AXI\_STR\_TXD to AXI\_STR\_RXD. Since we do not have a co-processor yet, this connection will have the effect of a coprocessor that simply echos (sends back) the data it receives.

![](2_HW_Platform/image-71e96a03-8315-4f5a-ad53-2fbf78e1d8da.png)

You can now optionally click on Regenerate Layout button (the clock-wise symbol) to tidy up the diagram. It should look like below.

![](2_HW_Platform/image-83ed6c64-ee32-4b4b-92c1-7270c79db2f3.png)

It is also a good time to inspect (no action required) the address editor tab. This shows the addresses of the memory-mapped peripherals / interfaces. We have two corresponding to AXI (mentioned as S\_AXI\_FULL) and AXI Lite (S\_AXI) interfaces of the AXI Stream FIFO. You can edit the addresses and ranges if you wish, but unless you have a good reason to (or if you are into numerology), it is fine to leave it as such.

![](2_HW_Platform/image-e365250c-832d-4c29-8c77-405d8cf5710e.png)

We are done with the block design. Save the block design (Ctrl+S).

Synthesis tools can't synthesize a block design directly. We need to convert the block design into HDL. Under Sources > Design Sources, right-click the .bd file and select 'Create HDL Wrapper'. 

![](2_HW_Platform/image-c898cdb2-83ba-495a-9b6d-4faad71d37ee.png)

Accept the default, i.e., let 'Vivado manage ...' and click OK.

Now click 'Generate Bitstream' and OK.

Once it is done, File > Export > Export Hardware > Next > Change to Include Bitstream.

Next > (note the path, the default is the project directory itself)> Next > Finish.

For the various steps such as synthesis/implementation etc,  setting the number of jobs equal to the number of cores (maximum in the drop-down list) may cause it to complete faster, esp on Linux. Often, the number appearing by default is 4, which can be changed to a higher number. If you have other programs running in the background, set it to the maximum value in the list minus one or two.

Continue to the instructions for software development using Vitis.
