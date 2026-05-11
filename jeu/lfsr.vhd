library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lfsr is
    Port (
        clk : in std_logic;
        res : in std_logic;
        ena : in std_logic;
        rnd : out std_logic_vector(3 downto 0)
    );
end lfsr;

entity timeout is
    Port(
        clk : in std_logic;
        res : in std_logic;
        sta : in std_logic;
        sw_level : in std_logic_vector(1 downto 0);
        time_out : out std_logic
    );
end timeout;

entity score_counter is
    Port(
        clk : in std_logic;
        res : in std_logic;
        valid_hit : in std_logic;
        score : out std_logic_vector(3 downto 0);
        game_over : out std_logic
    );
end score_counter;

entity validation is 
    Port(
        clk : in std_logic;
        res : in std_logic;
        timeout : in std_logic;
        led_color : in  std_logic_vector(2 downto 0);
        btn_r : in std_logic;
        btn_g : in std_logic;
        btn_b : in std_logic;
        valid_hit : out std_logic
    );
end validation;

entity game_controller is
    Port(
        clk      : in  std_logic;
        res      : in  std_logic;
        sw_level : in  std_logic_vector(1 downto 0);
        btn_r    : in  std_logic;
        btn_g    : in  std_logic;
        btn_b    : in  std_logic;
        led_color: out std_logic_vector(2 downto 0);
        score    : out std_logic_vector(3 downto 0)
    );
end game_controller;

architecture Behavioral of LFSR is
    signal reg : std_logic_vector(3 downto 0);
begin
    process(clk,res)
    begin
        if res='1' then 
            reg<="1011";
        
        elsif rising_edge(clk) then
            if ena='1' then
                reg<=(reg(3) xor reg(2) )& reg(3 downto 1);
            end if;
        end if;
    end process;
    rnd<=reg;
end Behavioral;

architecture Behavioral of timeout is
    signal running  : std_logic := '0';
    signal compteur : unsigned(29 downto 0) := (others => '0');
    begin 
        process(clk,res)
        begin
            if res='1' then 
                time_out<='0';
                compteur <= (others => '0');
            elsif rising_edge(clk) then
                if sta='1' then 
                    running<='1';
                    compteur <= (others => '0');
                    time_out <= '0';
                elsif running='1' then
                    compteur<=compteur+1;
                    case sw_level is 
                        when "00" =>
                            if compteur=to_unsigned(500_000_000,30) then
                                time_out<='1';
                                compteur <= (others => '0');
                            end if;
                        when "01" =>
                            if compteur=to_unsigned(200_000_000,30) then
                                time_out<='1';
                                compteur <= (others => '0');
                            end if;
                        when "10" =>
                            if compteur=to_unsigned(100_000_000,30) then
                                time_out<='1';
                                compteur <= (others => '0');
                            end if;
                        when "11" =>
                            if compteur=to_unsigned(50_000_000,30) then
                                time_out<='1';
                                compteur <= (others => '0');
                            end if;
                end case;  
            end if;
        end if;          
    end process;
end Behavioral;

architecture Behavioral of score_counter is 
    signal scoring : unsigned(3 downto 0) := (others => '0');
    begin
        process(clk,res)
        begin
            if res='1' then 
                scoring <= (others => '0');
                game_over<='0';
            elsif rising_edge(clk) then 
                if valid_hit='1' then
                    if scoring = 14 then
                        scoring<=scoring+1;
                        game_over<='1';
                    else 
                        scoring<=scoring+1;
                    end if;
                elsif valid_hit='0' then
                    game_over<='1';
            end if;
        end if;
    end process;
    score<=std_logic_vector(scoring);
end Behavioral;

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
                            hit <= '1'; user_pressed <= '1';
                        elsif btn_g = '1' or btn_b = '1' then
                            hit <= '0'; user_pressed <= '1';
                        end if;
                    when "010" =>
                        if btn_g = '1' then
                            hit <= '1'; user_pressed <= '1';
                        elsif btn_r = '1' or btn_b = '1' then
                            hit <= '0'; user_pressed <= '1';
                        end if;
                    when "001" =>
                        if btn_b = '1' then
                            hit <= '1'; user_pressed <= '1';
                        elsif btn_r = '1' or btn_g = '1' then
                            hit <= '0'; user_pressed <= '1';
                        end if;
                    when others => null;
                end case;
            end if;
        end if;
    end process;
    valid_hit <= hit;
end Behavioral;

architecture Behavioral of game_controller is

    type state_type is (IDLE, NEW_ROUND, WAIT_RESPONSE, END_GAME);
    signal state : state_type := IDLE;

    signal rnd         : std_logic_vector(3 downto 0);
    signal led_color_s : std_logic_vector(2 downto 0) := "000";
    signal time_out_s  : std_logic := '0';
    signal valid_hit_s : std_logic := '0';
    signal game_over_s : std_logic := '0';
    signal ena_lfsr    : std_logic := '0';
    signal sta_timer   : std_logic := '0';

begin

    U_LFSR : entity work.lfsr
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
            game_over => game_over_s
        );

    U_VALID : entity work.validation
        port map(
            clk       => clk,
            res       => res,
            timeout   => time_out_s,
            led_color => led_color_s,
            btn_r     => btn_r,
            btn_g     => btn_g,
            btn_b     => btn_b,
            valid_hit => valid_hit_s
        );

    led_color <= led_color_s;

    -- FSM
    process(clk, res)
    begin
        if res = '1' then
            state       <= IDLE;
            ena_lfsr    <= '0';
            sta_timer   <= '0';
            led_color_s <= "000";

        elsif rising_edge(clk) then
            ena_lfsr  <= '0';
            sta_timer <= '0';
            case state is

                when IDLE =>
                    led_color_s <= "000";
                    state       <= NEW_ROUND;

                when NEW_ROUND =>
                    
                    ena_lfsr  <= '1';
                    
                    sta_timer <= '1';

                    case rnd(1 downto 0) is
                        when "00"   => led_color_s <= "100";
                        when "01"   => led_color_s <= "010";
                        when others => led_color_s <= "001";
                    end case;
                    state <= WAIT_RESPONSE;

                when WAIT_RESPONSE =>
                    if game_over_s = '1' then
                        state <= END_GAME;
                    elsif valid_hit_s = '1' then
                        state <= NEW_ROUND;
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