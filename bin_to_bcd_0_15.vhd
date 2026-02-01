library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bin_to_bcd_0_15 is
  port (
    i_bin  : in  std_logic_vector(3 downto 0); -- 0..15
    o_bcd1 : out std_logic_vector(3 downto 0); -- tens (0 or 1)
    o_bcd2 : out std_logic_vector(3 downto 0)  -- units (0..9)
  );
end entity;

architecture rtl of bin_to_bcd_0_15 is
begin
  process(i_bin)
    variable val  : integer range 0 to 15;
    variable tens : integer range 0 to 1;
    variable unit : integer range 0 to 9;
  begin
    val  := to_integer(unsigned(i_bin));
    tens := val / 10;
    unit := val mod 10;

    o_bcd1 <= std_logic_vector(to_unsigned(tens, 4));
    o_bcd2 <= std_logic_vector(to_unsigned(unit, 4));
  end process;
end architecture;
