library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity teclado is
  Port (PS2CLK: in std_logic;
        PS2DATA: in std_logic;
        reset: in std_logic;
        light: out std_logic_vector(7 downto 0);
        nueva_tecla: out std_logic
         );
end teclado;

architecture Behavioral of teclado is
signal reg_tecla: std_logic_vector(21 downto 0);
begin

registro :process(PS2CLK, reset)
begin 
    if reset='1' then
        reg_tecla<=(others=>'0');
    elsif falling_edge(PS2CLK) then
        reg_tecla<= PS2DATA & reg_tecla(20 downto 0);
    end if;
end process registro;

nueva_tecla<='1' when reg_tecla(20 downto 13)="00001111" else '0';
light(7 downto 0) <= reg_tecla(9 downto 2);


end Behavioral;