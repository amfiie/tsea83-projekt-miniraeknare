library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity ADDR_DEC is 
    port (
        full_in_addr : in unsigned(15 downto 0);
        full_out_addr : in unsigned(15 downto 0);
        mem_addr : out unsigned(10 downto 0);
        mem_in_select : out unsigned(4 downto 0); -- To allow implementation of new memories
        mem_out_select : out unsigned(4 downto 0)
    );
end ADDR_DEC;

architecture func of ADDR_DEC is
begin
    mem_in_select <= full_in_addr(15 downto 11);
    mem_out_select <= full_out_addr(15 downto 11);
    mem_addr <= full_in_addr(10 downto 0);
end architecture;


