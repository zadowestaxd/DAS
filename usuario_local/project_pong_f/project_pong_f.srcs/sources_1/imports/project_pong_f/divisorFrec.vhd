library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity divisorFrec is
  Port (
    rst, clk: in std_logic;
    cuentaMax: std_logic_vector(27 downto 0);
    clkOUT: out std_logic
   );
end divisorFrec;

architecture Behavioral of divisorFrec is
    signal enciende: std_logic;
    signal cuenta: std_logic_vector(27 downto 0);
begin
    
    divisor: process (rst,clk) begin
        if(rst = '1') then
            cuenta <= (others => '0');
            enciende <= '0';
        elsif (rising_edge(clk)) then
            if(cuenta = cuentaMax) then
                enciende <= not enciende;
                cuenta <= (others => '0');
            else
                cuenta <= cuenta + 1;
            end if;
        end if;
     end process;
            
     clkOUT <= enciende;

end Behavioral;
