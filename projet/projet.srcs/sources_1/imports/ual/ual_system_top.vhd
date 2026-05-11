library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Top-level system integrating custom operations with UAL and memory controller
entity ual_system_top is
    Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        
        -- External inputs
        A_IN        : in  STD_LOGIC_VECTOR(3 downto 0);
        B_IN        : in  STD_LOGIC_VECTOR(3 downto 0);
        SR_IN_L     : in  STD_LOGIC;
        SR_IN_R     : in  STD_LOGIC;
        
        -- Outputs
        S_OUT       : out STD_LOGIC_VECTOR(7 downto 0);  -- UAL output
        RES_OUT     : out STD_LOGIC_VECTOR(7 downto 0);  -- Custom ops output
        RES_VALID   : out STD_LOGIC;                     -- Custom ops result valid
        
        -- Caches
        CACHE_1_OUT : out STD_LOGIC_VECTOR(7 downto 0);
        CACHE_2_OUT : out STD_LOGIC_VECTOR(7 downto 0);
        
        -- Program counter
        PC_OUT      : out STD_LOGIC_VECTOR(6 downto 0);
        
        -- Debug: instruction and decoded signals
        INSTR_OUT   : out STD_LOGIC_VECTOR(9 downto 0);
        SEL_FCT_OUT : out STD_LOGIC_VECTOR(3 downto 0);
        SEL_ROUTE_OUT : out STD_LOGIC_VECTOR(3 downto 0);
        SEL_OUT_SIG : out STD_LOGIC_VECTOR(1 downto 0);
        
        -- Shift register outputs (for display)
        SR_OUT_L    : out STD_LOGIC;
        SR_OUT_R    : out STD_LOGIC
    );
end ual_system_top;

architecture Behavioral of ual_system_top is

    -- Internal signals from memory controller
    signal A_to_ual       : STD_LOGIC_VECTOR(3 downto 0);
    signal B_to_ual       : STD_LOGIC_VECTOR(3 downto 0);
    signal SEL_FCT_internal  : STD_LOGIC_VECTOR(3 downto 0);
    signal SEL_ROUTE_internal: STD_LOGIC_VECTOR(3 downto 0);
    signal SEL_OUT_internal  : STD_LOGIC_VECTOR(1 downto 0);
    signal S_from_ual     : STD_LOGIC_VECTOR(7 downto 0);
    signal SR_OUT_L_sig   : STD_LOGIC;
    signal SR_OUT_R_sig   : STD_LOGIC;
    signal custom_start_sig : STD_LOGIC;
    signal custom_operation_sig : STD_LOGIC_VECTOR(1 downto 0);

begin

    -- Button-driven custom ops selection (encoded in SR inputs from board top):
    -- SR_IN_L=1, SR_IN_R=0 -> RES_OUT_1 (A*B)      => "00"
    -- SR_IN_L=0, SR_IN_R=1 -> RES_OUT_2 (A+B)      => "01"
    -- SR_IN_L=1, SR_IN_R=1 -> RES_OUT_3 (XNOR/OR)  => "10"
    custom_start_sig <= SR_IN_L or SR_IN_R;
    custom_operation_sig <= "10" when (SR_IN_L = '1' and SR_IN_R = '1') else
                            "01" when (SR_IN_R = '1') else
                            "00";

    -- Instantiate memory controller (manages buffers, caches, instruction sequencing)
    mem_ctrl: entity work.memory_controller
        port map (
            clk => clk,
            reset => reset,
            A_IN => A_IN,
            B_IN => B_IN,
            SR_IN_L => SR_IN_L,
            SR_IN_R => SR_IN_R,
            S_from_ual => S_from_ual,
            SR_OUT_L => SR_OUT_L_sig,
            SR_OUT_R => SR_OUT_R_sig,
            A_to_ual => A_to_ual,
            B_to_ual => B_to_ual,
            SEL_FCT => SEL_FCT_internal,
            SEL_ROUTE => SEL_ROUTE_internal,
            SEL_OUT => SEL_OUT_internal,
            CACHE_1_OUT => CACHE_1_OUT,
            CACHE_2_OUT => CACHE_2_OUT,
            PC_OUT => PC_OUT
        );

    -- Instantiate UAL (arithmetic/logic operations)
    ual_inst: entity work.UAL
        port map (
            A => A_to_ual,
            B => B_to_ual,
            SEL_FCT => SEL_FCT_internal,
            SEL_ROUTE => SEL_ROUTE_internal,
            SEL_OUT => SEL_OUT_internal,
            SR_IN_L => SR_IN_L,
            SR_IN_R => SR_IN_R,
            S => S_from_ual,
            SR_OUT_L => SR_OUT_L_sig,
            SR_OUT_R => SR_OUT_R_sig
        );

    -- Instantiate custom operations (3 specific functions)
    custom_ops_inst: entity work.custom_operations
        port map (
            clk => clk,
            reset => reset,
            start => custom_start_sig,
            operation => custom_operation_sig,
            A => A_to_ual,
            B => B_to_ual,
            RES_OUT => RES_OUT,
            RES_VALID => RES_VALID
        );

    -- Output assignments
    S_OUT <= S_from_ual;
    SR_OUT_L <= SR_OUT_L_sig;
    SR_OUT_R <= SR_OUT_R_sig;
    
    -- Debug outputs
    INSTR_OUT <= (others => '0');  -- Could feed back instruction from memory_controller
    SEL_FCT_OUT <= SEL_FCT_internal;
    SEL_ROUTE_OUT <= SEL_ROUTE_internal;
    SEL_OUT_SIG <= SEL_OUT_internal;

end Behavioral;
