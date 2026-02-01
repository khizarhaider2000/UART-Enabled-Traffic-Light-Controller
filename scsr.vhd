-- scsr.vhd
library ieee;
use ieee.std_logic_1164.all;

entity scsr is
  port(
    i_resetBar : in  std_logic;
    i_clock    : in  std_logic;
    i_TDRE     : in  std_logic;
    i_RDRF     : in  std_logic;
    i_OE       : in  std_logic;
    i_FE       : in  std_logic;
    o_q        : out std_logic_vector(7 downto 0)
  );
end scsr;

architecture rtl of scsr is
  signal status_reg : std_logic_vector(7 downto 0);
begin
  process(i_clock, i_resetBar)
  begin
    if i_resetBar = '0' then
      status_reg <= (others => '0');
    elsif rising_edge(i_clock) then
      status_reg(7) <= i_TDRE;
      status_reg(6) <= i_RDRF;
      status_reg(5) <= i_OE;
      status_reg(4) <= i_FE;
      status_reg(3 downto 0) <= (others => '0');
    end if;
  end process;
  o_q <= status_reg;
end rtl;
