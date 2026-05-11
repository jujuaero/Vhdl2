library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Arty_Digilent_TopLevel is
    Port (
        CLK100MHZ : in STD_LOGIC;
        sw        : in STD_LOGIC_VECTOR(3 downto 0);
        btn       : in STD_LOGIC_VECTOR(3 downto 0);
        led       : out STD_LOGIC_VECTOR(3 downto 0);
        led0_r : out STD_LOGIC; led0_g : out STD_LOGIC; led0_b : out STD_LOGIC;                
        led1_r : out STD_LOGIC; led1_g : out STD_LOGIC; led1_b : out STD_LOGIC;
        led2_r : out STD_LOGIC; led2_g : out STD_LOGIC; led2_b : out STD_LOGIC;                
        led3_r : out STD_LOGIC; led3_g : out STD_LOGIC; led3_b : out STD_LOGIC
    );
end Arty_Digilent_TopLevel;

architecture Behavioral of Arty_Digilent_TopLevel is

    signal a_in_sig      : std_logic_vector(3 downto 0);
    signal b_in_sig      : std_logic_vector(3 downto 0);
    signal reset_sig     : std_logic;
    signal s_out_sig     : std_logic_vector(7 downto 0);
    signal res_out_sig   : std_logic_vector(7 downto 0);
    signal res_valid_sig : std_logic;
    signal cache_1_sig   : std_logic_vector(7 downto 0);
    signal cache_2_sig   : std_logic_vector(7 downto 0);
    signal pc_sig        : std_logic_vector(6 downto 0);
    signal instr_sig     : std_logic_vector(9 downto 0);
    signal sel_fct_sig   : std_logic_vector(3 downto 0);
    signal sel_route_sig : std_logic_vector(3 downto 0);
    signal sel_out_sig   : std_logic_vector(1 downto 0);

begin

    -- Mapping simple pour permettre une génération de bitstream rapide.
    -- sw pilote A, btn pilote B et btn(0) sert de reset.
    a_in_sig  <= sw;
    b_in_sig  <= btn;
    reset_sig <= btn(0);

    top_inst: entity work.ual_system_top
        port map (
            clk           => CLK100MHZ,
            reset         => reset_sig,
            A_IN          => a_in_sig,
            B_IN          => b_in_sig,
            SR_IN_L       => '0',
            SR_IN_R       => '0',
            S_OUT         => s_out_sig,
            RES_OUT       => res_out_sig,
            RES_VALID     => res_valid_sig,
            CACHE_1_OUT   => cache_1_sig,
            CACHE_2_OUT   => cache_2_sig,
            PC_OUT        => pc_sig,
            INSTR_OUT     => instr_sig,
            SEL_FCT_OUT   => sel_fct_sig,
            SEL_ROUTE_OUT => sel_route_sig,
            SEL_OUT_SIG   => sel_out_sig
        );

    led <= s_out_sig(3 downto 0);

    led0_r <= res_valid_sig;
    led0_g <= s_out_sig(0);
    led0_b <= s_out_sig(1);
    led1_r <= cache_1_sig(0);
    led1_g <= cache_1_sig(1);
    led1_b <= cache_1_sig(2);
    led2_r <= cache_2_sig(0);
    led2_g <= cache_2_sig(1);
    led2_b <= cache_2_sig(2);
    led3_r <= pc_sig(0);
    led3_g <= pc_sig(1);
    led3_b <= pc_sig(2);
    
end Behavioral;
