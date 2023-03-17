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

entity frecuencia is
    Port (clk: in std_logic;
          rst: in std_logic;
          cuentamax: in std_logic_vector(26 downto 0);
          clkOUT: out std_logic);
end frecuencia;

architecture Behavioral of frecuencia is
    signal estado: std_logic := '0';
    signal count: std_logic_vector(26 downto 0);
begin
   
sumador: process(rst)
begin
 
    if rst = '1' then
        estado <= '0';
        count <= "000000000000000000000000000";
    elsif (rising_edge(clk)) then
        if count = cuentamax then
            estado <= not estado;
            count <= "000000000000000000000000000";
        else
            count <= count + 1;
        end if;
    end if;
end process sumador;
   
    clkOUT <= estado;

end Behavioral;