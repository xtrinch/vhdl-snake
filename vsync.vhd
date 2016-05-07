library IEEE;
use IEEE. STD_LOGIC_1164. ALL;
use IEEE. STD_LOGIC_ARITH. ALL;
use IEEE. STD_LOGIC_UNSIGNED. ALL;

entity vsync is
Generic (
	-- this generics are relative to the clock produced
	-- in the hsync module ; so are invariant to main clk frequency
	-- in general , you would not change this values ,
	-- when clk freq changes
	vcount_width : integer;
	pulse_width : integer;
	display_time : integer;
	front_porch : integer;
	back_porch : integer;
	scan_time : integer
);
Port ( 
	clk_i : in STD_LOGIC;
	rst_i : in STD_LOGIC;
	ce_i : in STD_LOGIC;
	VSync_o : out STD_LOGIC;
	VDataOn_o : out STD_LOGIC;
	row_o : out STD_LOGIC_VECTOR ( vcount_width -1 downto 0)
);
end vsync ;
architecture Behavioral of vsync is

	signal vsync: STD_LOGIC;
	signal vvidon: STD_LOGIC;

	signal count: STD_LOGIC_VECTOR( vcount_width - 1 downto 0);

	component counter 
	Generic ( 
		width : integer;
		reset_value : integer
	);
	Port ( 
		clk_i : in  STD_LOGIC;
		reset_i : in  STD_LOGIC;
		enable_i : in STD_LOGIC;
		data_o : out  STD_LOGIC_VECTOR(width-1 downto 0)
	);
	end component;
	
begin

	cntr : counter
	generic map (	
		width => vcount_width,
		reset_value => scan_time-1 -- -1????
	)
	port map	(
		clk_i => clk_i, 
		reset_i => rst_i, 
		enable_i => ce_i,
		data_o => count
	);

	VSync_o <= vsync;
	VDataOn_o <= vvidon;
	
	
	-- row
	-- kaže številko trenutne vrstice v vidnem polju (od 0 do 479)
	row_o <= count;
	
	--process(clk_i, count)
	--begin
	--	if (clk_i'event and clk_i='1' and ce_i='1') then
	--		if (rst_i='0') then
	--			if(count>scan_time) then
	--				count <= (others => '0');
	--			else
	--				count <= count + 1;
	--			end if;
	--		elsif (count>scan_time) then
	--			count <= (others => '0');
	--		else
	--			count <= (others => '0');
	--		end if;
			
	--	end if ;
	--end process;
	
	-- vsync
	-- 0, ko smo v podrocju SP, 1, sicer
	process(clk_i, count)
	begin
		if (count > display_time + front_porch - 3 and count < display_time + front_porch + pulse_width - 1) then
			vsync <= '0';
		else
			vsync <= '1';
		end if;
	end process;
	
	-- vvidon
	-- 1, ko smo v vidnem podrocju, 0, sicer
	process(clk_i, count)
	begin
		-- if (count < display_time ) then
		if (count < display_time) then
			vvidon <= '1';
		else
			vvidon <= '0';
		end if;
	end process;

end Behavioral;