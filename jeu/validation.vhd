library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity validation is
    Port(
        clk : in std_logic;
        res : in std_logic;
        timeout : in std_logic;
        start_round : in std_logic;
        led_color : in std_logic_vector(2 downto 0);
        btn_r : in std_logic;
        btn_g : in std_logic;
        btn_b : in std_logic;
        valid_hit : out std_logic;
        invalid_hit : out std_logic
    );
end validation;

architecture Behavioral of validation is
    signal valid_hit_s   : std_logic := '0';
    signal invalid_hit_s : std_logic := '0';
    signal round_done_s  : std_logic := '0';
    signal armed_s       : std_logic := '0';
begin
    process(clk, res)
    begin
        if res = '1' then
            valid_hit_s   <= '0';
            invalid_hit_s <= '0';
            round_done_s  <= '0';
            armed_s       <= '0';
        elsif rising_edge(clk) then
            valid_hit_s   <= '0';
            invalid_hit_s <= '0';

            if timeout = '1' then
                round_done_s <= '1';
                armed_s      <= '0';
            elsif start_round = '1' then
                round_done_s <= '0';
                if btn_r = '0' and btn_g = '0' and btn_b = '0' then
                    armed_s <= '1';
                else
                    armed_s <= '0';
                end if;
            elsif round_done_s = '0' then
                if armed_s = '0' then
                    if btn_r = '0' and btn_g = '0' and btn_b = '0' then
                        armed_s <= '1';
                    end if;
                elsif btn_r = '1' or btn_g = '1' or btn_b = '1' then
                    round_done_s <= '1';

                    case led_color is
                        when "100" =>
                            if btn_r = '1' and btn_g = '0' and btn_b = '0' then
                                valid_hit_s <= '1';
                            else
                                invalid_hit_s <= '1';
                            end if;
                        when "010" =>
                            if btn_g = '1' and btn_r = '0' and btn_b = '0' then
                                valid_hit_s <= '1';
                            else
                                invalid_hit_s <= '1';
                            end if;
                        when "001" =>
                            if btn_b = '1' and btn_r = '0' and btn_g = '0' then
                                valid_hit_s <= '1';
                            else
                                invalid_hit_s <= '1';
                            end if;
                        when others =>
                            invalid_hit_s <= '1';
                    end case;
                end if;
            end if;
        end if;
    end process;

    valid_hit <= valid_hit_s;
    invalid_hit <= invalid_hit_s;
end Behavioral;