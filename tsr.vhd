library ieee;
use ieee.std_logic_1164.all;

entity tsr is
  port(
    i_resetBar : in  std_logic;
    i_clock    : in  std_logic;
    i_load     : in  std_logic;                       -- Load from TDR (active high)
    i_shift_en : in  std_logic;                       -- Shift enable (pulse per bit)
    i_d        : in  std_logic_vector(7 downto 0);    -- 8-bit data
    o_serial   : out std_logic
  );
end tsr;

architecture rtl of tsr is
  signal data_10bit    : std_logic_vector(9 downto 0);
  signal shift_loadbar : std_logic;
  signal enable        : std_logic;
begin
  shift_loadbar <= not i_load;           -- PISO expects loadbar active low
  enable        <= i_load or i_shift_en; -- enable during load or shift
  data_10bit    <= "00" & i_d;           -- pad MSBs (start/stop placeholders)

  PISO: entity work.PISOReg8
    port map(i_d => data_10bit, i_resetBar => i_resetBar, i_enable => enable,
             i_shift => '0', i_shift_LoadBAR => shift_loadbar, i_clock => i_clock, s_out => o_serial);
end rtl;
