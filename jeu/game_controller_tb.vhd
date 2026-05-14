library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity game_controller_tb is
end game_controller_tb;

architecture behavior of game_controller_tb is

    component game_controller
        Port(
            clk      : in std_logic;
            res      : in std_logic;
            sw_level : in std_logic_vector(1 downto 0);
            btn_r    : in std_logic;
            btn_g    : in std_logic;
            btn_b    : in std_logic;
            led_color: out std_logic_vector(2 downto 0);
            score    : out std_logic_vector(3 downto 0);
            game_over : out std_logic
        );
    end component;

    signal clk      : std_logic := '0';
    signal res      : std_logic := '1';
    signal sw_level : std_logic_vector(1 downto 0) := "00";
    signal btn_r    : std_logic := '0';
    signal btn_g    : std_logic := '0';
    signal btn_b    : std_logic := '0';
    signal led_color: std_logic_vector(2 downto 0);
    signal score    : std_logic_vector(3 downto 0);
    signal game_over : std_logic;

    constant CLK_PERIOD : time := 10 ns;

    procedure press_color(
        signal btn_r_s : out std_logic;
        signal btn_g_s : out std_logic;
        signal btn_b_s : out std_logic;
        color : std_logic_vector(2 downto 0)
    ) is
    begin
        btn_r_s <= '0';
        btn_g_s <= '0';
        btn_b_s <= '0';

        case color is
            when "100" => btn_r_s <= '1';
            when "010" => btn_g_s <= '1';
            when "001" => btn_b_s <= '1';
            when others => null;
        end case;
    end procedure;

    procedure press_wrong_color(
        signal btn_r_s : out std_logic;
        signal btn_g_s : out std_logic;
        signal btn_b_s : out std_logic;
        color : std_logic_vector(2 downto 0)
    ) is
    begin
        btn_r_s <= '0';
        btn_g_s <= '0';
        btn_b_s <= '0';

        case color is
            when "100" => btn_g_s <= '1';
            when "010" => btn_b_s <= '1';
            when "001" => btn_r_s <= '1';
            when others => btn_r_s <= '1';
        end case;
    end procedure;

begin

    uut: game_controller
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

    -- Clock generation
    clk_process: process
    begin
        while True loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;

    -- Stimulus process
    stim_process: process
        variable expected_score : unsigned(3 downto 0) := (others => '0');
        variable color_sample : std_logic_vector(2 downto 0);
    begin
        -- Reset pulse
        res <= '1';
        wait for 20 ns;
        res <= '0';
        wait for 100 ns;

        sw_level <= "11";
        report "=== Test: Correct hits for several rounds ===";
        wait for 10 * CLK_PERIOD;

        for i in 0 to 4 loop
            color_sample := led_color;
            press_color(btn_r, btn_g, btn_b, color_sample);
            wait for 2 * CLK_PERIOD;
            btn_r <= '0';
            btn_g <= '0';
            btn_b <= '0';
            wait for 2 * CLK_PERIOD;

            expected_score := expected_score + 1;
            assert unsigned(score) = expected_score
                report "Score mismatch after round " & integer'image(i + 1)
                severity error;
            assert game_over = '0'
                report "Unexpected game_over during correct rounds"
                severity error;

            wait for 6 * CLK_PERIOD;
        end loop;

        report "=== Test: Wrong hit triggers game_over ===";
        color_sample := led_color;
        press_wrong_color(btn_r, btn_g, btn_b, color_sample);
        wait for 2 * CLK_PERIOD;
        btn_r <= '0';
        btn_g <= '0';
        btn_b <= '0';
        wait for 4 * CLK_PERIOD;

        assert game_over = '1'
            report "game_over not asserted after wrong hit"
            severity error;

        wait for 200 ns;
        report "=== Simulation End ===";
        wait;
    end process;

end behavior;