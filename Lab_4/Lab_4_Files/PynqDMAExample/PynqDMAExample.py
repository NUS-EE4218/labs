# PYNQ program to exercise AXI DMA with a streaming accelerator
# Mirrors the logic in your standalone C example (no SG, polling, 2 test vectors)

from pynq import Overlay, allocate
import numpy as np

# --- Configuration constants (match your C code) ---
NUMBER_OF_INPUT_WORDS  = 4
NUMBER_OF_OUTPUT_WORDS = 4
NUMBER_OF_TEST_VECTORS = 2

# --- Load overlay and get DMA ---
# Replace with your actual bitstream path
overlay = Overlay('/home/ubuntu/PynqDMAExample/design_1_wrapper.bit')

# Inspect IPs if you’re unsure about names:
# print(overlay.ip_dict)
# print(overlay.dma_dict)

# Replace with your actual DMA instance name from the overlay
dma = overlay.axi_dma_0

# --- Allocate contiguous buffers in DDR (pynq.allocate handles cache coherency) ---
# We'll reuse single buffers per test case, as in your C loop, to send/receive 4 words.
in_buf  = allocate(shape=(NUMBER_OF_INPUT_WORDS,),  dtype=np.int32)
out_buf = allocate(shape=(NUMBER_OF_OUTPUT_WORDS,), dtype=np.int32)

# --- Prepare inputs (same pattern as your C code) ---
# test_input_memory[word_cnt + test_case_cnt * NUMBER_OF_INPUT_WORDS] = word_cnt + test_case_cnt*NUMBER_OF_INPUT_WORDS + 1
# We'll fill per test case into in_buf.
def fill_input_for_case(case_idx, buf):
    for word_cnt in range(NUMBER_OF_INPUT_WORDS):
        buf[word_cnt] = word_cnt + case_idx * NUMBER_OF_INPUT_WORDS + 1

# --- Software reference computation (sum of 4 inputs; outputs are sum + index) ---
def expected_output_for_case(case_idx):
    # Compute the 4 inputs as above
    inputs = np.array([word_cnt + case_idx * NUMBER_OF_INPUT_WORDS + 1
                       for word_cnt in range(NUMBER_OF_INPUT_WORDS)], dtype=np.int32)
    s = int(np.sum(inputs))
    return np.array([s + i for i in range(NUMBER_OF_OUTPUT_WORDS)], dtype=np.int32)

# --- Run tests ---
all_ok = True

for test_case_cnt in range(NUMBER_OF_TEST_VECTORS):
    print(f"Transmitting data for test case {test_case_cnt} ...")

    # Prepare input for this test case
    fill_input_for_case(test_case_cnt, in_buf)

    # Start DMA transfers: send input vector, receive output vector
    dma.sendchannel.transfer(in_buf)
    dma.recvchannel.transfer(out_buf)

    # Polling wait for completion (equivalent to XAxiDma_Busy loops)
    dma.sendchannel.wait()
    dma.recvchannel.wait()

    print(f"Receiving data for test case {test_case_cnt} ...")

    # Validate results
    exp = expected_output_for_case(test_case_cnt)
    ok = np.array_equal(out_buf, exp)
    print(f"Case {test_case_cnt} received: {out_buf}, expected: {exp}, match: {ok}")
    all_ok = all_ok and ok

# --- Final result ---
if all_ok:
    print("Test Success")
else:
    print("Test Failed")
