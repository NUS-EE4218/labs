`timescale 1ns / 1ps

// width is the number of bits per location; depth_bits is the number of address bits. 2^depth_bits is the number of locations

module memory_RAM
	#(
		parameter width = 8, 					// width is the number of bits per location
		parameter depth_bits = 2				// depth is the number of locations (2^number of address bits)
	) 
	(
		input clk,
		input write_en,
		input [depth_bits-1:0] write_address,
		input [width-1:0] write_data_in,
		input read_en,    
		input [depth_bits-1:0] read_address,
		output reg [width-1:0] read_data_out
	);
    
    reg [width-1:0] RAM [0:2**depth_bits-1];
    wire [depth_bits-1:0] address;
    wire enable;
    
    // to convert external signals to a form followed in the template given in Vivado synthesis manual. 
    // Not really necessary, but to follow the spirit of using templates
    assign enable = read_en | write_en;
    assign address = write_en? write_address:read_address;
    
  	// the following is from a template given in Vivado synthesis manual.
  	// Read up more about write first, read first, no change modes.

	always @(posedge clk)
	begin
		 if (enable)
		 begin
			if (write_en)
				RAM[address] <= write_data_in;
		 else
			read_data_out <= RAM[address];
		 end
	end

endmodule
