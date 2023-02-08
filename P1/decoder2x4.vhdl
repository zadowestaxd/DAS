library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decodificador2x4 is
    port (
        En: in std_logic;
        e: in std_logic_vector(1 downto 0);
        s: out std_logic_vector(3 downto 0)
    );
end entity decodificador2x4;

architecture decodificador2x4_rtl of decodificador2x4 is
begin    
    s <=     "0001" when (e="00" and Em='1') else
             "0010" when (e="01" and En='1') else
             "0100" when (e="10" and En='1') else
             "1000" when (e="11" and En='1') else
             "0000" when En='0' else "1111";
end architecture decodificador2x4_rtl;