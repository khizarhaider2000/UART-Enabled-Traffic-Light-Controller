library ieee;
use ieee.std_logic_1164.all;

entity uart_address_decoder is
  port(
    i_addr        : in  std_logic_vector(1 downto 0);
    i_rw          : in  std_logic;
    i_uart_select : in  std_logic;
    o_tdr_enable  : out std_logic;
    o_sccr_enable : out std_logic;
    o_rdr_select  : out std_logic;
    o_scsr_select : out std_logic;
    o_sccr_select : out std_logic
  );
end uart_address_decoder;

architecture rtl of uart_address_decoder is
begin
  o_tdr_enable <= '1' when (i_uart_select = '1' and i_rw = '0' and i_addr = "00") else '0';
  o_sccr_enable <= '1' when (i_uart_select = '1' and i_rw = '0' and i_addr(1) = '1') else '0';
  o_rdr_select <= '1' when (i_uart_select = '1' and i_rw = '1' and i_addr = "00") else '0';
  o_scsr_select <= '1' when (i_uart_select = '1' and i_rw = '1' and i_addr = "01") else '0';
  o_sccr_select <= '1' when (i_uart_select = '1' and i_rw = '1' and i_addr(1) = '1') else '0';
end rtl;
