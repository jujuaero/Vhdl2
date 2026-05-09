library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UAL_Controller is
    Port (
        clk      : in  STD_LOGIC;
        reset    : in  STD_LOGIC;
        instr_in : in  STD_LOGIC_VECTOR(9 downto 0); -- [9:6]=SEL_FCT, [5:2]=SEL_ROUTE, [1:0]=SEL_OUT
        SEL_FCT  : out STD_LOGIC_VECTOR(3 downto 0);
        SEL_ROUTE: out STD_LOGIC_VECTOR(3 downto 0);
        SEL_OUT  : out STD_LOGIC_VECTOR(1 downto 0)
    );
end UAL_Controller;

architecture Behavioral of UAL_Controller is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                SEL_FCT   <= (others => '0');
                SEL_ROUTE <= (others => '0');
                SEL_OUT   <= (others => '0');
            else
                SEL_FCT   <= instr_in(9 downto 6);
                SEL_ROUTE <= instr_in(5 downto 2);
                SEL_OUT   <= instr_in(1 downto 0);
            end if;
        end if;
    end process;
end Behavioral;
