library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;
entity P5REVISION is
    Port ( CLK : in  STD_LOGIC;
           WE : in  STD_LOGIC;
           ADDR : in  STD_LOGIC_VECTOR (13 downto 0);
           DATA_OUT : out  STD_LOGIC_VECTOR (31 downto 0);
           DATA_IN: in STD_LOGIC_VECTOR(31 downto 0));
end P5REVISION;

architecture Behavioral of P5REVISION is
    type RAM_TYPE is array (0 to 2**14-1) of std_logic_vector(31 downto 0);
    signal RAM : RAM_TYPE := (others => (others => '0'));
    attribute ram_style: string;
    attribute ram_style of RAM: signal is "distributed";
begin
    process (CLK, ADDR)
    begin
        if rising_edge(CLK) then
            if WE = '1' then
                RAM(to_integer(unsigned(ADDR))) <= DATA_IN;
            end if;
        end if;
        DATA_OUT <= RAM(to_integer(unsigned(ADDR)));
    end process;
    --DATA_OUT <= RAM(to_integer(unsigned(ADDR)));
end Behavioral;