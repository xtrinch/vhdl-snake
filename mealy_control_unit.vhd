----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:38:26 12/03/2014 
-- Design Name: 
-- Module Name:    mealy_control_unit - Behavioral 
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

entity mealy_control_unit is
	Port (
		clk_i : in STD_LOGIC;
		sync_kdbdata_i : in STD_LOGIC;
		kdbclk_negfront_i : in STD_LOGIC; -- negative front of keyboard clock, which is held at logic 1 when there is no data transfers
		rst_i : in STD_LOGIC;
		shr_enable_o : out STD_LOGIC; -- NOT WORKING
		ready_o : out STD_LOGIC
	);
end mealy_control_unit;

architecture Behavioral of mealy_control_unit is

   type state_type is (idle, start, st0, st1, st2, st3, st4, st5, st6, st7, parity); 
   signal state, next_state : state_type; 
   --Declare internal signals for all outputs of the state-machine
   signal shr_enable : std_logic; 
	signal ready : std_logic; 

begin

	SYNC_PROC: process (clk_i)
   begin
      if rising_edge(clk_i) then
         if (rst_i = '1') then
            state <= idle;
            shr_enable_o <= '0';
				ready_o <= '0';
         else
            state <= next_state;
            shr_enable_o <= shr_enable;
				ready_o <= ready; 
         end if;        
      end if;
   end process;
 
   --MEALY State-Machine - Outputs based on state and inputs
   OUTPUT_DECODE: process (state, sync_kdbdata_i, kdbclk_negfront_i)
   begin
	
      --insert statements to decode internal output signals
      --below is simple example
      if (state = start and kdbclk_negfront_i = '1') then
         shr_enable <= '1';
			ready <= '0';
		elsif  ( (state = st0 or state = st1 or state = st2 or state = st3 or state = st4 or state = st5 or state = st6 or state = st7) and kdbclk_negfront_i = '1') then
		   shr_enable <= '1';
			ready <= '0';
		elsif (state = parity and kdbclk_negfront_i = '1') then
		   shr_enable <= '0';
			ready <= '1';			
		else
			shr_enable <= '0';
			ready <= '0';
      end if;
   end process;
 
 
	-- transfer is synchronized to negative front of keyboard clock
   NEXT_STATE_DECODE: process (state, kdbclk_negfront_i, sync_kdbdata_i)
   begin
      --declare default state for next_state to avoid latches
      next_state <= state;

      case (state) is
         when idle =>
            if (kdbclk_negfront_i = '1' and sync_kdbdata_i = '0') then -- start bit 0 na keyboard data in negativna fronta keyboard ure
               next_state <= start;
            end if;
         when start =>
            if kdbclk_negfront_i = '1' then
               next_state <= st0;
            end if;
         when st0 =>
				if kdbclk_negfront_i = '1' then
					next_state <= st1;
				end if;
			when st1 =>
				if kdbclk_negfront_i = '1' then
					next_state <= st2;
				end if;
			when st2 =>
				if kdbclk_negfront_i = '1' then
					next_state <= st3;
				end if;
			when st3 =>
				if kdbclk_negfront_i = '1' then
					next_state <= st4;
				end if;
			when st4 =>
				if kdbclk_negfront_i = '1' then
					next_state <= st5;
				end if;
			when st5 =>
				if kdbclk_negfront_i = '1' then
					next_state <= st6;
				end if;
			when st6 =>
				if kdbclk_negfront_i = '1' then
					next_state <= st7;
				end if;
			when st7 =>
				if kdbclk_negfront_i = '1' then
					next_state <= parity;
				end if;
			when parity =>
				if (kdbclk_negfront_i = '1') then
					next_state <= idle;
				end if;
         when others =>
            next_state <= idle;
      end case;      
   end process;


end Behavioral;

