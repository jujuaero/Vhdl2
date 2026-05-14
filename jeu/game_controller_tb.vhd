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
    begin
        -- Reset pulse
        res <= '1';
        wait for 20 ns;
        res <= '0';
        wait for 100 ns;

        report "=== Test 1: Display first color (LFSR output) ===";
        wait for 100 ns;

        -- Simulate button press for red button
        report "Pressing RED button";
        btn_r <= '1';
        wait for 50 ns;
        btn_r <= '0';
        wait for 200 ns;

        report "Pressing GREEN button";
        btn_g <= '1';
        wait for 50 ns;
        btn_g <= '0';
        wait for 200 ns;

        report "Pressing BLUE button";
        btn_b <= '1';
        wait for 50 ns;
        btn_b <= '0';
        wait for 200 ns;

        -- Continue for several rounds
        for i in 0 to 4 loop
            report "Round " & integer'image(i+2);
            wait for 500 ns;
            btn_r <= '1';
            wait for 50 ns;
            btn_r <= '0';
            wait for 500 ns;
        end loop;

        wait for 1 us;
        report "=== Simulation End ===";
        wait;
    end process;

end behavior;