library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;

entity ram32kx32 is
    generic(
        NUMPAL: natural := 14;
        NUMBIT: natural := 32
    );

    port (
        clkFPGA: in std_logic;
        we: in std_logic; --write enable
        addr: in std_logic_vector(NUMBIT-1 downto 0);
        data_in: in std_logic_vector(NUMPAL-1 downto 0);
        data_out: out std_logic_vector(NUMPAL-1 downto 0)
      
    );
    
    attribute SYN_CLOCK : string;
    attribute SYN_CLOCK of clkFPGA : signal is "TRUE";
    attribute SYN_RESET : string;
  

end entity ram32kx32;

architecture Behavioral of ram32kx32 is
    --array bidimensional de 16384 (numero de palabras) por 32 (numero de bits por palabra)
    type ram_type is array (NUMPAL-1 downto 0) of std_logic_vector(NUMPAL-1 downto 0);
    signal RAM : ram_type := (others => (others => '0')); -- Se inicializa en ceros
     attribute SYN_RESET of RAM : signal is "TRUE";
begin
    --proceso para escritura y lectura de RAM
    process (clkFPGA)
    begin
        if rising_edge(clkFPGA) then
            --si we es '1' escribimos en la dirección indicada por addr
            if we = '1' then
                RAM(to_integer(unsigned(addr))) <= data_in;
            end if;
            --lectura de la dirección indicada por addr
            data_out <= RAM(to_integer(unsigned(addr)));
        end if;
    end process;
     
    --asignación de la salida leds a la dirección 0 de la RAM
    
end architecture Behavioral;
