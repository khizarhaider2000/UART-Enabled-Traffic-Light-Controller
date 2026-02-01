library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_fsm is
  port(
    i_resetBar       : in  std_logic;
    i_clock          : in  std_logic;

    -- traffic state (LSBs from traffic_fsm)
    i_traffic_state  : in  std_logic_vector(1 downto 0);

    -- CPU-style bus to uart_core
    o_uart_select    : out std_logic;
    o_addr           : out std_logic_vector(1 downto 0); -- "00"=TDR/RDR, "01"=SCSR, "1x"=SCCR
    o_rw             : out std_logic;                    -- 1=read, 0=write
    o_data_bus       : out std_logic_vector(7 downto 0); -- to uart_core.i_data_in
    i_data_bus       : in  std_logic_vector(7 downto 0); -- from uart_core.o_data_out

    -- optional debug
    o_busy           : out std_logic
  );
end uart_fsm;

architecture rtl of uart_fsm is

  -- TDRE bit position in SCSR (adjust to your SCSR implementation)
  constant TDRE_BIT : integer := 7;

  -- Message per state (ASCII)
  -- Message length (6 bytes: 5 chars + CR)
constant MSG_LEN : integer := 6;  

-- ASCII messages (spec page 9)
type t_msg is array (0 to MSG_LEN-1) of std_logic_vector(7 downto 0);

-- State 00: "Mg Sr\r" (Main green, Side red)
constant MSG_MG_SR : t_msg := (x"4D", x"67", x"20", x"53", x"72", x"0D");

-- State 01: "My Sr\r" (Main yellow, Side red)  
constant MSG_MY_SR : t_msg := (x"4D", x"79", x"20", x"53", x"72", x"0D");

-- State 10: "Mr Sg\r" (Main red, Side green)
constant MSG_MR_SG : t_msg := (x"4D", x"72", x"20", x"53", x"67", x"0D");

-- State 11: "Mr Sy\r" (Main red, Side yellow)
constant MSG_MR_SY : t_msg := (x"4D", x"72", x"20", x"53", x"79", x"0D");

  -- FSM states
  type t_state is (
    ST_IDLE,
    ST_READ_REQ,     -- issue SCSR read
    ST_READ_SAMPLE,  -- sample SCSR on next cycle
    ST_WAIT_TDRE,    -- loop until TDRE=1
    ST_WRITE_TDR,    -- single-cycle write to TDR
    ST_NEXT_BYTE     -- advance byte index or finish
  );

  signal state        : t_state := ST_IDLE;

  -- track traffic state changes
  signal prev_trf     : std_logic_vector(1 downto 0) := (others => '0');
  signal trf_changed  : std_logic := '0';

  -- current message buffer and index
  signal msg_buf      : t_msg := MSG_MG_SR;
  signal byte_idx     : integer range 0 to MSG_LEN-1 := 0;

  -- latched status after read sample
  signal scsr_sample  : std_logic_vector(7 downto 0) := (others => '0');
  signal tdre         : std_logic := '0';

  -- bus outputs (registered)
  signal sel_r        : std_logic := '0';
  signal addr_r       : std_logic_vector(1 downto 0) := "00";
  signal rw_r         : std_logic := '1';
  signal data_r       : std_logic_vector(7 downto 0) := (others => '0');

begin

  -- Default bus outputs
  o_uart_select <= sel_r;
  o_addr        <= addr_r;
  o_rw          <= rw_r;
  o_data_bus    <= data_r;
  o_busy        <= '1' when state /= ST_IDLE else '0';

  -- Detect traffic state change and select message
  process(i_clock, i_resetBar)
  begin
    if i_resetBar = '0' then
      prev_trf    <= (others => '0');
      trf_changed <= '0';
    elsif rising_edge(i_clock) then
      if i_traffic_state /= prev_trf then
        trf_changed <= '1';
        prev_trf    <= i_traffic_state;
      else
        trf_changed <= '0';
      end if;
    end if;
  end process;

  -- Combinational helper: choose message for current traffic state
  process(i_traffic_state)
begin
  case i_traffic_state is
    when "00"   => msg_buf <= MSG_MG_SR;  
    when "01"   => msg_buf <= MSG_MY_SR;
    when "10"   => msg_buf <= MSG_MR_SG;
    when others => msg_buf <= MSG_MR_SY;
  end case;
end process;
  -- Main UART control FSM
  process(i_clock, i_resetBar)
  begin
    if i_resetBar = '0' then
      state    <= ST_IDLE;
      byte_idx <= 0;
      sel_r    <= '0';
      addr_r   <= "00";
      rw_r     <= '1';
      data_r   <= (others => '0');
      scsr_sample <= (others => '0');
      tdre        <= '0';
    elsif rising_edge(i_clock) then

      -- Default: deassert bus unless a state drives it
      sel_r  <= '0';
      rw_r   <= '1';
      addr_r <= "00";
      data_r <= (others => '0');

      case state is
        when ST_IDLE =>
          byte_idx <= 0;
          if trf_changed = '1' then
            state <= ST_READ_REQ; -- before writing, check TDRE
          end if;

        when ST_READ_REQ =>
          -- Issue a read of SCSR at addr "01"
          sel_r  <= '1';
          rw_r   <= '1';
          addr_r <= "01";
          state  <= ST_READ_SAMPLE;

        when ST_READ_SAMPLE =>
          -- Sample SCSR (data valid next cycle after read request)
          scsr_sample <= i_data_bus;
          tdre        <= i_data_bus(TDRE_BIT);
          state       <= ST_WAIT_TDRE;

        when ST_WAIT_TDRE =>
          if tdre = '1' then
            state <= ST_WRITE_TDR;
          else
            -- Re-read SCSR until TDRE=1
            sel_r  <= '1';
            rw_r   <= '1';
            addr_r <= "01";
            -- Next cycle we'll sample again
            state  <= ST_READ_SAMPLE;
          end if;

        when ST_WRITE_TDR =>
          -- Single-cycle write to TDR at addr "00"
          sel_r  <= '1';
          rw_r   <= '0';
          addr_r <= "00";
          data_r <= msg_buf(byte_idx);
          state  <= ST_NEXT_BYTE;

        when ST_NEXT_BYTE =>
          if byte_idx = MSG_LEN-1 then
            -- Finished message
            byte_idx <= 0;
            state    <= ST_IDLE;
          else
            -- Advance and check TDRE again for next byte
            byte_idx <= byte_idx + 1;
            state    <= ST_READ_REQ;
          end if;

        when others =>
          state <= ST_IDLE;
      end case;
    end if;
  end process;

end rtl;
