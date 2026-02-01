library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_divider is
  generic (DIVISOR : integer := 50000000);
  port (
    i_resetBar : in  std_logic;
    i_clock    : in  std_logic;
    o_clk_out  : out std_logic
  );
end clock_divider;

architecture rtl of clock_divider is
  signal counter : unsigned(31 downto 0);
  signal out_reg : std_logic := '0';
begin
  process(i_clock, i_resetBar)
  begin
    if i_resetBar = '0' then
      counter <= (others => '0');
      out_reg <= '0';
      o_clk_out <= '0';
    elsif rising_edge(i_clock) then
      if counter >= to_unsigned(DIVISOR - 1, 32) then
        counter <= (others => '0');
        out_reg <= not out_reg; -- toggling gives 50% duty
      else
        counter <= counter + 1;
      end if;
      o_clk_out <= out_reg;
    end if;
  end process;
end rtl;
