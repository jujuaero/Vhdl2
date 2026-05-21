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
            SEL_ROUTE: in  STD_LOGIC_VECTOR(3 downto 0);
            SEL_OUT  : in  STD_LOGIC_VECTOR(1 downto 0);
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
    signal SEL_ROUTE_tb: STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal SEL_OUT_tb  : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal instr_tb    : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
    signal clk_tb      : STD_LOGIC := '0';
    signal reset_tb    : STD_LOGIC := '1';
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
        SEL_ROUTE => SEL_ROUTE_tb,
        SEL_OUT => SEL_OUT_tb,
        SR_IN_L => SR_IN_L_tb,
        SR_IN_R => SR_IN_R_tb,
        S => S_tb,
        SR_OUT_L => SR_OUT_L_tb,
        SR_OUT_R => SR_OUT_R_tb
    );

    controller_inst: entity work.UAL_Controller
        port map (
            clk => clk_tb,
            reset => reset_tb,
            instr_in => instr_tb,
            SEL_FCT => SEL_FCT_tb,
            SEL_ROUTE => SEL_ROUTE_tb,
            SEL_OUT => SEL_OUT_tb
        );

    -- 4. Le processus de test (les stimulus)
    -- Clock generation
    clk_proc: process
    begin
        while True loop
            clk_tb <= '0';
            wait for 5 ns;
            clk_tb <= '1';
            wait for 5 ns;
        end loop;
        wait;
    end process clk_proc;

    -- Stimulus process (drives instruction vector, A/B and reset)
    stim_proc2: process
    begin
        -- Reset pulse
        reset_tb <= '1';
        wait for 12 ns;
        reset_tb <= '0';
        wait for 8 ns;

        -- Afin d'être sûr d'attendre le coup d'horloge pour le contrôleur
        -- chaque test assignera les entrées, puis attendra 20 ns pour lire et vérifier

        -- Test 0: NOP (0000)
        A_tb <= "0101";
        B_tb <= "0011";
        instr_tb <= "0000" & "0000" & "00";
        wait for 20 ns;
        assert (S_tb = "00000000") report "Echec Test 0: NOP" severity error;

        -- Test 1: S = A (0001)
        A_tb <= "0110"; -- 6
        B_tb <= "1001";
        instr_tb <= "0001" & "0000" & "00";
        wait for 20 ns;
        assert (S_tb = "00000110") report "Echec Test 1: S = A" severity error;

        -- Test 2: S = not A (0010)
        A_tb <= "0101"; 
        instr_tb <= "0010" & "0000" & "00";
        wait for 20 ns;
        assert (S_tb = "00001010") report "Echec Test 2: S = not A" severity error; -- not 0101 = 1010

        -- Test 3: S = B (0011)
        A_tb <= "0000";
        B_tb <= "1100"; -- -4 ou 12 (unsigned)
        instr_tb <= "0011" & "0000" & "00";
        wait for 20 ns;
        -- B est casté en signed 8 bits : 1100 sign-extended -> 11111100
        assert (S_tb = "11111100") report "Echec Test 3: S = B" severity error;

        -- Test 4: S = not B (0100)
        B_tb <= "0110"; 
        instr_tb <= "0100" & "0000" & "00";
        wait for 20 ns;
        assert (S_tb = "00001001") report "Echec Test 4: S = not B" severity error; -- not 0110 = 1001

        -- Test 5: S = A and B (0101)
        A_tb <= "1100";
        B_tb <= "1010";
        instr_tb <= "0101" & "0000" & "00";
        wait for 20 ns;
        assert (S_tb = "00001000") report "Echec Test 5: A and B" severity error;

        -- Test 6: S = A or B (0110)
        A_tb <= "1100";
        B_tb <= "1010";
        instr_tb <= "0110" & "0000" & "00";
        wait for 20 ns;
        assert (S_tb = "00001110") report "Echec Test 6: A or B" severity error;

        -- Test 7: S = A xor B (0111)
        A_tb <= "1100";
        B_tb <= "1010";
        instr_tb <= "0111" & "0000" & "00";
        wait for 20 ns;
        assert (S_tb = "00000110") report "Echec Test 7: A xor B" severity error;

        -- Test 8: S = A + B avec retenue d'entrée (1000)
        A_tb <= "0011"; -- 3
        B_tb <= "0010"; -- 2
        SR_IN_R_tb <= '1';
        instr_tb <= "1000" & "0000" & "00";
        wait for 20 ns;
        assert (S_tb = "00000110") report "Echec Test 8: A + B + 1" severity error; -- 3 + 2 + 1 = 6

        -- Test 9: S = A + B sans retenue (1001)
        A_tb <= "0010"; -- 2
        B_tb <= "0011"; -- 3
        SR_IN_R_tb <= '0';
        instr_tb <= "1001" & "0000" & "00";
        wait for 20 ns;
        assert (S_tb = "00000101") report "Echec Test 9: A + B" severity error; -- 2 + 3 = 5

        -- Test 10: S = A - B (1010)
        A_tb <= "0111"; -- 7
        B_tb <= "0010"; -- 2
        instr_tb <= "1010" & "0000" & "00";
        wait for 20 ns;
        assert (S_tb = "00000101") report "Echec Test 10: A - B" severity error; -- 7 - 2 = 5

        -- Test 11: S = A * B (1011)
        A_tb <= "0011"; -- 3
        B_tb <= "0010"; -- 2
        instr_tb <= "1011" & "0000" & "00";
        wait for 20 ns;
        assert (S_tb = "00000110") report "Echec Test 11: A * B" severity error; -- 3 * 2 = 6

        -- Test 12: Décalage droite A sur 4 bits (1100)
        A_tb <= "1010";
        SR_IN_L_tb <= '1';
        instr_tb <= "1100" & "0000" & "00";
        wait for 20 ns;
        -- S(3) <= SR_IN_L (1), S(2..0) <= A(3..1) (101) => 1101
        assert (S_tb(3 downto 0) = "1101" and SR_OUT_R_tb = '0') report "Echec Test 12: Déc Droite A" severity error;

        -- Test 13: Décalage gauche A sur 4 bits (1101)
        A_tb <= "1010";
        SR_IN_R_tb <= '1';
        instr_tb <= "1101" & "0000" & "00";
        wait for 20 ns;
        -- S(3..1) <= A(2..0) (010), S(0) <= SR_IN_R (1) => 0101
        assert (S_tb(3 downto 0) = "0101" and SR_OUT_L_tb = '1') report "Echec Test 13: Déc Gauche A" severity error;

        -- Test 14: Décalage droite B (1110)
        B_tb <= "0111";
        SR_IN_L_tb <= '0';
        instr_tb <= "1110" & "0000" & "00";
        wait for 20 ns;
        -- S(3) <= 0, S(2..0) <= B(3..1) (011) => 0011
        assert (S_tb(3 downto 0) = "0011" and SR_OUT_R_tb = '1') report "Echec Test 14: Déc Droite B" severity error;

        -- Test 15: Décalage gauche B (1111)
        B_tb <= "1101";
        SR_IN_R_tb <= '0';
        instr_tb <= "1111" & "0000" & "00";
        wait for 20 ns;
        -- S(3..1) <= B(2..0) (101), S(0) <= 0 => 1010
        assert (S_tb(3 downto 0) = "1010" and SR_OUT_L_tb = '1') report "Echec Test 15: Déc Gauche B" severity error;

        report "TESTS TERMINES AVEC SUCCES" severity note;
        wait;
    end process;

end behavior;