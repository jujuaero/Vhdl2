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

        -- Test 1 : Addition (A + B sans retenue)
        A_tb <= "0011"; -- 3
        B_tb <= "0100"; -- 4
        instr_tb <= "1001" & "0000" & "00"; -- SEL_FCT=1001, SEL_ROUTE=0000, SEL_OUT=00
        wait for 20 ns;

        -- Test 2 : AND
        A_tb <= "1100";
        B_tb <= "1010";
        instr_tb <= "0101" & "0001" & "01"; -- SEL_FCT=0101, route=0001, out=01
        wait for 20 ns;

        -- Test 3 : Subtraction
        A_tb <= "0111"; -- 7
        B_tb <= "0010"; -- 2
        instr_tb <= "1010" & "0010" & "10"; -- SEL_FCT=1010, route=0010, out=10
        wait for 20 ns;

        wait;
    end process;

end behavior;