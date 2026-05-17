library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity lfsr_only_tb is
end lfsr_only_tb;

architecture Behavioral of lfsr_only_tb is
    signal clk : std_logic := '0';
    signal res : std_logic := '1';
    signal ena : std_logic := '0';
    signal rnd : std_logic_vector(3 downto 0);
    constant CLK_PERIOD : time := 10 ns;
begin
    UUT : entity work.lfsr
        port map(
            clk => clk,
            res => res,
            ena => ena,
            rnd => rnd
        );

    clk_process : process
    begin
        while True loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;

    stim_process : process
    begin
        report "Starting LFSR testbench";
        res <= '1';
        wait for 20 ns;
        res <= '0';
        ena <= '1';
        wait for CLK_PERIOD;

        for i in 0 to 14 loop
            report "Cycle " & integer'image(i) & ": rnd=" &
                   std_logic'image(rnd(3)) & std_logic'image(rnd(2)) &
                   std_logic'image(rnd(1)) & std_logic'image(rnd(0)) severity note;
            wait for CLK_PERIOD;
        end loop;

        ena <= '0';
        report "LFSR testbench finished";
        wait;
    end process;
end Behavioral;
