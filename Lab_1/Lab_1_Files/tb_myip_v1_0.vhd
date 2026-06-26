----------------------------------------------------------------------------------
-- (c) Rajesh C Panicker, NUS
-- Description : Self-checking testbench for Matrix Multiplication AXI Stream Coprocessor.
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
use IEEE.STD_LOGIC_TEXTIO.all;
use std.textio.all;

entity tb_myip_v1_0 is
	-- Port ();
end tb_myip_v1_0;

architecture arch_tb_myip_v1_0 of tb_myip_v1_0 is

	component myip_v1_0
		port (
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
		);
	end component;

	signal ACLK                     : std_logic := '0';
	signal ARESETN                  : std_logic;
	signal S_AXIS_TREADY            : std_logic;
	signal S_AXIS_TDATA             : std_logic_vector(31 downto 0);
	signal S_AXIS_TLAST             : std_logic;
	signal S_AXIS_TVALID            : std_logic;
	signal M_AXIS_TVALID            : std_logic;
	signal M_AXIS_TDATA             : std_logic_vector(31 downto 0);
	signal M_AXIS_TLAST             : std_logic;
	signal M_AXIS_TREADY            : std_logic;

	constant clk_period             : time := 100 ns;

	constant NUMBER_OF_INPUT_WORDS  : integer := 4; -- length of an input vector
	constant NUMBER_OF_OUTPUT_WORDS : integer := 4; -- length of an input vector
	constant NUMBER_OF_TEST_VECTORS : integer := 2; -- number of such test vectors (cases)
	constant width                  : integer := 8; -- width of an input vector

	type test_input_memory_type is array (0 to NUMBER_OF_TEST_VECTORS * NUMBER_OF_INPUT_WORDS - 1) of std_logic_vector(width - 1 downto 0);
	type test_result_memory_type is array (0 to NUMBER_OF_TEST_VECTORS * NUMBER_OF_OUTPUT_WORDS - 1) of std_logic_vector(width - 1 downto 0);

	signal test_input_memory           : test_input_memory_type; -- 4 inputs * 2
	signal test_result_expected_memory : test_result_memory_type; -- 4 outputs *2
	signal result_memory               : test_result_memory_type; -- same size as test_result_expected_memory

	signal M_AXIS_TLAST_prev           : std_logic := '0';

