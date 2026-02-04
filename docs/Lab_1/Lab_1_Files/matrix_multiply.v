`timescale 1ns / 1ps

// those outputs which are assigned in an always block of matrix_multiply should be changed to reg (such as output reg Done).

module matrix_multiply
	#(	parameter width = 8, 			// width is the number of bits per location
		parameter A_depth_bits = 3, 	// depth is the number of locations (2^number of address bits)
		parameter B_depth_bits = 2, 	// e.g., RAM A has 2^3=8 addresses, requires 3 bits to represent them
		parameter RES_depth_bits = 1
	) 
	(
		input clk,										
		input Start,										// myip_v1_0 -> matrix_multiply_0.
		output reg Done,									// matrix_multiply_0 -> myip_v1_0. Possibly reg.
		
		output reg A_read_en,  								// matrix_multiply_0 -> A_RAM. Possibly reg.
		output reg [A_depth_bits-1:0] A_read_address, 		// matrix_multiply_0 -> A_RAM. Possibly reg.		
		input  [width-1:0] A_read_data_out,					// A_RAM -> matrix_multiply_0.


		output reg B_read_en, 								// matrix_multiply_0 -> B_RAM. Possibly reg.
		output reg [B_depth_bits-1:0] B_read_address, 		// matrix_multiply_0 -> B_RAM. Possibly reg.
		input  [width-1:0] B_read_data_out,					// B_RAM -> matrix_multiply_0.
		
		output reg RES_write_en, 							// matrix_multiply_0 -> RES_RAM. Possibly reg.
		output reg [RES_depth_bits-1:0] RES_write_address, 	// matrix_multiply_0 -> RES_RAM. Possibly reg.
		output reg [width-1:0] RES_write_data_in 			// matrix_multiply_0 -> RES_RAM. Possibly reg.
	);
	
	// implement the logic to read A_RAM, read B_RAM, do the multiplication and write the results to RES_RAM
	// Note: A_RAM and B_RAM are to be read synchronously. Read the wiki for more details.
	

	// Derived dimensions (for the default lab setup):
	// M = number of rows in A = number of entries in RES = 2^RES_depth_bits (2)
	// N = number of columns in A = number of entries in B = 2^B_depth_bits (4)
	localparam integer M = (1 << RES_depth_bits);	// Multiplying by 2 to get # of rows
	localparam integer N = (1 << B_depth_bits);		// Multiplying by 2 to get # of cols
	
	// FSM states
	localparam IDLE    = 3'd000;
	localparam WAIT    = 3'd001; // wait 1 cycle for synchronous RAM output
	localparam COMPUTE = 3'd010; // multiply-accumulate using current A/B outputs
	localparam WRITE   = 3'd011; // write RES[row]
	localparam DONE    = 3'd100; // pulse Done for 1 cycle

	reg [2:0] state;			 // store the current state of the MM unit

	reg [RES_depth_bits-1:0] row;      // 0..M-1, which row we are currently computing (2)
	reg [B_depth_bits-1:0]   col;      // 0..N-1, which col we are currently computing (4)

	reg  [15:0] acc;                   // sum of 16-bit products fits in 16 bits for lab constraints
	wire [15:0] prod = A_read_data_out * B_read_data_out;
	wire [15:0] acc_next = acc + prod;

	reg [width-1:0] row_result_byte;   // stores (acc_next / 256) for stable write in next state

	// Helper: compute A address = row*N + col
	// Since # of cols, N = 2^B_depth_bits, row*N = row << B_depth_bits
	wire [A_depth_bits-1:0] a_addr_next = (row << B_depth_bits) + col;

	always @(posedge clk) begin
		// Defaults
		Done          <= 1'b0;
		RES_write_en  <= 1'b0;

		case (state)
			IDLE: begin
				A_read_en       <= 1'b0;
				B_read_en       <= 1'b0;
				A_read_address  <= {A_depth_bits{1'b0}};
				B_read_address  <= {B_depth_bits{1'b0}};
				RES_write_address <= {RES_depth_bits{1'b0}};
				RES_write_data_in <= {width{1'b0}};

				row <= {RES_depth_bits{1'b0}};
				col <= {B_depth_bits{1'b0}};
				acc <= 16'd0;

				if (Start) begin
					// Start a new computation
					A_read_en      <= 1'b1;
					B_read_en      <= 1'b1;

					row <= {RES_depth_bits{1'b0}};
					col <= {B_depth_bits{1'b0}};
					acc <= 16'd0;

					// Issue first read addresses (data will be available after 1 cycle)
					A_read_address <= (({RES_depth_bits{1'b0}}) << B_depth_bits) + {B_depth_bits{1'b0}};
					B_read_address <= {B_depth_bits{1'b0}};

					state <= WAIT;
				end
			end

			WAIT: begin
				// Keep reads enabled; RAM will update outputs on this edge.
				A_read_en <= 1'b1;
				B_read_en <= 1'b1;

				// Next cycle, the data is now stable to use in COMPUTE
				state <= COMPUTE;
			end

			COMPUTE: begin
				A_read_en <= 1'b1;
				B_read_en <= 1'b1;

				if (col == N-1) begin
					// Finish this row: include the last product
					row_result_byte <= acc_next[15:8]; // divide by 256
					acc <= 16'd0;
					state <= WRITE;
				end else begin
					// Continue accumulating
					acc <= acc_next;
					col <= col + 1'b1;

					// Issue next addresses for the next column
					A_read_address <= (row << B_depth_bits) + (col + 1'b1);
					B_read_address <= col + 1'b1;

					state <= WAIT; // wait for synchronous read
				end
			end

			WRITE: begin
				// Write RES[row] (pulse write enable for 1 cycle)
				RES_write_en      <= 1'b1;
				RES_write_address <= row;
				RES_write_data_in <= row_result_byte;

				if (row == M-1) begin
					// Last row written
					state <= DONE;
				end else begin
					// Next row
					row <= row + 1'b1;
					col <= {B_depth_bits{1'b0}};
					acc <= 16'd0;

					// Issue first address for next row (col=0)
					A_read_address <= ((row + 1'b1) << B_depth_bits) + {B_depth_bits{1'b0}};
					B_read_address <= {B_depth_bits{1'b0}};

					state <= WAIT;
				end
			end

			DONE: begin
				// Pulse Done for exactly 1 cycle
				Done  <= 1'b1;
				state <= IDLE;
			end

			default: begin
				// Self-recover from X/invalid state (since module has no reset port)
				state <= IDLE;
			end
		endcase
	end

endmodule


