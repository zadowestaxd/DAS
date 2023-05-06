library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_ram is
    port(
    clk : in std_logic;
    we : in std_logic;
    addr : in std_logic_vector(2 downto 0);
    data_in : in std_logic_vector(11 downto 0);
    data_out : out std_logic_vector(11 downto 0)
);
end mem_ram;

architecture syn of mem_ram is
type ram_type is array (7 downto 0) of std_logic_vector(11 downto 0);
signal RAM: ram_type := (x"000",x"CCB",x"0E0",x"EA1",x"153",x"C6B",x"D5E",x"BA2");
begin
    process(clk)
    begin
        if (clk'event and clk = '1') then
            if (we = '1') then
                RAM(to_integer(unsigned(addr))) <= data_in;
            end if;
        end if;
    end process;
    data_out <= RAM(to_integer(unsigned(addr)));
end syn;