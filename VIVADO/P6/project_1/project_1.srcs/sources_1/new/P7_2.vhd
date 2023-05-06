library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity keyboard is
Port (PS2_CLK: in std_logic;
PS2_DATA: in std_logic;
reset_input: in std_logic;
output_signal: out std_logic_vector(7 downto 0);
key_pressed: out std_logic
);
end keyboard;

architecture Func of keyboard is
signal key_register: std_logic_vector(21 downto 0); --21 0
begin

key_register_process:process(PS2_CLK, reset_input)
begin
if reset_input = '1' then
key_register <= (others=>'0');
elsif falling_edge(PS2_CLK) then
key_register <= key_register(20 downto 0) & PS2_DATA; -- 20 0
end if;
end process key_register_process;

key_pressed <= '1' when key_register(20 downto 13) = "00001111" else '0';
output_signal(7 downto 0) <= key_register(9 downto 2);

end Func;