library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bootloader_tb is
end entity;


architecture func of bootloader_tb is
    component bootloader is 
        port (
          clk     : in std_logic;
          rst     : in std_logic;
          RxD      : in std_logic; 
          booting : inout std_logic;
          we      : out std_logic;
          pm_addr : out unsigned(10 downto 0);
          instr   : out unsigned(15 downto 0) 
        );
    end component;

    signal clk     : std_logic;
    signal rst     : std_logic;
    signal RxD      : std_logic;
    signal booting : std_logic;
    signal we      : std_logic;
    signal pm_addr : unsigned(10 downto 0);
    signal instr   : unsigned(15 downto 0);

    signal tb_running : boolean := true;
    -- alla bitar för 1234
    signal rxs :  unsigned(70 downto 0) := B"1_01010010_0_1_01000100_0_1_01000011_0_1_01000010_0_1_01000001_0_1_00000000_0_1_00011100_0_1";
    
begin
    bootloader_map : bootloader port map (
        clk => clk,
        rst => rst,
        RxD => RxD,
        booting => booting,
        we => we,
        pm_addr => pm_addr,
        instr => instr
    );

    clk_gen : process
    begin
      while tb_running loop
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
      end loop;
      wait;
    end process;
  
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
      
      for i in 0 to 70 loop
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