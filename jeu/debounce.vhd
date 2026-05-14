library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debounce is
    generic(
        DEBOUNCE_TICKS : natural := 2000000
    );
    Port(
        clk  : in std_logic;
        res  : in std_logic;
        din  : in std_logic;
        dout : out std_logic
    );
end debounce;

architecture Behavioral of debounce is
    signal din_sync_0 : std_logic := '0';
    signal din_sync_1 : std_logic := '0';
    signal stable_s   : std_logic := '0';
    signal count_s    : natural range 0 to DEBOUNCE_TICKS := 0;
begin
    process(clk, res)
    begin
        if res = '1' then
            din_sync_0 <= '0';
            din_sync_1 <= '0';
            stable_s   <= '0';
            count_s    <= 0;
        elsif rising_edge(clk) then
            din_sync_0 <= din;
            din_sync_1 <= din_sync_0;

            if din_sync_1 = stable_s then
                count_s <= 0;
            elsif count_s = DEBOUNCE_TICKS then
                stable_s <= din_sync_1;
                count_s  <= 0;
            else
                count_s <= count_s + 1;
            end if;
        end if;
    end process;

    dout <= stable_s;
end Behavioral;