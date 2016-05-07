----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:00:51 12/03/2014 
-- Design Name: 
-- Module Name:    shift_register - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity shift_register is
    Port ( clk_i : in  STD_LOGIC;
           rst_i : in  STD_LOGIC;
           enable_i : in  STD_LOGIC; -- enable iz avtomata
           input_i : in  STD_LOGIC; -- signal, ki ga shranjujemo v register
           data_o : out  STD_LOGIC_VECTOR (8 downto 0));
end shift_register;

architecture Behavioral of shift_register is

	signal data : STD_LOGIC_VECTOR(8 downto 0);
	
begin

	data_o <= data;
	
	SHIFT_REG: process(clk_i, enable_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				data <= (others => '0');
			elsif enable_i = '1' then
				-- LSB first
				data(8 downto 0) <= input_i & data(8 downto 1);
				-- data(8) <= input_i;
				-- data(8 downto 1) <= data(7 downto 0);
				-- data(0) <= input_i;
			else
				data <= data;
			end if;
		end if;
	end process;
	
end Behavioral;

