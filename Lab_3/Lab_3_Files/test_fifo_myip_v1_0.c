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
#include "xparameters.h"
#include "xil_exception.h"
#include "xstreamer.h"
#include "xil_cache.h"
#include "xllfifo.h"
#include "xstatus.h"


/***************** Macros *********************/
#define NUMBER_OF_INPUT_WORDS 4  // length of an input vector
#define NUMBER_OF_OUTPUT_WORDS 4  // length of an input vector
#define NUMBER_OF_TEST_VECTORS 2  // number of such test vectors (cases)

#define FIFO_DEV_ID	   	XPAR_AXI_FIFO_0_DEVICE_ID

#define TIMEOUT_VALUE 1<<20; // timeout for reception

/************************** Variable Definitions *****************************/
u16 DeviceId = FIFO_DEV_ID;
XLlFifo FifoInstance; 	// Device instance
XLlFifo *InstancePtr = &FifoInstance; // Device pointer

int test_input_memory [NUMBER_OF_TEST_VECTORS*NUMBER_OF_INPUT_WORDS] = {0x01, 0x02, 0x03, 0x04, 0x02, 0x03, 0x04, 0x05}; // 4 inputs * 2
int test_result_expected_memory [NUMBER_OF_TEST_VECTORS*NUMBER_OF_OUTPUT_WORDS];// 4 outputs *2
int result_memory [NUMBER_OF_TEST_VECTORS*NUMBER_OF_OUTPUT_WORDS]; // same size as test_result_expected_memory

/*****************************************************************************
* Main function
******************************************************************************/
int main()
{
	int Status = XST_SUCCESS;
	int word_cnt, test_case_cnt = 0;
	int success;

	/************************** Initializations *****************************/
	XLlFifo_Config *Config;

	/* Initialize the Device Configuration Interface driver */
	Config = XLlFfio_LookupConfig(DeviceId);
	if (!Config) {
		xil_printf("No config found for %d\r\n", DeviceId);
		return XST_FAILURE;
	}

	Status = XLlFifo_CfgInitialize(InstancePtr, Config, Config->BaseAddress);
	if (Status != XST_SUCCESS) {
		xil_printf("Initialization failed\r\n");
		return XST_FAILURE;
	}

	/* Check for the Reset value */
	Status = XLlFifo_Status(InstancePtr);
	XLlFifo_IntClear(InstancePtr,0xffffffff);
	Status = XLlFifo_Status(InstancePtr);
	if(Status != 0x0) {
		xil_printf("\n ERROR : Reset value of ISR0 : 0x%x\t. Expected : 0x0\r\n",
			    XLlFifo_Status(InstancePtr));
		return XST_FAILURE;
	}

	/************** Run a software version of the hardware function to validate results ************/
	// instead of hard-coding the results in test_result_expected_memory
	int sum;
	for (test_case_cnt=0 ; test_case_cnt < NUMBER_OF_TEST_VECTORS ; test_case_cnt++){
		sum = 0;
		for (word_cnt=0 ; word_cnt < NUMBER_OF_INPUT_WORDS ; word_cnt++){
			sum +=test_input_memory[word_cnt+test_case_cnt*NUMBER_OF_INPUT_WORDS];
		}
		for (word_cnt=0; word_cnt < NUMBER_OF_OUTPUT_WORDS; word_cnt++) {
			test_result_expected_memory[word_cnt+test_case_cnt*NUMBER_OF_OUTPUT_WORDS] = sum + word_cnt;
		}
	}


	for (test_case_cnt=0 ; test_case_cnt < NUMBER_OF_TEST_VECTORS ; test_case_cnt++){

		/******************** Input to Coprocessor : Transmit the Data Stream ***********************/

		xil_printf(" Transmitting Data for test case %d ... \r\n", test_case_cnt);

		/* Writing into the FIFO Transmit Port Buffer */
		for (word_cnt=0 ; word_cnt < NUMBER_OF_INPUT_WORDS ; word_cnt++){
			if( XLlFifo_iTxVacancy(InstancePtr) ){
				XLlFifo_TxPutWord(InstancePtr, test_input_memory[word_cnt+test_case_cnt*NUMBER_OF_INPUT_WORDS]);
			}
		}

		/* Start Transmission by writing transmission length (number of bytes = 4* number of words) into the TLR */
		XLlFifo_iTxSetLen(InstancePtr, NUMBER_OF_INPUT_WORDS * 4);

		/* Check for Transmission completion */
		while( !(XLlFifo_IsTxDone(InstancePtr)) ){

		}
		/* Transmission Complete */

		/******************** Output from Coprocessor : Receive the Data Stream ***********************/

		xil_printf(" Receiving data for test case %d ... \r\n", test_case_cnt);

		int timeout_count = TIMEOUT_VALUE;
		// wait for coprocessor to send data, subject to a timeout
		while(!XLlFifo_iRxOccupancy(InstancePtr)) {
			timeout_count--;
			if (timeout_count == 0)
			{
				xil_printf("Timeout while waiting for data ... \r\n");
				return XST_FAILURE;
			}
		}

		// we are expecting only one packet of data per test case. one packet = sequence of data until TLAST
		// if more packets are expected from the coprocessor, the part below should be done in a loop.
		u32 ReceiveLength = XLlFifo_iRxGetLen(InstancePtr)/4;
		for (word_cnt=0; word_cnt < ReceiveLength; word_cnt++) {
			// read one word at a time
			result_memory[word_cnt+test_case_cnt*NUMBER_OF_OUTPUT_WORDS] = XLlFifo_RxGetWord(InstancePtr);
		}

		Status = XLlFifo_IsRxDone(InstancePtr);
		if(Status != TRUE){
			xil_printf("Failing in receive complete ... \r\n");
			return XST_FAILURE;
		}
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

