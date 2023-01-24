library library IEEE;
use IEEE.std_logic_1164.all;

entity decoder_3x8 is
    port (
        e: in std_logic;
        i: in std_logic_vector(0 to 2);
        o: out std_logic_vector(0 to 7);
    );
end entity decoder_3x8;

architecture arch of decoder_3x8 is
begin 
    process(e, i) 
    begin 
        if e='0' then
            o <= "00000000";
        else then
            case i is
                when "000" => o <= "00000001";
                when "001" => o <= "00000010";
                when "010" => o <= "00000100";
                when "011" => o <= "00001000";
                when "100" => o <= "00010000";
                when "101" => o <= "00100000";
                when "110" => o <= "01000000";
                when "111" => o <= "10000000";
                when others => d <= "11111111";
            end case;
        end if;
    end process;
end architecture arch;