library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use IEEE.std_logic_textio.all;
use ieee.std_logic_unsigned.all;
--use ieee.std_logic_arith_unsigned.all;
library std;
use std.textio.all;
entity slavemaster4 is
port ( clk_slave:in std_logic;
	mosi:in std_logic;
	miso :out std_logic;
	valid:in std_logic;
	dout_slave:out std_logic_vector (7 downto 0);
	din_slave:in std_logic_vector (7 downto 0);
	readorwrite : in std_logic;
	address_slave : in std_logic_vector (4 downto 0);
	trigger_slave : in integer := 0
);
end slavemaster4;
architecture slave_spi of slavemaster4 is
	type ram_type is array (0 to 255) of std_logic_vector(7 downto 0);
	signal ram1 : ram_type:=(others => (others => '0'));
	--signal read_address : std_logic_vector(4 downto 0);
	file file3 :text;
	signal rorw:std_logic := '0';
	signal slave_send_int : std_logic:= '0';
	signal slave_recieve_int: std_logic := '0';
	signal din_vector : std_logic_vector(7 downto 0):= (others => '0');
	signal dout_vector : std_logic_vector(7 downto 0):= (others => '0');
	signal index_slave : integer := 0;
	signal trigger_slave1 : integer :=0;
	signal addrslave : std_logic_vector (4 downto 0);
begin
	addrslave <= address_slave;
	slave_recieve_int <= mosi;
	trigger_slave1 <= trigger_slave;
	--din_vector <= din_slave;
	rorw <= readorwrite;
	--din_vector <= ram1(conv_integer(addrslave));
	process begin
		file_open(file3, "output_results1.txt", write_mode);
		wait;
	end process;
	process(clk_slave)
		variable v_oline : line;
	begin
		if (rorw = '0') then
		--- recieve data ---
			if(falling_edge(clk_slave)) then
				if(index_slave = 7) then
					write(v_oline,slave_recieve_int);
					writeline(file3,v_oline);
					dout_vector <= dout_vector(8-2 downto 0) & slave_recieve_int;
					index_slave <= 0;
				elsif(valid ='0') then
					dout_vector <= dout_vector(8-2 downto 0) & slave_recieve_int;
					write(v_oline,slave_recieve_int);
					writeline(file3,v_oline);
					index_slave <= index_slave +1;
					--ram1(slavecounter) <= slave_recieve_int;
				end if;
			end if;
		elsif (rorw = '1') then
			--din_vector <= ram1(conv_integer(address_slave));
			din_vector <= ram1(conv_integer(addrslave));
			if (falling_edge(clk_slave) and index_slave < 8) then
				slave_send_int<= din_vector(index_slave);
				index_slave <= index_slave+1;
			elsif(index_slave =8) then
				index_slave <= 0;
			end if;
		--- send data ---
		--if(falling_edge(clk_slave)) then
		-- if(index_slave = 7) then
		-- slave_send_int <= din_vector(8 - 1);
		-- din_vector <= din_vector(8 -2 downto 0) & '0';
		-- index_slave <= 0;
		-- elsif(valid = '0') then
		-- slave_send_int <= din_vector(8 - 1);
		-- din_vector <= din_vector(8 -2 downto 0) & '0';
		-- index_slave <= index_slave + 1;
		-- end if;
		--end if;
		end if;
	end process;
	miso<=slave_send_int;
	dout_slave <=dout_vector;
	ram1(conv_integer(address_slave)) <= dout_vector;
	--read_address <= address_slave;
end slave_spi;