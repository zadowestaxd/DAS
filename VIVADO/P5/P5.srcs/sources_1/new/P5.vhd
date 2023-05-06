library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
-- use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;


entity ram8x8 is
    generic(
        NUMPAL: natural := 8;
        NUMBIT: natural := 3
    );

    port (
        clkFPGA: in std_logic;
        we: in std_logic; --write enable
        addr: in std_logic_vector(NUMBIT-1 downto 0);
        data_in: in std_logic_vector(NUMPAL-1 downto 0);
        data_out: out std_logic_vector(NUMPAL-1 downto 0)
    );
end entity ram8x8;

architecture Behavioral of ram8x8 is
    --array bidimensional de 8 (numero de palabras) por 8 (numero de bits por palabra)
    type ram_type is array (NUMPAL-1 downto 0) of std_logic_vector(NUMPAL-1 downto 0);
    signal RAM : ram_type := (others => (others => '0')); -- Se inicializa en ceros

begin
--pag 121
    process (clkFPGA)
    begin
    --El proceso se activa en cada flanco de subida de reloj. 
    --Después, dependiendo del valor de we, escribe o lee de la memoria ram.
        if rising_edge(clkFPGA) then
            if we = '1' then
                RAM(to_integer(unsigned(addr))) <= data_in;
           end if;
                data_out <= RAM(to_integer(unsigned(addr)));
        end if;
    end process;  
    
    
end architecture Behavioral;