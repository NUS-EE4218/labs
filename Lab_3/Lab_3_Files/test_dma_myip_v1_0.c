/*
----------------------------------------------------------------------------------
--	(c) Rajesh C Panicker, NUS,
--	Modified from XLlFifo_polling_example.c, (c) Xilinx Inc
--  Description : Self-checking sample program for AXI Stream Coprocessor interfaced using AXI Stream FIFO.
--	License terms :
--	You are free to use this code as long as you
--		(i) DO NOT post a modified version of this on any public repository;
--		(ii) use it only for educational purposes;
--		(iii) accept the responsibility to ensure that your implementation does not violate any intellectual property of any entity.
--		(iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
--		(v) send an email to rajesh.panicker@ieee.org briefly mentioning its use (except when used for the course EE4218 at the National University of Singapore);
--		(vi) retain this notice in this file or any files derived from this.
----------------------------------------------------------------------------------
*/

/***************************** Include Files *********************************/
#include "xaxidma.h"
#include "xdebug.h"
#include "xparameters.h"
#include "xil_exception.h"
#include "xil_cache.h"
#include "xstatus.h"

/***************** Transmit and receive buffers *********************/
#ifndef DDR_BASE_ADDR
#warning CHECK FOR THE VALID DDR ADDRESS IN XPARAMETERS.H, \
DEFAULT SET TO 0x01000000
#define MEM_BASE_ADDR		0x01000000
#else
#define MEM_BASE_ADDR		(DDR_BASE_ADDR + 0x1000000)
#endif

// Transmit and receive buffer allocated sufficiently away from the start of DDR, hopefully not overlapping with the program's other memory segments.
// It is better to hard code transmit and receive buffers to avoid it being in the same cache line as other variables, and for better alignment.
#define TX_BUFFER_BASE		(MEM_BASE_ADDR + 0x00100000) 
#define RX_BUFFER_BASE		(MEM_BASE_ADDR + 0x00300000)
#define RX_BUFFER_HIGH		(MEM_BASE_ADDR + 0x004FFFFF)

/***************** Macros *********************/
#define NUMBER_OF_INPUT_WORDS 4  // length of an input vector
#define NUMBER_OF_OUTPUT_WORDS 4  // length of an input vector
#define NUMBER_OF_TEST_VECTORS 2  // number of such test vectors (cases)

#define DMA_DEV_ID        XPAR_XAXIDMA_0_BASEADDR

/************************** Variable Definitions *****************************/
XAxiDma AxiDma;	// Device instance
XAxiDma *InstancePtr = &AxiDma; // Device pointer

// Commenting out the lines below as we are using hardcoded buffers, and not compiler/linker allocated.
//int test_input_memory [NUMBER_OF_TEST_VECTORS*NUMBER_OF_INPUT_WORDS] = {0x01, 0x02, 0x03, 0x04, 0x02, 0x03, 0x04, 0x05}; // 4 inputs * 2
//int result_memory [NUMBER_OF_TEST_VECTORS*NUMBER_OF_OUTPUT_WORDS]; // same size as test_result_expected_memory
int test_result_expected_memory [NUMBER_OF_TEST_VECTORS*NUMBER_OF_OUTPUT_WORDS];// 4 outputs *2

