library ieee;
use ieee.std_logic_1164.all;

entity PISOReg8 is
  port(
    i_d             : in  std_logic_vector(9 downto 0);
    i_resetBar      : in  std_logic;
    i_enable        : in  std_logic;
    i_shift         : in  std_logic;
    i_shift_LoadBAR : in  std_logic;
    i_clock         : in  std_logic;
    s_out           : out std_logic
  );
end PISOReg8;

architecture rtl of PISOReg8 is
  signal d_sigs : std_logic_vector(9 downto 0);
  signal q_outs : std_logic_vector(9 downto 0);

  component enARdFF_2
    port(
      i_resetBar : in  std_logic;
      i_d        : in  std_logic;
      i_enable   : in  std_logic;
      i_clock    : in  std_logic;
      o_q        : out std_logic;
      o_qBar     : out std_logic
    );
  end component;
begin
  d_sigs(0) <= (i_d(0) and not i_shift_LoadBAR) or (q_outs(1) and i_shift_LoadBAR);
  d_sigs(1) <= (i_d(1) and not i_shift_LoadBAR) or (q_outs(2) and i_shift_LoadBAR);
  d_sigs(2) <= (i_d(2) and not i_shift_LoadBAR) or (q_outs(3) and i_shift_LoadBAR);
  d_sigs(3) <= (i_d(3) and not i_shift_LoadBAR) or (q_outs(4) and i_shift_LoadBAR);
  d_sigs(4) <= (i_d(4) and not i_shift_LoadBAR) or (q_outs(5) and i_shift_LoadBAR);
  d_sigs(5) <= (i_d(5) and not i_shift_LoadBAR) or (q_outs(6) and i_shift_LoadBAR);
  d_sigs(6) <= (i_d(6) and not i_shift_LoadBAR) or (q_outs(7) and i_shift_LoadBAR);
  d_sigs(7) <= (i_d(7) and not i_shift_LoadBAR) or (q_outs(8) and i_shift_LoadBAR);
  d_sigs(8) <= (i_d(8) and not i_shift_LoadBAR) or (q_outs(9) and i_shift_LoadBAR);
  d_sigs(9) <= (i_d(9) and not i_shift_LoadBAR) or (i_shift and i_shift_LoadBAR);

  bit0: enARdFF_2 port map(i_resetBar => i_resetBar, i_d => d_sigs(0), i_enable => i_enable, i_clock => i_clock, o_q => q_outs(0), o_qBar => OPEN);
  bit1: enARdFF_2 port map(i_resetBar => i_resetBar, i_d => d_sigs(1), i_enable => i_enable, i_clock => i_clock, o_q => q_outs(1), o_qBar => OPEN);
  bit2: enARdFF_2 port map(i_resetBar => i_resetBar, i_d => d_sigs(2), i_enable => i_enable, i_clock => i_clock, o_q => q_outs(2), o_qBar => OPEN);
  bit3: enARdFF_2 port map(i_resetBar => i_resetBar, i_d => d_sigs(3), i_enable => i_enable, i_clock => i_clock, o_q => q_outs(3), o_qBar => OPEN);
  bit4: enARdFF_2 port map(i_resetBar => i_resetBar, i_d => d_sigs(4), i_enable => i_enable, i_clock => i_clock, o_q => q_outs(4), o_qBar => OPEN);
  bit5: enARdFF_2 port map(i_resetBar => i_resetBar, i_d => d_sigs(5), i_enable => i_enable, i_clock => i_clock, o_q => q_outs(5), o_qBar => OPEN);
  bit6: enARdFF_2 port map(i_resetBar => i_resetBar, i_d => d_sigs(6), i_enable => i_enable, i_clock => i_clock, o_q => q_outs(6), o_qBar => OPEN);
  bit7: enARdFF_2 port map(i_resetBar => i_resetBar, i_d => d_sigs(7), i_enable => i_enable, i_clock => i_clock, o_q => q_outs(7), o_qBar => OPEN);
  bit8: enARdFF_2 port map(i_resetBar => i_resetBar, i_d => d_sigs(8), i_enable => i_enable, i_clock => i_clock, o_q => q_outs(8), o_qBar => OPEN);
  bit9: enARdFF_2 port map(i_resetBar => i_resetBar, i_d => d_sigs(9), i_enable => i_enable, i_clock => i_clock, o_q => q_outs(9), o_qBar => OPEN);

  s_out <= q_outs(0);
end rtl;
