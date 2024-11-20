library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity computer_tb is
end entity;

architecture func of computer_tb is
    component computer is 
        port (
            clk : in std_logic;
            rst : in std_logic;
            PS2KeyboardCLK : in std_logic;
            PS2KeyboardData : in std_logic;
            Hsync	                : out std_logic;                     
            Vsync	                : out std_logic;                     
            vgaRed	                : out	std_logic_vector(2 downto 0);
            vgaGreen               : out std_logic_vector(2 downto 0); 
            vgaBlue	        : out std_logic_vector(2 downto 1);
            RxD : in std_logic
        );
    end component;

    signal clk : std_logic;
    signal rst : std_logic;
    signal PS2KeyboardCLK       : std_logic;
    signal PS2KeyboardData      : std_logic;
    signal Hsync	            : std_logic;                     
    signal Vsync	            : std_logic;                     
    signal vgaRed	            : std_logic_vector(2 downto 0);
    signal vgaGreen             : std_logic_vector(2 downto 0); 
    signal vgaBlue	            : std_logic_vector(2 downto 1);
    signal RxD : std_logic;

    constant clk_period : time := 10 ns;
    constant ps2_clk_period : time := 60 us;
    constant PS2_time : time := 1 ms;

begin
    comput : computer port map (
        clk => clk,
        rst => rst,
        PS2KeyboardCLK => PS2KeyboardCLK,
        PS2KeyboardData => PS2KeyboardData,
        Hsync => Hsync,
        Vsync => Vsync,
        vgaRed => vgaRed,
        vgaGreen => vgaGreen,
        vgaBlue => vgaBlue,
        RxD => RxD
    );

    clk_process : process begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    rst <= '1', '0' after 23 ns;

    RxD <= '1';
    
    PS2_stimuli : process
                type pattern_array is array(natural range <>) of unsigned(7 downto 0);
        constant patterns : pattern_array :=
                (
                 x"26",		    -- 3
                 x"F0",		    
                 x"26",
                 x"1E",		    -- 2
                 x"F0",		    
                 x"1E",		
                 x"1E",		    -- 2
                 x"F0",		    
                 x"1E",		
                 x"4E",         -- +
                 x"F0",
                 x"4E",
                 x"25",		    -- 4 
                 x"F0",		    
                 x"25",				
                 x"49",         -- .
                 x"F0",
                 x"49",
                 x"1E",		    -- 2
                 x"F0",		    
                 x"1E",
                 x"5A",         -- Enter
                 x"F0",         
                 x"5A",
                 x"1E",         -- 2
                 x"F0",
                 x"1E",
                 x"75",         -- Up
                 x"F0",
                 x"75"
                );
     
    begin
        PS2KeyboardData <= '1';											-- initial value
        PS2KeyboardCLK <= '1';
        wait for PS2_time;
        for i in patterns'range loop
            PS2KeyboardData <= '0';										-- start bit
            wait for PS2_clk_period/2;
            PS2KeyboardCLK <= '0';
            for j in 0 to 7 loop
                wait for PS2_clk_period/2;
                PS2KeyboardData <= patterns(i)(j);			-- data bit(s)
                PS2KeyboardCLK <= '1';
                wait for PS2_clk_period/2;
                PS2KeyboardCLK <= '0';									-- data valid on negative flank
            end loop;
            wait for PS2_clk_period/2;
            PS2KeyboardData <= '0';										-- parity bit (bogus value, always '0')
            PS2KeyboardCLK <= '1';
            wait for PS2_clk_period/2;
            PS2KeyboardCLK <= '0';
            wait for PS2_clk_period/2;
            PS2KeyboardData <= '1';										-- stop bit
            PS2KeyboardCLK <= '1';
            wait for PS2_clk_period/2;
            PS2KeyboardCLK <= '0';
            wait for PS2_clk_period/2;
            PS2KeyboardCLK <= '1';
            if (((i mod 3) = 0) or (((i+1) mod 3) = 0)) then
                wait for PS2_time;											-- wait between Make and Break
            else
                wait for PS2_clk_period/2;
            end if;
        end loop;
        wait; -- for ever
    end process;
end architecture;