/*****************************************************************************
* Main function
******************************************************************************/
int main()
{
	int Status;
	int word_cnt, test_case_cnt = 0;
	int success;
	Status = XST_SUCCESS;

	int* test_input_memory = (int*)TX_BUFFER_BASE;
	int* result_memory = (int*)RX_BUFFER_BASE;
	for (test_case_cnt=0 ; test_case_cnt < NUMBER_OF_TEST_VECTORS ; test_case_cnt++){
		for (word_cnt=0 ; word_cnt < NUMBER_OF_INPUT_WORDS ; word_cnt++){
			test_input_memory[word_cnt+test_case_cnt*NUMBER_OF_INPUT_WORDS] = word_cnt+test_case_cnt*NUMBER_OF_INPUT_WORDS+1;
		}
	}

	/************************** Initializations *****************************/

	 XAxiDma_Config *CfgPtr;

	/* Initialize the XAxiDma device.*/
	CfgPtr = XAxiDma_LookupConfig(DMA_DEV_ID);
	if (!CfgPtr) {
	  xil_printf("No config found for %d\r\n", DMA_DEV_ID);
	  return XST_FAILURE;
	}

	Status = XAxiDma_CfgInitialize(&AxiDma, CfgPtr);
	if (Status != XST_SUCCESS) {
	  xil_printf("Initialization failed %d\r\n", Status);
	  return XST_FAILURE;
	}

	if(XAxiDma_HasSg(&AxiDma)){
	  xil_printf("Device configured as SG mode \r\n");
	  return XST_FAILURE;
	}

	/* Disable interrupts, we use polling mode */
	XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
	XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);

	//Xil_DCacheDisable(); // uncomment this as a last resort, which will avoid all cache related issues, but at the expense of performance.

	/************** Run a software version of the hardware function to validate results ************/
	// instead of hard-coding the results in test_result_expected_memory
	int sum;
	for (test_case_cnt=0 ; test_case_cnt < NUMBER_OF_TEST_VECTORS ; test_case_cnt++){
		sum = 0;
		for (word_cnt=0 ; word_cnt < NUMBER_OF_INPUT_WORDS ; word_cnt++){
			sum +=test_input_memory[word_cnt+test_case_cnt*NUMBER_OF_INPUT_WORDS];
		}
		for (word_cnt=0; word_cnt < NUMBER_OF_INPUT_WORDS; word_cnt++) {
			test_result_expected_memory[word_cnt+test_case_cnt*NUMBER_OF_OUTPUT_WORDS] = sum + word_cnt;
		}
	}


	for (test_case_cnt=0 ; test_case_cnt < NUMBER_OF_TEST_VECTORS ; test_case_cnt++){

		/************************** Transmit the Data Stream *****************************/

		xil_printf(" Transmitting Data for test case %d ... \r\n", test_case_cnt);

		/* Flush the SrcBuffer and DestBuffer before the DMA transfer, in case the Data Cache is enabled */
		Xil_DCacheFlushRange((u32)(result_memory+test_case_cnt*NUMBER_OF_INPUT_WORDS), 4*NUMBER_OF_INPUT_WORDS);
		Xil_DCacheFlushRange((u32)(test_input_memory+test_case_cnt*NUMBER_OF_INPUT_WORDS), 4*NUMBER_OF_INPUT_WORDS);

		Status = XAxiDma_SimpleTransfer(&AxiDma,(u32) (test_input_memory+test_case_cnt*NUMBER_OF_INPUT_WORDS), 4*NUMBER_OF_INPUT_WORDS, XAXIDMA_DMA_TO_DEVICE);

		if (Status != XST_SUCCESS) {
		  return XST_FAILURE;
		}
		while (XAxiDma_Busy(&AxiDma,XAXIDMA_DMA_TO_DEVICE)) {
			//wait for transfer to complete
		}

		/* Transmission Complete */

		/************************** Receive the Data Stream *****************************/

		xil_printf(" Receiving data for test case %d ... \r\n", test_case_cnt);

		Status = XAxiDma_SimpleTransfer(&AxiDma,(u32) (result_memory+test_case_cnt*NUMBER_OF_OUTPUT_WORDS), 4*NUMBER_OF_OUTPUT_WORDS, XAXIDMA_DEVICE_TO_DMA);

		if (Status != XST_SUCCESS) {
		  return XST_FAILURE;
		}
		while (XAxiDma_Busy(&AxiDma,XAXIDMA_DEVICE_TO_DMA)) {
			//wait for transfer to complete
		}

		/* Invalidate the DestBuffer before receiving the data, in case the Data Cache is enabled */
		Xil_DCacheInvalidateRange((u32)(result_memory+test_case_cnt*NUMBER_OF_OUTPUT_WORDS), 4*NUMBER_OF_OUTPUT_WORDS);

		/* Reception Complete */
	}

	/************************** Checking correctness of results *****************************/

	success = 1;

	/* Compare the data send with the data received */
	xil_printf(" Comparing data ...\r\n");
	for(word_cnt=0; word_cnt < NUMBER_OF_TEST_VECTORS*NUMBER_OF_OUTPUT_WORDS; word_cnt++){
		success = success & (result_memory[word_cnt] == test_result_expected_memory[word_cnt]);
	}

	if (success != 1){
		xil_printf("Test Failed\r\n");
		return XST_FAILURE;
	}

	xil_printf("Test Success\r\n");

	return XST_SUCCESS;
}

