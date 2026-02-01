library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity baud_rate_generator is
  port(
    i_resetBar : in  std_logic;
    i_clock    : in  std_logic;                        -- system clock
    i_sel      : in  std_logic_vector(2 downto 0);     -- SEL[2:0]
    o_bclkx8   : out std_logic;                        -- 8x sub-tick (pulse)
    o_bclk     : out std_logic                         -- bit tick (pulse)
  );
end baud_rate_generator;

architecture rtl of baud_rate_generator is
  signal divisor       : unsigned(31 downto 0);
  signal counter       : unsigned(31 downto 0);
  signal subcount      : unsigned(2 downto 0); -- 0..7
  signal bclkx8_pulse  : std_logic;
  signal bclk_pulse    : std_logic;
begin
  -- Map SEL to divisor for BClkx8 (system_clock / (baud * 8))
  process(i_sel)
  begin
    case i_sel is
      -- Example mapping for 50 MHz system clock:
      -- divisor = round( sys_clk / (baud * 8) )
      when "000" => divisor <= to_unsigned(5208, 32); 
      
      when "001" => divisor <= to_unsigned(2604, 32);
      when "010" => divisor <= to_unsigned(1302, 32);
      when "011" => divisor <= to_unsigned(651, 32);
      when "100" => divisor <= to_unsigned(325, 32);
      when "101" => divisor <= to_unsigned(163, 32);
      when "110" => divisor <= to_unsigned(81, 32);
      when "111" => divisor <= to_unsigned(41, 32);
      when others => divisor <= to_unsigned(5208, 32);
    end case;
  end process;

  process(i_clock, i_resetBar)
  begin
    if i_resetBar = '0' then
      counter      <= (others => '0');
      subcount     <= (others => '0');
      bclkx8_pulse <= '0';
      bclk_pulse   <= '0';
    elsif rising_edge(i_clock) then
      bclkx8_pulse <= '0';
      bclk_pulse   <= '0';
      if counter >= divisor - 1 then
        counter <= (others => '0');
        bclkx8_pulse <= '1';  -- one-clock pulse for BClkx8
        if subcount = "111" then
          subcount <= (others => '0');
          bclk_pulse <= '1';  -- one-clock pulse for BClk (every 8 sub-ticks)
        else
          subcount <= subcount + 1;
        end if;
      else
        counter <= counter + 1;
      end if;
    end if;
  end process;

  o_bclkx8 <= bclkx8_pulse;
  o_bclk   <= bclk_pulse;
end rtl;
