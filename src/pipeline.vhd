library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity CPU is 
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
        RxD : in std_logic --USB pin input for UART and BOOTLOADER communication
    );
end CPU;

architecture func of CPU is
    signal IR1 : unsigned(15 downto 0);
    alias IR1_oper  : unsigned(4 downto 0) is IR1(15 downto 11);
    alias IR1_regx  : unsigned(3 downto 0) is IR1(10 downto 7);
    alias IR1_regy  : unsigned(3 downto 0) is IR1(6 downto 3);
    alias IR1_im11 : unsigned(10 downto 0) is IR1(10 downto 0);
    alias IR1_im7  : unsigned(6 downto 0) is IR1(6 downto 0);

    signal IR2 : unsigned(15 downto 0);
    alias IR2_oper  : unsigned(4 downto 0) is IR2(15 downto 11);
    alias IR2_regx  : unsigned(3 downto 0) is IR2(10 downto 7);
    alias IR2_regy  : unsigned(3 downto 0) is IR2(6 downto 3);
    alias IR2_im11 : unsigned(10 downto 0) is IR2(10 downto 0);
    alias IR2_im7  : unsigned(6 downto 0) is IR2(6 downto 0);

    signal IR3 : unsigned(15 downto 0);
    alias IR3_oper  : unsigned(4 downto 0) is IR3(15 downto 11);
    alias IR3_regx  : unsigned(3 downto 0) is IR3(10 downto 7);
    alias IR3_regy  : unsigned(3 downto 0) is IR3(6 downto 3);
    alias IR3_im11 : unsigned(10 downto 0) is IR3(10 downto 0);
    alias IR3_im7  : unsigned(6 downto 0) is IR3(6 downto 0);

    signal IR4 : unsigned(15 downto 0);
    alias IR4_oper  : unsigned(4 downto 0) is IR4(15 downto 11);
    alias IR4_regx  : unsigned(3 downto 0) is IR4(10 downto 7);
    alias IR4_regy  : unsigned(3 downto 0) is IR4(6 downto 3);
    alias IR4_im11 : unsigned(10 downto 0) is IR4(10 downto 0);
    alias IR4_im7  : unsigned(6 downto 0) is IR4(6 downto 0);

    signal PC, PC0, PC1 : unsigned(10 downto 0);

    signal IR0 : unsigned(15 downto 0);

    signal stall1, stall2 : std_logic;

    signal Z_flag, N_flag, O_flag, C_flag : std_logic;
    signal alu_result : unsigned(15 downto 0);

    signal reg_file_out_x, reg_file_out_y : unsigned(15 downto 0);
    signal reg_we : std_logic;
    signal reg_waddress : unsigned(3 downto 0);
    signal X_REG : unsigned(15 downto 0);
    signal Y_REG : unsigned(15 downto 0);

    signal stack_ptr : unsigned(10 downto 0);

    signal D3 : unsigned(15 downto 0);
    signal D4 : unsigned(15 downto 0);

    signal Data_forward_y, Data_forward_x : unsigned(15 downto 0);

    signal Level_4_data : unsigned(15 downto 0);

    signal kbd_enc_ascii_code : unsigned(7 downto 0);
    signal kbd_done : std_logic;
    signal k_flag : std_logic;

    signal booting : std_logic;
    signal booting_we : std_logic;
    signal booting_pm_addr : unsigned(10 downto 0);
    signal booting_instr : unsigned(15 downto 0);

    signal halted : std_logic;

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
    constant LOADPC_INSTR  : unsigned(4 downto 0) := "11100";
    constant CMPI_INSTR    : unsigned(4 downto 0) := "11101";
    constant POP_INSTR     : unsigned(4 downto 0) := "11110";
    constant PUSH_INSTR    : unsigned(4 downto 0) := "11111";

    component PM is 
        port(
            clk : in std_logic;
            addr : in unsigned(10 downto 0);
            pm_out : out unsigned(15 downto 0); 
            we : in std_logic;
            w_addr : in unsigned(10 downto 0);
            w_data : in unsigned(15 downto 0)
        );
    end component;

    component ALU is 
        port(
            clk : in std_logic;
            rst : in std_logic;
            instr : in unsigned(15 downto 0);
            X : in unsigned(15 downto 0);
            Y : in unsigned(15 downto 0);
            result : out unsigned(15 downto 0);
            Z,N,C,O : inout std_logic
        );
    end component;

    component register_file is
        port (
            clk : in std_logic;
            addr_x : in unsigned(3 downto 0);
            addr_y : in unsigned(3 downto 0);
            w_d : in std_logic;
            addr_w : in unsigned(3 downto 0);
            data_w : in unsigned(15 downto 0);
            ascii_code : in unsigned(7 downto 0);
            k_flag : in std_logic;
            out_x : out unsigned(15 downto 0);
            out_y : out unsigned(15 downto 0)
        );
    end component;

    component KBD_ENC is
        port (
            clk : in std_logic;
            rst : in std_logic;
            PS2KeyboardCLK : in std_logic;
            PS2KeyboardData	: in std_logic;
            ascii_code : out unsigned(7 downto 0);
            done_flag : out std_logic
        );
    end component;

    component bootloader is
        port(
            clk    : in std_logic;
            rst     : in std_logic;
            RxD      : in std_logic; 
            booting : inout std_logic;
            we      : out std_logic;
            pm_addr : out unsigned(10 downto 0);
            instr   : out unsigned(15 downto 0)
        );
    end component;

