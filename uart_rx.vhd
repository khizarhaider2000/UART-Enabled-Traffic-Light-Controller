library ieee;
use ieee.std_logic_1164.all;

entity uart_rx is
  port(
    i_resetBar  : in  std_logic;
    i_clock     : in  std_logic;
    i_rxd       : in  std_logic;
    i_bclkx8    : in  std_logic;
    o_rx_data   : out std_logic_vector(7 downto 0);
    o_rx_done   : out std_logic;
    o_rx_error  : out std_logic;
    o_RDRF      : out std_logic
  );
end uart_rx;

architecture structural of uart_rx is

  -- signals between FSM and RSR
  signal shift_rsr : std_logic;
  signal load_rdr  : std_logic;
  signal rsr_data  : std_logic_vector(7 downto 0);
  signal rxd_sync  : std_logic;  -- sampled serial bit from FSM

begin

  -- Instantiate the receiver FSM. It synchronizes i_rxd, detects start,
  -- generates bclkx8-edge-driven shift/load pulses, and exposes rxd_sync.
  RX_FSM: entity work.uart_rx_fsm
    port map(
      i_resetBar  => i_resetBar,
      i_clock     => i_clock,
      i_rxd       => i_rxd,
      i_bclkx8    => i_bclkx8,
      o_shift_rsr => shift_rsr,
      o_load_rdr  => load_rdr,
      o_rx_done   => o_rx_done,
      o_rx_error  => o_rx_error,
      o_RDRF      => o_RDRF,
      o_rxd_sync  => rxd_sync
    );

  -- Instantiate the receive shift register (SIPO).
  -- Connect the sampled serial bit (rxd_sync) to the SIPO serial input.
  RSR_INST: entity work.rsr
    port map(
      i_resetBar => i_resetBar,
      i_clock    => i_clock,
      i_shift_en => shift_rsr,
      i_serial   => rxd_sync,   -- <-- fixed: connect sampled serial bit here
      o_q        => rsr_data
    );

  -- When FSM asserts load_rdr, the top-level or uart_core should transfer rsr_data into RDR.
  -- Here we present the parallel data from the RSR as the receiver output.
  o_rx_data <= rsr_data;

end structural;
