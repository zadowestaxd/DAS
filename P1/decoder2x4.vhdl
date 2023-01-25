library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decoder2x4 is
    port (
        e: in std_logic;
        i: in std_logic_vector(1 downto 0);
        o: out std_logic_vector(3 downto 0)
    );
end entity decoder2x4;

architecture decoder2x4_rtl of decoder2x4 is
begin    
    with i&e select
    o <= 
        "0001" when "001",
        "0010" when "011",
        "0100" when "101",
        "1000" when "111",
        "0000" when "000",
        "0000" when "010",
        "0000" when "100",
        "0000" when "110",
        "1111" when others;
end architecture decoder2x4_rtl;