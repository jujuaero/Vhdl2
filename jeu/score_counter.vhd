library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity score_counter is
    Port(
        clk : in std_logic;
        res : in std_logic;
        valid_hit : in std_logic;
        score : out std_logic_vector(3 downto 0);
        game_over : out std_logic
    );
end score_counter;

architecture Behavioral of score_counter is
    signal scoring : unsigned(3 downto 0) := (others => '0');
begin
    process(clk,res)
    begin
        if res='1' then
            scoring <= (others => '0');
            game_over <= '0';
        elsif rising_edge(clk) then
            if valid_hit='1' then
                if scoring = 15 then
                    scoring <= scoring + 1;
                    game_over <= '1';
                else
                    scoring <= scoring + 1;
                end if;
            elsif valid_hit='0' then
                game_over <= '1';
            end if;
        end if;
    end process;
    score <= std_logic_vector(scoring);
end Behavioral;
