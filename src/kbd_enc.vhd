library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity KBD_ENC is
    port ( clk : in std_logic;
           rst : in std_logic;
           PS2KeyboardCLK : in std_logic;
           PS2KeyboardData	: in std_logic;
           ascii_code : out unsigned(7 downto 0);
           done_flag : out std_logic
    );
end entity;

architecture behavioral of KBD_ENC is
    signal PS2Clk : std_logic;			            -- Synchronized PS2 clock
    signal PS2Data : std_logic;			            -- Synchronized PS2 data
    signal PS2Clk_Q1, PS2Clk_Q2 : std_logic;		-- PS2 clock one pulse flip flop
    signal PS2Clk_op : std_logic;			        -- PS2 clock one pulse 
      
    signal PS2Data_sr : unsigned(10 downto 0);      -- PS2 data shift register
      
    signal PS2BitCounter : unsigned(3 downto 0);    -- PS2 bit counter
    signal BC11 : std_logic;                        -- Counter signal for PS2BitCounter
  
    type state_type is (IDLE, MAKE, BREAK, SHIFT, SHIFT_MAKE, SHIFT_BREAK);			-- declare state types for PS2
    signal PS2state : state_type;					-- PS2 state

    signal shift_flag : std_logic;
    signal select_input : unsigned(8 downto 0);

    alias scan_code : unsigned(7 downto 0) is PS2Data_sr(8 downto 1);
  
