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

        
        sw_level<="11";
        wait for 30 ns;
        wait for 50 ns;

        while game_over = '0' loop
            wait until led_color /= "000"; -- rien
                wait for 30 ns;
                if led_color = "010" then -- Vert
                    btn_g<='1';
                    wait for 10 ns;
                    btn_g<='0';
                    wait for 20 ns;
                elsif led_color ="001" then -- Bleu
                    btn_b<='1';
                    wait for 10 ns;
                    btn_b<='0';
                    wait for 20 ns;
                elsif led_color = "100" then -- rouge
                    btn_r<='1';
                    wait for 10 ns;
                    btn_r<='0';
                    wait for 20 ns;
                end if;
        end loop;

        -- Scénario mauvaise réponse
        res <= '1';
        wait for 20 ns;
        res <= '0';
        wait for 50 ns;

        wait until led_color /= "000";
        wait for 30 ns;
        -- appuyer volontairement sur le mauvais bouton
        if led_color = "100" then      -- rouge affiché → on appuie vert
            btn_g <= '1'; wait for 10 ns; btn_g <= '0';
        elsif led_color = "010" then   -- vert affiché → on appuie bleu
            btn_b <= '1'; wait for 10 ns; btn_b <= '0';
        else                           -- bleu affiché → on appuie rouge
            btn_r <= '1'; wait for 10 ns; btn_r <= '0';
        end if;
        wait until game_over = '1';

        -- Scénario timeout
        res <= '1';
        wait for 20 ns;
        res <= '0';
        wait for 50 ns;
        sw_level <= "11";  -- niveau difficile = 0.5s

        wait until led_color /= "000";
        -- ne rien appuyer, attendre que le timeout déclenche le game_over
        wait until game_over = '1';
    wait;
    end process;

end Behavioral;