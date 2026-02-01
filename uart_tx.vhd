library ieee;
use ieee.std_logic_1164.all;

entity uart_tx is
  port(
    i_resetBar  : in  std_logic;
    i_clock     : in  std_logic;
    i_tx_start  : in  std_logic;
    i_bclk      : in  std_logic;
    i_tx_data   : in  std_logic_vector(7 downto 0);
    o_txd       : out std_logic;
    o_tx_active : out std_logic;
    o_tx_done   : out std_logic;
    o_TDRE      : out std_logic
  );
end uart_tx;

architecture structural of uart_tx is
  signal load_tsr, shift_tsr, serial_bit : std_logic;
begin
  TSR_INST: entity work.tsr port map(i_resetBar => i_resetBar, i_clock => i_clock, i_load => load_tsr, i_shift_en => shift_tsr, i_d => i_tx_data, o_serial => serial_bit);
  TXFSM: entity work.uart_tx_fsm port map(i_resetBar => i_resetBar, i_clock => i_clock, i_tx_start => i_tx_start, i_bclk => i_bclk, i_serial_bit => serial_bit, o_load_tsr => load_tsr, o_shift_tsr => shift_tsr, o_txd => o_txd, o_TDRE => o_TDRE, o_tx_done => o_tx_done, o_tx_active => o_tx_active);
end structural;
