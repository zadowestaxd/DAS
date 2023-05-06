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
--use IEEE.NUMERIC_STD.ALL;


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
    
    leds: out std_logic_vector(7 downto 0)
    
   );
end pong;

architecture Behavioral of pong is

signal scancode: std_logic_vector (7 downto 0);
signal newkey: std_logic;



signal hcnt: std_logic_vector(11 downto 0);
signal vcnt: std_logic_vector(11 downto 0);
signal marc: std_logic;
signal fond: std_logic;
signal bar: std_logic;

signal bar_v_ini : std_logic_vector(11 downto 0) := x"190"; -- 400
signal bar_v_fin : std_logic_vector(11 downto 0) := x"258"; -- 600
signal bar_h_ini : std_logic_vector(11 downto 0) := x"04B"; -- 75
signal bar_h_fin : std_logic_vector(11 downto 0) := x"064"; -- 100


signal barclk : std_logic;
--fsm barra
type estados_bar is (parado, up, down);
signal estado_bar, sig_estado_bar: estados_bar;

begin

div: entity work.divisorFrec port map (
    valorMax => x"0008000",
    rst => reset,
    clk => clkFPGA,
    clkOUT => barclk
);

tec: entity work.teclado port map(
     PS2CLK => PS2CLK,
     PS2DATA => PS2DATA,
     rst => reset,
     leds => scancode,
     newkey => newkey
);

            
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

barsync: process(barclk,reset)
begin
    if reset ='1' then
        estado_bar<=parado; -- Estado inicial
    elsif barclk'event and barclk='1' then
        estado_bar<= sig_estado_bar;
    end if;
end process barsync;

barfsm: process(barclk,reset)
begin
--TODO: falta que la barra no pueda subir mas o no pueda bajar mas porque chocque con el marco
    case estado_bar is
        when parado =>
            if(newkey = '0' and scancode = "00011101" and bar_v_ini > 50)then
                sig_estado_bar <= up;
            elsif(newkey = '0' and scancode = "00011011"and bar_v_fin < 950) then
                sig_estado_bar <= down;
            else
                sig_estado_bar <= estado_bar; 
            end if;
        when up =>
            if(newkey = '0' and scancode = "00011101"and bar_v_ini > 50)then
                sig_estado_bar <= estado_bar;
            elsif(newkey = '0' and scancode = "00011011"and bar_v_fin < 950) then
                sig_estado_bar <= down;
            else
                sig_estado_bar <= parado; 
            end if;
        when down =>
            if(newkey = '0' and scancode = "00011101"and bar_v_ini > 50)then
                sig_estado_bar <= up;
            elsif(newkey = '0' and scancode = "00011011"and bar_v_fin < 950) then
                sig_estado_bar <= estado_bar;
            else
                sig_estado_bar <= parado; 
            end if;
    end case;
end process barfsm;

barpos: process (reset,barclk,bar_v_ini,bar_v_fin,bar_h_ini,bar_h_fin)
begin
    if reset = '1' then 
        bar_v_ini <= x"190";
        bar_v_fin <= x"258";
        bar_h_ini <= x"04B";
        bar_h_fin <= x"064";
    elsif(rising_edge(barclk)) then
    case estado_bar is
        when parado =>
            bar_v_ini <= bar_v_ini;
            bar_v_fin <= bar_v_fin;
            bar_h_ini <= bar_h_ini;
            bar_h_fin <= bar_h_fin;
        when up =>
             bar_v_ini <= bar_v_ini - 1;
            bar_v_fin <= bar_v_fin - 1;
            bar_h_ini <= bar_h_ini;
            bar_h_fin <= bar_h_fin;
        when down =>
            bar_v_ini <= bar_v_ini + 1;
            bar_v_fin <= bar_v_fin + 1;
            bar_h_ini <= bar_h_ini;
            bar_h_fin <= bar_h_fin;
    end case;
    end if;
    
end process barpos;

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

mul: process(hsyncb,reset)
begin
	-- reset asynchronously sets vertical sync to inactive
	if(bar = '1') then
	   rgb <= "111111111111";
	   
	elsif(fond = '1') then
	   rgb <= "000100100100";
	   
	elsif(marc = '1') then
	   rgb <= "000000001111";
	else
	   rgb <= "000000000000";
	end if;
end process;

leds <= scancode;

end Behavioral;
