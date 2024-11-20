library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity DM is
    port (
        clk : in std_logic;
        we  : in std_logic;
        data_in : in unsigned(15 downto 0);
        data_out : out unsigned(15 downto 0);
        addr : in unsigned(10 downto 0)
    );
end DM;

architecture func of DM is
    type ram_t is array (0 to 2047) of unsigned(15 downto 0);
    signal dm : ram_t := (
        others => (others => '0')
    );

begin

process(clk) begin
    if rising_edge(clk) then
        if (we = '1') then
            dm(to_integer(addr)) <= data_in;
        end if;
        data_out <= dm(to_integer(addr));
    end if;
end process;
end architecture;