begin

    PM_map : PM port map (
        clk => clk,
        addr => PC,
        pm_out => IR0,
        we => booting_we,
        w_addr => booting_pm_addr,
        w_data => booting_instr
    );

    ALU_map : ALU port map (
        clk => clk,
        rst => rst,
        instr => IR2,
        X => Data_forward_x,
        Y => Data_forward_y,
        result => alu_result,
        Z => Z_flag,
        N => N_flag,
        C => C_flag,
        O => O_flag
    );

    Register_map : register_file port map (
        clk => clk,
        addr_x => IR1_regx,
        addr_y => IR1_regy,
        w_d => reg_we,
        addr_w => reg_waddress,
        data_w => level_4_data,
        ascii_code => kbd_enc_ascii_code,
        k_flag => k_flag,
        out_x => reg_file_out_x,
        out_y => reg_file_out_y
    );

    KBD_ENC_map : KBD_ENC port map (
        clk => clk,
        rst => rst,
        PS2KeyboardCLK => PS2KeyboardClk, 
        PS2KeyboardData => PS2KeyboardData,
        ascii_code => kbd_enc_ascii_code,
        done_flag => kbd_done
    );

    bootloader_map : bootloader port map (
        clk => clk,   
        rst => rst,
        RxD => RxD,    
        booting => booting,
        we => booting_we,
        pm_addr => booting_pm_addr,
        instr => booting_instr
    );
        
    process(clk) begin -- PC Process
        if rising_edge(clk) then
            if (rst = '1') then
                PC0 <= (others => '0');
                PC1 <= (others => '0');
            else 
                PC0 <= PC;
                PC1 <= PC0;
            end if;
        end if;
    end process;


    PC <= (others => '0') when rst = '1' or booting = '1' else 
        PC0 when stall1 = '1' or stall2 = '1' else
        IR2_im11 when (IR2_oper = JMPEQ_INSTR and Z_flag = '1') or
            (IR2_oper = JMPI_INSTR) or 
            (IR2_oper = JMPGE_INSTR and N_flag = '0') or
            (IR2_oper = JMPNEQ_INSTR and Z_flag = '0') or
            (IR2_oper = JMPO_INSTR and O_flag = '1') or
            (IR2_oper = JMPN_INSTR and N_flag = '1') else
        Data_forward_x(10 downto 0) when IR2_oper = JMP_INSTR else
        PC0 + 1;

    process(clk) begin -- IR1 Process
        if rising_edge(clk) then
            if (rst = '1') then
                IR1 <= (others => '0');
            else
                if stall1 = '1' then
                    if stall2 = '0' then
                        IR1_oper <= NOP_INSTR;
                    end if;
                elsif stall2 = '0' then
                    IR1 <= IR0;
                end if; --else keep value
            end if;
        end if;
    end process;

    process(clk) begin -- IR2-4 Process
        if rising_edge(clk) then
            if (rst = '1') then
                IR2 <= (others => '0');
                IR3 <= (others => '0');
                IR4 <= (others => '0');
            else
                if stall2 = '1' then
                    IR2_oper <= NOP_INSTR;
                else 
                    IR2 <= IR1;
                end if;
                IR3 <= IR2;
                IR4 <= IR3;
            end if;
        end if;
    end process;

    process(clk) begin --X and Y reg Process
        if rising_edge(clk) then
            if (rst = '1') then
                X_REG <= (others => '0');
                Y_REG <= (others => '0');
                stack_ptr <= (others => '1');
            else
                X_REG <= reg_file_out_x;
                if IR1_oper = POP_INSTR then
                    stack_ptr <= stack_ptr + 1;
                    Y_REG <= "00000" & (stack_ptr + 1);
                elsif IR1_oper = PUSH_INSTR then
                    stack_ptr <= stack_ptr - 1;
                    Y_REG <= "00000" & stack_ptr;
                elsif IR1_oper = LOADPC_INSTR then
                    Y_REG <= ("00000" & (PC1 + 1));
                elsif IR1_oper =  MOV0_INSTR then
                    Y_REG <= "00000" & IR1_im11;
                elsif IR1_oper = MOVI_INSTR or IR1_oper = ADDI_INSTR or IR1_oper = SUBI_INSTR or IR1_oper = CMPI_INSTR then
                    Y_REG <= "000000000" & IR1_im7;
                else 
                    Y_REG <= reg_file_out_y;
                end if;
                    
            end if;
        end if;
    end process;

    -- WAITK_INSTR + Halt stall
    process(clk) begin
        if rising_edge(clk) then
            if (rst = '1' or booting = '1') then
                k_flag <= '0';
            elsif k_flag = '1' and kbd_done = '1' then
                k_flag <= '0';
            elsif IR1_oper = WAITK_INSTR then
                k_flag <= '1';
            end if;
        end if;
    end process;

    process(clk) begin
        if rising_edge(clk) then
            if rst = '1' or booting = '1' then
                halted <= '0';
            else
                if IR1_oper = HALT_INSTR then
                    halted <= '1';
                end if;
            end if;
        end if;
    end process;

    reg_waddress <= "0000" when IR4_oper = MOV0_INSTR else 
            IR4_regx;
    -- reg_we mux
    reg_we <= '0' when IR4_oper(4 downto 3) = "01" or IR4_oper = NOP_INSTR or IR4_oper = CMP_INSTR or IR4_oper = CMPI_INSTR or
                IR4_oper = STORE_INSTR or IR4_oper = WAITK_INSTR or IR4_oper = PUSH_INSTR else
            '1';
    
    -- Data forward x mux
    Data_forward_x <= D3 when (not (IR3_oper(4 downto 3) = "01" or IR3_oper = WAITK_INSTR or IR3_oper = CMP_INSTR or IR3_oper = STORE_INSTR or IR3_oper = NOP_INSTR or IR3_oper = CMPI_INSTR or IR3_oper = MOV0_INSTR or IR3_oper = PUSH_INSTR) and
            IR3_regx = IR2_regx) or (IR3_oper = MOV0_INSTR and IR2_regx = "0000") else
        Level_4_data when (not (IR4_oper(4 downto 3) = "01" or IR4_oper = WAITK_INSTR or IR4_oper = CMP_INSTR or IR4_oper = STORE_INSTR or IR4_oper = NOP_INSTR or IR4_oper = CMPI_INSTR or IR4_oper = MOV0_INSTR or IR4_oper = PUSH_INSTR) and
            IR4_regx = IR2_regx) or (IR4_oper = MOV0_INSTR and IR2_regx = "0000") else
        X_REG;
    -- Data forward y mux
    Data_forward_y <= 
        Y_REG when IR2_oper(4 downto 3) = "11" else
        D3 when (not (IR3_oper(4 downto 3) = "01" or IR3_oper = WAITK_INSTR or IR3_oper = CMP_INSTR or IR3_oper = STORE_INSTR or IR3_oper = NOP_INSTR or IR3_oper = CMPI_INSTR or IR3_oper = MOV0_INSTR or IR3_oper = PUSH_INSTR) and
            IR3_regx = IR2_regy) or (IR3_oper = MOV0_INSTR and IR2_regy = "0000") else
        Level_4_data when (not (IR4_oper(4 downto 3) = "01" or IR4_oper = WAITK_INSTR or IR4_oper = CMP_INSTR or IR4_oper = STORE_INSTR or IR4_oper = NOP_INSTR or IR4_oper = CMPI_INSTR or IR4_oper = MOV0_INSTR or IR4_oper = PUSH_INSTR) and
            IR4_regx = IR2_regy) or (IR4_oper = MOV0_INSTR and IR2_regy = "0000") else
        Y_REG;


    process(clk) begin --D3/D4 reg Process
        if rising_edge(clk) then
            if (rst = '1') then
                D4 <= (others => '0');
                D3 <= (others => '0');
            else
                D3 <= alu_result;
                D4 <= D3;
            end if;
        end if;
    end process;

    stall1 <= '1' when (IR1_oper(4 downto 3) = "01" or k_flag = '1' or halted = '1' or booting = '1') else --BOOT_HIDE
            '0';
    stall2 <= '1' when (IR2_oper = LOAD_INSTR or IR2_oper = POP_INSTR) and 
        not (IR1_oper = PUSH_INSTR or IR1_oper = NOP_INSTR or IR1_oper = MOV0_INSTR or IR1_oper = JMPI_INSTR or IR1_oper = JMPEQ_INSTR or IR1_oper = JMPN_INSTR or IR1_oper = JMPGE_INSTR or IR1_oper = JMPNEQ_INSTR or IR1_oper = JMPO_INSTR or IR1_oper = WAITK_INSTR)
        and (IR2_regx = IR1_regx or (not (IR1_oper = MOVI_INSTR or IR1_oper = ADDI_INSTR or IR1_oper = SUBI_INSTR or IR1_oper = CMPI_INSTR) and IR2_regx = IR1_regy)) else 
            '0';
    
    Level_4_data <= mem_data_out when IR4_oper = LOAD_INSTR or IR4_oper = POP_INSTR else
                    D4;

    mem_data_in <= data_forward_x;

    mem_addr_4 <= D4;
    mem_addr_3 <= D3;
    mem_we <= '1' when IR3_oper = STORE_INSTR or IR3_oper = PUSH_INSTR else
        '0';

end architecture;