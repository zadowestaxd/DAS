library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ascensor is
    Port ( clkFPGA : in STD_LOGIC;
           reset : in STD_LOGIC;
           piso_ir : in STD_LOGIC_VECTOR(2 downto 0);
           mover : in STD_LOGIC;
           piso_actual : out STD_LOGIC_VECTOR(1 downto 0));
end ascensor;

architecture Behavioral of ascensor is

    type estados is (Esperando, Subiendo, Bajando);
    signal estado_actual, estado_siguiente : estados;
    signal piso_destino, piso_actual_int : unsigned(1 downto 0);
    signal contador : integer range 0 to 100000000; -- divisor de frecuencia
    signal entrada_switches : std_logic_vector(2 downto 0);

begin

    -- Módulo combinacional para decodificar la entrada de los switches
    with entrada_switches select
        piso_destino <= "00" when "000",
                        "01" when "001",
                        "10" when "010",
                        "11" when others;

   -- Máquina de estados
    FSM: process(clkFPGA, reset)
    begin
        if (reset = '1') then
            estado_actual <= Esperando;
            contador <= 0;
            piso_actual_int <= "00";
        elsif (rising_edge(clkFPGA)) then
            estado_actual <= estado_siguiente;
            case estado_actual is
                when Esperando =>
                    if (mover = '1') then
                        if (piso_ir /= "000") then
                            piso_destino <= unsigned(piso_ir(2 downto 1));
                            if (piso_ir(0) = '1') then
                                estado_siguiente <= Subiendo;
                            else
                                estado_siguiente <= Bajando;
                            end if;
                        end if;
                    else
                        estado_siguiente <= Esperando;
                    end if;
                when Subiendo =>
                    if (contador = 50000000) then -- 2 segundos
                        if (piso_actual_int = "01") then
                            estado_siguiente <= Esperando;
                        else
                            estado_siguiente <= Subiendo;
                            piso_actual_int <= piso_actual_int + 1;
                        end if;
                        contador <= 0;
                    else
                        estado_siguiente <= Subiendo;
                        contador <= contador + 1;
                    end if;
                when Bajando =>
                    if (contador = 50000000) then -- 2 segundos
                        if (piso_actual_int = "00") then
                            estado_siguiente <= Esperando;
                        else
                            estado_siguiente <= Bajando;
                            piso_actual_int <= piso_actual_int - 1;
                        end if;
                        contador <= 0;
                    else
                        estado_siguiente <= Bajando;
                        contador <= contador + 1;
                    end if;
            end case;
        end if;
    end process FSM;

    -- Asignaciones de salida
    piso_actual <= std_logic_vector(piso_actual_int);

end Behavioral;