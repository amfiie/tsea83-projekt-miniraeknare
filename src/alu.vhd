library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU is 
        port(
            clk : in std_logic;
            rst : in std_logic;
            instr : in unsigned(15 downto 0);
            X : in unsigned(15 downto 0);
            Y : in unsigned(15 downto 0);
            result : out unsigned(15 downto 0);
            Z,N,C,O : inout std_logic
        );
end ALU;

architecture func of ALU is
    constant NOP_INSTR     : unsigned(4 downto 0) := "00000";
    constant CMP_INSTR     : unsigned(4 downto 0) := "00001";
    constant LOAD_INSTR    : unsigned(4 downto 0) := "00010";
    constant STORE_INSTR   : unsigned(4 downto 0) := "00011";
    constant WAITK_INSTR   : unsigned(4 downto 0) := "00100";
    constant MUL_INSTR     : unsigned(4 downto 0) := "00101";
    constant SWAP_INSTR    : unsigned(4 downto 0) := "00110";
    constant SHR_INSTR     : unsigned(4 downto 0) := "00111";
    constant JMPI_INSTR    : unsigned(4 downto 0) := "01000";
    constant JMP_INSTR     : unsigned(4 downto 0) := "01001";
    constant JMPEQ_INSTR   : unsigned(4 downto 0) := "01010";
    constant JMPN_INSTR    : unsigned(4 downto 0) := "01011";
    constant JMPGE_INSTR   : unsigned(4 downto 0) := "01100";
    constant JMPNEQ_INSTR  : unsigned(4 downto 0) := "01101";
    constant JMPO_INSTR    : unsigned(4 downto 0) := "01110";
    constant ADD_INSTR     : unsigned(4 downto 0) := "10000";
    constant SUB_INSTR     : unsigned(4 downto 0) := "10001";
    constant OR_INSTR      : unsigned(4 downto 0) := "10010";
    constant HALT_INSTR    : unsigned(4 downto 0) := "10011";
    constant AND_INSTR     : unsigned(4 downto 0) := "10100";
    constant MULS_INSTR    : unsigned(4 downto 0) := "10101";
    constant MOV_INSTR     : unsigned(4 downto 0) := "10110";
    constant SHL_INSTR     : unsigned(4 downto 0) := "10111";
    constant ADDI_INSTR    : unsigned(4 downto 0) := "11000";
    constant SUBI_INSTR    : unsigned(4 downto 0) := "11001";
    constant MOV0_INSTR    : unsigned(4 downto 0) := "11010";
    constant MOVI_INSTR    : unsigned(4 downto 0) := "11011";
    constant LOAD_PC_INSTR : unsigned(4 downto 0) := "11100";
    constant CMPI_INSTR    : unsigned(4 downto 0) := "11101";
    constant POP_INSTR     : unsigned(4 downto 0) := "11110";
    constant PUSH_INSTR    : unsigned(4 downto 0) := "11111";
    

    alias op : unsigned(4 downto 0) is instr(15 downto 11);
    alias use_c : std_logic is instr(0);

    signal Zc, Nc, Cc, Oc : std_logic;
    signal R : unsigned(31 downto 0);

begin   
    -----------------------Beräkning av resultat-----------------------
    process(X, Y, op) 
    begin
        R <= (others => '0'); --default
        case op is
            when ADD_INSTR => R(16 downto 0) <= ('0'&X) + ('0'&Y) + (unsigned'((0=>C)) AND unsigned'((0=>use_c))); --ADDC
            when ADDI_INSTR => R(16 downto 0) <= ('0'&X) + ('0'&Y);
            when CMP_INSTR => R(16 downto 0) <= ('0'&X) - ('0'&Y); --CMP
            when CMPI_INSTR => R(16 downto 0) <= ('0'&X) - ('0'&Y); 

            when SUB_INSTR => R(16 downto 0) <= ('0'&X) - ('0'&Y) - (unsigned'((0=>C)) AND unsigned'((0=>use_c))); --SUBC
            when SUBI_INSTR => R(16 downto 0) <= ('0'&X) - ('0'&Y);
            when SHR_INSTR => R(15 downto 0) <= shift_right(unsigned(X), 1); --SHR
            when SHL_INSTR => R(16 downto 1) <= shift_left(unsigned(X), 1);--SHL
            when SWAP_INSTR => R(7 downto 0) <= X(15 downto 8); R(15 downto 8) <= X(7 downto 0);--SWAP
            when AND_INSTR => R(16 downto 0) <= ('0'&X) AND ('0'&Y); --AND
            when OR_INSTR => R(16 downto 0) <= ('0'&X) OR ('0'&Y); --OR
            when others => R(16 downto 0) <= ('0'&Y); --OTHERS
        end case;
    end process;

    result <= R(15 downto 0);

    -----------------------Beräkning av flaggor------------------------
    Zc <= '1' when R(31 downto 0) = 0 else '0';

    Nc <= R(15);

    Cc <= R(16);
    
    Oc <= (not X(15) and not Y(15) and R(15)) or
          (X(15) and Y(15) and not R(15)) when ((op=ADD_INSTR) or (op=SHL_INSTR)) else
          (not X(15) and Y(15) and R(15)) or
          (X(15) and not Y(15) and not R(15)) when ((op=SUB_INSTR) or (op=SHR_INSTR)) else
          '0';
    
    -----------------------Tilldelning av flaggor------------------------
    process(clk) begin
        if rising_edge(clk) then
            if (rst='1') then
                Z <= '0'; N <= '0'; C <= '0'; O <= '0'; 
            else
                Z<=Zc; N<=Nc; C<=Cc; O<=Oc;
            end if;
        end if;
    end process;
end architecture;