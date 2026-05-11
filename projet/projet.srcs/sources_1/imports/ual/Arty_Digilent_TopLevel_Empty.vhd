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
    signal sr_out_l_sig  : std_logic;
    signal sr_out_r_sig  : std_logic;
    signal custom_sel_l_sig : std_logic;
    signal custom_sel_r_sig : std_logic;

begin

    -- ===== CÂBLAGE SELON SPEC DU TEST =====
    -- Fonctionnement à 100 MHZ (clk)
    -- A = B : les mêmes switches pilotent A et B
    a_in_sig  <= sw;     -- sw[3:0] → A_IN[3:0]
    b_in_sig  <= sw;     -- sw[3:0] → B_IN[3:0] (A = B)
    reset_sig <= btn(0); -- btn(0) : reset global

    -- Mapping boutons -> opérations custom
    -- btn1: RES_OUT_1 (A*B)        => L=1, R=0
    -- btn2: RES_OUT_2 (A+B)        => L=0, R=1
    -- btn3: RES_OUT_3 (XNOR/OR)    => L=1, R=1
    custom_sel_l_sig <= btn(1) or btn(3);
    custom_sel_r_sig <= btn(2) or btn(3);

    top_inst: entity work.ual_system_top
        port map (
            clk           => CLK100MHZ,
            reset         => reset_sig,
            A_IN          => a_in_sig,
            B_IN          => b_in_sig,
            SR_IN_L       => custom_sel_l_sig,
            SR_IN_R       => custom_sel_r_sig,
            S_OUT         => s_out_sig,
            RES_OUT       => res_out_sig,
            RES_VALID     => res_valid_sig,
            CACHE_1_OUT   => cache_1_sig,
            CACHE_2_OUT   => cache_2_sig,
            PC_OUT        => pc_sig,
            INSTR_OUT     => instr_sig,
            SEL_FCT_OUT   => sel_fct_sig,
            SEL_ROUTE_OUT => sel_route_sig,
            SEL_OUT_SIG   => sel_out_sig,
            SR_OUT_L      => sr_out_l_sig,
            SR_OUT_R      => sr_out_r_sig
        );

    -- ===== AFFICHAGE DES RÉSULTATS SUR LES 8 LEDS =====
    -- Affichage principal : RES_OUT[7:0] en rouge (multiplexé sur 4 LEDs RGB)
    -- led[3:0] = RES_OUT[3:0]  (4 LEDs simples — 4 bits bas en rouge)
    -- led0_r/g/b, led1_r/g/b, led2_r/g/b, led3_r/g/b = RES_OUT[7:4] + signaux spéciaux
    
    -- Résultats de calculs : 8 leds (couleur = rouge)
    -- Les 4 bits bas sur les LEDs simples
    led <= res_out_sig(3 downto 0);

    -- LED 0 (RGB) : bit 4 en rouge, SR_OUT_L en bleu
    led0_r <= res_out_sig(4);   -- 5ème LED = RES_OUT[4] en rouge
    led0_g <= '0';               -- Vert libre
    led0_b <= sr_out_l_sig;      -- Bleu = SR_OUT_L (5ème LED avec du bleu quand SR_OUT_L=1)

    -- LED 1 (RGB) : bit 5 en rouge, SR_OUT_R en bleu
    led1_r <= res_out_sig(5);   -- 6ème LED = RES_OUT[5] en rouge
    led1_g <= '0';               -- Vert libre
    led1_b <= sr_out_r_sig;      -- Bleu = SR_OUT_R (6ème LED avec du bleu quand SR_OUT_R=1)

    -- LED 2 (RGB) : bit 6 en rouge
    led2_r <= res_out_sig(6);   -- 7ème LED = RES_OUT[6] en rouge
    led2_g <= '0';
    led2_b <= '0';

    -- LED 3 (RGB) : bit 7 en rouge, VERT si résultat disponible
    led3_r <= res_out_sig(7);   -- 8ème LED = RES_OUT[7] en rouge
    led3_g <= res_valid_sig;     -- Vert = RES_VALID (8ème LED avec du vert quand résultat dispo)
    led3_b <= '0';
end Behavioral;