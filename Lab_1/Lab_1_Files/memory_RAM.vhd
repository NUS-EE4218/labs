----------------------------------------------------------------------------------
-- Description : Module implementing a single port fully synchronous RAM to act as local memory for the AXI Stream Coprocessor
-- (c) Rajesh C Panicker, NUS
-- License terms :
-- You are free to use this code as long as you
-- (i) DO NOT post a modified version of this on any public repository;
-- (ii) use it only for educational purposes;
-- (iii) accept the responsibility to ensure that your implementation does not violate any intellectual property of any entity.
-- (iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
-- (v) send an email to rajesh.panicker@ieee.org briefly mentioning its use (except when used for the course EE4218 at the National University of Singapore);
-- (vi) retain this notice in this file or any files derived from this.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity memory_RAM is
	generic (
		width      : integer := 8; -- width is the number of bits per location
		depth_bits : integer := 2 -- depth is the number of locations (2^number of address bits)
	);
	port (
		clk           : in STD_LOGIC;
		write_en      : in STD_LOGIC;
		write_address : in STD_LOGIC_VECTOR (depth_bits - 1 downto 0);
		write_data_in : in STD_LOGIC_VECTOR (width - 1 downto 0);
		read_en       : in STD_LOGIC;
		read_address  : in STD_LOGIC_VECTOR (depth_bits - 1 downto 0);
		read_data_out : out STD_LOGIC_VECTOR (width - 1 downto 0)
	);
end memory_RAM;

architecture arch_memory_RAM of memory_RAM is
	type ram_type is array (0 to 2 ** depth_bits - 1) of std_logic_vector(width - 1 downto 0);
	signal RAM     : ram_type;
	signal address : std_logic_vector(depth_bits - 1 downto 0);
	signal enable  : std_logic;

begin
	-- to convert external signals to a form followed in the template given in Vivado synthesis manual.
	-- Not really necessary, but to follow the spirit of using templates
	enable  <= read_en or write_en;
	address <= write_address when write_en = '1' else
	           read_address;

	-- the following is from a template given in Vivado synthesis manual.
	-- Read up more about write first, read first, no change modes.

	process (clk)
	begin
		if clk'EVENT and clk = '1' then
			if enable = '1' then
				if write_en = '1' then
					RAM(to_integer(unsigned(address))) <= write_data_in;
				else
					read_data_out <= RAM(to_integer(unsigned(address)));
				end if;
			end if;
		end if;
	end process;

end arch_memory_RAM;