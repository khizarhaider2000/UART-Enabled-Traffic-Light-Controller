library ieee;
use ieee.std_logic_1164.all;

entity uart_tx_fsm is
  port(
    i_resetBar  : in  std_logic;
    i_clock     : in  std_logic;
    i_tx_start  : in  std_logic;   -- request to start (pulse)
    i_bclk      : in  std_logic;   -- bit tick (pulse)
    i_serial_bit: in  std_logic;   -- TSR serial output
    o_load_tsr  : out std_logic;
    o_shift_tsr : out std_logic;
    o_txd       : out std_logic;
    o_TDRE      : out std_logic;
    o_tx_done   : out std_logic;
    o_tx_active : out std_logic
  );
end uart_tx_fsm;

architecture rtl of uart_tx_fsm is
  type state_type is (IDLE, START_BIT, DATA_BITS, STOP_BIT);
  signal state       : state_type;
  signal bit_cnt     : integer range 0 to 7;
  signal bclk_d      : std_logic;
  signal bclk_edge   : std_logic;
begin
  -- detect rising edge of i_bclk synchronously
  process(i_clock, i_resetBar)
  begin
    if i_resetBar = '0' then
      bclk_d <= '0';
      bclk_edge <= '0';
    elsif rising_edge(i_clock) then
      bclk_edge <= '0';
      if i_bclk = '1' and bclk_d = '0' then
        bclk_edge <= '1';
      end if;
      bclk_d <= i_bclk;
    end if;
  end process;

  process(i_clock, i_resetBar)
  begin
    if i_resetBar = '0' then
      state <= IDLE;
      bit_cnt <= 0;
      o_load_tsr <= '0';
      o_shift_tsr <= '0';
      o_txd <= '1';
      o_TDRE <= '1';
      o_tx_done <= '0';
      o_tx_active <= '0';
    elsif rising_edge(i_clock) then
      -- defaults
      o_load_tsr <= '0';
      o_shift_tsr <= '0';
      o_tx_done <= '0';

      case state is
        when IDLE =>
          o_txd <= '1';
          o_tx_active <= '0';
          o_TDRE <= '1';
          bit_cnt <= 0;
          if i_tx_start = '1' then
            o_load_tsr <= '1';
            o_TDRE <= '0';
            state <= START_BIT;
          end if;

        when START_BIT =>
          o_tx_active <= '1';
          o_txd <= '0';
          if bclk_edge = '1' then
            state <= DATA_BITS;
          end if;

        when DATA_BITS =>
          o_tx_active <= '1';
          o_txd <= i_serial_bit;
          if bclk_edge = '1' then
            o_shift_tsr <= '1';
            if bit_cnt = 7 then
              bit_cnt <= 0;
              o_TDRE <= '1';
              state <= STOP_BIT;
            else
              bit_cnt <= bit_cnt + 1;
            end if;
          end if;

        when STOP_BIT =>
          o_tx_active <= '1';
          o_txd <= '1';
          if bclk_edge = '1' then
            o_tx_done <= '1';
            state <= IDLE;
          end if;
      end case;
    end if;
  end process;
end rtl;
