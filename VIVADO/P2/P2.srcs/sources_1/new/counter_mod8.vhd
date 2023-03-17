library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.ALL;

entity counter_mod8 is
    Port ( clk : in  STD_LOGIC;
           enable : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           count : out  STD_LOGIC_VECTOR (2 downto 0)); -- 2 downto 0
end counter_mod8;

architecture Behavioral of counter_mod8 is
    signal count_int : std_logic_vector(2 downto 0) := (others => '0');
begin
    process (clk, reset)
    begin
        if reset = '1' then
            count_int <= (others => '0');
        elsif (clk'event and clk = '1') then
            if enable = '1' then
                count_int <= (count_int + 1);
            end if;
        end if;
    end process;
    count <= count_int;
end Behavioral;