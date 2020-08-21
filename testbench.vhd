LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY testbench4 IS
END testbench4;
ARCHITECTURE behavior OF testbench4 IS
	signal MAX_DATA_WIDTH :integer:=8;
	signal MAX_ADDR_WIDTH : integer := 5;
	signal NO_PRECLOCK : boolean := FALSE;
	signal NUM_PRECLOCK : integer := 3;
	signal counter: integer := 2;
--Master components--
COMPONENT master4
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
	addr_master : IN std_logic_vector(MAX_ADDR_WIDTH - 1 downto 0);
	din_master : IN std_logic_vector(MAX_DATA_WIDTH - 1 downto 0);
	rdy_master : OUT std_logic;
	dout_master : OUT std_logic_vector(MAX_DATA_WIDTH - 1 downto 0);
	valid_master : out std_logic;
	spi_state : out std_logic_vector(2 downto 0);
	SCK : OUT std_logic;
	MDI : IN std_logic;
	MDO : OUT std_logic;
	CS : OUT std_logic;
	byte_master : in std_logic_vector(1 downto 0);
	rorw_send : out std_logic;
	rorw_recieve : out std_logic;
	trigger_master : out integer
);
END COMPONENT;
--Slave components--
component slavemaster4
port (
	address_slave : in std_logic_vector (4 downto 0);
	clk_slave:in std_logic;
	mosi:in std_logic;
	miso :out std_logic;
	valid:in std_logic;
	dout_slave:out std_logic_vector (7 downto 0);
	din_slave:in std_logic_vector (7 downto 0);
	readorwrite : in std_logic;
	trigger_slave :in integer
);
end component;
---Master i/o Signals---
signal address_slave : std_logic_vector (4 downto 0);
signal clk_master : std_logic;
signal reset : std_logic;
signal wr_en_master : std_logic;
signal rd_en_master : std_logic;
signal addr_master : std_logic_vector(MAX_ADDR_WIDTH - 1 downto 0);
signal din_master : std_logic_vector(MAX_DATA_WIDTH - 1 downto 0);
signal rdy_master : std_logic;
signal dout_master : std_logic_vector(MAX_DATA_WIDTH - 1 downto 0);
signal valid_master : std_logic;
signal spi_state : std_logic_vector(2 downto 0);
signal SCK : std_logic;
signal MDI : std_logic;
signal MDO : std_logic;
signal CS : std_logic;
signal byte_master : std_logic_vector(1 downto 0);
signal rorw_send : std_logic;
signal rorw_recieve : std_logic;
signal trigger_master : integer;
---Slave i/o Signals---
signal trigger_slave :integer;
signal clk_slave: std_logic;
signal mosi: std_logic;
signal miso : std_logic;
signal valid: std_logic;
signal dout_slave: std_logic_vector (7 downto 0);
signal din_slave: std_logic_vector (7 downto 0);
signal readorwrite : std_logic;
---Clock period definitions---
constant master_clk_period : time := 10 ps;
BEGIN
	---uut master---
	uut: master4 GENERIC MAP(
		MAX_DATA_WIDTH => MAX_DATA_WIDTH,
		MAX_ADDR_WIDTH => MAX_ADDR_WIDTH,
		NO_PRECLOCK => NO_PRECLOCK,
		NUM_PRECLOCK => NUM_PRECLOCK
	)
	PORT MAP (
		clk_master => clk_master,
		reset => reset,
		wr_en_master => wr_en_master,
		rd_en_master => rd_en_master,
		addr_master => addr_master,
		din_master =>din_master,
		rdy_master =>rdy_master,
		dout_master =>dout_master,
		valid_master =>valid_master,
		spi_state =>spi_state,
		SCK =>SCK,
		MDI =>miso,
		MDO =>MDO,
		CS =>CS,
		byte_master =>byte_master,
		rorw_send =>rorw_send,
		rorw_recieve =>rorw_recieve,
		trigger_master =>trigger_master
	);
	---UUT generic map---
	---uut slave---
	slave_uut: slavemaster4 port map(
		address_slave => addr_master,
		trigger_slave => trigger_master,
		clk_slave => SCK,
		mosi => MDO,
		miso => miso,
		valid => valid,
		dout_slave => dout_slave,
		din_slave => din_slave,
		readorwrite => rorw_send);
	---Clock process definitions---
	master_clk_process :process
	begin
		clk_master <= '0';
		wait for master_clk_period/2;
		clk_master <= '1';
		wait for master_clk_period/2;
	end process;
	---Stimulus process---
	stim_proc: process
	begin
	--clk_slave <= SCK;
		address_slave <= addr_master;
		reset<='1';
		wait for 10 ps;
		reset <= '0';
		wr_en_master<='1';
		rd_en_master <= '0';
		No_Preclock <= FALSE;
		--rdy_master <= '1';
		readorwrite <= rorw_send;
		valid <= '0';
		-- insert stimulus here
		byte_master<="01";
		addr_master<="10011";
		din_master<="10001111";
		mosi <= MDO;
		wait for 500 ps;
		reset <= '1';
		wait for 100 ps;
		reset <='0';
		wr_en_master <= '0';
		rd_en_master <= '1';
		No_Preclock <= FALSE;
		readorwrite <= rorw_send;
		--readorwrite <= rorw_send;
		valid <= '0';
		byte_master <="01";
		addr_master<="10011";
		MDI<=miso;
		--wait for 20 ps;
		-- reset <= '1';
		-- wait for 10 ps;
		-- reset <= '0';
		-- wr_en_master <= '0';
		-- rd_en_master <='1';
		-- No_Preclock <= FALSE;
		-- readorwrite <= rorw_recieve;
		-- addr_master <="10011";
		--wr_en_master<='1';
		-- wait for 500 ps;
		-- reset <= '1';
		-- wait for 10 ps;
		-- reset <= '0';
		-- wr_en_master<='1';
		-- rd_en_master <= '0';
		-- No_Preclock <= FALSE;
		--rdy_master <= '1';
		-- readorwrite <= rorw_send;
		-- valid <= '0';
		-- addr_master<="10101";
		-- din_master<="10010110";
		-- reset<='0';
	wait;
	end process;
END;