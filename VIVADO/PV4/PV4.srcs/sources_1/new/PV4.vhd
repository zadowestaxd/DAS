----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.02.2023 12:26:25
-- Design Name: 
-- Module Name: P3 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity divisor_frecuencia is
 Port ( clk : in std_logic;
        reset : in std_logic;
        cuentamax : in std_logic_vector (26 downto 0);
        light : out std_logic); 
end divisor_frecuencia;

architecture Behavioral of divisor_frecuencia is
signal counter : std_logic_vector(26 downto 0) := (others=> '0'); --esto se debe al número de bits necesario
signal clock : std_logic := '0';
begin                                       --para representar 100MHz
process(clk, reset)
begin
if(reset = '1') THEN
 counter <=(others=>('0'));
 clock<='0';
elsif(clk'event and clk='1') THEN
    if(counter=cuentamax) THEN  --101111101011110000100000000
      counter<=(others=>('0'));
      clock<= not clock;
    else
        counter<=counter + 1;
    end if;
end if; 

light<=clock; 
end process;
end Behavioral;
