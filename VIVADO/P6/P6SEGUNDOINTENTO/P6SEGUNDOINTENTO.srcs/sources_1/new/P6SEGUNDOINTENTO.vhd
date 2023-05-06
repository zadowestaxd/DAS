library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity P6SEGUNDOINTENTO is
port (
rst: in std_logic; -- reset
clk: in std_logic;
hsync: buffer std_logic; -- horizontal (line) sync
vsync: out std_logic; -- vertical (frame) sync
color: out std_logic_vector(11 downto 0) -- 4 red, 4 green, 4 blue colors
);
end P6SEGUNDOINTENTO;

architecture Behavioral of P6SEGUNDOINTENTO is
signal h_count: std_logic_vector(11 downto 0);
signal v_count: std_logic_vector(11 downto 0);

begin

-- Horizontal Counter
counter_h: process(clk, rst)
begin
-- Asynchronously clear the horizontal counter when reset is high
if rst = '1' then
h_count <= "000000000000";
-- Increment the horizontal counter on the rising edge of the dot clock
elsif rising_edge(clk) then
-- The horizontal counter rolls over after 381 pixels
if h_count < 1687 then
h_count <= h_count + 1;
else
h_count <= "000000000000";
end if;
end if;
end process;

-- Vertical Counter
counter_v: process(hsync, rst)
begin
-- Asynchronously clear the vertical counter when reset is high
if rst = '1' then
v_count <= "000000000000";
-- Increment the vertical counter after every horizontal line
elsif rising_edge(hsync) then
-- The vertical counter rolls over after 528 lines
if v_count < 1065 then
v_count <= v_count + 1;
else
v_count <= "000000000000";
end if;
end if;
end process;

-- Horizontal Sync
sync_h: process(clk, rst)
begin
-- Asynchronously set horizontal sync to inactive when reset is high
if rst = '1' then
hsync <= '1';
-- Recompute horizontal sync on the rising edge of the dot clock
elsif rising_edge(clk) then
-- Horizontal sync is low in this interval to signal start of a new line
if h_count >= 1327 and h_count < 1439 then
hsync <= '0';
else
hsync <= '1';
end if;
end if;
end process;

-- Vertical Sync
sync_v: process(hsync, rst)
begin
-- Asynchronously set vertical sync to inactive when reset is high
if rst = '1' then
vsync <= '1';
-- Recompute vertical sync at the end of every line of pixels
elsif falling_edge(hsync) then
-- Vertical sync is low in this interval to signal start of a new frame
if v_count >= 1024 and v_count < 1027 then
vsync <= '0';
else
vsync <= '1';
end if;
end if;
end process;

-- Here goes the part to draw on the screen

--
--
end Behavioral;