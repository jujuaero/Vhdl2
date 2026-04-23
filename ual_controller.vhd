library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ual_controller is
    Port (
        clk      : in  STD_LOGIC;
        reset    : in  STD_LOGIC;
        -- Entrées principales
        A_IN     : in  STD_LOGIC_VECTOR(3 downto 0);
        B_IN     : in  STD_LOGIC_VECTOR(3 downto 0);
        -- Sortie principale
        RES_OUT  : out STD_LOGIC_VECTOR(7 downto 0)
    );
end ual_controller;

architecture Behavioral of ual_controller is
    -- Signaux internes
    signal pc         : STD_LOGIC_VECTOR(6 downto 0) := (others => '0'); -- pointeur instruction
    signal instr      : STD_LOGIC_VECTOR(9 downto 0);
    signal sel_fct    : STD_LOGIC_VECTOR(3 downto 0);
    signal sel_route  : STD_LOGIC_VECTOR(3 downto 0);
    signal sel_out    : STD_LOGIC_VECTOR(1 downto 0);
    -- Instanciation de la mémoire d'instructions
    component mem_instructions
        Port (
            clk      : in  STD_LOGIC;
            reset    : in  STD_LOGIC;
            addr     : in  STD_LOGIC_VECTOR(6 downto 0);
            data_out : out STD_LOGIC_VECTOR(9 downto 0)
        );
    end component;
    -- Instanciation de l'UAL
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
    -- Signaux pour UAL
    signal A_sig, B_sig : STD_LOGIC_VECTOR(3 downto 0);
    signal S_sig        : STD_LOGIC_VECTOR(7 downto 0);
    signal SR_IN_L, SR_IN_R, SR_OUT_L, SR_OUT_R : STD_LOGIC;
    -- Mémoires internes (buffers, caches, etc.) à ajouter ici
begin
    -- Lecture instruction
    memi: mem_instructions port map (
        clk => clk,
        reset => reset,
        addr => pc,
        data_out => instr
    );
    -- Décodage instruction
    sel_fct   <= instr(9 downto 6);
    sel_route <= instr(5 downto 2);
    sel_out   <= instr(1 downto 0);
    -- Instanciation UAL
    ual1: UAL port map (
        A => A_sig,
        B => B_sig,
        SEL_FCT => sel_fct,
        SR_IN_L => SR_IN_L,
        SR_IN_R => SR_IN_R,
        S => S_sig,
        SR_OUT_L => SR_OUT_L,
        SR_OUT_R => SR_OUT_R
    );
    -- TODO: Ajouter la logique de gestion des buffers, caches, mémoires, routage, etc.
    -- TODO: Ajouter la logique de sélection de la sortie RES_OUT selon sel_out
    -- TODO: Incrémentation du PC à chaque front d'horloge
end Behavioral;
