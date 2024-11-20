library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity computer is
    port(
        clk : in std_logic;
        rst : in std_logic;
        PS2KeyboardCLK : in std_logic;
        PS2KeyboardData : in std_logic;
        Hsync	                : out std_logic;                     
	    Vsync	                : out std_logic;                     
	    vgaRed	                : out	std_logic_vector(2 downto 0);
	    vgaGreen               : out std_logic_vector(2 downto 0); 
	    vgaBlue	        : out std_logic_vector(2 downto 1);
        RxD : in std_logic --USB pin input for UART and BOOTLOADER communication
    );
end computer; 

architecture func of computer is

    signal Z3 : unsigned(15 downto 0);

    signal IOR : unsigned(15 downto 0);

    signal we_vector : unsigned(31 downto 0);

    signal mem_addr : unsigned(10 downto 0);

    signal mem_in_select : unsigned(4 downto 0);
    signal mem_out_select : unsigned(4 downto 0);

    signal mem_data_out : unsigned(15 downto 0);
    signal mem_data_in : unsigned(15 downto 0);

    signal mem_addr_3 : unsigned(15 downto 0);
    signal mem_addr_4 : unsigned(15 downto 0);
    signal mem_we : std_logic;

    signal dm_data_out : unsigned(15 downto 0);

    signal pict_addr : unsigned(8 downto 0);
    signal pict_data_out : unsigned(4 downto 0);

    signal tile_internal_x : unsigned(2 downto 0);
    signal tile_internal_y : unsigned(2 downto 0);
    signal tile_data_out : unsigned(7 downto 0);


    constant DM_ADDR : unsigned(4 downto 0) := "00000";
    constant PICT_MEM_ADDR : unsigned(4 downto 0) := "00001";
    constant IOR_ADDR : unsigned(4 downto 0) := "00010";

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

    component ADDR_DEC is
        port (
            full_in_addr : in unsigned(15 downto 0);
            full_out_addr : in unsigned(15 downto 0);
            mem_addr : out unsigned(10 downto 0);
            mem_in_select : out unsigned(4 downto 0); -- To allow implementation of new memories
            mem_out_select : out unsigned(4 downto 0)
        );
    end component;

    component DM is
        port (
            clk : in std_logic;
            we  : in std_logic;
            data_in : in unsigned(15 downto 0);
            data_out : out unsigned(15 downto 0);
            addr : in unsigned(10 downto 0)
        );
    end component;

    component VGA_motor is
        port ( clk	             : in std_logic;                     
            rst                    : in std_logic;                     
            pixel_color                  : in unsigned(7 downto 0);
            ior                     : in unsigned(15 downto 0);
            tile_screen_pos         : out unsigned(8 downto 0);
            tile_internal_x         : out unsigned(2 downto 0);
            tile_internal_y         : out unsigned(2 downto 0);
            Hsync	                : out std_logic;                     
            Vsync	                : out std_logic;                     
            vgaRed	                : out	std_logic_vector(2 downto 0);
            vgaGreen               : out std_logic_vector(2 downto 0); 
            vgaBlue	        : out std_logic_vector(2 downto 1)
        );                                       
    end component;
    
    component PICT_MEM is
        port(clk			: in std_logic;                         
            we_pipe		        : in std_logic;                     
            data_in_pipe	        : in unsigned(4 downto 0);      
            data_out_VGA	: out unsigned(4 downto 0);
            addr_pipe	        : in unsigned(8 downto 0);          
            addr_VGA      : in unsigned(8 downto 0)
        );
    end component;

    component tile_mem is
        port(clk : in std_logic;
            addr : in unsigned(4 downto 0);
            x_pos : in unsigned(2 downto 0);
            y_pos : in unsigned(2 downto 0);
            color_out : out unsigned(7 downto 0)
        );
    end component;

begin
    CPU_map : CPU port map (
        clk => clk,
        rst => rst, 
        mem_addr_3 => mem_addr_3,
        mem_addr_4 => mem_addr_4,
        mem_we => mem_we,
        mem_data_out => mem_data_out,
        mem_data_in => mem_data_in,
        PS2KeyboardCLK => PS2KeyboardCLK,
        PS2KeyboardData => PS2KeyboardData,
        RxD => RxD
    );

    ADDR_DEC_map : ADDR_DEC port map (
        full_in_addr => mem_addr_3,
        full_out_addr => mem_addr_4,
        mem_addr => mem_addr,
        mem_in_select => mem_in_select,
        mem_out_select => mem_out_select
    );

    DM_map : DM port map (
        clk => clk, 
        we => we_vector(0),
        data_in => Z3,
        data_out => dm_data_out,
        addr => mem_addr
    );

    VGAM_map : VGA_motor port map (
        clk => clk,
        rst => rst,
        pixel_color => tile_data_out,
        ior => IOR,
        tile_screen_pos => pict_addr,
        tile_internal_x => tile_internal_x,
        tile_internal_y => tile_internal_y,
        Hsync => Hsync,
        Vsync => Vsync,
        vgaRed => vgaRed,
        vgaGreen => vgaGreen,
        vgaBlue => vgaBlue
    );

    PICT_MEM_map : PICT_MEM port map (
        clk => clk,
        we_pipe => we_vector(1),
        data_in_pipe => Z3(4 downto 0),
        data_out_VGA => pict_data_out,
        addr_pipe => mem_addr(8 downto 0),
        addr_VGA => pict_addr
    );

    TILE_MEM_map : tile_mem port map (
        clk => clk,
        addr => pict_data_out,
        x_pos => tile_internal_x,
        y_pos => tile_internal_y,
        color_out => tile_data_out
    );

    process(clk) begin -- Z3
        if rising_edge(clk) then
            if (rst = '1') then
                Z3 <= (others => '0');
            else
                Z3 <= mem_data_in;
            end if;
        end if;
    end process;

    process(clk) begin -- IOR
        if rising_edge(clk) then
            if rst = '1' then
                IOR <= (others => '0');
            elsif we_vector(2) = '1' then
                IOR <= Z3;
            end if;
        end if;
    end process;

     -- mem_we mux
     we_vector <= X"00000000" when mem_we = '0' else
     X"00000001" when mem_in_select = DM_ADDR else
     X"00000002" when mem_in_select = PICT_MEM_ADDR else
     X"00000004" when mem_in_select = IOR_ADDR else
     X"0000000A";

     -- memory data out mux
    mem_data_out <=  dm_data_out when mem_out_select = DM_ADDR else
                    IOR when mem_out_select = IOR_ADDR else
                    (others => '0'); -- CHANGE WHEN MORE REGISTERS OR MEMS CAN BE OUTPUT (mem_out_select)

end architecture;