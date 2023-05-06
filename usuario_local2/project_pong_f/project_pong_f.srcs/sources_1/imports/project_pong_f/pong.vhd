----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.03.2023 13:12:26
-- Design Name: 
-- Module Name: pong - Behavioral
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

-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;


entity pong is
  Port (
    clkFPGA: in std_logic;
    reset: in std_logic;
    
    --parametros teclado
    PS2CLK: in std_logic;
    PS2DATA: in std_logic;
    
    --salida por pantalla
    
    hsyncb: buffer std_logic; -- horizontal (line) sync
    vsyncb: out std_logic; -- vertical (frame) sync
    rgb: out std_logic_vector(11 downto 0);
    
    --salida contador
    disp: out std_logic_vector(6 downto 0);
    an: out std_logic_vector(3 downto 0)
    
   );
end pong;

architecture Behavioral of pong is

signal scancode: std_logic_vector (7 downto 0);
signal newkey: std_logic;
signal reset_teclado: std_logic;


-- mostrar en pantalla
signal hcnt: std_logic_vector(11 downto 0);
signal vcnt: std_logic_vector(11 downto 0);
signal marc: std_logic;
signal fond: std_logic;
signal bar: std_logic;
signal ball: std_logic;

--dimensiones barra + reloj
signal bar_v_ini : std_logic_vector(11 downto 0);
signal bar_v_fin : std_logic_vector(11 downto 0);
signal bar_h_ini : std_logic_vector(11 downto 0);
signal bar_h_fin : std_logic_vector(11 downto 0);


--fsm barra
type estados_bar is (parado, up, down);
signal estado_bar, sig_estado_bar: estados_bar;

--dimensiones bola + reloj
signal ball_v_ini : std_logic_vector(11 downto 0);
signal ball_v_fin : std_logic_vector(11 downto 0);
signal ball_h_ini : std_logic_vector(11 downto 0);
signal ball_h_fin : std_logic_vector(11 downto 0);
signal ballclk : std_logic;

--fsm bola
type estados_ball is (no,so,se,ne); --noroeste, suroeste, sureste, noreste
signal estado_ball, sig_estado_ball: estados_ball;

--contador
signal cont: std_logic_vector(2 downto 0);
signal choque: std_logic;

--ram con 8 palabras
signal cambia_color: std_logic_vector(11 downto 0);

begin
an <= "1110";

--divisor de frecuencia para la pelota
divball: entity work.divisorFrec port map (
    valorMax => x"0012000",
    rst => reset,
    clk => clkFPGA,
    clkOUT => ballclk
);
-- se encarga de pasar desde el teclado una se�al de bits que representa la tecla pulsada 
-- y una se�al para saber si ya se ha dejado de pulsar esa tecla o no
tec: entity work.teclado port map(
     PS2CLK => PS2CLK,
     PS2DATA => PS2DATA,
     rst => reset_teclado,
     leds => scancode,
     newkey => newkey
);

----------------memoria ram-----------------------

-- se encarga de pasar cont como direccion de memoria y devuelve cambia_color que va directamente al controlador
-- vga para que actualize el color del fondo
m_ram: entity work.mem_ram port map(

    clk => clkFPGA,
    we => '0',
    a => cont,
    di => "000000000000",
    do => cambia_color 

);

---------------------------- CONTROLADOR VGA---------------------------------

