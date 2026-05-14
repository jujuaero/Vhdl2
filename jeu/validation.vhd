library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity validation is
    Port(
        clk : in std_logic;
        res : in std_logic;
        timeout : in std_logic;
        led_color : in std_logic_vector(2 downto 0);
        btn_r : in std_logic;
        btn_g : in std_logic;
        btn_b : in std_logic;
        valid_hit : out std_logic
    );
end validation;

architecture Behavioral of validation is
    signal hit          : std_logic := '0';
    signal user_pressed : std_logic := '0';
begin
    process(clk, res)
    begin
        if res = '1' then
            hit          <= '0';
            user_pressed <= '0';
        elsif rising_edge(clk) then
            if timeout = '1' then
                hit          <= '0';
                user_pressed <= '0';
            elsif user_pressed = '0' then
                case led_color is
                    when "100" =>
                        if btn_r = '1' then
                            hit <= '1';
                            user_pressed <= '1';
                        elsif btn_g = '1' or btn_b = '1' then
                            hit <= '0';
                            user_pressed <= '1';
                        end if;
                    when "010" =>
                        if btn_g = '1' then
                            hit <= '1';
                            user_pressed <= '1';
                        elsif btn_r = '1' or btn_b = '1' then
                            hit <= '0';
                            user_pressed <= '1';
                        end if;
                    when "001" =>
                        if btn_b = '1' then
                            hit <= '1';
                            user_pressed <= '1';
                        elsif btn_r = '1' or btn_g = '1' then
                            hit <= '0';
                            user_pressed <= '1';
                        end if;
                    when others => null;
                end case;
            end if;
        end if;
    end process;
    valid_hit <= hit;
end Behavioral;
