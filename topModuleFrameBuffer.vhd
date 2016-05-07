use work.all;
library IEEE;
use IEEE. STD_LOGIC_1164. ALL;
use IEEE. STD_LOGIC_ARITH. ALL;
use IEEE. STD_LOGIC_UNSIGNED. ALL;

entity topModuleFrameBuffer is
	Generic (
		vcount_width : integer := 10;
		hcount_width : integer := 11
	);
	Port(
		clk_i: in STD_LOGIC;
		reset_i: in STD_LOGIC;
		hsync_o: out STD_LOGIC;
		vsync_o: out STD_LOGIC;
		color_blue: out STD_LOGIC_VECTOR(1 downto 0);
		color_red: out STD_LOGIC_VECTOR(2 downto 0);
		color_green: out STD_LOGIC_VECTOR(2 downto 0);
		data_o:	out STD_LOGIC_VECTOR(1 downto 0);
		rowIN_i:	in STD_LOGIC_VECTOR(4 downto 0);
		colIN_i: in STD_LOGIC_VECTOR(5 downto 0);
		rowOUT_i: in STD_LOGIC_VECTOR(4 downto 0);
		colOUT_i: in STD_LOGIC_VECTOR(5 downto 0);
		data_i:	in STD_LOGIC_VECTOR(1 downto 0);
		we_i:		in STD_LOGIC
	);
end topModuleFrameBuffer;

architecture Behavioral of topModuleFrameBuffer is
	signal hvidon: STD_LOGIC;
	signal vvidon: STD_LOGIC;
	
	signal rowclk: STD_LOGIC;
	
	signal row: STD_LOGIC_VECTOR(vcount_width-1 downto 0);
	signal column: STD_LOGIC_VECTOR(hcount_width-2 downto 0);

	signal ram_data: STD_LOGIC_VECTOR(1 downto 0);
	signal ram_out_data: STD_LOGIC_VECTOR(1 downto 0); -- data from the ram that goes out
begin

	data_o <= ram_out_data;
	--color_red <= "111";
	--color_green <= "111";
	--color_blue <= "11";

	ram : entity work.RAM32x40
	port map (
		clk_i => clk_i,
		we_i => we_i, -- stikalo ali logicna enica, kasneje to do procesorja
		rowIN_i => rowIN_i,
		colIN_i => colIN_i,
		data_i => data_i,
		rowOUT_i => row(8 downto 4),
		colOUT_i => column(9 downto 4),
		row1OUT_i => rowOUT_i,
		col1OUT_i => colOUT_i,
		data_o => ram_data,
		data1_o => ram_out_data
	);

	h : entity work.hsync
	generic map (
		hcount_width => hcount_width,
		pulse_width => 192, -- 3.84 us
		display_time => 1280, --1280 25.6 us
		front_porch => 50, -- 1.92 us
		back_porch => 96, -- 640 ns
		scan_time => 1600, -- 32.0 us
		column_width => 10	
	)
	port map (
		clk_i => clk_i,
		rst_i => reset_i,
		HSync_o => hsync_o,
		HDataOn_o => hvidon,
		rowclk_o => rowclk,
		column_o => column
	);
	
	v : entity work.vsync
	generic map (
		vcount_width => 10,
		pulse_width => 2,
		display_time => 480,
		front_porch => 5,
		back_porch => 99,
		scan_time => 521
	)
	port map (
		clk_i => clk_i,
		rst_i => reset_i,
		ce_i => rowclk,
		VSync_o => vsync_o,
		VDataOn_o => vvidon,
		row_o => row
	);
	
	
	process(hvidon, vvidon, row, column, ram_data)
	begin
		if (hvidon='1' and vvidon='1') then
			
			if (row=0 or row = 479 or column = 0 or column = 639) then
				color_blue <= "11";
				color_red <= "111";
				color_green <= "111";
			elsif (ram_data(1)='1') then
				color_blue <= "11";
				color_red <= "111";
				color_green <= "111";		
			elsif (ram_data(0)='1') then
				color_blue <= "10";
				color_red <= "010";
				color_green <= "010";				
			else
				color_blue <= "00";
				color_red <= "000";
				color_green <= "000";
			end if;
		else
			color_blue <= "00";
			color_red <= "000";
			color_green <= "000";
		end if;
	end process;
	
end Behavioral;

