library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_logigame is
    Port(
        CLK100MHZ : in  std_logic;
        btn       : in  std_logic_vector(3 downto 0);
        sw        : in  std_logic_vector(3 downto 2);
        led       : out std_logic_vector(3 downto 0);
        led3_r    : out std_logic;
        led3_g    : out std_logic;
        led3_b    : out std_logic
    );
end top_logigame;

architecture Behavioral of top_logigame is
    signal led_color_s : std_logic_vector(2 downto 0);
    signal btn_r_db_s  : std_logic := '0';
    signal btn_g_db_s  : std_logic := '0';
    signal btn_b_db_s  : std_logic := '0';
begin
    U_DB_R : entity work.debounce
        port map(
            clk  => CLK100MHZ,
            res  => btn(0),
            din  => btn(1),
            dout => btn_r_db_s
        );

    U_DB_G : entity work.debounce
        port map(
            clk  => CLK100MHZ,
            res  => btn(0),
            din  => btn(2),
            dout => btn_g_db_s
        );

    U_DB_B : entity work.debounce
        port map(
            clk  => CLK100MHZ,
            res  => btn(0),
            din  => btn(3),
            dout => btn_b_db_s
        );

    U_GAME : entity work.game_controller
        port map(
            clk       => CLK100MHZ,
            res       => btn(0),
            sw_level  => sw(3 downto 2),
            btn_r     => btn_r_db_s,
            btn_g     => btn_g_db_s,
            btn_b     => btn_b_db_s,
            led_color => led_color_s,
            score     => led,
            game_over => open
        );

    led3_r <= led_color_s(2);
    led3_g <= led_color_s(1);
    led3_b <= led_color_s(0);

end Behavioral;