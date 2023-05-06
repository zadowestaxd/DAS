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
    
    --pintando por pantalla
    hsyncb: buffer std_logic; -- horizontal (line) sync
    vsyncb: out std_logic; -- vertical (frame) sync
    rgb: out std_logic_vector(11 downto 0);
    
    --output contador
    disp: out std_logic_vector(6 downto 0);
    an: out std_logic_vector(3 downto 0)
    
   );
end pong;

architecture Behavioral of pong is

--señales necesarias para interfaz de teclado
signal scancode: std_logic_vector (7 downto 0);
signal newkey: std_logic;
signal reset_teclado: std_logic;


-- señales necesarias para mostrar en pantalla
signal hcnt: std_logic_vector(11 downto 0);
signal vcnt: std_logic_vector(11 downto 0);
signal marc: std_logic;
signal fond: std_logic;
signal bar: std_logic;
signal ball: std_logic;

--límites de la barra
signal bar_v_ini : std_logic_vector(11 downto 0);
signal bar_v_fin : std_logic_vector(11 downto 0);
signal bar_h_ini : std_logic_vector(11 downto 0);
signal bar_h_fin : std_logic_vector(11 downto 0);

--límites de la bola y reloj
signal ball_v_ini : std_logic_vector(11 downto 0);
signal ball_v_fin : std_logic_vector(11 downto 0);
signal ball_h_ini : std_logic_vector(11 downto 0);
signal ball_h_fin : std_logic_vector(11 downto 0);
signal ballclk : std_logic;

--máquina de estado barra
type estados_bar is (parado, up, down);
signal estado_bar, sig_estado_bar: estados_bar;

--estados bola
type estados_ball is (upleft,downleft ,downright ,upright); 
signal estado_ball, sig_estado_ball: estados_ball;

--ram que guarda las 8 palabras
signal background_color: std_logic_vector(11 downto 0);

--señales para el contador
signal cont: std_logic_vector(2 downto 0);
signal choque: std_logic;


begin
--Para que muestre tan sólo un dígito del display
an <= "1110";

--divisor de frecuencia para la pelota
divball: entity work.divisorFrec port map (cuentaMax => x"0011111", rst => reset, clk => clkFPGA, clkOUT => ballclk);

-- Esta tarea consiste en transformar la acción de pulsar
--una tecla en una señal digital y en otra señal que indique si se ha soltado la tecla o no.
tec: entity work.teclado port map(PS2CLK => PS2CLK, PS2DATA => PS2DATA, reset => reset_teclado, light => scancode, nueva_tecla => newkey
);

---memoria ram---
-- se encarga de acceder a la direccion de memoria en la que se almacenan los colores del fondo en función del contador
-- y devuelve el color asignado que va directamente al controlador vga para que actualize el color del fondo
m_ram: entity work.mem_ram port map(clk => clkFPGA, we => '0', addr => cont, data_in => "000000000000", data_out => background_color);

--CONTROLADOR VGA
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
        if (hcnt>=1330 and hcnt<1440) then
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
        if (vcnt>=1022 and vcnt<1030) then
            vsyncb <= '0';
        else
            vsyncb <= '1';
        end if;
    end if;
end process;
--Estamos dibujando un borde alrededor de la pantalla, cubriendo toda su área, 
--para indicar las dimensiones en las que queremos que se realice la pintura en la pantalla.
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
--pintamos el fondo dentro del marco y definimos donde queremos que se pinte
background: process(hsyncb,reset)
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
end process background;

-- pinta la barra en la pantalla segun las dimensiones de las señales en ese preciso estado
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

--pinta la pelota en la pantalla según las dimensiones de sus seáles en ese preciso estado
drawball: process(ball_h_ini,ball_h_fin,ball_v_ini,ball_v_fin)
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
end process drawball;
--muestra el color y el orden de prioridad con la que se muestra cada cosa (como si pintaras con capas)
--es decir el fondo se pinta por encima del marco y la barra y la pelota por emcima del fondo
mul: process(hsyncb,reset)
begin
	-- reset asynchronously sets vertical sync to inactive
	if(bar = '1') then
	   rgb <= "111111111111";
	   
	elsif(ball = '1') then
	   rgb <= "101010101110";
	   
	elsif(fond = '1') then
	   rgb <= background_color;
	   
	elsif(marc = '1') then
	   rgb <= "000000011111";
	else
	   rgb <= "000000000000";
	end if;
