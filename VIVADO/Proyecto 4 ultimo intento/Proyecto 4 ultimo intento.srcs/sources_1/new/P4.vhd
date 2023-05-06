library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ascensor is
    Port ( clkFPGA : in STD_LOGIC;
           reset : in STD_LOGIC;
           piso_ir : in STD_LOGIC_VECTOR(3 downto 0);
           mover : in STD_LOGIC;
           piso_actual : out STD_LOGIC_VECTOR(3 downto 0));
end ascensor;


architecture Behavioral of ascensor is

component frecuencia is
    Port ( clk : in std_logic;
        rst : in std_logic;
        cuentamax : in std_logic_vector (26 downto 0);
        clkOUT : out std_logic);
        end component;

    type estados is (p0, p1, p2, p3);
    signal estado_siguiente : estados;
    signal estado_actual : estados;
    signal clk_aux : std_logic;
    signal piso_destino : std_logic_vector(1 downto 0);
    signal piso_actual_int: std_logic_vector(1 downto 0);
    signal counter : std_logic_vector(26 downto 0);     

begin

frec: frecuencia port map (clk => clkFPGA, rst => reset, cuentamax => "101111101011110000100000000", clkOUT => clk_aux); --pormap

    -- Módulo combinacional para codificar la entrada de los switches
    codificador_entrada : process(piso_ir)
    begin
case piso_ir is
        when "0000" => piso_destino <= "00";
         when "0001" => piso_destino <= "00";
          when "0010" => piso_destino <= "01";
           when "0011" => piso_destino <= "01";
            when "0100" => piso_destino <= "10";
             when "0101" => piso_destino <= "10";
              when "0110" => piso_destino <= "10";
              when "0111" => piso_destino <= "10";
               when "1000" => piso_destino <= "11";
               when "1001" => piso_destino <= "11";
               when "1010" => piso_destino <= "11";
                 when "1011" => piso_destino <= "11";  
                when "1100" => piso_destino <= "11"; 
                 when "1101" => piso_destino <= "11";   
                 when "1110" => piso_destino <= "11";  
                 when "1111" => piso_destino <= "11";  
     end case;
end process;

   -- Máquina de estados
    Sincrono : process(reset, clk_aux)
    begin
        if reset = '1' then
        estado_actual <=p0;
    elsif clk_aux'event and clk_aux = '1' then
    estado_actual <= estado_siguiente;
        
        end if;
    end process Sincrono;
    
    PROCESS1: process(estado_actual)
    begin
    case estado_actual is
    when p0 =>
        if(piso_actual_int > "00") then
            estado_siguiente <= p1; 
        else
			estado_siguiente <= p0;
					end if;
      when p1 =>
        if(piso_actual_int > "01") then
            estado_siguiente <= p2; 
        elsif( piso_actual_int = "01") then
        estado_siguiente <= p1;
        else
			estado_siguiente <= p0;
					end if;
	  when p2 =>
        if(piso_actual_int > "10") then
            estado_siguiente <= p3; 
            elsif( piso_actual_int = "10") then
        estado_siguiente <= p2;
        else
			estado_siguiente <= p1;
					end if;
        when p3 =>
        if(piso_actual_int < "11") then
            estado_siguiente <= p2; 
        else
			estado_siguiente <= p3;
					end if;
            end case;
        end process PROCESS1;
    
    MOVER1: process(reset, mover)
    begin
    if reset = '1' then
            piso_actual_int <="00";
    elsif rising_edge(mover) then
            piso_actual_int <= piso_destino;
    end if;
    end process MOVER1;

    SAL: process(estado_actual)
    begin
        case estado_actual is
         when p0 =>
         piso_actual <= "0001";
         when p1 =>
         piso_actual <= "0010";
         when p2 =>
         piso_actual <= "0100";
         when p3 =>
         piso_actual <= "1000";
        end case;
      end process SAL;
		

end Behavioral;