begin
	uut : myip_v1_0
	port map(
		ACLK          => ACLK, 
		ARESETN       => ARESETN, 
		S_AXIS_TREADY => S_AXIS_TREADY, 
		S_AXIS_TDATA  => S_AXIS_TDATA, 
		S_AXIS_TLAST  => S_AXIS_TLAST, 
		S_AXIS_TVALID => S_AXIS_TVALID, 
		M_AXIS_TVALID => M_AXIS_TVALID, 
		M_AXIS_TDATA  => M_AXIS_TDATA, 
		M_AXIS_TLAST  => M_AXIS_TLAST, 
		M_AXIS_TREADY => M_AXIS_TREADY
	);

	clk_process : process
	begin
		ACLK <= '0';
		wait for clk_period / 2;
		ACLK <= '1';
		wait for clk_period / 2;
	end process;

	TLAST_EdgeDetection_process : process (ACLK)
	begin
		if ACLK'EVENT and ACLK = '1' then
			M_AXIS_TLAST_prev <= M_AXIS_TLAST;
		end if;
	end process;

	stimulus                  : process
		file test_input           : TEXT open READ_MODE is "test_input.mem";
		file test_result_expected : TEXT open READ_MODE is "test_result_expected.mem";
		variable Lr               : line;
		variable Lr_hex           : std_logic_vector(width - 1 downto 0);
		variable word_cnt         : integer := 0;
		variable success          : std_logic := '1';

	begin
			-- Note : signal assignments are like non-blocking assignments in Verilog. You will see the updated LHS only when execution hits a wait statement
	 
		report ("Loading Memory.");
		word_cnt := 0;
		while not endfile(test_input) loop
			readline (test_input, Lr);
			if Lr.all'LENGTH = 0 or (Lr.all(1) = '/' and Lr.all(2) = '/') then -- skipping blank lines and those starting with //
				next;
			else
				hread(Lr, Lr_hex); -- Read the argument as hex value
				test_input_memory(word_cnt) <= Lr_hex;
				word_cnt := word_cnt + 1;
			end if;
		end loop;
		word_cnt := 0;
		while not endfile(test_result_expected) loop
			readline (test_result_expected, Lr);
			if Lr.all'LENGTH = 0 or (Lr.all(1) = '/' and Lr.all(2) = '/') then -- skipping blank lines and those starting with //
				next;
			else
				hread(Lr, Lr_hex); -- Read the argument as hex value
				test_result_expected_memory(word_cnt) <= Lr_hex;
				word_cnt := word_cnt + 1;
			end if;
		end loop;
		file_close(test_input);
		file_close(test_result_expected);
		-- done loading memory
	 
		wait for 25 ns; --to make inputs and capture from testbench not aligned with clock edges
		ARESETN       <= '0'; -- apply reset (active low)
		S_AXIS_TVALID <= '0'; -- no valid data placed on the S_AXIS_TDATA yet
		S_AXIS_TLAST  <= '0'; -- not required unless we are dealing with an unknown number of inputs. Ignored by the coprocessor. We will be asserting it correctly anyway
		M_AXIS_TREADY <= '0'; -- not ready to receive data from the co-processor yet.
	 
		wait for 100 ns; -- hold reset for 100 ns.
		ARESETN <= '1'; -- release reset
	 
		for test_case_cnt in 0 to NUMBER_OF_TEST_VECTORS - 1 loop
	 
			--- Input
			word_cnt := 0;
			S_AXIS_TVALID <= '1'; -- data is ready at the input of the coprocessor.
			while word_cnt < NUMBER_OF_INPUT_WORDS loop
				if S_AXIS_TREADY = '1' then -- S_AXIS_TREADY is asserted by the coprocessor in response to S_AXIS_TVALID
					S_AXIS_TDATA <= (32 - width - 1 downto 0 => '0') & test_input_memory(word_cnt + test_case_cnt * NUMBER_OF_INPUT_WORDS); -- set the next data ready
					if word_cnt = NUMBER_OF_INPUT_WORDS - 1 then
						S_AXIS_TLAST <= '1';
					else
						S_AXIS_TLAST <= '0';
					end if;
					word_cnt := word_cnt + 1;
				end if;
				wait for 100 ns; 	-- wait for one clock cycle before for co-processor to capture data (if S_AXIS_TREADY was set)
									-- or before checking S_AXIS_TREADY again (if S_AXIS_TREADY was not set)
			end loop;
		 
			S_AXIS_TVALID <= '0'; -- we no longer give any data to the co-processor
			S_AXIS_TLAST  <= '0';
		 
			--- Output
			-- Note: result_memory is not written at a clock edge, which is fine as it is just a testbench construct and not actual hardware
			word_cnt := 0;
			M_AXIS_TREADY <= '1'; -- we are now ready to receive data
			while M_AXIS_TLAST = '1' or M_AXIS_TLAST_prev = '0' loop -- receive data until the falling edge of M_AXIS_TLAST
				if M_AXIS_TVALID = '1' then
					result_memory(word_cnt + test_case_cnt * NUMBER_OF_OUTPUT_WORDS) <= M_AXIS_TDATA(width - 1 downto 0);
					word_cnt := word_cnt + 1;
				end if;
				wait for 100 ns;
			end loop; -- receive loop
			M_AXIS_TREADY <= '0'; -- not ready to receive data from the co-processor anymore.
		end loop; -- next test vector
	 
		-- checking correctness of results
		for word_cnt in 0 to NUMBER_OF_TEST_VECTORS * NUMBER_OF_OUTPUT_WORDS - 1 loop
			if success = '1' and result_memory(word_cnt) = test_result_expected_memory(word_cnt) then
				success := '1';
			else
				success := '0';
			end if;
		end loop;
		if success = '1' then
			report ("Test Passed.");
		else
			report ("Test Failed.");
		end if;
		wait;
	end process;

end arch_tb_myip_v1_0;