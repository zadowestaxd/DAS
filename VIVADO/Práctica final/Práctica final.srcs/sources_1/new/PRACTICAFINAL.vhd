library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;


entity PRACTICAFINAL is
port
(
    reset: in std_logic; -- reset
    clk_in: in std_logic;
    hsyncb: buffer std_logic; -- horizontal (line) sync
    vsyncb: out std_logic; -- vertical (frame) sync
    rgb: out std_logic_vector(11 downto 0) -- 4 red, 4 green,4 blue colors
);
end PRACTICAFINAL;

architecture PRACTICAFINAL_arch of PRACTICAFINAL is


signal hcnt: std_logic_vector(11 downto 0);
signal vcnt: std_logic_vector(11 downto 0);
signal rectangle: std_logic;
signal frame: std_logic;
signal r1_ouput: std_logic;
signal r2_ouput: std_logic;

begin

--horizontal counter
A: process(clk_in,reset)
begin
    -- reset asynchronously clears pixel counter
    if reset='1' then
        hcnt <= "000000000000";
        -- horiz. pixel counter increments on rising edge of dot clock
    elsif (clk_in'event and clk_in='1') then
        -- horiz. pixel counter rolls-over after 381 pixels
        if hcnt<1687 then
            hcnt <= hcnt + 1;
        else
            hcnt <= "000000000000";
        end if;
    end if;
end process;

--vertical counter
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

--At Hor Sync
C: process(clk_in,reset)
begin
    -- reset asynchronously sets horizontal sync to inactive
    if reset='1' then
        hsyncb <= '1';
        -- horizontal sync is recomputed on the rising edge of every dot clock
    elsif (clk_in'event and clk_in='1') then
        -- horiz. sync is low in this interval to signal start of a new line
        if (hcnt>=1327 and hcnt<1439) then
            hsyncb <= '0';
        else
            hsyncb <= '1';
        end if;
    end if;
end process;
--At V Sync
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

--At Display
E: process(hsyncb,reset)
begin
if (hcnt>=1 and hcnt<1299) then
    if (vcnt>=1 and vcnt<995) then
        rectangle<= '1';
         else 
   rectangle<= '0';
    end if;
   else 
   rectangle<= '0';
end if;

if (hcnt>=100 and hcnt<1200) then
    if (vcnt>=101 and vcnt<896) then
        r1_ouput<= '1';
        else
        r1_ouput<= '0';
    end if;
    
end if;

if (hcnt>=397 and hcnt<498) then
    if (vcnt>=397 and vcnt<498) then
        r2_ouput<= '1';
        else
         r2_ouput<= '0';
    end if;
    else
         r2_ouput<= '0';
end if;
end process;


--Multiplexor
F: process(hsyncb,reset)
begin
	
	if(r2_ouput = '1') then
	   rgb <= "111100000000"; --red
	  
	  elsif(rectangle = '1') then
	   rgb <= "000000011111"; --blue
	   
	elsif(r1_ouput = '1') then
	   rgb <= "000000000000";  --negro
	   
	else
	   rgb <= "000000000000";
	end if;
end process;

end PRACTICAFINAL_arch;