library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity loadable_counter is
  port(
    i_loadable   : in  std_logic_vector(3 downto 0); -- value to load
    i_setCounter : in  std_logic;                    -- load pulse (synchronous)
    i_resetBar   : in  std_logic;
    i_clk        : in  std_logic;
    o_done       : out std_logic;                    -- asserted when counter reaches 0
    o_q          : out std_logic_vector(3 downto 0)  -- current count
  );
end loadable_counter;

architecture rtl of loadable_counter is
  signal cnt : unsigned(3 downto 0) := (others => '0');
begin
  process(i_clk, i_resetBar)
  begin
    if i_resetBar = '0' then
      cnt <= (others => '0');
      o_done <= '0';
    elsif rising_edge(i_clk) then
      if i_setCounter = '1' then
        cnt <= unsigned(i_loadable);
        o_done <= '0';
      else
        if cnt = 0 then
          o_done <= '1';
        else
          cnt <= cnt - 1;
          o_done <= '0';
        end if;
      end if;
    end if;
  end process;

  o_q <= std_logic_vector(cnt);
end rtl;
