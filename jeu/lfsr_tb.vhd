library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_game_controller is
end tb_game_controller;

architecture Behavioral of tb_game_controller is

    signal clk      : std_logic := '0';
    signal res      : std_logic := '0';
    signal sw_level : std_logic_vector(1 downto 0) := "01";
    signal btn_r    : std_logic := '0';
    signal btn_g    : std_logic := '0';
    signal btn_b    : std_logic := '0';
    signal led_color: std_logic_vector(2 downto 0);
    signal score    : std_logic_vector(3 downto 0);
    signal game_over : std_logic;

begin

    UUT : entity work.game_controller
        port map(
            clk       => clk,
            res       => res,
            sw_level  => sw_level,
            btn_r     => btn_r,
            btn_g     => btn_g,
            btn_b     => btn_b,
            led_color => led_color,
            score     => score,
            game_over => game_over
        );

    clk <= not clk after 5 ns;

    process
    begin
        res <= '1';
        wait for 20 ns;
        res <= '0';
        wait for 20 ns;

        wait for 30 ns;
        btn_g<='1';
        wait for 10ns;
        btn_g<='0';
        wait for 20 ns;

        wait for 30 ns;
        btn_r<='1';
        wait for 10 ns;
        btn_r<='0';
        wait until game_over='1';

        sw_level<="11";
        wait for 30 ns;
        wait for 500 ms;

        for i in 0 to 14 loop
    wait for 30 ns;
    btn_g <= '1';
    wait for 10 ns;
    btn_g <= '0';
    wait for 20 ns;
    end loop;

        wait;
    end process;

end Behavioral;