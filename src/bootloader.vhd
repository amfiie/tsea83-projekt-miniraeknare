library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity bootloader is
    Port (
        clk     : in std_logic;
        rst     : in std_logic;
        RxD      : in std_logic; 
        booting : inout std_logic;
        we      : out std_logic;
        pm_addr : out unsigned(10 downto 0);
        instr   : out unsigned(15 downto 0)
    );
end entity;

architecture func of bootloader is

    signal pm_addr_signal : unsigned(10 downto 0);

    signal lp : std_logic;
    signal bitCount : unsigned(1 downto 0);
    
    signal hex_sign : unsigned(3 downto 0);
    signal ascii_sign : unsigned(7 downto 0);

    constant ascii_0 : unsigned(7 downto 0) := X"30";
    constant ascii_1 : unsigned(7 downto 0) := X"31";
    constant ascii_2 : unsigned(7 downto 0) := X"32";
    constant ascii_3 : unsigned(7 downto 0) := X"33";
    constant ascii_4 : unsigned(7 downto 0) := X"34";
    constant ascii_5 : unsigned(7 downto 0) := X"35";
    constant ascii_6 : unsigned(7 downto 0) := X"36";
    constant ascii_7 : unsigned(7 downto 0) := X"37";
    constant ascii_8 : unsigned(7 downto 0) := X"38";
    constant ascii_9 : unsigned(7 downto 0) := X"39";
    constant ascii_A : unsigned(7 downto 0) := X"41";
    constant ascii_B : unsigned(7 downto 0) := X"42";
    constant ascii_C : unsigned(7 downto 0) := X"43";
    constant ascii_D : unsigned(7 downto 0) := X"44";
    constant ascii_E : unsigned(7 downto 0) := X"45";
    constant ascii_F : unsigned(7 downto 0) := X"46";
    constant ascii_R : unsigned(7 downto 0) := X"52";
    constant ascii_S : unsigned(7 downto 0) := X"53";
    
    component bootloader_uart is
        port(clk  : in std_logic;
            rst   : in std_logic;
            RxD    : in std_logic; 
            out_data : out unsigned (7 downto 0);
            lp    : out std_logic
        );
    end component;

begin

    bootloader_uart_map : bootloader_uart port map (
        clk => clk,
        rst => rst,
        RxD => RxD,
        out_data => ascii_sign,
        lp => lp
    );

    process(clk) begin
        if rising_edge(clk) then
            if (rst = '1') then
                booting <= '0';
                bitCount <= "00";
                we <= '0';
                pm_addr <= "00000000000";
                pm_addr_signal <= "00000000000";
                instr <= X"0000";
            elsif (lp = '1') then
                if (((ascii_sign >= ascii_0) and (ascii_sign <= ascii_9)) or 
                    ((ascii_sign >= ascii_A) and (ascii_sign <= ascii_F))) then
                    
                    case bitCount is
                        when "00" => instr(15 downto 12) <= hex_sign; bitCount <= "01";
                        when "01" => instr(11 downto 8)  <= hex_sign; bitCount <= "10";
                        when "10" => instr(7 downto 4)   <= hex_sign; bitCount <= "11";
                        when "11" => instr(3 downto 0)   <= hex_sign; bitCount <= "00"; we <= '1'; 
                                     pm_addr <= pm_addr_signal; pm_addr_signal <= pm_addr_signal + 1;
                        when others => null;
                    end case;

                elsif (ascii_sign = ascii_S) then
                    booting <= '1';
                elsif (ascii_sign = ascii_R) then
                    booting <= '0';
                end if;
            else 
                we <= '0';
            end if;
        end if;
    end process;

    hex_sign <= X"0" when (ascii_sign = ascii_0) else
                X"1" when (ascii_sign = ascii_1) else
                X"2" when (ascii_sign = ascii_2) else
                X"3" when (ascii_sign = ascii_3) else
                X"4" when (ascii_sign = ascii_4) else
                X"5" when (ascii_sign = ascii_5) else
                X"6" when (ascii_sign = ascii_6) else
                X"7" when (ascii_sign = ascii_7) else
                X"8" when (ascii_sign = ascii_8) else
                X"9" when (ascii_sign = ascii_9) else
                X"A" when (ascii_sign = ascii_A) else
                X"B" when (ascii_sign = ascii_B) else
                X"C" when (ascii_sign = ascii_C) else
                X"D" when (ascii_sign = ascii_D) else
                X"E" when (ascii_sign = ascii_E) else
                X"F" when (ascii_sign = ascii_F);
                
end architecture;