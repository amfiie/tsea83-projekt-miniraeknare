library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;


entity bootloader_uart is
    Port ( 
        clk : in std_logic;
        rst : in std_logic;
        RxD : in std_logic; 
        out_data : out unsigned(7 downto 0);
        lp : out std_logic 
    );
end entity;

architecture func of bootloader_uart is

    signal sreg : UNSIGNED(9 downto 0) := B"0_00000000_0";  -- 18 bit skiftregister 
    signal rx1,rx2 : std_logic;         -- vippor på insignalen
    signal sp : std_logic;              -- skiftpuls
    signal lp_signal : std_logic;       -- laddpuls
    -- Styrenhet
    signal sp_clock : unsigned(9 downto 0) := "0000000000"; -- Klockpulser under en skiftpuls
    signal lp_count : unsigned(3 downto 0) := "0000"; -- Shiftpulser under en laddpuls
    signal isInput : std_logic := '0'; -- 1 om inmatning annars 0

begin

    -- *****************************
    -- *  synkroniseringsvippor    *
    -- *****************************
    process(clk) begin
        if rst='1' then
            rx1 <= '0';
            rx2 <= '0';
        elsif rising_edge(clk) then
            rx1 <= RxD;
            rx2 <= rx1;
        end if;
    end process;

    
    -- -- *****************************
    -- -- *       styrenhet           *
    -- -- *****************************

    lp_signal <= '1' when (lp_count = 10) else '0';
    lp <= lp_signal;

    sp <= '1' when (sp_clock = 434) else '0';

    process(clk) begin
        if rst='1' then
            sp_clock <= "0000000000";
            lp_count <= "0000";
            isInput <= '0';
        elsif rising_edge(clk) then
            if (rx1 = '0') and (rx2 = '1') and (isInput = '0') then 
                sp_clock <= "0000000000";
                lp_count <= "0000";
                isInput <= '1';
            elsif (isInput = '1') then
                sp_clock <= sp_clock + 1;
                if (lp_count = 10) then
                    lp_count <= "0000";
                    isInput <= '0';
                elsif (sp_clock = 867) then
                    sp_clock <= "0000000000";
                elsif (sp_clock = 650) then
                    lp_count <= lp_count + 1;
                end if;
            end if;
        end if;
    end process;


    -- *****************************
    -- * 10 bit skiftregister      *
    -- *****************************
    process(clk) begin
        if rising_edge(clk) then
            if rst='1' and sp='0' then
                sreg <= B"0_00000000_0";
            elsif sp='1' then
                sreg <= shift_right(UNSIGNED(sreg), 1);
                sreg(9) <= rx2;
            end if;
        end if;
    end process;

    out_data <= sreg(8 downto 1) when (lp_signal = '1');

 end architecture;
