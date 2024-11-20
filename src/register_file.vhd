library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity register_file is 
    port(clk : in std_logic;
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
end entity;

architecture func of register_file is

signal R0, R1, R2,  R3,  R4,  R5,  R6,  R7, 
       R8, R9, R10, R11, R12, R13, R14, R15 : unsigned(15 downto 0);
signal data_x, data_y : unsigned(15 downto 0);

begin

process(clk) 
begin
    if rising_edge(clk) then
        if (w_d = '1') then
            case addr_w is
                when "0000" => R0  <= data_w;
                when "0001" => R1  <= data_w;
                when "0010" => R2  <= data_w;
                when "0011" => R3  <= data_w;
                when "0100" => R4  <= data_w;
                when "0101" => R5  <= data_w;
                when "0110" => R6  <= data_w;
                when "0111" => R7  <= data_w;
                when "1000" => R8  <= data_w;
                when "1001" => R9  <= data_w;
                when "1010" => R10 <= data_w;
                when "1011" => R11 <= data_w;
                when "1100" => R12 <= data_w;
                when "1101" => R13 <= data_w;
                when others => R14 <= data_w;
            end case;
        end if;

        if (k_flag = '1') then
            R15 <= X"00" & ascii_code;
        end if;
    end if;
end process;

data_x <= R0  when (addr_x = "0000") else
          R1  when (addr_x = "0001") else
          R2  when (addr_x = "0010") else
          R3  when (addr_x = "0011") else
          R4  when (addr_x = "0100") else
          R5  when (addr_x = "0101") else
          R6  when (addr_x = "0110") else
          R7  when (addr_x = "0111") else
          R8  when (addr_x = "1000") else
          R9  when (addr_x = "1001") else
          R10 when (addr_x = "1010") else
          R11 when (addr_x = "1011") else
          R12 when (addr_x = "1100") else
          R13 when (addr_x = "1101") else
          R14 when (addr_x = "1110") else
          R15;

data_y <= R0  when (addr_y = "0000") else
          R1  when (addr_y = "0001") else
          R2  when (addr_y = "0010") else
          R3  when (addr_y = "0011") else
          R4  when (addr_y = "0100") else
          R5  when (addr_y = "0101") else
          R6  when (addr_y = "0110") else
          R7  when (addr_y = "0111") else
          R8  when (addr_y = "1000") else
          R9  when (addr_y = "1001") else
          R10 when (addr_y = "1010") else
          R11 when (addr_y = "1011") else
          R12 when (addr_y = "1100") else
          R13 when (addr_y = "1101") else
          R14 when (addr_y = "1110") else
          R15;

out_x <= data_w when ((addr_x = addr_w) and (w_d = '1')) else
         data_x;

out_y <= data_w when ((addr_y = addr_w) and (w_d = '1')) else
         data_y;

end architecture;