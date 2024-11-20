library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity computer_bl_tb is
    end entity;
    
architecture func of computer_bl_tb is
    component computer is 
        port (
            clk          : in std_logic;
            rst             : in std_logic;
            PS2KeyboardCLK  : in std_logic;
            PS2KeyboardData : in std_logic;
            Hsync	        : out std_logic;                     
            Vsync	        : out std_logic;                     
            vgaRed	        : out std_logic_vector(2 downto 0);
            vgaGreen        : out std_logic_vector(2 downto 0); 
            vgaBlue	        : out std_logic_vector(2 downto 1);
            RxD             : in std_logic
        );
    end component;

    signal clk               : std_logic;
    signal rst                  : std_logic;
    signal PS2KeyboardCLK       : std_logic;
    signal PS2KeyboardData      : std_logic;
    signal Hsync	            : std_logic;                     
    signal Vsync	            : std_logic;                     
    signal vgaRed	            : std_logic_vector(2 downto 0);
    signal vgaGreen             : std_logic_vector(2 downto 0); 
    signal vgaBlue	            : std_logic_vector(2 downto 1);
    signal RxD                  : std_logic;

    signal tb_running : boolean := true;
    -- alla bitar för 1234
    signal rxs :  unsigned(139 downto 0) := B"1_01010010_0_1_01000110_0_1_01000110_0_1_01000110_0_1_01000110_0_1_01000110_0_1_01000110_0_1_01000110_0_1_01000110_0_1_01000100_0_1_01000011_0_1_01000010_0_1_01000001_0_1_01010011_0";

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
  
    stimuli_generator : process
      variable i : integer;
    begin
      -- Aktivera reset ett litet tag.
      rst <= '1';
      wait for 500 ns;
  
      wait until rising_edge(clk);        -- se till att reset släpps synkront
                                          -- med klockan
      rst <= '0';
      report "Reset released" severity note;
      RxD <= '1';
      wait for 25 us;
      
      for i in 0 to 139 loop
        RxD <= rxs(i);
        wait for 8.68 us;
      end loop;  -- i
      
      for i in 0 to 50000000 loop         -- Vänta ett antal klockcykler
        wait until rising_edge(clk);
      end loop;  -- i
      
      tb_running <= false;                -- Stanna klockan (vilket medför att inga
                                          -- nya event genereras vilket stannar
                                          -- simuleringen).
      wait;
    end process;
end architecture;