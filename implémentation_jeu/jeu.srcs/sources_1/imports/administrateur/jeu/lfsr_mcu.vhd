library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lfsr_mcu is
    Port (
        clk  : in  std_logic;
        res  : in  std_logic;
        ena  : in  std_logic;
        rnd  : out std_logic_vector(3 downto 0)
    );
end lfsr_mcu;

architecture Behavioral of lfsr_mcu is
    signal current_state : std_logic_vector(3 downto 0) := "1011";
    signal feedback_bit  : std_logic;
    signal s_out         : std_logic_vector(7 downto 0);
begin
    feedback_bit <= current_state(1) xor current_state(0);

    U_MCU : entity work.ual_system_top
        port map(
            clk           => clk,
            reset         => res,
            A_IN          => current_state,
            B_IN          => "0000",
            SR_IN_L       => feedback_bit,
            SR_IN_R       => '0',
            S_OUT         => s_out,
            RES_OUT       => open,
            RES_VALID     => open,
            CACHE_1_OUT   => open,
            CACHE_2_OUT   => open,
            PC_OUT        => open,
            INSTR_OUT     => open,
            SEL_FCT_OUT   => open,
            SEL_ROUTE_OUT => open,
            SEL_OUT_SIG   => open,
            SR_OUT_L      => open,
            SR_OUT_R      => open
        );

    process(clk, res)
    begin
        if res = '1' then
            current_state <= "1011";
        elsif rising_edge(clk) then
            if ena = '1' then
                current_state <= s_out(3 downto 0);
            end if;
        end if;
    end process;

    rnd <= current_state;

end Behavioral;