begin

    -- Synchronize PS2-KBD signals

    process(clk)
    begin
        if rising_edge(clk) then
            PS2Clk <= PS2KeyboardCLK;
            PS2Data <= PS2KeyboardData;
        end if;
    end process;

    -- Generate one cycle pulse from PS2 clock, negative edge

    process(clk)
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                PS2Clk_Q1 <= '1';
                PS2Clk_Q2 <= '0';
            else
                PS2Clk_Q1 <= PS2Clk;
                PS2Clk_Q2 <= not PS2Clk_Q1;
            end if;
        end if;
    end process;
        
    PS2Clk_op <= (not PS2Clk_Q1) and (not PS2Clk_Q2);


    -- PS2 data shift register

    -- ***********************************
    -- *                                 *
    -- *  VHDL for :                     *
    -- *  PS2_data_shift_reg             *
    -- *                                 *
    -- ***********************************

    process(clk) begin
        if rising_edge(clk) then
            if (rst = '1') then
                PS2Data_sr <= B"0_000000000_0";
            elsif (PS2Clk_op = '1') then 
                PS2Data_sr <= unsigned(shift_right(UNSIGNED(PS2DATA_sr), 1));
                PS2Data_sr(10) <= PS2DATA;
            end if;
        end if;
    end process;

    -- PS2 bit counter
    -- The purpose of the PS2 bit counter is to tell the PS2 state machine when to change state

    -- ***********************************
    -- *                                 *
    -- *  VHDL for :                     *
    -- *  PS2_bit_Counter                *
    -- *                                 *
    -- ***********************************
    
    -- BC11 combinatorical logic
    BC11 <= '1' when (PS2BitCounter = 11) else '0';

    process(clk) begin
        if rising_edge(clk) then
            if (rst = '1') or (BC11 = '1') then
                PS2BitCounter <= "0000";
            elsif (PS2Clk_op = '1') then
                PS2BitCounter <= PS2BitCounter + 1;
            end if;
        end if;
    end process;


    -- PS2 state
    -- Either MAKE or BREAK state is identified from the scancode
    -- Only single character scan codes are identified
    -- The behavior of multiple character scan codes is undefined

    -- ***********************************
    -- *                                 *
    -- *  VHDL for :                     *
    -- *  PS2_State                      *
    -- *                                 *
    -- ***********************************

    process(clk) begin
        if rising_edge(clk) then
            if (rst = '1')then
                shift_flag <= '0';
                PS2state <= IDLE;
            elsif (BC11 = '1') then
                if (PS2state = IDLE) then 
                    if (scan_code = X"F0") then 
                        PS2state <= BREAK;
                    elsif (scan_code = x"12") or (scan_code = x"59") then
                        PS2state <= SHIFT;
                        shift_flag <= '1';
                    elsif (scan_code /= x"E0") then
                        PS2state <= MAKE;
                    end if;
                elsif (PS2state = SHIFT) then
                    if (scan_code = X"F0") then
                        PS2state <= SHIFT_BREAK;
                    elsif (scan_code /= x"12") and (scan_code /= x"59") then
                        PS2state <= SHIFT_MAKE;
                    end if;
                elsif (PS2state = BREAK) then
                    PS2state <= IDLE;
                elsif (PS2state = SHIFT_BREAK) then
                    if (scan_code = x"12") or (scan_code = x"59") then
                        PS2state <= IDLE;
                        shift_flag <= '0';
                    else
                        PS2state <= SHIFT;
                    end if;
                end if;
            elsif (PS2state = MAKE) then
                PS2state <= IDLE;
            elsif (PS2state = SHIFT_MAKE) then
                PS2state <= SHIFT;
            end if;
        end if;
    end process;

    -- k_flag combinatorical logic
    process(clk) begin
        if rising_edge(clk) then
            if (rst = '1') then
                done_flag <= '0';
            elsif (PS2state = MAKE) or (PS2state = SHIFT_MAKE) then
                done_flag <= '1';
            else
                done_flag <= '0';
            end if;
        end if;
    end process;
    
    -- Scan Code -> Ascii Code mapping
    select_input <= scan_code & shift_flag;
    with select_input select
    ascii_code <= 
                x"08" when "011001100", -- x"66" & '0', -- backspace
                x"08" when "011001101", -- x"66" & '1', -- backspace
                x"0A" when "010110100", -- x"5A" & '0', -- enter
                x"0A" when "010110101", -- x"5A" & '1', -- enter + shift
                x"20" when "001010010", -- x"29" & '0', -- space            
                x"2B" when "010011100", -- x"4E" & '0', -- +
                x"2D" when "010010100", -- x"4A" & '0', -- -
                x"2E" when "010010010", -- x"49" & '0', -- .
                x"30" when "010001010", -- x"45" & '0', -- 0
                x"31" when "000101100", -- x"16" & '0', -- 1
                x"32" when "000111100", -- x"1E" & '0', -- 2
                x"33" when "001001100", -- x"26" & '0', -- 3
                x"34" when "001001010", -- x"25" & '0', -- 4
                x"35" when "001011100", -- x"2E" & '0', -- 5
                x"36" when "001101100", -- x"36" & '0', -- 6
                x"37" when "001111010", -- x"3D" & '0', -- 7
                x"38" when "001111100", -- x"3E" & '0', -- 8
                x"39" when "010001100", -- x"46" & '0', -- 9
                x"61" when "000111000", -- x"1C" & '0', -- a
                x"62" when "001100100", -- x"32" & '0', -- b
                x"63" when "001000010", -- x"21" & '0', -- c
                x"64" when "001000110", -- x"23" & '0', -- d
                x"65" when "001001000", -- x"24" & '0',	-- e
                x"66" when "001010110", -- x"2B" & '0',	-- f
                x"67" when "001101000", -- x"34" & '0',	-- g
                x"68" when "001100110", -- x"33" & '0',	-- h
                x"69" when "010000110", -- x"43" & '0',	-- i
                x"6A" when "001110110", -- x"3B" & '0',	-- j
                x"6B" when "010000100", -- x"42" & '0',	-- k
                x"6C" when "010010110", -- x"4B" & '0',	-- l
                x"6D" when "001110100", -- x"3A" & '0',	-- m
                x"6E" when "001100010", -- x"31" & '0',	-- n
                x"6F" when "010001000", -- x"44" & '0',	-- o
                x"70" when "010011010", -- x"4D" & '0',	-- p
                x"71" when "000101010", -- x"15" & '0',	-- q
                x"72" when "001011010", -- x"2D" & '0',	-- r
                x"73" when "000110110", -- x"1B" & '0',	-- s
                x"74" when "001011000", -- x"2C" & '0',	-- t
                x"75" when "001111000", -- x"3C" & '0',	-- u
                x"76" when "001010100", -- x"2A" & '0',	-- v
                x"77" when "000111010", -- x"1D" & '0',	-- w
                x"78" when "001000100", -- x"22" & '0',	-- x
                x"79" when "001101010", -- x"35" & '0',	-- y
                x"7A" when "000110100", -- x"1A" & '0',	-- z
                x"21" when "000101101", -- x"16" & '1', -- !
                x"25" when "001011101", -- x"2E" & '1', -- %
                x"28" when "001111101", -- x"3E" & '1', -- (
                x"29" when "010001101", -- x"46" & '1', -- )
                x"2A" when "010111011", -- x"5D" & '1', -- *
                x"2F" when "001111011", -- x"3D" & '1', -- /
                x"3D" when "010001011", -- x"45" & '1', -- =
                x"5E" when "010110111", -- x"5B" & '1', -- ^
                x"5F" when "010010101", -- x"4A" & '1', -- _
                x"1A" when "011101010", -- x"75" & '0', -- arrow up
                x"1A" when "011101011", -- x"75" & '1', -- arrow up
                x"00" when others;

    -- ascii_code <= scan_code;

end architecture;