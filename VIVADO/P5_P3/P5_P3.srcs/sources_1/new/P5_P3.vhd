library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity ram8x8 is
    generic(
        NUMPAL: natural := 8;
        NUMBIT: natural := 3
    );

    port (
        clkFPGA: in std_logic;
        we: in std_logic; --write enable
        addr: in std_logic_vector(NUMBIT-1 downto 0);
        data_in: in std_logic_vector(NUMPAL-1 downto 0);
        data_out: out std_logic_vector(NUMPAL-1 downto 0)
    );
end entity ram8x8;

architecture Behavioral of ram8x8 is
    attribute ram_style: string;
    type mem_array_t is array (0 to 2**NUMBIT-1) of std_logic_vector(NUMPAL-1 downto 0);
    signal RAM : mem_array_t := (others => (others => '0'));
    attribute ram_style of RAM: signal is "block";

begin

    process (clkFPGA)
    begin
        if rising_edge(clkFPGA) then
            if we = '1' then
                RAM(to_integer(unsigned(addr))) <= data_in;
            else
                RAM(to_integer(unsigned(addr))) <= std_logic_vector(to_unsigned(to_integer(unsigned(addr)) + 3, NUMPAL));
            end if;
                data_out <= RAM(to_integer(unsigned(addr)));
        end if;
    end process;  
    
end architecture Behavioral;
