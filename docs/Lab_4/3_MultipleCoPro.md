# Connecting Multiple Coprocessors (Optional)

This document describes how you can (optional) connect multiple coprocessors to your system.

It is possible to connect 2 coprocessors through 2 AXI FIFOs (or AXI DMAs). This is not a requirement, but not a bad idea as you can compare the various implementations in one go. You just need to add one more AXI Stream FIFO IP from the IP catalog and make connections the same way you did for the first one. On the C side, the following should help. A similar idea can be used if you have 2 coprocessors connected through 2 AXI DMAs (or for any two instances of the same IP for that matter).

!!! info "General Idea"
    The code below is to illustrate the general idea. Appropriate changes will be necessary depending on the specific peripheral being duplicated as well as the version of Vitis used.

``` c

XLlFifo FifoInstance0;     // Device 0 instance
XLlFifo *InstancePtr0 = &FifoInstance0; // Device 0 pointer
XLlFifo FifoInstance1;     // Device 1 instance
XLlFifo *InstancePtr1 = &FifoInstance1; // Device 1 pointer
 
int main()
{
    int Status0 = XST_SUCCESS; // can also use just a single status variable.
    int Status1 = XST_SUCCESS;
 
    XLlFifo_Config *Config0; // can also reuse the config pointer instead of having two.
    XLlFifo_Config *Config1;
 
    /* Initialize the Device Configuration Interface driver for FIFO0 */
    Config0 = XLlFfio_LookupConfig(XPAR_AXI_FIFO_MM_S_0_BASEADDR);
    if (!Config0) {
        xil_printf("No config found for %d\r\n", XPAR_AXI_FIFO_MM_S_0_BASEADDR);
        return XST_FAILURE;
    }
 
    Status0 = XLlFifo_CfgInitialize(InstancePtr0, Config0, Config0->BaseAddress);
    if (Status0 != XST_SUCCESS) {
        xil_printf("Initialization failed\r\n");
        return XST_FAILURE;
    }
 
     /* Initialize the Device Configuration Interface driver for FIFO1 */
    Config1 = XLlFfio_LookupConfig(XPAR_AXI_FIFO_MM_S_1_BASEADDR);
    if (!Config1) {
        xil_printf("No config found for %d\r\n", XPAR_AXI_FIFO_MM_S_1_BASEADDR);
        return XST_FAILURE;
    }
 
    Status1 = XLlFifo_CfgInitialize(InstancePtr1, Config1, Config1->BaseAddress);
    if (Status1 != XST_SUCCESS) {
        xil_printf("Initialization failed\r\n");
        return XST_FAILURE;
    }
 
    Status0 = XLlFifo_Status(InstancePtr0); /* use the correct driver pointer 
                        depending on the device instance you are interacting with.*/
    Status1 = XLlFifo_Status(InstancePtr1);
```
