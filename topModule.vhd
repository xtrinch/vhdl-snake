
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.all;

entity topModulePS2 is
Generic (width:integer := 4); 
    Port ( 
				clk_i : in  STD_LOGIC;
				kbdclk_i : in  STD_LOGIC;
				kbddata_i: in STD_LOGIC;
				rst_i : in STD_LOGIC;
				anode_o : out STD_LOGIC_VECTOR(3 downto 0); -- the 4 7-segment displays
				cathode_o : out  STD_LOGIC_VECTOR (6 downto 0);  -- one 7-segment display
				ready_o : out STD_LOGIC;
				parity_o : out STD_LOGIC;
				kbd_data_o : out STD_LOGIC_VECTOR(7 downto 0);
				score_data_i : in STD_LOGIC_VECTOR(7 downto 0);
				score_we_i	: in STD_LOGIC
	);
end topModulePS2;

architecture Behavioral of topModulePS2 is

	signal sync_kbdclk : STD_LOGIC; -- sinhroniziran signal keyboard clk
	signal sync_kbddata : STD_LOGIC; -- sinhroniziran signal keyboard data
	signal kbdclk_negclk : STD_LOGIC; -- signal, ki nam pove negativno fronto ure tipkovnice
	signal shr_enable : STD_LOGIC; -- signal, s katerim omogocimo shiftanje v registru
	signal ready : STD_LOGIC; -- signal, ki pove da smo koncali prenos in je celotna koda v registru
	signal kbd_code : STD_LOGIC_VECTOR(8 downto 0); -- podatki o kodi iz tipkovnice in pariteti
	signal prescaler_seg7 : STD_LOGIC; -- enable signal iz prescalerja za preklapljanje anode
	signal score : STD_LOGIC_VECTOR(7 downto 0); -- saved score signal
	
begin

	kbd_data_o <= kbd_code(7 downto 0);
	ready_o <= ready;
	parity_o <= kbd_code(8);
	
	SCORE_SAVE: process(clk_i, score_we_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				score <= (others => '0');
			elsif score_we_i = '1' then
				score <= score_data_i;
			else
				score <= score;
			end if;
		end if;
	end process;	

	 cu : entity work.mealy_control_unit
	 port map (
		clk_i => clk_i,
		sync_kdbdata_i => sync_kbddata,
		kdbclk_negfront_i => kbdclk_negclk,
		rst_i => rst_i,
		shr_enable_o => shr_enable,
		ready_o => ready
	 );

	sce : entity work.shift_register
	port map	(
		input_i => sync_kbddata,
		clk_i => clk_i, 
		rst_i => rst_i, 
		enable_i => shr_enable, -- enable from the control unit into the shift register
		data_o => kbd_code
	);

	sync_kbdclk_signal : entity work.sync_signal
	port map(
		unsynced_i => kbdclk_i,
		synced_o => sync_kbdclk,
		clk_i => clk_i,
		rst_i => rst_i
	);
	
	sync_kbddata_signal : entity work.sync_signal
	port map(
		unsynced_i => kbddata_i,
		synced_o => sync_kbddata,
		clk_i => clk_i,
		rst_i => rst_i	
	);
	
	negfront_det : entity work.negfront_detector
	port map(
		switch_sync_i => sync_kbdclk,
		clk_i => clk_i,
		reset_i => rst_i,
		cenable_o => kbdclk_negclk	
	);
	
	sg7 : entity work.seg7
	port map (
		clk_i => clk_i,
		anodecount_i => prescaler_seg7,
		data_i => score,
		anode_o => anode_o,
		cathode_o => cathode_o
	);
	
	pscaler : entity work.prescaler
	port map (
		clk_i => clk_i,
		enable_o => prescaler_seg7,
		reset_i => rst_i
	);
	

end Behavioral;