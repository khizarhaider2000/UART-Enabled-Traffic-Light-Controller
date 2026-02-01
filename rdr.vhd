-- rdr.vhd
library ieee;
use ieee.std_logic_1164.all;

entity rdr is
  port(
    i_resetBar : in  std_logic;
    i_clock    : in  std_logic;
    i_enable   : in  std_logic;
    i_d        : in  std_logic_vector(7 downto 0);
    o_q        : out std_logic_vector(7 downto 0)
  );
end rdr;

architecture rtl of rdr is
  component register8bit
    port(i_resetBar : in std_logic; i_enable : in std_logic; i_d : in std_logic_vector(7 downto 0); i_clock : in std_logic; q_out : out std_logic_vector(7 downto 0));
  end component;
begin
  RDR_REG: register8bit port map(i_resetBar => i_resetBar, i_enable => i_enable, i_d => i_d, i_clock => i_clock, q_out => o_q);
end rtl;
