library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            
use IEEE.NUMERIC_STD.ALL;

entity tile_mem is
    port(clk : in std_logic;
        addr : in unsigned(4 downto 0); -- what tile
        x_pos : in unsigned(2 downto 0);
        y_pos : in unsigned(2 downto 0);
        color_out : out unsigned(7 downto 0)
    );
end entity;

architecture func of tile_mem is
    --type tile_t is array (0 to 63) of unsigned(2 downto 0);
    type tile_mem_t is array (0 to 2047) of unsigned(2 downto 0);
    type pallet_t is array(0 to 7) of unsigned(7 downto 0); 

    signal xy_index : unsigned(5 downto 0);
    signal color_code : unsigned(2 downto 0);

    signal tile_memory : tile_mem_t := (
        "000", "000", "001", "001", "001", "000", "000", "000", -- 0
        "000", "001", "000", "000", "000", "001", "000", "000",
        "000", "001", "000", "000", "000", "001", "000", "000",
        "000", "001", "000", "000", "000", "001", "000", "000",
        "000", "001", "000", "000", "000", "001", "000", "000",
        "000", "001", "000", "000", "000", "001", "000", "000",
        "000", "000", "001", "001", "001", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",

        "000", "000", "000", "001", "000", "000", "000", "000", -- 1
        "000", "000", "001", "001", "000", "000", "000", "000",
        "000", "000", "000", "001", "000", "000", "000", "000",
        "000", "000", "000", "001", "000", "000", "000", "000",
        "000", "000", "000", "001", "000", "000", "000", "000",
        "000", "000", "000", "001", "000", "000", "000", "000",
        "000", "000", "001", "001", "001", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",

        "000", "001", "001", "001", "001", "001", "000", "000", -- 2
        "001", "001", "000", "000", "000", "001", "000", "000",
        "001", "000", "000", "000", "001", "001", "000", "000",
        "000", "000", "001", "001", "001", "000", "000", "000",
        "001", "001", "001", "000", "000", "000", "000", "000",
        "001", "000", "000", "000", "000", "000", "000", "000",
        "001", "001", "001", "001", "001", "001", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",

        "000", "001", "001", "001", "001", "000", "000", "000", -- 3
        "001", "001", "000", "000", "001", "001", "000", "000",
        "000", "000", "000", "001", "001", "000", "000", "000",
        "000", "001", "001", "001", "001", "001", "000", "000",
        "000", "000", "000", "000", "000", "001", "001", "000",
        "001", "001", "000", "000", "001", "001", "000", "000",
        "000", "001", "001", "001", "001", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",

        "000", "001", "000", "000", "000", "000", "000", "000", -- 4
        "000", "001", "000", "000", "001", "000", "000", "000",
        "001", "000", "000", "000", "001", "000", "000", "000",
        "001", "000", "000", "000", "001", "000", "000", "000",
        "001", "001", "001", "001", "001", "001", "001", "000",
        "000", "000", "000", "000", "001", "000", "000", "000",
        "000", "000", "000", "000", "001", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",

        "000", "001", "001", "001", "001", "001", "000", "000", -- 5
        "000", "001", "000", "000", "000", "000", "000", "000",
        "000", "001", "000", "000", "000", "000", "000", "000",
        "000", "001", "001", "001", "001", "000", "000", "000",
        "000", "000", "000", "000", "000", "001", "000", "000",
        "001", "000", "000", "000", "000", "001", "000", "000",
        "000", "001", "001", "001", "001", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",

        "000", "001", "001", "001", "001", "000", "000", "000", -- 6
        "001", "000", "000", "000", "000", "000", "000", "000",
        "001", "000", "000", "000", "000", "000", "000", "000",
        "001", "001", "001", "001", "001", "000", "000", "000",
        "001", "000", "000", "000", "000", "001", "000", "000",
        "001", "000", "000", "000", "000", "001", "000", "000",
        "000", "001", "001", "001", "001", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",

        "000", "001", "001", "001", "001", "001", "001", "000", -- 7
        "000", "000", "000", "000", "000", "000", "001", "000",
        "000", "000", "000", "000", "000", "001", "000", "000",
        "000", "000", "000", "000", "000", "001", "000", "000",
        "000", "000", "000", "000", "001", "000", "000", "000",
        "000", "000", "000", "001", "000", "000", "000", "000",
        "000", "000", "000", "001", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
    
        "000", "000", "001", "001", "001", "000", "000", "000", -- 8
        "000", "001", "000", "000", "000", "001", "000", "000",
        "000", "001", "000", "000", "000", "001", "000", "000",
        "000", "000", "001", "001", "001", "000", "000", "000",
        "000", "001", "000", "000", "000", "001", "000", "000",
        "000", "001", "000", "000", "000", "001", "000", "000",
        "000", "000", "001", "001", "001", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",

        "000", "000", "001", "001", "001", "001", "000", "000", -- 9
        "000", "001", "000", "000", "000", "000", "001", "000",
        "000", "001", "000", "000", "000", "000", "001", "000",
        "000", "000", "001", "001", "001", "001", "001", "000",
        "000", "000", "000", "000", "000", "000", "001", "000",
        "000", "000", "000", "000", "000", "000", "001", "000",
        "000", "000", "001", "001", "001", "001", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
 
        "000", "000", "001", "001", "001", "000", "000", "000", -- A 10
        "000", "001", "001", "000", "001", "001", "000", "000",
        "001", "001", "000", "000", "000", "001", "001", "000",
        "001", "001", "000", "000", "000", "001", "001", "000",
        "001", "001", "001", "001", "001", "001", "001", "000",
        "001", "001", "000", "000", "000", "001", "001", "000",
        "001", "001", "000", "000", "000", "001", "001", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",

        "000", "001", "001", "001", "000", "000", "000", "000", -- B 11
        "000", "001", "000", "000", "001", "000", "000", "000",
        "000", "001", "000", "000", "001", "000", "000", "000",
        "000", "001", "001", "001", "000", "000", "000", "000",
        "000", "001", "000", "000", "001", "000", "000", "000",
        "000", "001", "000", "000", "001", "000", "000", "000",
        "000", "001", "001", "001", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",

        "000", "001", "001", "001", "001", "000", "000", "000", -- C 12
        "001", "000", "000", "000", "000", "001", "000", "000",
        "001", "000", "000", "000", "000", "000", "000", "000",
        "001", "000", "000", "000", "000", "000", "000", "000",
        "001", "000", "000", "000", "000", "000", "000", "000",
        "001", "000", "000", "000", "000", "001", "000", "000",
        "000", "001", "001", "001", "001", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",

        "001", "001", "001", "001", "000", "000", "000", "000", -- D 13
        "001", "000", "000", "000", "001", "000", "000", "000",
        "001", "000", "000", "000", "001", "000", "000", "000",
        "001", "000", "000", "000", "001", "000", "000", "000",
        "001", "000", "000", "000", "001", "000", "000", "000",
        "001", "000", "000", "000", "001", "000", "000", "000",
        "001", "001", "001", "001", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",

        "011", "011", "011", "011", "011", "011", "000", "000", -- E 14
        "011", "000", "000", "000", "000", "000", "000", "000",
        "011", "000", "000", "000", "000", "000", "000", "000",
        "011", "011", "011", "011", "000", "000", "000", "000",
        "011", "000", "000", "000", "000", "000", "000", "000",
        "011", "000", "000", "000", "000", "000", "000", "000",
        "011", "011", "011", "011", "011", "011", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",

        "001", "001", "001", "001", "001", "001", "000", "000", -- F 15
        "001", "000", "000", "000", "000", "000", "000", "000",
        "001", "000", "000", "000", "000", "000", "000", "000",
        "001", "001", "001", "001", "000", "000", "000", "000",
        "001", "000", "000", "000", "000", "000", "000", "000",
        "001", "000", "000", "000", "000", "000", "000", "000",
        "001", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",

        "000", "000", "000", "000", "000", "000", "000", "000", -- EMPTY 16
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",

        "010", "010", "010", "010", "010", "010", "010", "010", -- CURSOR 17
        "010", "010", "010", "010", "010", "010", "010", "010",
        "010", "010", "010", "010", "010", "010", "010", "010",
        "010", "010", "010", "010", "010", "010", "010", "010",
        "010", "010", "010", "010", "010", "010", "010", "010",
        "010", "010", "010", "010", "010", "010", "010", "010",
        "010", "010", "010", "010", "010", "010", "010", "010",
        "010", "010", "010", "010", "010", "010", "010", "010",

        "000", "000", "000", "000", "000", "000", "000", "000", -- PLUS 18
        "000", "000", "000", "100", "000", "000", "000", "000",
        "000", "000", "000", "100", "000", "000", "000", "000",
        "000", "100", "100", "100", "100", "100", "000", "000",
        "000", "000", "000", "100", "000", "000", "000", "000",
        "000", "000", "000", "100", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",

        "000", "000", "000", "000", "000", "000", "000", "000", -- MINUS 19
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "100", "100", "100", "100", "100", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        
        "000", "000", "000", "000", "000", "000", "000", "000", -- SEPARATOR 20
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "110", "110", "110", "110", "110", "110", "110", "110",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",

        "000", "000", "000", "000", "000", "000", "000", "000", -- MUL 21
        "000", "100", "000", "000", "000", "100", "000", "000",
        "000", "000", "100", "000", "100", "000", "000", "000",
        "000", "000", "000", "100", "000", "000", "000", "000",
        "000", "000", "100", "000", "100", "000", "000", "000",
        "000", "100", "000", "000", "000", "100", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        
        "000", "000", "000", "000", "100", "000", "000", "000", -- DIV 22
        "000", "000", "000", "000", "100", "000", "000", "000",
        "000", "000", "000", "100", "000", "000", "000", "000",
        "000", "000", "000", "100", "000", "000", "000", "000",
        "000", "000", "000", "100", "000", "000", "000", "000",
        "000", "000", "100", "000", "000", "000", "000", "000",
        "000", "000", "100", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",

        "000", "000", "000", "000", "000", "000", "000", "000", -- EMPTY 23
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",

        "000", "100", "000", "000", "100", "000", "000", "000", -- MODULUS 24
        "000", "000", "000", "000", "100", "000", "000", "000",
        "000", "000", "000", "100", "000", "000", "000", "000",
        "000", "000", "000", "100", "000", "000", "000", "000",
        "000", "000", "000", "100", "000", "000", "000", "000",
        "000", "000", "100", "000", "000", "000", "000", "000",
        "000", "000", "100", "000", "000", "100", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",

        "000", "000", "000", "000", "000", "000", "000", "000", -- EMPTY 25
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",

        "000", "000", "000", "100", "000", "000", "000", "000", -- FACTORIAL 26
        "000", "000", "000", "100", "000", "000", "000", "000",
        "000", "000", "000", "100", "000", "000", "000", "000",
        "000", "000", "000", "100", "000", "000", "000", "000",
        "000", "000", "000", "100", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "100", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",

        "000", "000", "000", "001", "001", "000", "000", "000", -- OPEN_PAR 27
        "000", "000", "001", "001", "000", "000", "000", "000",
        "000", "000", "001", "001", "000", "000", "000", "000",
        "000", "000", "001", "001", "000", "000", "000", "000",
        "000", "000", "001", "001", "000", "000", "000", "000",
        "000", "000", "001", "001", "000", "000", "000", "000",
        "000", "000", "000", "001", "001", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",

        "000", "000", "000", "100", "000", "000", "000", "000", -- POWER 28
        "000", "000", "100", "000", "100", "000", "000", "000",
        "000", "100", "000", "000", "000", "100", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",

        "000", "000", "001", "001", "000", "000", "000", "000", -- CLOSE_PAR 29
        "000", "000", "000", "001", "001", "000", "000", "000",
        "000", "000", "000", "001", "001", "000", "000", "000",
        "000", "000", "000", "001", "001", "000", "000", "000",
        "000", "000", "000", "001", "001", "000", "000", "000",
        "000", "000", "000", "001", "001", "000", "000", "000",
        "000", "000", "001", "001", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",

        "000", "000", "000", "000", "000", "000", "000", "000", -- NEGATIVE 30
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "111", "111", "111", "111", "111", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",

        "000", "000", "000", "000", "000", "000", "000", "000", -- POINT 31
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000",
        "000", "000", "101", "101", "000", "000", "000", "000",
        "000", "000", "101", "101", "000", "000", "000", "000",
        "000", "000", "000", "000", "000", "000", "000", "000"
    );

    signal pallet : pallet_t := (
        0 => X"FF", -- 7/7/3 <=> 255/255/255
        1 => X"00", -- 0/0/0 <=> 0/0/0
        2 => X"AA", -- 5/2/2 <=> 182/73/170
        3 => X"B0", 
        4 => X"88",
        5 => X"99",
        6 => X"12",
        7 => X"5F"
    );
begin
    process(clk) begin
        if rising_edge(clk) then
            color_code <= tile_memory(to_integer(addr & xy_index));
        end if;
    end process;
        
    color_out <= pallet(to_integer(color_code));
    xy_index <= shift_left("000" & y_pos, 3) + x_pos;

end architecture;