use work.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- generates a random number to use in generating the food for snake

entity randomGen is
    Port ( clk_i : in  STD_LOGIC;
           rand_o : out  STD_LOGIC_VECTOR(5 downto 0));
end randomGen;

architecture Behavioral of randomGen is

	signal temp	: STD_LOGIC;
	signal rand : STD_LOGIC_VECTOR(5 downto 0) := "111110";
	
begin
	
	rand_o <= rand;
	
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			temp <= rand(5) xor rand(4);
			rand(5 downto 1) <= rand(4 downto 0);
			rand(0) <= temp;
		end if;
	end process;

end Behavioral;

