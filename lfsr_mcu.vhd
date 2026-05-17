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
    signal cache_out : std_logic_vector(7 downto 0);
begin

    U_MCU : entity work.ual_system_top
        port map(
            clk           => clk,
            reset         => res,
            A_IN          => "1011",
            B_IN          => "0000",
            SR_IN_L       => '0',
            SR_IN_R       => '0',
            S_OUT         => open,
            RES_OUT       => open,
            RES_VALID     => open,
            CACHE_1_OUT   => cache_out,
            CACHE_2_OUT   => open,
            PC_OUT        => open,
            INSTR_OUT     => open,
            SEL_FCT_OUT   => open,
            SEL_ROUTE_OUT => open,
            SEL_OUT_SIG   => open,
            SR_OUT_L      => open,
            SR_OUT_R      => open
        );

    -- Sortie du vecteur pseudo-aleatoire
    rnd <= cache_out(3 downto 0);

end Behavioral;