end process;
--Este fragmento de código define la posición de la barra en cada cambio de estado y cuando reset está a 1. 
--Debido a que la velocidad del reloj de la FPGA es alta, la barra se mueve muy poco 
--en cada estado, lo que garantiza que tanto la barra como la pelota se muevan suavemente.¡
barpos: process (reset,clkFPGA,bar_v_ini,bar_v_fin,bar_h_ini,bar_h_fin)
begin
    if reset = '1' then 
        bar_v_ini <= x"191";
        bar_v_fin <= x"257";
        bar_h_ini <= x"04A";
        bar_h_fin <= x"063";
    elsif(rising_edge(clkFPGA)) then
    case estado_bar is
        when parado =>
            bar_v_ini <= bar_v_ini;
            bar_v_fin <= bar_v_fin;
            bar_h_ini <= bar_h_ini;
            bar_h_fin <= bar_h_fin;
        when up =>
             bar_v_ini <= bar_v_ini - 10;
            bar_v_fin <= bar_v_fin - 10;
            bar_h_ini <= bar_h_ini;
            bar_h_fin <= bar_h_fin;
        when down =>
            bar_v_ini <= bar_v_ini + 10;
            bar_v_fin <= bar_v_fin + 10;
            bar_h_ini <= bar_h_ini;
            bar_h_fin <= bar_h_fin;
    end case;
    end if;
    
end process barpos;

--Este fragmento de código define la posición de la bola en cada cambio de estado y cuando reset está a 1. 
--Debido a que la velocidad del reloj de la FPGA es alta, la barra se mueve muy poco 
--en cada estado, lo que garantiza que tanto la barra como la pelota se muevan suavemente.¡
ballpos: process (reset,ballclk,ball_v_ini,ball_v_fin,ball_h_ini,ball_h_fin)
begin
    if reset = '1' then 
        ball_v_ini <= x"191";
        ball_v_fin <= x"1C1";
        ball_h_ini <= x"191";
        ball_h_fin <= x"1C1";
    elsif(rising_edge(ballclk)) then
    case estado_ball is
        when upleft =>
            ball_v_ini <= ball_v_ini - 1;
            ball_v_fin <= ball_v_fin - 1;
            ball_h_ini <= ball_h_ini - 1;
            ball_h_fin <= ball_h_fin - 1;
        when downleft =>
            ball_v_ini <= ball_v_ini + 1;
            ball_v_fin <= ball_v_fin + 1;
            ball_h_ini <= ball_h_ini - 1;
            ball_h_fin <= ball_h_fin - 1;
        when downright =>
            ball_v_ini <= ball_v_ini + 1;
            ball_v_fin <= ball_v_fin + 1;
            ball_h_ini <= ball_h_ini + 1;
            ball_h_fin <= ball_h_fin + 1;
        when upright =>
            ball_v_ini <= ball_v_ini - 1;
            ball_v_fin <= ball_v_fin - 1;
            ball_h_ini <= ball_h_ini + 1;
            ball_h_fin <= ball_h_fin + 1;
    end case;
    end if;
    
end process ballpos;

-- MAQUINA DE ESTADO BARRA
--hacemos la sincronización donde cambia de estado segun el flanco de reloj
barsync: process(clkFPGA,reset)
begin
    if reset ='1' then
        estado_bar<=parado;
    elsif clkFPGA'event and clkFPGA='1' then
        estado_bar<= sig_estado_bar;
    end if;
