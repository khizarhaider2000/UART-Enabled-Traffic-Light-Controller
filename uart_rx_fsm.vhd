library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx_fsm is
  port(
    i_resetBar  : in  std_logic;
    i_clock     : in  std_logic;
    i_rxd       : in  std_logic;
    i_bclkx8    : in  std_logic;  -- high-rate sub-tick (pulse)
    o_shift_rsr : out std_logic;  -- pulse to shift RSR
    o_load_rdr  : out std_logic;  -- pulse to load RDR
    o_rx_done   : out std_logic;
    o_rx_error  : out std_logic;
    o_RDRF      : out std_logic;
    o_rxd_sync  : out std_logic
  );
end uart_rx_fsm;

architecture rtl of uart_rx_fsm is

  -- FSM state type
  type state_type is (IDLE, START_WAIT, DATA_SAMPLE, STOP_SAMPLE);

  -- Internal signals (must be declared here, before begin)
  signal state       : state_type;
  signal rxd_sync1   : std_logic;
  signal rxd_sync2   : std_logic;
  signal subcount    : integer range 0 to 7; -- counts BClkx8 pulses
  signal bit_cnt     : integer range 0 to 7;
  signal bclkx8_d    : std_logic;
  signal bclkx8_edge : std_logic;

begin

  -------------------------------------------------------------------
  -- Synchronize RxD into clock domain (two-stage synchronizer)
  -------------------------------------------------------------------
  process(i_clock, i_resetBar)
  begin
    if i_resetBar = '0' then
      rxd_sync1 <= '1';
      rxd_sync2 <= '1';
    elsif rising_edge(i_clock) then
      rxd_sync1 <= i_rxd;
      rxd_sync2 <= rxd_sync1;
    end if;
  end process;

  -------------------------------------------------------------------
  -- Detect synchronous edge of i_bclkx8 (one-cycle pulse detection)
  -------------------------------------------------------------------
  process(i_clock, i_resetBar)
  begin
    if i_resetBar = '0' then
      bclkx8_d    <= '0';
      bclkx8_edge <= '0';
    elsif rising_edge(i_clock) then
      bclkx8_edge <= '0';
      if i_bclkx8 = '1' and bclkx8_d = '0' then
        bclkx8_edge <= '1';
      end if;
      bclkx8_d <= i_bclkx8;
    end if;
  end process;

  -------------------------------------------------------------------
  -- Main UART RX FSM
  -- - Wait for falling edge (start)
  -- - Wait 4 sub-ticks to sample middle of start bit
  -- - Sample each data bit every 8 sub-ticks (issue o_shift_rsr)
  -- - Sample stop bit and set RDRF/FE accordingly
  -------------------------------------------------------------------
  process(i_clock, i_resetBar)
  begin
    if i_resetBar = '0' then
      state       <= IDLE;
      subcount    <= 0;
      bit_cnt     <= 0;
      o_shift_rsr <= '0';
      o_load_rdr  <= '0';
      o_rx_done   <= '0';
      o_rx_error  <= '0';
      o_RDRF      <= '0';
    elsif rising_edge(i_clock) then
      -- default outputs each cycle
      o_shift_rsr <= '0';
      o_load_rdr  <= '0';
      o_rx_done   <= '0';

      case state is
        when IDLE =>
          o_RDRF <= '0';
          o_rx_error <= '0';
          subcount <= 0;
          bit_cnt <= 0;
          if rxd_sync2 = '0' then  -- detected start edge (line went low)
            state <= START_WAIT;
            subcount <= 0;
          end if;

        when START_WAIT =>
          -- wait 4 BClkx8 pulses to reach middle of start bit
          if bclkx8_edge = '1' then
            if subcount = 3 then
              -- sample start bit; if still low, proceed
              if rxd_sync2 = '0' then
                subcount <= 0;
                bit_cnt <= 0;
                state <= DATA_SAMPLE;
              else
                -- false start, return to idle
                state <= IDLE;
              end if;
            else
              subcount <= subcount + 1;
            end if;
          end if;

        when DATA_SAMPLE =>
          -- sample each data bit every 8 sub-ticks
          if bclkx8_edge = '1' then
            if subcount = 7 then
              -- sample now (middle of data bit)
              o_shift_rsr <= '1';  -- pulse to shift sampled bit into SIPO
              subcount <= 0;
              if bit_cnt = 7 then
                bit_cnt <= 0;
                state <= STOP_SAMPLE;
              else
                bit_cnt <= bit_cnt + 1;
              end if;
            else
              subcount <= subcount + 1;
            end if;
          end if;

        when STOP_SAMPLE =>
          -- sample stop bit after 8 sub-ticks
          if bclkx8_edge = '1' then
            if subcount = 7 then
              -- sample stop bit
              if rxd_sync2 = '1' then
                o_load_rdr <= '1';  -- transfer RSR -> RDR
                o_rx_done <= '1';
                o_RDRF <= '1';
                o_rx_error <= '0';
              else
                o_rx_error <= '1';
                o_RDRF <= '0';
              end if;
              subcount <= 0;
              state <= IDLE;
            else
              subcount <= subcount + 1;
            end if;
          end if;

        when others =>
          state <= IDLE;
      end case;
    end if;
  end process;

  -------------------------------------------------------------------
  -- Expose synchronized RxD for other modules if needed
  -------------------------------------------------------------------
  o_rxd_sync <= rxd_sync2;

end rtl;
