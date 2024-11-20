-- library declaration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            
use IEEE.NUMERIC_STD.ALL;               
                                        

-- entity
entity VGA_motor is
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
end VGA_motor;


-- architecture
architecture func of VGA_motor is
  signal	Xpixel	        : unsigned(9 downto 0);         -- Horizontal pixel counter
  signal Xpipe1, Xpipe2 : unsigned(9 downto 0);
  signal	Ypixel	        : unsigned(9 downto 0);		-- Vertical pixel counter
  signal Ypipe1, Ypipe2 : unsigned(9 downto 0);
  signal	ClkDiv	        : unsigned(1 downto 0);		-- Clock divisor, to generate 25 MHz signal
  signal    add_x     : unsigned(0 downto 0); 
  constant      VisibleWidth    : unsigned(9 downto 0) := to_unsigned(640, 10); --"1010000000";
  constant      FullWidth       : unsigned(9 downto 0) := to_unsigned(800, 10); --"1100100000";
  constant      VisibleHeight   : unsigned(9 downto 0) := to_unsigned(480, 10); --"0111100000";
  constant      FullHeight      : unsigned(9 downto 0) := to_unsigned(521, 10); --"1000001001";
  
  signal	Clk25		: std_logic;			-- One pulse width 25 MHz signal
		
  signal 	tilePixel       : std_logic_vector(7 downto 0);	-- Tile pixel data
  signal	tile_addr	: unsigned(10 downto 0);	-- Tile address

  signal   blank, blank1, blank2       : std_logic;                    -- blanking signal
begin
  -- Clock divisor
  -- Divide system clock (100 MHz) by 4
  process(clk)
  begin
    if rising_edge(clk) then
      if rst='1' then
	      ClkDiv <= (others => '0');
      else
	      ClkDiv <= ClkDiv + 1;
      end if;
    end if;
  end process;
	
  -- 25 MHz clock (one system clock pulse width)
  Clk25 <= '1' when (ClkDiv = 3) else '0';
	
	
  -- Horizontal pixel counter
  process(clk)
  begin
    if rising_edge(clk) then
      if rst='1' then
        Xpixel <= (others => '0');
      elsif Clk25 = '1' then
        if Xpixel = (FullWidth - 1) then
          Xpixel <= (others => '0');
        else
          Xpixel <= Xpixel + 1;
        end if;
      end if;
    end if;
  end process;

  process(clk) begin
    if rising_edge(clk) then
      if rst = '1' then
        Xpipe1 <= (others => '0');
        Xpipe2 <= (others => '0');
        Ypipe1 <= (others => '0');
        Ypipe2 <= (others => '0');
        blank1 <= '0';
        blank2 <= '0';
      else
        Xpipe1 <= Xpixel;
        Xpipe2 <= Xpipe1;
        Ypipe1 <= Ypixel;
        Ypipe2 <= Ypipe1;
        blank1 <= blank;
        blank2 <= blank1;
      end if;
    end if;
  end process;

  
  -- Horizontal sync
  Hsync <= '0' when (Xpipe2 >= VisibleWidth + 16 and Xpipe2 < VisibleWidth + 112) else
           '1';

  
  -- Vertical pixel counter

  process(clk)
  begin
    if rising_edge(clk) then
      if rst='1' then
        Ypixel <= (others => '0');
      elsif Clk25 = '1' and Xpixel = (FullWidth - 1) then
        if Ypixel = (FullHeight- 1) then
          Ypixel <= (others => '0');
        else
          Ypixel <= Ypixel + 1;
        end if;
      end if;
    end if;
  end process;
	

  -- Vertical sync
  Vsync <= '0' when (Ypipe2 >= VisibleHeight + 10 and Ypipe2 < VisibleHeight + 12) else
           '1';


  
  -- Video blanking signal

  blank <= '1' when (Xpixel >= VisibleWidth or Ypixel >= VisibleHeight) else
           '0';

  
  tilePixel <= std_logic_vector(pixel_color) when blank2 = '0' else (others => '0');

  tile_addr <= to_unsigned(20, 7) * (Ypixel(8 downto 5) + ior(3 downto 0)) + Xpixel(9 downto 5);

  tile_screen_pos <= tile_addr(8 downto 0) when blank = '0' else (others => '0');
  tile_internal_x <= Xpipe1(4 downto 2);
  tile_internal_y <= Ypipe1(4 downto 2);

  -- VGA generation
  vgaRed(2) 	<= tilePixel(7);
  vgaRed(1) 	<= tilePixel(6);
  vgaRed(0) 	<= tilePixel(5);
  vgaGreen(2)   <= tilePixel(4);
  vgaGreen(1)   <= tilePixel(3);
  vgaGreen(0)   <= tilePixel(2);
  vgaBlue(2) 	<= tilePixel(1);
  vgaBlue(1) 	<= tilePixel(0);

  
  
end func;