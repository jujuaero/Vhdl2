library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity game_controller is
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
end game_controller;

architecture Behavioral of game_controller is
    type state_type is (IDLE, PREPARE_ROUND, NEW_ROUND, WAIT_RESPONSE, END_GAME);
    signal state : state_type := IDLE;

    signal rnd          : std_logic_vector(3 downto 0);
    signal rnd_color    : std_logic_vector(1 downto 0) := "00";
    signal led_color_s : std_logic_vector(2 downto 0) := "000";
    signal time_out_s   : std_logic := '0';
    signal valid_hit_s  : std_logic := '0';
    signal invalid_hit_s: std_logic := '0';
    signal win_game_s   : std_logic := '0'; 
    signal ena_lfsr     : std_logic := '0';
    signal sta_timer    : std_logic := '0';
    signal start_round_s: std_logic := '0';
begin
    game_over <= '1' when state = END_GAME else '0';
    U_LFSR : entity work.lfsr_mcu
        port map(
            clk => clk,
            res => res,
            ena => ena_lfsr,
            rnd => rnd
        );

    U_TIMEOUT : entity work.timeout
        port map(
            clk      => clk,
            res      => res,
            sta      => sta_timer,
            sw_level => sw_level,
            time_out => time_out_s
        );

    U_SCORE : entity work.score_counter
        port map(
            clk       => clk,
            res       => res,
            valid_hit => valid_hit_s,
            score     => score,
            game_over => win_game_s
        );

    U_VALID : entity work.validation
        port map(
            clk       => clk,
            res       => res,
            timeout   => time_out_s,
            start_round => start_round_s,
            led_color => led_color_s,
            btn_r     => btn_r,
            btn_g     => btn_g,
            btn_b     => btn_b,
            valid_hit => valid_hit_s,
            invalid_hit => invalid_hit_s
        );

    led_color <= led_color_s;

    process(clk, res)
    begin
        if res = '1' then
            state       <= IDLE;
            ena_lfsr    <= '0';
            sta_timer   <= '0';
            start_round_s <= '0';
            led_color_s <= "000";

        elsif rising_edge(clk) then
            ena_lfsr <= '0';
            sta_timer <= '0';
            start_round_s <= '0';
            case state is
                when IDLE =>
                    ena_lfsr <= '1';
                    state    <= PREPARE_ROUND;

                when PREPARE_ROUND =>
                    rnd_color <= std_logic_vector(to_unsigned(to_integer(unsigned(rnd)) mod 3, 2));
                    state <= NEW_ROUND;

                when NEW_ROUND =>
                    sta_timer     <= '1';
                    start_round_s <= '1';

                    case rnd_color is
                        when "00"   => led_color_s <= "100";
                        when "01"   => led_color_s <= "010";
                        when "10"   => led_color_s <= "001"; 
                        when others => led_color_s <= "000";
                    end case;
                    state <= WAIT_RESPONSE;

                when WAIT_RESPONSE =>
                    if win_game_s = '1' then
                        state <= END_GAME;
                    elsif invalid_hit_s = '1' then
                        state <= END_GAME;
                    elsif valid_hit_s = '1' then
                        ena_lfsr <= '1';
                        state <= PREPARE_ROUND;
                    elsif time_out_s = '1' then
                        state <= END_GAME;
                    end if;

                when END_GAME =>
                    led_color_s <= "000";
                    state       <= END_GAME;
            end case;
        end if;
    end process;
end Behavioral;