library ieee;
use ieee.std_logic_1164.all;

entity decoder_state_timer is
  port(
    i_state      : in  std_logic_vector(2 downto 0); -- state (we use lower 2 bits)
    o_setCounter : out std_logic_vector(3 downto 0)  -- one-hot: bit0=mainGreen,1=mainYellow,2=sideGreen,3=sideYellow
  );
end decoder_state_timer;

architecture rtl of decoder_state_timer is
  signal s2 : std_logic_vector(1 downto 0);
begin
  s2 <= i_state(1 downto 0);

  process(s2)
  begin
    case s2 is
      when "00" => o_setCounter <= "0001"; -- main green
      when "01" => o_setCounter <= "0010"; -- main yellow
      when "10" => o_setCounter <= "0100"; -- side green
      when "11" => o_setCounter <= "1000"; -- side yellow
      when others => o_setCounter <= (others => '0');
    end case;
  end process;
end rtl;
