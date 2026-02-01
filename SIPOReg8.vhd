library ieee;
use ieee.std_logic_1164.all;

entity SIPOReg8 is
  port(
    i_resetBar : in  std_logic;
    i_enable   : in  std_logic;
    i_shift    : in  std_logic;
    i_clock    : in  std_logic;
    s_out      : out std_logic_vector(7 downto 0)
  );
end SIPOReg8;

architecture rtl of SIPOReg8 is
  signal q_outs : std_logic_vector(7 downto 0);

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
  bit0: enARdFF_2 port map(i_resetBar => i_resetBar, i_d => q_outs(1), i_enable => i_enable, i_clock => i_clock, o_q => q_outs(0), o_qBar => OPEN);
  bit1: enARdFF_2 port map(i_resetBar => i_resetBar, i_d => q_outs(2), i_enable => i_enable, i_clock => i_clock, o_q => q_outs(1), o_qBar => OPEN);
  bit2: enARdFF_2 port map(i_resetBar => i_resetBar, i_d => q_outs(3), i_enable => i_enable, i_clock => i_clock, o_q => q_outs(2), o_qBar => OPEN);
  bit3: enARdFF_2 port map(i_resetBar => i_resetBar, i_d => q_outs(4), i_enable => i_enable, i_clock => i_clock, o_q => q_outs(3), o_qBar => OPEN);
  bit4: enARdFF_2 port map(i_resetBar => i_resetBar, i_d => q_outs(5), i_enable => i_enable, i_clock => i_clock, o_q => q_outs(4), o_qBar => OPEN);
  bit5: enARdFF_2 port map(i_resetBar => i_resetBar, i_d => q_outs(6), i_enable => i_enable, i_clock => i_clock, o_q => q_outs(5), o_qBar => OPEN);
  bit6: enARdFF_2 port map(i_resetBar => i_resetBar, i_d => q_outs(7), i_enable => i_enable, i_clock => i_clock, o_q => q_outs(6), o_qBar => OPEN);
  bit7: enARdFF_2 port map(i_resetBar => i_resetBar, i_d => i_shift,    i_enable => i_enable, i_clock => i_clock, o_q => q_outs(7), o_qBar => OPEN);

  s_out <= q_outs;
end rtl;
