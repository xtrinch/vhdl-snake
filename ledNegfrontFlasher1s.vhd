
library IEEE;
use IEEE. STD_LOGIC_1164. ALL;
use IEEE. STD_LOGIC_ARITH. ALL;
use IEEE. STD_LOGIC_UNSIGNED. ALL;

entity ledillum is
    Port ( clk_i : in  STD_LOGIC;
			  reset_i : in STD_LOGIC;
			  signal_i : in STD_LOGIC;	
			  led_illuminate_o : out STD_LOGIC );
end ledillum;

architecture Behavioral of ledillum is
	signal count : STD_LOGIC_VECTOR(25 downto 0);
begin

	
	process(clk_i, signal_i)
	begin
		if (clk_i'event and clk_i='1') then
			if (reset_i='1' or signal_i='1') then
				count <= (others => '0');
				led_illuminate_o <= '1';
			elsif (count = 50000000) then
				led_illuminate_o <= '0';
				count <= count;
			else
				count <= count + 1;
				led_illuminate_o <= '1';
			end if ;
		end if ;
	end process;

end Behavioral;