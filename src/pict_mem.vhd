library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;     

entity PICT_MEM is
    port(clk			: in std_logic;                         
          we_pipe		        : in std_logic;                     
          data_in_pipe	        : in unsigned(4 downto 0);      
          data_out_VGA	: out unsigned(4 downto 0);
          addr_pipe	        : in unsigned(8 downto 0);          
          addr_VGA      : in unsigned(8 downto 0)
    );
end entity;

architecture func of PICT_MEM is
    type pict_mem_t is array (0 to 319) of unsigned(4 downto 0);
    
    signal pict_mem : pict_mem_t := (
        others => "10000"
    );
begin
    process(clk) begin
        if rising_edge(clk) then
            if we_pipe = '1' then
                pict_mem(to_integer(addr_pipe)) <= data_in_pipe;
            end if;
            data_out_VGA <= pict_mem(to_integer(addr_VGA));
        end if;
    end process;
end architecture;