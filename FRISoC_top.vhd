----------------------------------------------------------------------------------
-- Company: FRI, Uni-Lj
-- Engineer: Patricio Bulic
-- 
-- Create Date:    16:06:18 06/27/2012 
-- Design Name: 
-- Module Name:    FRISoC_top - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FRISoC_top is
    Port ( 
		clk_i 			: in  STD_LOGIC;
		rst_i 			: in  STD_LOGIC;
		led_o 			: out  STD_LOGIC_VECTOR (7 downto 0);

		hsync_o			: out STD_LOGIC;
		vsync_o			: out STD_LOGIC;
		color_blue_o	: out STD_LOGIC_VECTOR(1 downto 0);
		color_red_o		: out STD_LOGIC_VECTOR(2 downto 0);
		color_green_o	: out STD_LOGIC_VECTOR(2 downto 0);
		kbd_data_o		: out STD_LOGIC_VECTOR(7 downto 0);
		
		anode_o 			: out STD_LOGIC_VECTOR(3 downto 0); -- the 4 7-segment displays
		cathode_o 		: out  STD_LOGIC_VECTOR (6 downto 0);  -- one 7-segment display
		
		kbdclk_i 		: in  STD_LOGIC;
		kbddata_i		: in STD_LOGIC
	);
end FRISoC_top;

architecture Behavioral of FRISoC_top is

	signal instruction_signal 		: std_logic_vector(17 downto 0);
	signal in_port_signal 			: std_logic_vector(7 downto 0);
	signal interrupt_signal 		: std_logic;
	signal address_signal 			: std_logic_vector(9 downto 0);
	signal port_id_signal 			: std_logic_vector(7 downto 0);
	signal write_strobe_signal 	: std_logic;
	signal out_port_signal 			: std_logic_vector(7 downto 0);
	signal read_strobe_signal 		: std_logic;
	signal interrupt_ack_signal 	: std_logic;
	
	-- framebuffer ram signals
	signal fb_row							: std_logic_vector(4 downto 0);
	signal fb_col							: std_logic_vector(5 downto 0);
	signal fb_data							: std_logic_vector(1 downto 0);
	signal fb_we							: std_logic;
	signal fb_data1						: std_logic_vector(1 downto 0);
	
	signal led 			: std_logic_vector(7 downto 0);
	signal led_reg 			: std_logic_vector(7 downto 0);
	
	signal rand				: std_logic_vector(5 downto 0);
	signal ps2_data		: std_logic_vector(7 downto 0);
	signal ps2_code_ready	: std_logic; -- interrupt signal (a key has been pressed on the keyboard)
	
	-- port id signals for kcpsm3
	
	signal ps2_sel	: std_logic;
	signal fb_col_sel : std_logic; -- frame buffer column select signal
	signal fb_row_sel : std_logic;
	signal fb_data_sel : std_logic;
	signal rnd_sel : std_logic;
	
	-- ps2 signals
	
	signal ps2_score : std_logic_vector(7 downto 0);
	signal ps2_we	: std_logic;	-- write enable for score
