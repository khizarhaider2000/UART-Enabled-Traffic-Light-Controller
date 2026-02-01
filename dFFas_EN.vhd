LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;

ENTITY dFFas_EN IS
  PORT(
    i_d        : in STD_LOGIC;
    i_setBar : in STD_LOGIC;
    i_clk      : in STD_LOGIC;
    i_en       : in STD_LOGIC;
    o_q        : out STD_LOGIC;
    o_qBar     : out STD_LOGIC
  );
END dFFas_EN;

ARCHITECTURE rtl OF dFFas_EN IS
  SIGNAL int_d1, int_d1Bar, int_d2, int_d2Bar     : STD_LOGIC;
  SIGNAL int_q, int_qBar                          : STD_LOGIC;
BEGIN
  -- Concurrent signals
  int_d1 <= not (i_setBar and int_d2Bar and int_d1Bar);
  int_d1Bar <= not (int_d1 and i_clk and i_en);
  int_d2 <= not (int_d1Bar and i_clk and i_en and int_d2Bar);
  int_d2Bar <= not (int_d2 and i_d);
  
  int_q <= not (i_setBar and int_d1Bar and int_qBar);
  int_qBar <= not (int_q and int_d2);
  
  -- Output drivers
  o_q <= int_q;
  o_qBar <= int_qBar;
  
END rtl;


