library ieee;
use ieee.std_logic_1164.all;

entity mux41 is
  port(
    i_A  : in  std_logic;
    i_B  : in  std_logic;
    i_C  : in  std_logic;
    i_D  : in  std_logic;
    i_s0 : in  std_logic;
    i_s1 : in  std_logic;
    o    : out std_logic
  );
end mux41;

architecture rtl of mux41 is
begin
  o <= i_A when (i_s1 = '0' and i_s0 = '0') else
       i_B when (i_s1 = '0' and i_s0 = '1') else
       i_C when (i_s1 = '1' and i_s0 = '0') else
       i_D;   -- (i_s1='1' and i_s0='1')
end rtl;
