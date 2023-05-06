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
    attribute rom_style: string;
     signal RAM : std_logic_vector((2**NUMBIT * NUMPAL/2)-1 downto 0) := (others => '0');
   attribute rom_style of RAM : signal is "distributed";

begin

    process (clkFPGA)
    begin
        if rising_edge(clkFPGA) then
            if we = '1' then
                RAM(to_integer(unsigned(addr)) * NUMPAL + NUMPAL-1 downto to_integer(unsigned(addr)) * NUMPAL) <= data_in;
            end if;
                data_out <= RAM(to_integer(unsigned(addr)) * NUMPAL + NUMPAL-1 downto to_integer(unsigned(addr)) * NUMPAL);
        end if;
    end process;  
    
end architecture Behavioral;