-- contador horizontal (VGA)            
A: process(clkFPGA,reset)
begin
    -- reset asynchronously clears pixel counter
    if reset='1' then
        hcnt <= "000000000000";
        -- horiz. pixel counter increments on rising edge of dot clock
    elsif (clkFPGA'event and clkFPGA='1') then
        -- horiz. pixel counter rolls-over after 381 pixels
        if hcnt<1687 then
            hcnt <= hcnt + 1;
        else
            hcnt <= "000000000000";
        end if;
    end if;
end process;
--contador vertical (VGA)
B: process(hsyncb,reset)
begin
-- reset asynchronously clears line counter
    if reset='1' then
        vcnt <= "000000000000";
        -- vert. line counter increments after every horiz. line
    elsif (hsyncb'event and hsyncb='1') then
        -- vert. line counter rolls-over after 528 lines
        if vcnt<1065 then
            vcnt <= vcnt + 1;
        else
            vcnt <= "000000000000";
        end if;
    end if;
end process;

C: process(clkFPGA,reset)
begin
    -- reset asynchronously sets horizontal sync to inactive
    if reset='1' then
        hsyncb <= '1';
        -- horizontal sync is recomputed on the rising edge of every dot clock
    elsif (clkFPGA'event and clkFPGA='1') then
        -- horiz. sync is low in this interval to signal start of a new line
        if (hcnt>=1327 and hcnt<1439) then
            hsyncb <= '0';
        else
            hsyncb <= '1';
        end if;
    end if;
end process;

D: process(hsyncb,reset)
begin
-- reset asynchronously sets vertical sync to inactive
    if reset='1' then
        vsyncb <= '1';
        -- vertical sync is recomputed at the end of every line of pixels
    elsif (hsyncb'event and hsyncb='1') then
        -- vert. sync is low in this interval to signal start of a new frame
        if (vcnt>=1024 and vcnt<1027) then
            vsyncb <= '0';
        else
            vsyncb <= '1';
        end if;
    end if;
end process;
-- pintamos el marco por pantalla, este ocupara toda la pantalla
--con esto indicamos en que dimensiones queremos que se pinte
marco: process(hsyncb,reset)
begin

    if (hcnt>=1 and hcnt<1300) then
        if (vcnt>=1 and vcnt<1000) then
            marc<= '1';
        else 
            marc <= '0';
        end if;
    else
            marc <= '0';
    end if;
end process;
--pintamos el fondo dentro del marco, marcamos las dimensiones donde queremos que se pinte
fondo: process(hsyncb,reset)
begin

    if (hcnt>=50 and hcnt<1250) then
        if (vcnt>=50 and vcnt<950) then
            fond<= '1';
        else
            fond <= '0';
        end if;
    else
            fond <= '0';
    end if;
end process;

-- saca la barra por pantalla segun las dimensiones de las se�ales en un estado.
barra: process(hsyncb,reset,bar_v_ini,bar_v_fin,bar_h_ini,bar_h_fin)
begin

    if (hcnt>=bar_h_ini and hcnt<bar_h_fin) then
        if (vcnt>=bar_v_ini and vcnt<bar_v_fin) then
            bar<= '1';
        else
            bar <= '0';
        end if;
    else
            bar <= '0';
    end if;
end process barra;

pelota: process(ball_h_ini,ball_h_fin,ball_v_ini,ball_v_fin)
begin
if (hcnt>=ball_h_ini and hcnt<ball_h_fin) then
        if (vcnt>=ball_v_ini and vcnt<ball_v_fin) then
            ball<= '1';
        else
            ball <= '0';
        end if;
    else
            ball <= '0';
    end if;
end process pelota;
--muestra el color y el orden de prioridad con la que se muestra cada cosa (como si pintaras con capas)
--es decir el fondo se pinta por encima del marco y la barra y la pelota por emcima del fondo
mul: process(hsyncb,reset)
begin
	-- reset asynchronously sets vertical sync to inactive
	if(bar = '1') then
	   rgb <= "111111111111";
	   
	elsif(ball = '1') then
	   rgb <= "101010101010";
	   
	elsif(fond = '1') then
	   rgb <= cambia_color;
	   
	elsif(marc = '1') then
	   rgb <= "000000001111";
	else
	   rgb <= "000000000000";
	end if;
end process;
--representa la posicion en la que tiene que estar la barra con cada cambio de estado
-- como la velocidad del reloj de la barra la puse alta he puesto que por cada estado la barra se mueva muy poco para 
--que tanto la barra como la pelota se muevan con fluidez
barpos: process (reset,clkFPGA,bar_v_ini,bar_v_fin,bar_h_ini,bar_h_fin)
begin
    if reset = '1' then 
        bar_v_ini <= x"190";
        bar_v_fin <= x"258";
        bar_h_ini <= x"04B";
        bar_h_fin <= x"064";
    elsif(rising_edge(clkFPGA)) then
    case estado_bar is
        when parado =>
            bar_v_ini <= bar_v_ini;
            bar_v_fin <= bar_v_fin;
            bar_h_ini <= bar_h_ini;
            bar_h_fin <= bar_h_fin;
        when up =>
             bar_v_ini <= bar_v_ini - 20;
            bar_v_fin <= bar_v_fin - 20;
            bar_h_ini <= bar_h_ini;
            bar_h_fin <= bar_h_fin;
        when down =>
            bar_v_ini <= bar_v_ini + 20;
            bar_v_fin <= bar_v_fin + 20;
            bar_h_ini <= bar_h_ini;
            bar_h_fin <= bar_h_fin;
    end case;
    end if;
    
end process barpos;

--representa la posicion en la que tiene que estar la pelota con cada cambio de estado
-- como la velocidad del reloj de la pelota la puse alta he puesto que por cada estado la barra se mueva muy poco para 
-- que tanto la barra como la pelota se muevan con fluidez
ballpos: process (reset,ballclk,ball_v_ini,ball_v_fin,ball_h_ini,ball_h_fin)
begin
    if reset = '1' then 
        ball_v_ini <= x"190";
        ball_v_fin <= x"1C2";
        ball_h_ini <= x"190";
        ball_h_fin <= x"1C2";
    elsif(rising_edge(ballclk)) then
    case estado_ball is
        when no =>
            ball_v_ini <= ball_v_ini - 1;
            ball_v_fin <= ball_v_fin - 1;
            ball_h_ini <= ball_h_ini - 1;
            ball_h_fin <= ball_h_fin - 1;
        when so =>
            ball_v_ini <= ball_v_ini + 1;
            ball_v_fin <= ball_v_fin + 1;
            ball_h_ini <= ball_h_ini - 1;
            ball_h_fin <= ball_h_fin - 1;
        when se =>
            ball_v_ini <= ball_v_ini + 1;
            ball_v_fin <= ball_v_fin + 1;
            ball_h_ini <= ball_h_ini + 1;
            ball_h_fin <= ball_h_fin + 1;
        when ne =>
            ball_v_ini <= ball_v_ini - 1;
            ball_v_fin <= ball_v_fin - 1;
            ball_h_ini <= ball_h_ini + 1;
            ball_h_fin <= ball_h_fin + 1;
    end case;
    end if;
    
end process ballpos;

------------------------- MAQUINA DE ESTADO BARRA---------------------------------

--hacemos la sync donde cambia de estado segun el flanco de reloj
barsync: process(clkFPGA,reset)
begin
    if reset ='1' then
        estado_bar<=parado; -- Estado inicial
    elsif clkFPGA'event and clkFPGA='1' then
        estado_bar<= sig_estado_bar;
    end if;
end process barsync;
--la fsm controla el estado siguente segun el scancode extraido del teclado 
--y procurando que no se pase de las dimensiones por las que puede moverse.

--maquina de estados mealy

barfsm: process(clkFPGA,reset)
begin
    case estado_bar is
        when parado =>
         reset_teclado <= '0';
            if(newkey = '1' and scancode = "00011101" and bar_v_ini > 50)then
                sig_estado_bar <= up;
            elsif(newkey = '1' and scancode = "00011011"and bar_v_fin < 950) then
                sig_estado_bar <= down;
            else
                sig_estado_bar <= estado_bar; 
            end if;
        when up =>
         reset_teclado <= '1';
            if(newkey = '1' and scancode = "00011101"and bar_v_ini > 50)then
                sig_estado_bar <= estado_bar;
            elsif(newkey = '1' and scancode = "00011011"and bar_v_fin < 950) then
                sig_estado_bar <= down;
            else
                sig_estado_bar <= parado; 
            end if;
        when down =>
         reset_teclado <= '1';
            if(newkey = '1' and scancode = "00011101"and bar_v_ini > 50)then
                sig_estado_bar <= up;
            elsif(newkey = '1' and scancode = "00011011"and bar_v_fin < 950) then
                sig_estado_bar <= estado_bar;
            else
                sig_estado_bar <= parado; 
            end if;
    end case;
end process barfsm;



------------------------- MAQUINA DE ESTADOS PELOTA------------------------------

--hacemos la sync de la pelota donde cambia de estado segun el flanco de reloj
ballsync: process(ballclk,reset)
begin
    if reset ='1' then
        estado_ball<=no; -- Estado inicial
    elsif ballclk'event and ballclk='1' then
        estado_ball<= sig_estado_ball;
    end if;
end process ballsync;
--la fsm controla el estado siguente segun en que zona chocque la pelota o si choca contra la barra
--y procurando que no se pase de las dimensiones por las que puede moverse.

-- pondre un ejemplo.
-- si la pelota se mueve hacia el noroeste y se choca contra la parte de arriba del marco pasa al estado de moverse al suroeste
--si por el contrario chocase contra la parte de al izquierda del marco pasaria al estado de moverse al noreste

--maquina de estados mealy
ballfsm: process(ballclk,reset)
begin
    case estado_ball is
        when no =>
            if(ball_v_ini < 50)then
                sig_estado_ball <= so;
                choque <= '0';
            elsif(ball_h_ini < 50 or (ball_h_ini = bar_h_fin and ball_v_ini <= bar_v_fin and ball_v_fin >= bar_v_ini)) then
                if(ball_h_ini = bar_h_fin and ball_v_ini <= bar_v_fin and ball_v_fin >= bar_v_ini) then
                    sig_estado_ball <= ne;
                    choque <= '1';
                else
                    sig_estado_ball <= ne;
                    choque <= '0'; 
                end if;
            else
                sig_estado_ball <= estado_ball; 
                choque <= '0';
            end if;
        when so =>
            if(ball_v_fin > 950)then
                sig_estado_ball <= no;
                choque <= '0';
            elsif(ball_h_ini < 50 or (ball_h_ini = bar_h_fin and ball_v_ini <= bar_v_fin and ball_v_fin >= bar_v_ini)) then
                if (ball_h_ini = bar_h_fin and ball_v_ini <= bar_v_fin and ball_v_fin >= bar_v_ini) then
                    sig_estado_ball <= se;
                    choque <= '1';
                else
                sig_estado_ball <= se;
                choque <= '0';
                end if;
            else
                sig_estado_ball <= estado_ball; 
                choque <= '0';
            end if;
        when se =>
            if(ball_v_fin > 950)then
                sig_estado_ball <= ne;
                choque <= '0';
            elsif(ball_h_fin > 1250) then
                sig_estado_ball <= so;
                choque <= '0';
            else
                sig_estado_ball <= estado_ball; 
                choque <= '0';
            end if;
        when ne =>
            if(ball_v_ini < 50)then
                sig_estado_ball <= se;
                choque <= '0';
            elsif(ball_h_fin > 1250) then
                sig_estado_ball <= no;
                choque <= '0';
            else
                sig_estado_ball <= estado_ball; 
                choque <= '0';
            end if;
    end case;
end process ballfsm;

----------------------CONTADOR---------------------------
-- desde la fsm de la pelota se envia una se�al al contador (choque) que incrementa 
-- el contador cada vez que la pelota toque la barra
contador: process(reset)
begin
    if reset = '1' then
        cont <= (others => '0');
    elsif rising_edge(ballclk)then 
        if choque = '1' then
            cont <= cont + 1;
        else
            cont <= cont;
        end if;
    end if;
end process contador;
-- convierte la salida del contador a 7segmentos para que el resultado salga por los displays
sietesegmentos: process (cont)
begin
    case cont is
        when "000" =>
                disp <= "0000001";
            when "001" =>
                disp <= "1001111";
            when "010" =>
                disp <= "0010010";        
            when "011" =>
                disp <= "0000110";
            when "100" =>
                disp <= "1001100";
            when "101" =>
                disp <= "0100100";
            when "110" =>
                disp <= "0100000";
            when "111" =>
                disp <= "0001111";
            when others =>
                disp <= (others => '1');
           end case;
end process sietesegmentos;


end Behavioral;
