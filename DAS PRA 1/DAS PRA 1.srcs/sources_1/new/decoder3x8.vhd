----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.01.2023 15:45:43
-- Design Name: 
-- Module Name: decoder3x8 - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity decoder3x8 is
    port (
        e: in std_logic;
        i: in std_logic_vector(2 downto 0);
        o: out std_logic_vector(7 downto 0)
    );
end decoder3x8;

architecture Behavioral of decoder3x8 is
    component decoder2x4 is
        port (
            e: in std_logic;
            i: in std_logic_vector(1 downto 0);
            o: out std_logic_vector(3 downto 0)
        );
    end component;

    signal i0, i1: std_logic_vector(1 downto 0);
    signal o0, o1, o2: std_logic_vector(3 downto 0);
begin
    i0 <= '0'&i(2);
    i1 <= i(1)&i(0);
    
    d0: decoder2x4 port map(e, i0, o0);
    d1: decoder2x4 port map(o0(1), i1, o1);
    d2: decoder2x4 port map(o0(0), i1, o2);
process
begin
    wait for 10 ns;
    o <= o1&o2;
end process;
end Behavioral;
