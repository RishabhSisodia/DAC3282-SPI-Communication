library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity master4 is
generic (
	MAX_DATA_WIDTH : integer := 8;
	MAX_ADDR_WIDTH : integer := 5;
	NO_PRECLOCK : boolean := FALSE;
	NUM_PRECLOCK : integer := 3;
	counter: integer := 2
);
PORT(
	clk_master : IN std_logic;
	reset : IN std_logic;
	wr_en_master : IN std_logic;
	rd_en_master : IN std_logic;
	addr_master : IN std_logic_vector(MAX_ADDR_WIDTH - 1 downto 0):=(others => '0');
	din_master : IN std_logic_vector(MAX_DATA_WIDTH - 1 downto 0):=(others => '0');
	rdy_master : OUT std_logic;
	dout_master : OUT std_logic_vector(MAX_DATA_WIDTH - 1 downto 0):=(others => '0');
	valid_master : out std_logic;
	spi_state : out std_logic_vector(2 downto 0);
	SCK : OUT std_logic;
	MDI : IN std_logic;
	MDO : OUT std_logic;
	CS : OUT std_logic;
	byte_master : in std_logic_vector(counter-1 downto 0) := (others => '0');
	rorw_send : out std_logic;
	rorw_recieve : out std_logic ;
	trigger_master :out integer
);
end master4;
architecture rtl of master4 is
type state_type is (idle, send_preclock, send_addr, send_rw_bit,send_data,receive_data, send_postclock,n0_n1);
signal state : state_type;
signal SCK_int : std_logic := '0';
signal CS_int : std_logic := '0';
signal DAC_RECEIVE_int: std_logic := '0';
signal doing_write : std_logic := '0';
signal doing_read : std_logic := '0';
signal rdy_int : std_logic := '1';
signal addr_int : std_logic_vector(MAX_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal din_int : std_logic_vector(MAX_DATA_WIDTH - 1 downto 0):= (others => '0');
signal dout_int : std_logic_vector(MAX_DATA_WIDTH - 1 downto 0):= (others => '0');
signal DAC_SEND_int : std_logic := '0';
signal valid_int : std_logic := '0';
signal NUM_POSTCLOCK : integer := NUM_PRECLOCK + 2;
signal byte_int : std_logic_vector(1 downto 0) := (others => '0');
signal index_int : integer range 0 to 100 := 0;
signal rorw_master_send : std_logic := '1';
signal rorw_master_recieve : std_logic := '0';
signal wr_en_master_metastable : std_logic;
signal wr_en_master_clksync : std_logic;
signal wr_en_master_clksync_dly1 : std_logic;
signal wr_en_master_rising_edge : std_logic;
signal rd_en_master_metastable : std_logic;
signal rd_en_master_clksync : std_logic;
signal rd_en_master_clksync_dly1 : std_logic;
signal rd_en_master_rising_edge : std_logic;
signal trigger : integer := 0;
begin
	DAC_RECEIVE_int <= MDI;
	--byte_int <= byte_master;
	--clock synchronization--
	process(reset, clk_master)
	begin
		if (reset = '1') then
			wr_en_master_metastable <= '0';
			wr_en_master_clksync <= '0';
			wr_en_master_clksync_dly1 <= '0';
			wr_en_master_rising_edge <= '0';
		elsif rising_edge(clk_master) then
			wr_en_master_metastable <= wr_en_master;
			wr_en_master_clksync <= wr_en_master_metastable;
			wr_en_master_clksync_dly1 <= wr_en_master_clksync;
			wr_en_master_rising_edge <= wr_en_master_clksync and not(wr_en_master_clksync_dly1);
		end if;
	end process;
	process(reset, clk_master)
	begin
		if (reset = '1') then
			rd_en_master_metastable <= '0';
			rd_en_master_clksync <= '0';
			rd_en_master_clksync_dly1 <= '0';
			rd_en_master_rising_edge <= '0';
		elsif rising_edge(clk_master) then
			rd_en_master_metastable <= rd_en_master;
			rd_en_master_clksync <= rd_en_master_metastable;
			rd_en_master_clksync_dly1 <= rd_en_master_clksync;
			rd_en_master_rising_edge <= rd_en_master_clksync and not(rd_en_master_clksync_dly1);
		end if;
	end process;
	process(reset, clk_master)
	begin
		if (reset = '1') then
			index_int <= 0;
			valid_int <= '0';
			rdy_int <= '1';
		elsif rising_edge(clk_master) then
			valid_int <= '0';
			case state is
				when idle =>
				CS_int <= '0';
				SCK_int <= '0';
				DAC_SEND_int <= '0';
				index_int <= 0 ;
				doing_write <= '0';
				doing_read <= '0';
				rdy_int <= '1';
				valid_int <= '0';
				rorw_master_send <= '1';
				rorw_master_recieve <='0';
					if(rdy_int = '1' and (wr_en_master_rising_edge = '1' or rd_en_master_rising_edge = '1')) then
						if (No_Preclock = FALSE) then
							state <= send_preclock;
						else
							state <= send_rw_bit;
							CS_int <= '1';
						end if;
						addr_int <= addr_master;
						din_int <= din_master;
						byte_int <= byte_master;
						rdy_int <= '0';
						if(wr_en_master_rising_edge = '1') then
							doing_write <= '1';
						elsif(rd_en_master_rising_edge = '1') then
							doing_read <= '1';
						end if;
					end if;
				when send_preclock =>
				SCK_int <= not(SCK_int);
					if(index_int = NUM_PRECLOCK - 2 and SCK_int = '1') then
					--if(SCK_int ='1') then
						index_int <= 0;
						state <= send_rw_bit;
					elsif(SCK_int = '1') then
						index_int <= index_int + 1;
					end if;
				when send_rw_bit =>
					--SCK_int <= not(SCK_int);
					if(doing_write = '1' and SCK_int = '1') then
						CS_int <= '1';
						index_int <= 0;
						DAC_SEND_int <= '1';
						state <= n0_n1;
					--DAC_SEND_int <= '1';
					elsif(doing_read = '1' and SCK_int = '1') then
						CS_int <= '1';
						index_int <= 0;
						state <= n0_n1;
						DAC_SEND_int <= '0';
					end if;
					SCK_int <= not(SCK_int);
				when n0_n1 =>
				SCK_int <= not(SCK_int);
					if((index_int = 1) and SCK_int ='1') then
						DAC_SEND_int <= byte_int(1);
						byte_int <= byte_int(0) & '0';
						index_int <=0;
						state <= send_addr;
					elsif(SCK_int ='1') then
						DAC_SEND_int <= byte_int(1);
						byte_int <= byte_int(0) &'0';
						index_int <= index_int+1;
					end if;
				when send_addr =>
				SCK_int <= not(SCK_int);
					if((index_int = MAX_ADDR_WIDTH-1 ) and SCK_int = '1') then
						DAC_SEND_int <= addr_int(MAX_ADDR_WIDTH - 1);
						addr_int <= addr_int(MAX_Addr_WIDTH-2 downto 0) & '0';
						index_int <= 0;
						trigger <= 1;
						if doing_read = '1' then
							state <= receive_data;
						else
							state <= send_data;
						end if;
					elsif(SCK_int = '1') then
						index_int <= index_int + 1;
						DAC_SEND_int <= addr_int(MAX_ADDR_WIDTH - 1);
						addr_int <= addr_int(MAX_Addr_WIDTH-2 downto 0) & '0';
					end if;
				when send_data =>
				SCK_int <= not(SCK_int);
				rorw_master_send <= '0';
					if(index_int = MAX_DATA_WIDTH-1 and SCK_int = '1') then
						DAC_SEND_int <= din_int(MAX_DATA_WIDTH - 1);
						din_int <= din_int(MAX_DATA_WIDTH-2 downto 0) & '0';
						index_int <= 0;
						trigger <= 0;
						state <= send_postclock;
					elsif(SCK_int = '1') then
						index_int <= index_int + 1;
						DAC_SEND_int <= din_int(MAX_DATA_WIDTH - 1);
						din_int <= din_int(MAX_DATA_WIDTH-2 downto 0) & '0';
					end if;
				when receive_data =>
				SCK_int <= not(SCK_int);
				rorw_master_send <= '1';
					--DAC_SEND_int <= 'Z';
					if(index_int = MAX_DATA_WIDTH-1 and SCK_int = '0') then
						dout_int <= dout_int(MAX_DATA_WIDTH-2 downto 0) & DAC_RECEIVE_int;
						index_int <= 0;
						state <= idle;
						valid_int <= '1';
					elsif(SCK_int = '0') then
						dout_int <= dout_int(MAX_DATA_WIDTH-2 downto 0) & DAC_RECEIVE_int;
						index_int <= index_int +1;
					end if;
				when send_postclock =>
					if(index_int = 0 ) then
						SCK_int <= not(SCK_int);
						index_int <= index_int+1;
					elsif(index_int = 1) then
						state <= idle;
						index_int <= 0;
					end if;
			end case;
		end if;
	end process;
	spi_state <= "000" when state = idle else
	"001" when state = send_preclock else
	"010" when state = send_addr else
	"011" when state = send_rw_bit else
	"100" when state = send_data else
	"101" when state = receive_data else
	"110" when state = send_postclock else
	"111" when state = n0_n1;
	CS <= not CS_int;
	SCK <= SCK_int;
	rdy_master <= rdy_int;
	MDO <= DAC_SEND_int;
	dout_master <= dout_int;
	valid_master <= valid_int;
	rorw_send <= rorw_master_send;
	trigger_master <= trigger;
end rtl;