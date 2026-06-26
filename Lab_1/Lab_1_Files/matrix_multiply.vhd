----------------------------------------------------------------------------------
-- (c) Rajesh C Panicker, NUS
-- Description : Template for the Matrix Multiply unit for the AXI Stream Coprocessor
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

entity matrix_multiply is
	generic (
		width          : integer := 8; -- width is the number of bits per location
		A_depth_bits   : integer := 3; -- depth is the number of locations (2^number of address bits)
		B_depth_bits   : integer := 2;
		RES_depth_bits : integer := 1
	);
	port (
		clk               : in STD_LOGIC;
		Start             : in STD_LOGIC; -- myip_v1_0 -> matrix_multiply_0.
		Done              : out STD_LOGIC; -- matrix_multiply_0 -> myip_v1_0.

		A_read_en         : out STD_LOGIC; -- matrix_multiply_0 -> A_RAM.
		A_read_address    : out STD_LOGIC_VECTOR (A_depth_bits - 1 downto 0); -- matrix_multiply_0 -> A_RAM.
		A_read_data_out   : in STD_LOGIC_VECTOR (width - 1 downto 0); -- A_RAM -> matrix_multiply_0.

		B_read_en         : out STD_LOGIC; -- matrix_multiply_0 -> B_RAM.
		B_read_address    : out STD_LOGIC_VECTOR (B_depth_bits - 1 downto 0); -- matrix_multiply_0 -> B_RAM.
		B_read_data_out   : in STD_LOGIC_VECTOR (width - 1 downto 0); -- B_RAM -> matrix_multiply_0.

		RES_write_en      : out STD_LOGIC; -- matrix_multiply_0 -> RES_RAM.
		RES_write_address : out STD_LOGIC_VECTOR (RES_depth_bits - 1 downto 0); -- matrix_multiply_0 -> RES_RAM.
		RES_write_data_in : out STD_LOGIC_VECTOR (width - 1 downto 0) -- matrix_multiply_0 -> RES_RAM.
	);

end matrix_multiply;

architecture arch_matrix_multiply of matrix_multiply is

begin
	-- implement the logic to read A_RAM, read B_RAM, do the multiplication and write the results to RES_RAM
	-- Note: A_RAM and B_RAM are to be read synchronously. Read the wiki for more details.

	Done <= Start; -- dummy code. Change as appropriate.

end arch_matrix_multiply;