begin

	led_o					<= led_reg;
	kbd_data_o 			<= ps2_data;
	
	kcpsm3: entity work.kcpsm3 PORT MAP(
		address 			=> address_signal,
		instruction 	=> instruction_signal,
		port_id 			=> port_id_signal,
		write_strobe 	=> write_strobe_signal,
		out_port 		=> out_port_signal,
		read_strobe 	=> read_strobe_signal,
		in_port 			=> in_port_signal,
		interrupt 		=> interrupt_signal,
		interrupt_ack 	=> interrupt_ack_signal,
		reset 			=> rst_i,
		clk 				=> clk_i
	);

	
	firmware: entity work.snake PORT MAP(
		address 			=> address_signal,
		instruction 	=> instruction_signal,
		clk 				=> clk_i 
	);
	
	ps2 : entity work.topModulePS2 PORT MAP(
		clk_i 				=> clk_i,
		kbdclk_i 			=> kbdclk_i, --from the keyboard into ps2 module
		kbddata_i 			=> kbddata_i, -- from the keyboard into ps2 module
		rst_i 				=> rst_i,
		anode_o 				=> anode_o, -- keyboard code to 7seg
		cathode_o 			=> cathode_o, -- keyboard code to 7seg
		ready_o 				=> ps2_code_ready, -- finished reading a code from keyboard
		--parity_o 			=> '0', -- TODO
		kbd_data_o 			=> ps2_data, -- keyboard code into picoblaze
		score_data_i 		=> ps2_score, -- keyboard code from picoblaze
		score_we_i			=> ps2_we
	);
	
	vgaFrameBuffer: entity work.topModuleFrameBuffer PORT MAP(
		clk_i				=> clk_i,
		reset_i 			=> rst_i,
		hsync_o 			=> hsync_o, -- horizontal screen sync signal
		vsync_o 			=> vsync_o, -- vertical screen sync signal
		color_blue 		=> color_blue_o,
		color_red 		=> color_red_o,
		color_green 	=> color_green_o,
		rowIN_i			=> fb_row,
		colIN_i			=> fb_col,
		--rowIN_i			=> "00001",
		--colIN_i			=> "000001",
		rowOUT_i			=> fb_row,
		colOUT_i			=> fb_col,
		data_i			=> fb_data,
		we_i				=> fb_we,
		--data_i			=> "10",
		--we_i				=> '1',
		data_o			=> fb_data1
	);

	randomGen: entity work.randomGen PORT MAP(
		clk_i => clk_i,
		rand_o => rand 
	);
	
	-- process for switching different ports (for readability of code?)
	
	PORT_SEL: process(clk_i, rst_i, port_id_signal)
	begin
		if rising_edge(clk_i) then
			ps2_sel 		<= '0';
			fb_col_sel 	<= '0';
			fb_row_sel 	<= '0';
			fb_data_sel <= '0';
			rnd_sel 		<= '0';
			if (rst_i = '0') then
				if 	(port_id_signal = x"00") then -- TODO: CASE
					fb_col_sel 	<= '1';
				elsif (port_id_signal = x"01") then
					fb_row_sel 	<= '1';
				elsif (port_id_signal = x"02") then
					fb_data_sel <= '1';
				elsif (port_id_signal = x"03") then
					ps2_sel 		<= '1';
				elsif (port_id_signal = x"04") then
					rnd_sel 		<= '1';
				end if;
			end if;
		end if;
	end process;
	
	-- multiplexer for picoblaze reading 

	PICOREADMUX : process(ps2_sel, rnd_sel, fb_row_sel, fb_col_sel, fb_data_sel, read_strobe_signal)
	begin
		if (read_strobe_signal = '1') then
			if (ps2_sel = '1') then
				in_port_signal <= ps2_data;
			elsif (rnd_sel ='1') then
				in_port_signal <= "00" & rand;
			elsif (fb_data_sel = '1') then
				in_port_signal <= "000000" & fb_data1;
			else
				in_port_signal <= "00000000";
			end if;
		else
			in_port_signal <= "00000000";
		end if;
	end process;

	-- process for writing to devices
	
	PICOWRITE: process(clk_i, rst_i, fb_row_sel, ps2_sel, fb_col_sel, fb_data_sel, write_strobe_signal)
	begin
		-- LATCHES
		if rising_edge(clk_i) then
			if (rst_i = '1') then
				fb_row <= "00000";
				fb_col <= "000000";
				fb_data <= "00";
				fb_we <= '0';
				ps2_we <= '0';
			else
				fb_row <= fb_row;
				fb_col <= fb_col;
				fb_data <= fb_data;
				fb_we <= fb_we;
			
				if (write_strobe_signal = '1') then
					if (fb_row_sel = '1') then
						fb_row <= out_port_signal(4 downto 0);
					elsif (fb_col_sel = '1') then
						fb_col <= out_port_signal(5 downto 0);
					elsif (fb_data_sel = '1') then
						fb_data <= out_port_signal(1 downto 0);
						fb_we <= '1';
					elsif (ps2_sel ='1') then
						ps2_score <= out_port_signal;
						ps2_we <= '1';
					end if;
				else
					fb_we <= '0';
					ps2_we <= '0';
				end if;
			end if;
		end if;
	end process;
	
	
	-- process for handling interrupts
	
	INTERRUPTS: process(clk_i, rst_i)
	begin
		if rising_edge(clk_i) then
			interrupt_signal <= interrupt_signal;
			if (rst_i = '1') then -- either we reset the game or there has been a key pressed
				interrupt_signal <= '1';
			elsif (ps2_code_ready = '1') then
				interrupt_signal <= '1';
			elsif (interrupt_ack_signal ='1') then -- kcpsm has acknowledged our keyboard or reset interupt
				interrupt_signal <= '0';
			end if;
		end if;
	end process;
	
	
-----------------------------------------------------------------------------------------
-- Vmesniki za povezovanje periferije: --------------------------------------------------

   -- register za LEDice:
	process (clk_i)
	begin
		if clk_i'event and clk_i='1' then
			if rst_i='1' then
				led_reg	<= (others => '0');
			else
				led_reg <= led;
			end if;
		end if;
	end process;
	

	-- delay za read_strobe signal.
	-- potrebujem ga zato, da prehitro ne pobrise vsebino keycode registra.
	-- prav tako moram zakasniti port_id signal
	
	-- povezimo ledice s procesorjem. LEdice naj bodo na Portu 0xff:
	process (clk_i)
	begin
		if clk_i'event and clk_i='1' then  
			if rst_i='1' then   
				led <= (others => '0');
			elsif ((write_strobe_signal = '1') and (port_id_signal = X"FF")) then
				led <= out_port_signal;
			end if;
		end if;
	end process;
	
	
end Behavioral;