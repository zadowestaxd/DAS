library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;

entity my_RAM is
    Port (
        CLK : in  STD_LOGIC;
        WE : in  STD_LOGIC;
        ADDR : in  STD_LOGIC_VECTOR (13 downto 0);
        DATA_OUT : out  STD_LOGIC_VECTOR (31 downto 0);
        DATA_IN : in STD_LOGIC_VECTOR(31 downto 0)
    );
end my_RAM;

architecture Behavioral of my_RAM is
    type ram_array_t is array (0 to 2**14-1) of std_logic_vector(31 downto 0);
    signal ram_array : ram_array_t := (others => (others => '0'));
    attribute ram_style: string;
    attribute ram_style of ram_array : signal is "distributed";
begin
    process (CLK)
    begin
        if rising_edge(CLK) then
            if WE = '1' then
                ram_array(to_integer(unsigned(ADDR))) <= DATA_IN;
            end if;
        end if;
        DATA_OUT <= ram_array(to_integer(unsigned(ADDR)));
    end process;
end Behavioral;
