library IEEE;
use IEEE. STD_LOGIC_1164. ALL;
use IEEE. STD_LOGIC_ARITH. ALL;
use IEEE. STD_LOGIC_UNSIGNED. ALL;
entity hsync is
	Generic (
		-- this values depend on the input clq frequency and
		-- scan frequency. The following are
		-- for the 50 MHz clk and 60 Hz scan frequency
		hcount_width : integer;
		pulse_width : integer; -- 3.84 us
		display_time : integer; -- 25.6 us
		front_porch : integer; -- 1.92 us
		back_porch : integer; -- 640 ns
		scan_time : integer; -- 32.0 us
		column_width : integer
		
		-- za counter, sirina je 11, saj stejemo do 1600
	);
	Port ( 
		clk_i : in STD_LOGIC;
		rst_i : in STD_LOGIC;
		HSync_o : out STD_LOGIC;
		HDataOn_o : out STD_LOGIC;
		rowclk_o : out STD_LOGIC;
		column_o : out STD_LOGIC_VECTOR ( column_width -1 downto 0)
	);
end hsync ;

architecture Behavioral of hsync is

	signal count: STD_LOGIC_VECTOR( hcount_width - 1 downto 0);

	component counter 
	Generic ( 
		width : integer;
		reset_value : integer
	);
	Port ( 
		clk_i : in  STD_LOGIC;
		reset_i : in  STD_LOGIC;
		enable_i: in STD_LOGIC;
		data_o : out  STD_LOGIC_VECTOR(width-1 downto 0)
	);
	end component;
	
begin

	cntr : counter
	generic map (	
		width => hcount_width,
		reset_value => scan_time - 1
	)
	port map	(
		clk_i => clk_i, 
		reset_i => rst_i, 
		enable_i => '1',
		data_o => count
	);

	column_o <= count(10 downto 1);

	-- proces za hsync
	-- 0, ko smo v podrocju SP, 1, sicer
	p_hsync: process(clk_i, count)
	begin
			if (count > display_time + front_porch - 3 and count < display_time + front_porch + pulse_width - 1) then
				HSync_o <= '0';
			else
				HSync_o <= '1';
			end if;
	end process;
	
	-- proces za hvidon / hdataon
	-- 1, ko smo v vidnem podrocju, 0, sicer
	p_hvidon: process(clk_i, count)
	begin
			if (count < display_time) then
				HDataOn_o <= '1';
			else
				HDataOn_o <= '0';
			end if;
	end process;
	
	-- proces za column
	-- v vidnem podrocju kaže številko trenutnega stolpca v vidnem polju (0 do 639)
	--process(clk_i)
	--begin
	--	if (clk_i'event and clk_i='1') then
	--		column_o <= count(10 downto 1);
	--	end if;
	--end process;
	
	-- proces za rowclk
	-- impulz ob koncu ST (1 UP)
	p_rowclk: process(clk_i, count)
	begin
			if (count = scan_time - 1) then
				rowclk_o <= '1';
			else
				rowclk_o <= '0';
			end if;
	end process;


end Behavioral;

