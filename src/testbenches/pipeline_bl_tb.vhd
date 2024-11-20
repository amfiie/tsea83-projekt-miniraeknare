library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pipeline_bl_tb is
end entity;

architecture func of pipeline_bl_tb is
    component CPU is 
        port (
            clk : in std_logic;
            rst : in std_logic;
            mem_addr_3 : out unsigned(15 downto 0);
            mem_addr_4 : out unsigned(15 downto 0);
            mem_we : out std_logic;
            mem_data_out : in unsigned(15 downto 0);
            mem_data_in : out unsigned(15 downto 0);
            PS2KeyboardCLK : in std_logic;
            PS2KeyboardData : in std_logic;
            RxD : in std_logic
        );
    end component;

    signal clk     : std_logic;
    signal rst     : std_logic;
    signal mem_addr_3 : unsigned(15 downto 0);
    signal mem_addr_4 : unsigned(15 downto 0);
    signal mem_we : std_logic;
    signal mem_data_out : unsigned(15 downto 0);
    signal mem_data_in : unsigned(15 downto 0);
    signal PS2KeyboardCLK : std_logic;
    signal PS2KeyboardData : std_logic;
    signal rx : std_logic;

    constant clk_period : time := 10 ns;

    signal tb_running : boolean := true;
    -- alla bitar för 1234
    signal rxs :  unsigned(140 downto 0) := B"1_01010010_0_1_01000100_0_1_01000011_0_1_01000010_0_1_01000001_0_1_00001101_0_1_01010011_0_1_00001101_0_1_01000100_0_1_01000011_0_1_01000010_0_1_01000001_0_1_00001101_0_1_01010011_0_1";
    
begin
    cpuut : CPU port map (
        clk => clk,
        rst => rst,
        mem_addr_3 => mem_addr_3,
        mem_addr_4 => mem_addr_4,
        mem_we => mem_we,
        mem_data_out => mem_data_out,
        mem_data_in => mem_data_in,
        PS2KeyboardCLK => PS2KeyboardCLK,
        PS2KeyboardData => PS2KeyboardData,
        RxD => rx
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
      wait for 1 us;
      
      for i in 0 to 140 loop
        rx <= rxs(i);
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