----------------------------------------------------------------------------------
-- (c) Rajesh C Panicker, NUS
-- Description : Matrix Multiplication AXI Stream Coprocessor. Based on the orginal AXIS Coprocessor template (c) Xilinx Inc
-- License terms :
-- You are free to use this code as long as you
-- (i) DO NOT post a modified version of this on any public repository;
-- (ii) use it only for educational purposes;
-- (iii) accept the responsibility to ensure that your implementation does not violate any intellectual property of any entity.
-- (iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
-- (v) send an email to rajesh.panicker@ieee.org briefly mentioning its use (except when used for the course EE4218 at the National University of Singapore);
-- (vi) retain this notice in this file or any files derived from this.
----------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
-- Definition of Ports
-- ACLK : Synchronous clock
-- ARESETN : System reset, active low
-- S_AXIS_TREADY : Ready to accept data in
-- S_AXIS_TDATA : Data in
-- S_AXIS_TLAST : Optional data in qualifier
-- S_AXIS_TVALID : Data in is valid
-- M_AXIS_TVALID : Data out is valid
-- M_AXIS_TDATA : Data Out
-- M_AXIS_TLAST : Optional data out qualifier
-- M_AXIS_TREADY : Connected slave device is ready to accept data out
--
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-------------------------------------------------------------------------------------
--
--
-- Definition of Ports
-- ACLK : Synchronous clock
-- ARESETN : System reset, active low
-- S_AXIS_TREADY : Ready to accept data in
-- S_AXIS_TDATA : Data in
-- S_AXIS_TLAST : Optional data in qualifier
-- S_AXIS_TVALID : Data in is valid
-- M_AXIS_TVALID : Data out is valid
-- M_AXIS_TDATA : Data Out
-- M_AXIS_TLAST : Optional data out qualifier
-- M_AXIS_TREADY : Connected slave device is ready to accept data out
--
-------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Entity Section
------------------------------------------------------------------------------

entity myip_v1_0 is
	port (
		-- DO NOT EDIT BELOW THIS LINE ---------------------
		-- Bus protocol ports, do not add or delete.
		ACLK          : in std_logic;
		ARESETN       : in std_logic;
		S_AXIS_TREADY : out std_logic;
		S_AXIS_TDATA  : in std_logic_vector(31 downto 0);
		S_AXIS_TLAST  : in std_logic;
		S_AXIS_TVALID : in std_logic;
		M_AXIS_TVALID : out std_logic;
		M_AXIS_TDATA  : out std_logic_vector(31 downto 0);
		M_AXIS_TLAST  : out std_logic;
		M_AXIS_TREADY : in std_logic
		-- DO NOT EDIT ABOVE THIS LINE ---------------------
	);

	attribute SIGIS         : string;
	attribute SIGIS of ACLK : signal is "Clk";

end myip_v1_0;

------------------------------------------------------------------------------
-- Architecture Section
------------------------------------------------------------------------------

-- In this section, we povide an example implementation of ENTITY hw_acc
-- that does the following:
--
-- 1. Read all inputs
-- 2. Add each input to the contents of register 'sum' which acts as an accumulator
-- 3. After all the inputs have been read, write out the content of 'sum', 'sum+1', 'sum+2', 'sum+3'
--
-- You will need to modify this example or implement a new architecture for
-- ENTITY hw_acc to implement your coprocessor

architecture EXAMPLE of myip_v1_0 is

	component matrix_multiply is
		generic (
			width          : integer := 8;
			A_depth_bits   : integer := 3;
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

	end component;

	component memory_RAM is
		generic (
			width      : integer := 8;
			depth_bits : integer := 2
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
	end component;

	-- RAM parameters for assignment 1
	constant A_depth_bits   : integer := 3; -- 8 elements (A is a 2x4 matrix)
	constant B_depth_bits   : integer := 2; -- 4 elements (B is a 4x1 matrix)
	constant RES_depth_bits : integer := 1; -- 2 elements (RES is a 2x1 matrix)
	constant width          : integer := 8; -- all 8-bit data

	-- signals to connect to RAMs and matrix_multiply_0 for assignment 1
	signal A_write_en        : STD_LOGIC; -- myip_v1_0 -> A_RAM. To be assigned within myip_v1_0.
	signal A_write_address   : STD_LOGIC_VECTOR (A_depth_bits - 1 downto 0); -- myip_v1_0 -> A_RAM. To be assigned within myip_v1_0.
	signal A_write_data_in   : STD_LOGIC_VECTOR (width - 1 downto 0); -- myip_v1_0 -> A_RAM. To be assigned within myip_v1_0.
	signal A_read_en         : STD_LOGIC; -- matrix_multiply_0 -> A_RAM.
	signal A_read_address    : STD_LOGIC_VECTOR (A_depth_bits - 1 downto 0); -- matrix_multiply_0 -> A_RAM.
	signal A_read_data_out   : STD_LOGIC_VECTOR (width - 1 downto 0); -- A_RAM -> matrix_multiply_0.
	signal B_write_en        : STD_LOGIC; -- myip_v1_0 -> B_RAM. To be assigned within myip_v1_0.
	signal B_write_address   : STD_LOGIC_VECTOR (B_depth_bits - 1 downto 0); -- myip_v1_0 -> B_RAM. To be assigned within myip_v1_0.
	signal B_write_data_in   : STD_LOGIC_VECTOR (width - 1 downto 0); -- myip_v1_0 -> B_RAM. To be assigned within myip_v1_0.
	signal B_read_en         : STD_LOGIC; -- matrix_multiply_0 -> B_RAM.
	signal B_read_address    : STD_LOGIC_VECTOR (B_depth_bits - 1 downto 0); -- matrix_multiply_0 -> B_RAM.
	signal B_read_data_out   : STD_LOGIC_VECTOR (width - 1 downto 0); -- B_RAM -> matrix_multiply_0.
	signal RES_write_en      : STD_LOGIC; -- matrix_multiply_0 -> RES_RAM.
	signal RES_write_address : STD_LOGIC_VECTOR (RES_depth_bits - 1 downto 0);-- matrix_multiply_0 -> RES_RAM.
	signal RES_write_data_in : STD_LOGIC_VECTOR (width - 1 downto 0); -- matrix_multiply_0 -> RES_RAM.
	signal RES_read_en       : STD_LOGIC; -- myip_v1_0 -> RES_RAM. To be assigned within myip_v1_0.
	signal RES_read_address  : STD_LOGIC_VECTOR (RES_depth_bits - 1 downto 0); -- myip_v1_0 -> RES_RAM. To be assigned within myip_v1_0.
	signal RES_read_data_out : STD_LOGIC_VECTOR (width - 1 downto 0); -- RES_RAM -> myip_v1_0

	-- signals to connect to matrix_multiply for assignment 1
	signal Start : STD_LOGIC; -- myip_v1_0 -> matrix_multiply_0. To be assigned within myip_v1_0.
	signal Done  : STD_LOGIC; -- matrix_multiply_0 -> myip_v1_0.

	-- Total number of input data.
	constant NUMBER_OF_INPUT_WORDS : natural := 4; -- 2**A_depth_bits + 2**B_depth_bits = 12 for assignment 1

	-- Total number of output data
	constant NUMBER_OF_OUTPUT_WORDS : natural := 4; -- 2**RES_depth_bits = 2 for assignment 1

	type STATE_TYPE is (Idle, Read_Inputs, Compute, Write_Outputs);

	signal state : STATE_TYPE;

	-- Accumulator to hold sum of inputs read at any point in time
	signal sum : std_logic_vector(31 downto 0);

	-- Counters to store the number inputs read & outputs written.
	-- Could be done using the same counter if reads and writes are not overlapped (i.e., no dataflow optimization)
	-- Left as separate for ease of debugging
	signal read_counter  : natural range 0 to NUMBER_OF_INPUT_WORDS - 1;
	signal write_counter : natural range 0 to NUMBER_OF_OUTPUT_WORDS - 1;
	
begin
	-- CAUTION:
	-- The sequence in which data are read in and written out should be
	-- consistent with the sequence they are written and read in the driver's hw_acc.c file

	The_SW_accelerator : process (ACLK) is
	begin
		-- implemented as a single-process Moore machine
		-- a Mealy machine that asserts S_AXIS_TREADY and captures S_AXIS_TDATA etc can save a clock cycle
		if ACLK'EVENT and ACLK = '1' then -- Rising clock edge
			if ARESETN = '0' then -- Synchronous reset (active low)
				-- CAUTION: make sure your reset polarity is consistent with the system reset polarity
				state        <= Idle;
			else
				case state is
					when Idle => 
						read_counter <= 0;
						write_counter <= 0;
						sum          <= (others => '0');
						S_AXIS_TREADY <= '0';
						M_AXIS_TVALID <= '0';
						M_AXIS_TLAST  <= '0';
						if (S_AXIS_TVALID = '1') then
							state       <= Read_Inputs;
							S_AXIS_TREADY <= '1'; 
							-- start receiving data once you go into Read_Inputs
						end if;

					when Read_Inputs => 
						S_AXIS_TREADY <= '1';
						if (S_AXIS_TVALID = '1') then
							-- Coprocessor function (adding the numbers together) happens here (partly)
							sum <= std_logic_vector(unsigned(sum) + unsigned(S_AXIS_TDATA));
							-- If we are expecting a variable number of words, we should make use of S_AXIS_TLAST.
							-- Since the number of words we are expecting is fixed, we simply count and receive 
							-- the expected number (NUMBER_OF_INPUT_WORDS) instead.
							if (read_counter = NUMBER_OF_INPUT_WORDS-1) then
								state        <= Compute;
								S_AXIS_TREADY <= '0';
							else
								read_counter <= read_counter + 1;
							end if;
						end if;

					when Compute => 
						-- Coprocessor function to be implemented (matrix multiply) should be here. Right now, nothing happens here.
						state        <= Write_Outputs;
						-- Possible to save a cycle by asserting M_AXIS_TVALID and presenting M_AXIS_TDATA just before going into 
						-- Write_Outputs state. However, need to adjust write_counter limits accordingly
						-- Alternatively, M_AXIS_TVALID and M_AXIS_TDATA can be asserted combinationally to save a cycle.
						
					when Write_Outputs => 
						M_AXIS_TVALID <= '1';
						-- Coprocessor function (adding 1 to sum in each iteration = adding iteration count to sum) happens here (partly)
						M_AXIS_TDATA  <= std_logic_vector(unsigned(sum) + write_counter);
						if (M_AXIS_TREADY = '1') then
							if (write_counter = NUMBER_OF_OUTPUT_WORDS-1) then
								state <= Idle;
								M_AXIS_TLAST <= '1';
								-- M_AXIS_TLAST, though optional in AXIS, is necessary in practice as AXI Stream FIFO and AXI DMA expects it.
							else
								write_counter <= write_counter + 1;
							end if;
						end if;
				end case;
			end if;
		end if;
	end process The_SW_accelerator;

	-- Connection to sub-modules / components for assignment 1

	A_RAM : memory_RAM
		generic map(
		width      => width, 
		depth_bits => A_depth_bits
		)
		port map(
			clk           => ACLK, 
			write_en      => A_write_en, 
			write_address => A_write_address, 
			write_data_in => A_write_data_in, 
			read_en       => A_read_en, 
			read_address  => A_read_address, 
			read_data_out => A_read_data_out
		);
	
	B_RAM : memory_RAM
		generic map(
		width      => width, 
		depth_bits => B_depth_bits
		)
		port map(
			clk           => ACLK, 
			write_en      => B_write_en, 
			write_address => B_write_address, 
			write_data_in => B_write_data_in, 
			read_en       => B_read_en, 
			read_address  => B_read_address, 
			read_data_out => B_read_data_out
		);
	
	RES_RAM : memory_RAM
		generic map(
		width      => width, 
		depth_bits => RES_depth_bits
		)
		port map(
			clk           => ACLK, 
			write_en      => RES_write_en, 
			write_address => RES_write_address, 
			write_data_in => RES_write_data_in, 
			read_en       => RES_read_en, 
			read_address  => RES_read_address, 
			read_data_out => RES_read_data_out
		);

	matrix_multiply_0 : matrix_multiply
		generic map(
		width          => width, 
		A_depth_bits   => A_depth_bits, 
		B_depth_bits   => B_depth_bits, 
		RES_depth_bits => RES_depth_bits
		)
		port map(
			clk               => ACLK, 
			Start             => Start, 
			Done              => Done, 

			A_read_en         => A_read_en, 
			A_read_address    => A_read_address, 
			A_read_data_out   => A_read_data_out, 

			B_read_en         => B_read_en, 
			B_read_address    => B_read_address, 
			B_read_data_out   => B_read_data_out, 

			RES_write_en      => RES_write_en, 
			RES_write_address => RES_write_address, 
			RES_write_data_in => RES_write_data_in
		);

	end architecture EXAMPLE;

