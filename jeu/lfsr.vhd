library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lfsr is
    Port (
        clk : in std_logic;
        res : in std_logic;
        ena : in std_logic;
        rnd : out std_logic_vector(3 downto 0)
    );
end lfsr;

architecture Behavioral of lfsr is
    signal reg : std_logic_vector(3 downto 0);
begin
    process(clk,res)
    begin
        if res='1' then
            reg <= "1011";
        elsif rising_edge(clk) then
            if ena='1' then
                reg <= (reg(1) xor reg(0)) & reg(3 downto 1);
            end if;
        end if;
    end process;
    rnd <= reg;
end Behavioral;