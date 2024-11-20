library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_tb is
end entity;


architecture func of alu_tb is
    component ALU is 
        port (
            clk : in std_logic;
            rst : in std_logic;
            instr : in unsigned(15 downto 0);
            X : in unsigned(15 downto 0);
            Y : in unsigned(15 downto 0);
            result : out unsigned(15 downto 0);
            Z,N,C,O : inout std_logic
        );
    end component;

    signal clk : std_logic;
    signal rst : std_logic;
    signal instr : unsigned(15 downto 0);
    signal X : unsigned(15 downto 0);
    signal Y : unsigned(15 downto 0);
    signal result : unsigned(15 downto 0);

    constant clk_period : time := 10 ns;

    alias op : unsigned(4 downto 0) is instr(15 downto 11);
    alias use_c : std_logic is instr(0);
    signal Z, N, C, O : std_logic;

begin
    aluut : ALU port map (
        clk => clk,
        rst => rst,
        instr => instr,
        X => X,
        Y => Y,
        result => result,
        Z => Z,
        N => N,
        C => C,
        O => O
    );

    clk_process : process begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    rst <= '1', '0' after 25 ns;

    process begin
        -- NOP
        instr <= (others => '0'), "0000000000000000" after 25 ns;
        X <= (others => '0'), "0000000000001010" after 25 ns;
        Y <= (others => '0'), "0000000000000001" after 25 ns;
        wait for 100 ns;

        -- ADD
        instr <= (others => '0'), "1000000000000000" after 25 ns; -- Expected: result = 0, Z = 1, N = 0, C = 1, O = 1
        X <= (others => '0'), X"FFFF" after 25 ns;
        Y <= (others => '0'), X"0002" after 25 ns;
        wait for 100 ns;

        -- ADDC
        instr <= (others => '0'), X"8001" after 25 ns; 
        X <= (others => '0'), X"0001" after 25 ns;
        Y <= (others => '0'), X"FFFF" after 25 ns;
        wait for 100 ns;

        --ADDI
        instr <= (others => '0'), X"8100" after 25 ns;
        X <= (others => '0'), X"7000" after 25 ns;
        Y <= (others => '0'), X"7000" after 25 ns;
        wait for 100 ns;

        --CMP
        instr <= (others => '0'), X"0800" after 25 ns; 
        X <= (others => '0'), X"0005" after 25 ns;
        Y <= (others => '0'), X"0002" after 25 ns;
        wait for 100 ns;

        --SUB
        instr <= (others => '0'), X"C000" after 25 ns;
        X <= (others => '0'), X"0001" after 25 ns;
        Y <= (others => '0'), X"0002" after 25 ns;
        wait for 100 ns;

        --SUBC
        instr <= (others => '0'), X"C001" after 25 ns;
        X <= (others => '0'), X"0005" after 25 ns;
        Y <= (others => '0'), X"0002" after 25 ns;
        wait for 100 ns;

        --MUL
        instr <= (others => '0'), X"D000" after 25 ns;
        X <= (others => '0'), X"7FFF" after 25 ns;
        Y <= (others => '0'), X"0002" after 25 ns;
        wait for 100 ns;

        --MULS
        instr <= (others => '0'), X"D800" after 25 ns;
        X <= (others => '0'), X"FFF8" after 25 ns;
        Y <= (others => '0'), X"0003" after 25 ns;
        wait for 100 ns;

        --SHR
        instr <= (others => '0'), X"E000" after 25 ns;
        X <= (others => '0'), X"0001" after 25 ns;
        wait for 100 ns;

        --SHL
        instr <= (others => '0'), X"E800" after 25 ns;
        X <= (others => '0'), X"7FFF" after 25 ns;
        wait for 100 ns;

        --SWAP
        instr <= (others => '0'), X"3000" after 25 ns;
        X <= (others => '0'), X"FFDD" after 25 ns;
        wait for 100 ns;

        --AND
        instr <= (others => '0'), X"F000" after 25 ns;
        X <= (others => '0'), X"F0F0" after 25 ns;
        Y <= (others => '0'), X"8888" after 25 ns;
        wait for 100 ns;

        --OR
        instr <= (others => '0'), X"F800" after 25 ns;
        X <= (others => '0'), X"F0F0" after 25 ns;
        Y <= (others => '0'), X"8888" after 25 ns;
        wait for 100 ns;

        -- BCD
        -- BCD_ADD
        instr <= (others => '0'), X"9000" after 25 ns;
        X <= (others => '0'), X"0009" after 25 ns;
        Y <= (others => '0'), X"0009" after 25 ns;
        wait for 100 ns;

        instr <= (others => '0'), X"9001" after 25 ns;
        X <= (others => '0'), X"0002" after 25 ns;
        Y <= (others => '0'), X"0002" after 25 ns;
        wait for 100 ns;

        -- BCD_SUB
        instr <= (others => '0'), X"A000" after 25 ns;
        X <= (others => '0'), X"0004" after 25 ns;
        Y <= (others => '0'), X"0006" after 25 ns;
        wait for 100 ns;

        -- BCD_SUB
        instr <= (others => '0'), X"A001" after 25 ns;
        X <= (others => '0'), X"0006" after 25 ns;
        Y <= (others => '0'), X"0005" after 25 ns;
        wait for 100 ns;

        -- BCD_SUB
        instr <= (others => '0'), X"A001" after 25 ns;
        X <= (others => '0'), X"0003" after 25 ns;
        Y <= (others => '0'), X"0001" after 25 ns;
        wait for 100 ns;

        -- MOV and others
        instr <= (others => '0'), X"B000" after 25 ns;
        X <= (others => '0'), X"FFFF" after 25 ns;
        Y <= (others => '0'), X"0008" after 25 ns;
        wait for 100 ns;

        wait;
    end process;


    
end architecture;