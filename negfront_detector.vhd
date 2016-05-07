----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:20:05 11/26/2014 
-- Design Name: 
-- Module Name:    stikaloEnable - Behavioral 
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

entity negfront_detector is
    Port ( 
		switch_sync_i : in STD_LOGIC;
		clk_i : in STD_LOGIC;
		reset_i : in STD_LOGIC;
		cenable_o : out STD_LOGIC
	 );
end negfront_detector;

architecture Behavioral of negfront_detector is

type state_type is (st0_1hold, st1_generate, st2_0hold); 
signal state, next_state : state_type; 
--Declare internal signals for all outputs of the state-machine
signal cenable : std_logic;  -- output signal
begin


	SYNC_PROC: process (clk_i)
		begin
			if (clk_i'event and clk_i = '1') then
				if (reset_i = '1') then
					state <= st0_1hold;
					cenable_o <= '0';
				else
					state <= next_state;
					cenable_o <= cenable;
				end if;        
			end if;
		end process;


   --MOORE State-Machine - Outputs based on state only
   OUTPUT_DECODE: process (state)
   begin
      -- statements to decode internal output signals
		if state = st1_generate then
			cenable <= '1';
		else
			cenable <= '0';
      end if;
   end process;
 
	
   NEXT_STATE_DECODE: process (state, switch_sync_i)
   begin
      --declare default state for next_state to avoid latches
      --next_state <= state;  --default is to stay in current state
      next_state <= state;
      case (state) is
         when st0_1hold =>
            if switch_sync_i = '0' then
               next_state <= st1_generate;
            end if;
         when st1_generate =>
            next_state <= st2_0hold;
         when st2_0hold =>
				if switch_sync_i = '1' then
					next_state <= st0_1hold;
				end if;
         when others =>
            next_state <= st0_1hold;
      end case;      
   end process;

end Behavioral;