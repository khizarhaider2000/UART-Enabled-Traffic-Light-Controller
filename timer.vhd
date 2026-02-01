---------------------------------------------------------
-- timer.vhd
-- Wrapper for Lab 3 timer_collection
-- Drives main/yellow/side/yellow timers based on state
---------------------------------------------------------
LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE work.CEG3155_essentials_pkg.ALL;

ENTITY timer IS
  port(
    i_state            : in  STD_LOGIC_VECTOR(2 downto 0);
    i_mainStreet_timer : in  STD_LOGIC_VECTOR(3 downto 0);
    i_sideStreet_timer : in  STD_LOGIC_VECTOR(3 downto 0);
    i_resetBar         : in  STD_LOGIC;
    i_clk              : in  STD_LOGIC;
    o_done             : out STD_LOGIC;
    o_currentTimer     : out STD_LOGIC_VECTOR(3 downto 0)
  );
END timer;

ARCHITECTURE rtl OF timer IS
  SIGNAL int_set_counter            : STD_LOGIC_VECTOR(3 downto 0);
  SIGNAL int_currentTime            : STD_LOGIC_VECTOR(3 downto 0);
  SIGNAL int_done_mux               : STD_LOGIC_VECTOR(3 downto 0);
  SIGNAL int_done                   : STD_LOGIC;
  SIGNAL int_mainStreet_timer       : STD_LOGIC_VECTOR(3 downto 0);
  SIGNAL int_mainStreetYellow_timer : STD_LOGIC_VECTOR(3 downto 0);
  SIGNAL int_sideStreet_timer       : STD_LOGIC_VECTOR(3 downto 0);
  SIGNAL int_sideStreetYellow_timer : STD_LOGIC_VECTOR(3 downto 0);

  SIGNAL int_hardcode1              : STD_LOGIC_VECTOR(3 downto 0) := "0111";
  SIGNAL int_hardcode2              : STD_LOGIC_VECTOR(3 downto 0) := "0111";
BEGIN
  counter_MainStreet : ENTITY work.loadable_counter(rtl)
    PORT MAP(
      i_loadable   => i_mainStreet_timer,
      i_setCounter => int_set_counter(0),
      i_resetBar   => i_resetBar,
      i_clk        => i_clk,
      o_done       => int_done_mux(0),
      o_q          => int_mainStreet_timer
    );

  counter_MainStreetYellow : ENTITY work.loadable_counter(rtl)
    PORT MAP(
      i_loadable   => int_hardcode1,
      i_setCounter => int_set_counter(1),
      i_resetBar   => i_resetBar,
      i_clk        => i_clk,
      o_done       => int_done_mux(1),
      o_q          => int_mainStreetYellow_timer
    );

  counter_SideStreet : ENTITY work.loadable_counter(rtl)
    PORT MAP(
      i_loadable   => i_sideStreet_timer,
      i_setCounter => int_set_counter(2),
      i_resetBar   => i_resetBar,
      i_clk        => i_clk,
      o_done       => int_done_mux(2),
      o_q          => int_sideStreet_timer
    );

  counter_SideStreetYellow : ENTITY work.loadable_counter(rtl)
    PORT MAP(
      i_loadable   => int_hardcode2,
      i_setCounter => int_set_counter(3),
      i_resetBar   => i_resetBar,
      i_clk        => i_clk,
      o_done       => int_done_mux(3),
      o_q          => int_sideStreetYellow_timer
    );

  -- mux for done signal: A->00, B->01, C->10, D->11
  mux41_done : mux41
    PORT MAP(
      i_A  => int_done_mux(0), -- state 00 -> main green done
      i_B  => int_done_mux(1), -- state 01 -> main yellow done
      i_C  => int_done_mux(2), -- state 10 -> side green done
      i_D  => int_done_mux(3), -- state 11 -> side yellow done
      i_s0 => i_state(0),
      i_s1 => i_state(1),
      o    => int_done
    );

  -- current timer mux (bitwise) with same ordering A->00, B->01, C->10, D->11
  gen_mux41 : FOR i IN 0 TO 3 GENERATE
    mux41_currentTimer : mux41
      PORT MAP(
        i_A  => int_mainStreet_timer(i),        -- 00
        i_B  => int_mainStreetYellow_timer(i),  -- 01
        i_C  => int_sideStreet_timer(i),        -- 10
        i_D  => int_sideStreetYellow_timer(i),  -- 11
        i_s0 => i_state(0),
        i_s1 => i_state(1),
        o    => int_currentTime(i)
      );
  END GENERATE gen_mux41;

  -- decoder to generate set signals for counters
  decoder_state_timer : ENTITY work.decoder_state_timer(rtl)
    PORT MAP(
      i_state      => i_state,
      o_setCounter => int_set_counter
    );

  -- drive entity outputs
  o_done         <= int_done;
  o_currentTimer <= int_currentTime;

END rtl;

