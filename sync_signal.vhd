----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:56:29 12/03/2014 
-- Design Name: 
-- Module Name:    sync_signal - Behavioral 
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

entity sync_signal is
    Port ( unsynced_i : in STD_LOGIC;
           synced_o : out  STD_LOGIC;
			  clk_i : in STD_LOGIC;
			  rst_i : in STD_LOGIC
	 );
end sync_signal;

architecture Behavioral of sync_signal is

	signal synced : STD_LOGIC;
	
begin

	synced_o <= synced;

	SYNC_SIGNAL: process(clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				synced <= '0';
			else
				synced <= unsynced_i;
			end if;
		end if;
	end process;


end Behavioral;

