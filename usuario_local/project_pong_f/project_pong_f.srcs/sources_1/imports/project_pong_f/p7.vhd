
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity teclado is
  Port (
       PS2CLK: in std_logic;
       PS2DATA: in std_logic;
       reset: in std_logic;
       light: out std_logic_vector (7 downto 0);
       nueva_tecla: out std_logic
   );
end teclado;

architecture Behavioral of teclado is

signal reg_tecla: std_logic_vector(21 downto 0);

begin

reg: process(PS2CLK,reset,PS2DATA)
begin
    if (reset = '1') then
        reg_tecla <= (others => '0');
    elsif(PS2CLK'event and PS2CLK = '0') then
        reg_tecla <= PS2DATA & reg_tecla(21 downto 1);
    end if;  
end process;

nueva_tecla <= '1' when reg_tecla(8 downto 1) = "11110000" else
            '0';

light <= reg_tecla(19 downto 12);


end Behavioral;