end process barsync;
--La máquina de estados se encarga de controlar el siguiente estado dependiendo del
--código escaneado obtenido del teclado, y asegurándose de que no se salga de los 
--límites de las dimensiones en las que puede moverse el objeto controlado.
--maquina de estados Moore
barrafsm: process(clkFPGA,reset)
begin
    case estado_bar is
        when parado =>
         reset_teclado <= '0';
            if(bar_v_ini > 50and scancode = "00011101" and newkey = '1' )then
                sig_estado_bar <= up;
            elsif( bar_v_fin < 950 and scancode = "00011011" and newkey = '1') then
                sig_estado_bar <= down;
            else
                sig_estado_bar <= estado_bar; 
            end if;
        when up =>
         reset_teclado <= '1';
            if(bar_v_ini > 50 and scancode = "00011101" and newkey = '1')then
                sig_estado_bar <= estado_bar;
            elsif(bar_v_fin < 950 and scancode = "00011011"and newkey = '1') then
                sig_estado_bar <= down;
            else
                sig_estado_bar <= parado; 
            end if;
        when down =>
         reset_teclado <= '1';
            if( bar_v_ini > 50 and scancode = "00011101"and newkey = '1')then
                sig_estado_bar <= up;
            elsif(bar_v_fin < 950 and scancode = "00011011" and newkey = '1') then
                sig_estado_bar <= estado_bar;
            else
                sig_estado_bar <= parado; 
            end if;
    end case;
end process barrafsm;



-- MAQUINA DE ESTADOS PELOTA
--hacemos la sincronización de la pelota donde cambia de estado segun el flanco de reloj
ballsync: process(clkFPGA,reset)
begin
    if reset ='1' then
        estado_ball<=upleft; 
    elsif clkFPGA'event and clkFPGA='1' then
        estado_ball<= sig_estado_ball;
    end if;
end process ballsync;
--La FSM se encarga de controlar el siguiente estado de la pelota según en qué zona colisione 
--o si colisiona con la barra. Además, se asegura de que la pelota se mantenga dentro de los 
--límites establecidos para su movimiento en la pantalla
--maquina de estados Mealy
ballfsm: process(ballclk,reset)
begin
    case estado_ball is
        when upleft =>
            if(ball_v_ini < 50)then
                sig_estado_ball <= downleft;
                choque <= '0';
            elsif(ball_h_ini < 50 or (ball_h_ini = bar_h_fin and ball_v_ini <= bar_v_fin and ball_v_fin >= bar_v_ini)) then
                if(ball_h_ini = bar_h_fin and ball_v_ini <= bar_v_fin and ball_v_fin >= bar_v_ini) then
                    sig_estado_ball <= upright;
                    choque <= '1';
                else
                    sig_estado_ball <= upright;
                    choque <= '0'; 
                end if;
            else
                sig_estado_ball <= estado_ball; 
                choque <= '0';
            end if;
        when downleft =>
            if(ball_v_fin > 950)then
                sig_estado_ball <= upleft;
                choque <= '0';
            elsif(ball_h_ini < 50 or (ball_h_ini = bar_h_fin and ball_v_ini <= bar_v_fin and ball_v_fin >= bar_v_ini)) then
                if (ball_h_ini = bar_h_fin and ball_v_ini <= bar_v_fin and ball_v_fin >= bar_v_ini) then
                    sig_estado_ball <= downright;
                    choque <= '1';
                else
                sig_estado_ball <= downright;
                choque <= '0';
                end if;
            else
                sig_estado_ball <= estado_ball; 
                choque <= '0';
            end if;
        when downright =>
            if(ball_v_fin > 950)then
                sig_estado_ball <= upright;
                choque <= '0';
            elsif(ball_h_fin > 1250) then
                sig_estado_ball <= downleft;
                choque <= '0';
            else
                sig_estado_ball <= estado_ball; 
                choque <= '0';
            end if;
        when upright =>
            if(ball_v_ini < 50)then
                sig_estado_ball <= downright;
                choque <= '0';
            elsif(ball_h_fin > 1250) then
                sig_estado_ball <= upleft;
                choque <= '0';
            else
                sig_estado_ball <= estado_ball; 
                choque <= '0';
            end if;
    end case;
end process ballfsm;

--CONTADOR
--La máquina de estados de la pelota emite una señal al contador llamada "choque". 
--Cada vez que la pelota toca la barra, el contador se incrementa en uno
counter: process(reset)
begin
    if reset = '1' then
        cont <= (others => '0');
    elsif rising_edge(clkFPGA)then 
        if choque = '1' then
            cont <= cont + 1;
        else
            cont <= cont;
        end if;
    end if;
end process counter;
-- convierte la salida del contador a 7 segmentos para que el resultado salga por los displays
segmentos: process (cont)
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
end process segmentos;

end Behavioral;
