----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.02.2023 19:31:41
-- Design Name: 
-- Module Name: divisorFreq - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity divisor is
    Port (clk_in: in std_logic;
          max_count: std_logic_vector(27 downto 0);
          reset: in std_logic;
          clk_out: out std_logic);
end divisor;

architecture Behavioral of divisor is

signal count: std_logic_vector (27 downto 0);
signaL clk_aux: std_logic;

begin

clk_out <= clk_aux;

process (reset, clk_in)
    begin
        if reset = '1' then
            clk_aux <= '0';
            count <= (others=>'0');
        elsif rising_edge(clk_in) then
            if count = max_count then
                clk_aux <= not clk_aux;
                count <= (others=>'0');
            else
                count <= count + '1';
            end if;
        end if;
end process;  


end Behavioral;
