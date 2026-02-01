library ieee;
use ieee.std_logic_1164.all;

entity rsr is
  port(
    i_resetBar : in  std_logic;
    i_clock    : in  std_logic;
    i_shift_en : in  std_logic;
    i_serial   : in  std_logic;
    o_q        : out std_logic_vector(7 downto 0)
  );
end rsr;

architecture rtl of rsr is
begin
  SIPO: entity work.SIPOReg8
    port map(i_resetBar => i_resetBar, i_enable => i_shift_en, i_shift => i_serial, i_clock => i_clock, s_out => o_q);
end rtl;
