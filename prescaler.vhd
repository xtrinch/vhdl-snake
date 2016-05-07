library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE. STD_LOGIC_ARITH. ALL;
use IEEE. STD_LOGIC_UNSIGNED. ALL;

entity prescaler is
Port (
	clk_i: in STD_LOGIC; -- we are calculating one second, so we need the clock
	reset_i: in STD_LOGIC; -- i suppose when we reset count we want to be able to reset this 20 nano second counter
	enable_o: out STD_LOGIC -- when the count reaches 5 million, we send out an enable signal
);
end prescaler ;

architecture Behavioral of prescaler is
	signal count: STD_LOGIC_VECTOR(16 downto 0);
begin

	process(clk_i)
	begin
		if (clk_i'event and clk_i='1') then
			count <= count +1;
			
			if(reset_i='0') then				
			
				if (count=50000) then -- stejemo do 50.000 
					enable_o <= '1';
					count <= (others => '0');
				else
					enable_o <= '0';
				end if ;
			
			else
				count <= (others => '0');
			end if;
		end if ;
		-- prescaler
		-- naj generira enable signal, ki ga uporabite v zgornjem procesu
	end process;



end Behavioral;

