library ieee;
use ieee.std_logic_1164.all;

entity enARdFF_2 is
  port(
    i_resetBar : in  std_logic;
    i_d        : in  std_logic;
    i_enable   : in  std_logic;
    i_clock    : in  std_logic;
    o_q        : out std_logic;
    o_qBar     : out std_logic
  );
end enARdFF_2;

architecture rtl of enARdFF_2 is
  signal int_q : std_logic;
begin
  process(i_resetBar, i_clock)
  begin
    if i_resetBar = '0' then
      int_q <= '0';
    elsif rising_edge(i_clock) then
      if i_enable = '1' then
        int_q <= i_d;
      end if;
    end if;
  end process;

  o_q    <= int_q;
  o_qBar <= not int_q;
end rtl;
