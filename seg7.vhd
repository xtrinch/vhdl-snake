----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:28:09 10/22/2014 
-- Design Name: 
-- Module Name:    seg7 - Behavioral 
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

entity seg7 is

-- data_i ni generik, saj vec kot 3 do 0 ne moremo prikazati na enem 7-segmentu

Port ( 
	clk_i : in STD_LOGIC;
	anodecount_i : in STD_LOGIC; -- signal za preklapljanje anode
	data_i : in  STD_LOGIC_VECTOR (7 downto 0); -- the number we are displaying
	anode_o : out STD_LOGIC_VECTOR(3 downto 0); -- the 4 7-segment displays
	cathode_o : out  STD_LOGIC_VECTOR (6 downto 0)  -- one 7-segment display
	);
end seg7;

architecture Behavioral of seg7 is

	signal anode_s : STD_LOGIC_VECTOR(3 downto 0);
	signal data: STD_LOGIC_VECTOR(3 downto 0);

	constant zero : std_logic_vector(6 downto 0) := "1000000";
	constant one : std_logic_vector(6 downto 0) := "1111001";
	constant two : std_logic_vector(6 downto 0) := "0100100";
	constant three : std_logic_vector(6 downto 0) := "0110000";
	constant four : std_logic_vector(6 downto 0) := "0011001";
	constant five : std_logic_vector(6 downto 0) := "0010010";
	constant six : std_logic_vector(6 downto 0) := "0000010";
	constant seven : std_logic_vector(6 downto 0) := "1111000";
	constant eight : std_logic_vector(6 downto 0) := "0000000";
	constant nine : std_logic_vector(6 downto 0) := "0010000"; 
	constant a : std_logic_vector(6 downto 0) := "0001000"; -- OK
	constant b : std_logic_vector(6 downto 0) := "0000011"; 
	constant c : std_logic_vector(6 downto 0) := "1000110";
	constant d : std_logic_vector(6 downto 0) := "0100001"; 
	constant e : std_logic_vector(6 downto 0) := "0000110"; 
	constant f : std_logic_vector(6 downto 0) := "0001110"; 

begin

	anode_o <= anode_s;

	process(clk_i)
	begin
		if (clk_i'event and clk_i='1' and anodecount_i='1') then
			case anode_s is
				when "0111" =>
					anode_s <= "1110";
					data <= data_i(3 downto 0);
				when "1101" => 
					anode_s <= "1011";
					data <= "0000";
				when "1011" => 
					anode_s <= "0111";
					data <= "0000";
				when others => 
					anode_s <= "1101";
					data <= data_i(7 downto 4);
			end case;	
		end if;
	end process;

	process(anode_s, data)
	begin			
		if data="0000" then
			cathode_o <= zero;
		elsif data="0001" then
			cathode_o <= one;
		elsif data="0010" then
			cathode_o <= two;
		elsif data="0011" then
			cathode_o <= three;
		elsif data="0100" then
			cathode_o <= four;
		elsif data="0101" then
			cathode_o <= five;
		elsif data="0110" then
			cathode_o <= six;
		elsif data="0111" then
			cathode_o <= seven;
		elsif data="1000" then
			cathode_o <= eight;
		elsif data="1001" then
			cathode_o <= nine;
		elsif data="1010" then
			cathode_o <= a; 
		elsif data="1011" then
			cathode_o <= b; 
		elsif data="1100" then
			cathode_o <= c; 
		elsif data="1101" then
			cathode_o <= d; 
		elsif data="1110" then
			cathode_o <= e; 
		else
			cathode_o <= f; 
		end if;
	end process;
end Behavioral;

