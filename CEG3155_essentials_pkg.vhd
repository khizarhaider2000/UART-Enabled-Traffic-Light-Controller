LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;

-- ========================================================
-- PACKAGE DECLARATION
-- ========================================================
PACKAGE CEG3155_essentials_pkg IS

  -- Clock period constant for testbenches
  CONSTANT clk_period : TIME := 10 ns;

  -- D Flip-Flop with Asynchronous Reset and Enable
  COMPONENT dFFar_EN
    PORT(
      i_d        : IN  STD_LOGIC;
      i_resetBar : IN  STD_LOGIC;
      i_clk      : IN  STD_LOGIC;
      i_en       : IN  STD_LOGIC;
      o_q        : OUT STD_LOGIC;
      o_qBar     : OUT STD_LOGIC
    );
  END COMPONENT;

  -- D Flip-Flop with Asynchronous Set and Enable
  COMPONENT dFFas_EN
    PORT(
      i_d        : IN  STD_LOGIC;
      i_setBar   : IN  STD_LOGIC;
      i_clk      : IN  STD_LOGIC;
      i_en       : IN  STD_LOGIC;
      o_q        : OUT STD_LOGIC;
      o_qBar     : OUT STD_LOGIC
    );
  END COMPONENT;
  
  -- 2 by 1 Multiplexer
  COMPONENT mux21
    PORT(
      i_A       : IN STD_LOGIC;
      i_B       : IN STD_LOGIC;
      i_s       : IN STD_LOGIC;
      o         : OUT STD_LOGIC
    );
  END COMPONENT;
  
  -- 4 by 1 Multiplexer
  COMPONENT mux41
    PORT(
      i_A       : IN STD_LOGIC;
      i_B       : IN STD_LOGIC;
      i_C       : IN STD_LOGIC;
      i_D       : IN STD_LOGIC;
      i_s0      : IN STD_LOGIC;
      i_s1      : IN STD_LOGIC;
      o         : OUT STD_LOGIC
    );
  END COMPONENT;
  
END PACKAGE CEG3155_essentials_pkg;

-- ========================================================
-- PACKAGE BODY
-- ========================================================
PACKAGE BODY CEG3155_essentials_pkg IS
END PACKAGE BODY CEG3155_essentials_pkg;

