---------------------------------------------------------
-- traffic_fsm.vhd
-- Single-file traffic FSM + light decoder
-- Replaces external fsm_controller; keeps same wrapper ports
---------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity traffic_fsm is
  port(
    i_resetBar   : in  std_logic;
    i_clk        : in  std_logic;
    i_sscs       : in  std_logic;
    i_timerDone  : in  std_logic;
    o_state      : out std_logic_vector(2 downto 0);   -- canonical 3-bit state for timer
    o_state_2bit : out std_logic_vector(1 downto 0);   -- derived 2-bit view for UART
    o_MST        : out std_logic_vector(2 downto 0);
    o_SST        : out std_logic_vector(2 downto 0)
  );
end traffic_fsm;

architecture rtl of traffic_fsm is
  type t_state is (
    ST_MG_SR,  -- main green, side red
    ST_MY_SR,  -- main yellow, side red
    ST_MR_SG,  -- main red, side green
    ST_MR_SY   -- main red, side yellow
  );
  signal state_reg : t_state := ST_MG_SR;
  signal timer_d   : std_logic := '0';
  signal timer_rise: std_logic := '0';
  signal state_bin : std_logic_vector(2 downto 0);
begin

  -- edge detect for i_timerDone (single-cycle pulse)
  process(i_clk, i_resetBar)
  begin
    if i_resetBar = '0' then
      timer_d    <= '0';
      timer_rise <= '0';
    elsif rising_edge(i_clk) then
      timer_rise <= '0';
      if i_timerDone = '1' and timer_d = '0' then
        timer_rise <= '1';
      end if;
      timer_d <= i_timerDone;
    end if;
  end process;

  -- state register / next-state on timer rising edge
  process(i_clk, i_resetBar)
  begin
    if i_resetBar = '0' then
      state_reg <= ST_MG_SR;
    elsif rising_edge(i_clk) then
      if timer_rise = '1' then
        case state_reg is
          when ST_MG_SR =>
            state_reg <= ST_MY_SR;
          when ST_MY_SR =>
            if i_sscs = '1' then
              state_reg <= ST_MR_SG;
            else
              state_reg <= ST_MR_SY;
            end if;
          when ST_MR_SG =>
            state_reg <= ST_MR_SY;
          when ST_MR_SY =>
            state_reg <= ST_MG_SR;
          when others =>
            state_reg <= ST_MG_SR;
        end case;
      end if;
    end if;
  end process;

  -- canonical 3-bit encoding and outputs
  process(state_reg)
  begin
    case state_reg is
      when ST_MG_SR =>
        state_bin <= "000";  -- canonical index for timer
        o_MST     <= "100";
        o_SST     <= "001";
      when ST_MY_SR =>
        state_bin <= "001";
        o_MST     <= "010";
        o_SST     <= "001";
      when ST_MR_SG =>
        state_bin <= "010";
        o_MST     <= "001";
        o_SST     <= "100";
      when ST_MR_SY =>
        state_bin <= "011";
        o_MST     <= "001";
        o_SST     <= "010";
      when others =>
        state_bin <= "000";
        o_MST     <= "100";
        o_SST     <= "001";
    end case;
  end process;

  -- drive outputs
  o_state      <= state_bin;
  o_state_2bit <= state_bin(1 downto 0);

end rtl;
