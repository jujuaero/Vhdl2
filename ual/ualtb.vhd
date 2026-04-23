library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UAL_tb is
-- Un testbench n'a jamais de ports d'entrée ou de sortie
end UAL_tb;

architecture behavior of UAL_tb is

    -- 1. Déclaration du composant à tester (ton UAL)
    component UAL
        Port (
            A        : in  STD_LOGIC_VECTOR(3 downto 0);
            B        : in  STD_LOGIC_VECTOR(3 downto 0);
            SEL_FCT  : in  STD_LOGIC_VECTOR(3 downto 0);
            SR_IN_L  : in  STD_LOGIC;
            SR_IN_R  : in  STD_LOGIC;
            S        : out STD_LOGIC_VECTOR(7 downto 0);
            SR_OUT_L : out STD_LOGIC;
            SR_OUT_R : out STD_LOGIC
        );
    end component;

    -- 2. Création des signaux internes pour câbler le composant
    signal A_tb        : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal B_tb        : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal SEL_FCT_tb  : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal SR_IN_L_tb  : STD_LOGIC := '0';
    signal SR_IN_R_tb  : STD_LOGIC := '0';
    signal S_tb        : STD_LOGIC_VECTOR(7 downto 0);
    signal SR_OUT_L_tb : STD_LOGIC;
    signal SR_OUT_R_tb : STD_LOGIC;

begin

    -- 3. Instanciation de l'UAL (on relie les signaux du testbench aux ports de l'UAL)
    uut: UAL PORT MAP (
        A => A_tb,
        B => B_tb,
        SEL_FCT => SEL_FCT_tb,
        SR_IN_L => SR_IN_L_tb,
        SR_IN_R => SR_IN_R_tb,
        S => S_tb,
        SR_OUT_L => SR_OUT_L_tb,
        SR_OUT_R => SR_OUT_R_tb
    );

    -- 4. Le processus de test (les stimulus)
    stim_proc: process
    begin
        -- Test 1 : Addition (A + B sans retenue)
        A_tb <= "0011"; -- Valeur 3
        B_tb <= "0100"; -- Valeur 4
        SEL_FCT_tb <= "1001"; -- Code de l'addition sans retenue
        wait for 10 ns;

        -- Test 2 : Opération logique AND (A AND B)
        A_tb <= "1100";
        B_tb <= "1010";
        SEL_FCT_tb <= "0101"; -- Code du AND
        wait for 10 ns;

        -- Test 3 : Soustraction (A - B)
        A_tb <= "0111"; -- Valeur 7
        B_tb <= "0010"; -- Valeur 2
        SEL_FCT_tb <= "1010"; -- Code de la soustraction
        wait for 10 ns;

        -- Arrêt de la simulation
        wait;
    end process;

end behavior;