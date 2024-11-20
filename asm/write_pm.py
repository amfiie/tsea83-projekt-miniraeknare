import subprocess

pm_first_part = """library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PM is 
    port(
        clk : in std_logic;
        addr : in unsigned(10 downto 0);
        pm_out : out unsigned(15 downto 0);
        we : in std_logic; 
        w_addr : in unsigned(10 downto 0);
        w_data : in unsigned(15 downto 0)
    );
end PM;
--PM ska innehålla programmet vid start, bootloadern ska endast ladda in nya instruktioner 
architecture func of PM is 
    type PM_t is array(0 to 2047) of unsigned(15 downto 0);
    signal pm_data : PM_t := (
"""

pm_end_part = """others => (others => '0')
    );


begin
    process(clk) begin
        if rising_edge(clk) then
            if we = '1' then 
                pm_data(to_integer(w_addr)) <= w_data;
            end if;
            pm_out <= pm_data(to_integer(addr));
        end if;
    end process;
end architecture;
"""




if __name__ == "__main__":
    result = subprocess.run(['python3', 'assembly.py', 'parse', 'main.asm', '-c', '-v'], stdout=subprocess.PIPE)
    str_result = result.stdout.decode('utf-8')
    res = "\n".join(map(lambda x : '\t\t' + x, str_result.split("\n")))
    with open("../src/pm.vhd", 'w') as file:
        file.write(pm_first_part)
        file.write(res)
        file.write(pm_end_part)