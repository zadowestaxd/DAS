-- Single-Port RAM with Asynchronous Read (Distributed RAM)
-- File: rams_dist.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_ram is
    port(
    clk : in std_logic;
    we : in std_logic;
    a : in std_logic_vector(2 downto 0);
    di : in std_logic_vector(11 downto 0);
    do : out std_logic_vector(11 downto 0)
);
end mem_ram;

architecture syn of mem_ram is
type ram_type is array (7 downto 0) of std_logic_vector(11 downto 0);
signal RAM: ram_type := (x"000",x"CCC",x"0F0",x"FB1",x"053",x"E6A",x"F0F",x"F00");
begin
    process(clk)
    begin
        if (clk'event and clk = '1') then
            if (we = '1') then
                RAM(to_integer(unsigned(a))) <= di;
            end if;
        end if;
    end process;
    do <= RAM(to_integer(unsigned(a)));
end syn;