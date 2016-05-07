
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE. STD_LOGIC_ARITH. ALL; -- use arithmetic
use IEEE. STD_LOGIC_UNSIGNED. ALL;

entity counter is
	Generic(
		width:integer;
		reset_value:integer
	);
	Port(
		clk_i: in STD_LOGIC;
		reset_i: in STD_LOGIC;
		enable_i: in STD_LOGIC;
		data_o: out STD_LOGIC_VECTOR(width-1 downto 0)
	);
end counter;

architecture Behavioral of counter is
	signal count: STD_LOGIC_VECTOR(width-1 downto 0);
begin
	data_o <= count;
	
	process(clk_i)
	begin
		if(clk_i'event and clk_i='1') then -- pozitivna fronta
			if(reset_i='1') then
				count <= (others => '0');
			else
				if (enable_i = '1') then
					if (count < reset_value ) then
						count <= count + 1;
					else
						count <= (others => '0');
					end if;
				else
					count <= count;
				end if;
			end if;
		end if;
	end process;

end Behavioral;

