library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity RAM32x40 is
    Port ( clk_i 		: in  STD_LOGIC;
           we_i 		: in  STD_LOGIC; -- ali je dostop pisalni / bralni
			  data_o 	: out  STD_LOGIC_VECTOR (1 downto 0); -- prebrano iz RAM
			  data1_o	: out STD_LOGIC_VECTOR (1 downto 0);
           rowOUT_i  : in  STD_LOGIC_VECTOR (4 downto 0); -- naslov, iz katerega beremo
			  colOUT_i	: in STD_LOGIC_VECTOR (5 downto 0);
			  row1OUT_i	: in STD_LOGIC_VECTOR (4 downto 0);
			  col1OUT_i	: in STD_LOGIC_VECTOR (5 downto 0);
           --data_i 	: in  STD_LOGIC_VECTOR (0 to 39); -- za zapis v RAM
			  rowIN_i 	: in  STD_LOGIC_VECTOR (4 downto 0); -- naslov, na katerega pisemo
			  colIN_i	: in STD_LOGIC_VECTOR  (5 downto 0);
           --data_i	: in STD_LOGIC
			  data_i		: in STD_LOGIC_VECTOR (1 downto 0)
			);  
end RAM32x40;

architecture Behavioral of RAM32x40 is

	type cell is array (0 to 39) of std_logic_vector(1 downto 0);
	type ram_type is array(29 downto 0) of cell;

	-- type ram_type is array (29 downto 0) of std_logic_vector (0 to 39);
   signal RAM : ram_type;
	--signal rowDataOUT 	: STD_LOGIC_VECTOR (0 to 39);
	signal cellDataOUT 	: STD_LOGIC_VECTOR (1 downto 0);
	signal cellDataOUT1 	: STD_LOGIC_VECTOR (1 downto 0);
	
begin
	
	data_o	<= cellDataOUT;
	data1_o	<= cellDataOUT1;

	-- to je dvokanalni RAM. Pisemo na naslov addrIN_i, istocasno lahko beremo z naslova addrOUT_i
	-- RAM ima asinhronski bralni dostop, tako da ga je easy za uporabit. Ko naslovis, takoj dobis podatke.
	-- pisalni dostop je sinhronski.
	-- Pazi LSB bit je skrajno levi, zato da se lazje 'ujema' z organizacijo zaslona!

	-- Spremenite RAM tako, da bo možna sprememba posameznega piksla, ne samo celotne vrstice

	process (clk_i)
	begin
		if (clk_i'event and clk_i = '1') then
			if (we_i = '1') then
				RAM(conv_integer(rowIN_i))(conv_integer(colIN_i)) <= data_i;
			end if;
		end if;
	end process;

	cellDataOUT <= RAM(conv_integer(rowOUT_i))(conv_integer(colOUT_i));
	cellDataOUT1 <= RAM(conv_integer(row1OUT_i))(conv_integer(col1OUT_i));

end Behavioral;

