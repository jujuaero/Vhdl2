library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memory_system_tb is
end memory_system_tb;

architecture behavior of memory_system_tb is

    -- Components
    component memory_controller
        Port (
            clk         : in  STD_LOGIC;
            reset       : in  STD_LOGIC;
            A_IN        : in  STD_LOGIC_VECTOR(3 downto 0);
            B_IN        : in  STD_LOGIC_VECTOR(3 downto 0);
            SR_IN_L     : in  STD_LOGIC;
            SR_IN_R     : in  STD_LOGIC;
            S_from_ual  : in  STD_LOGIC_VECTOR(7 downto 0);
            SR_OUT_L    : in  STD_LOGIC;
            SR_OUT_R    : in  STD_LOGIC;
            A_to_ual    : out STD_LOGIC_VECTOR(3 downto 0);
            B_to_ual    : out STD_LOGIC_VECTOR(3 downto 0);
            SEL_FCT     : out STD_LOGIC_VECTOR(3 downto 0);
            SEL_ROUTE   : out STD_LOGIC_VECTOR(3 downto 0);
            SEL_OUT     : out STD_LOGIC_VECTOR(1 downto 0);
            CACHE_1_OUT : out STD_LOGIC_VECTOR(7 downto 0);
            CACHE_2_OUT : out STD_LOGIC_VECTOR(7 downto 0);
            PC_OUT      : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;

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

    -- Signals
    signal clk              : STD_LOGIC := '0';
    signal reset            : STD_LOGIC := '1';
    signal A_IN_tb          : STD_LOGIC_VECTOR(3 downto 0) := "0011";
    signal B_IN_tb          : STD_LOGIC_VECTOR(3 downto 0) := "0100";
    signal SR_IN_L_tb       : STD_LOGIC := '0';
    signal SR_IN_R_tb       : STD_LOGIC := '0';
    
    signal A_to_ual_sig     : STD_LOGIC_VECTOR(3 downto 0);
    signal B_to_ual_sig     : STD_LOGIC_VECTOR(3 downto 0);
    signal SEL_FCT_sig      : STD_LOGIC_VECTOR(3 downto 0);
    signal SEL_ROUTE_sig    : STD_LOGIC_VECTOR(3 downto 0);
    signal SEL_OUT_sig      : STD_LOGIC_VECTOR(1 downto 0);
    signal S_from_ual_sig   : STD_LOGIC_VECTOR(7 downto 0);
    signal SR_OUT_L_sig     : STD_LOGIC;
    signal SR_OUT_R_sig     : STD_LOGIC;
    signal CACHE_1_sig      : STD_LOGIC_VECTOR(7 downto 0);
    signal CACHE_2_sig      : STD_LOGIC_VECTOR(7 downto 0);
    signal PC_sig           : STD_LOGIC_VECTOR(6 downto 0);

begin

    -- Instantiate memory controller
    mem_ctrl: memory_controller
        port map (
            clk => clk,
            reset => reset,
            A_IN => A_IN_tb,
            B_IN => B_IN_tb,
            SR_IN_L => SR_IN_L_tb,
            SR_IN_R => SR_IN_R_tb,
            S_from_ual => S_from_ual_sig,
            SR_OUT_L => SR_OUT_L_sig,
            SR_OUT_R => SR_OUT_R_sig,
            A_to_ual => A_to_ual_sig,
            B_to_ual => B_to_ual_sig,
            SEL_FCT => SEL_FCT_sig,
            SEL_ROUTE => SEL_ROUTE_sig,
            SEL_OUT => SEL_OUT_sig,
            CACHE_1_OUT => CACHE_1_sig,
            CACHE_2_OUT => CACHE_2_sig,
            PC_OUT => PC_sig
        );

    -- Instantiate UAL
    ual_inst: UAL
        port map (
            A => A_to_ual_sig,
            B => B_to_ual_sig,
            SEL_FCT => SEL_FCT_sig,
            SEL_ROUTE => SEL_ROUTE_sig,
            SEL_OUT => SEL_OUT_sig,
            SR_IN_L => SR_IN_L_tb,
            SR_IN_R => SR_IN_R_tb,
            S => S_from_ual_sig,
            SR_OUT_L => SR_OUT_L_sig,
            SR_OUT_R => SR_OUT_R_sig
        );

    -- Clock generation
    clk_proc: process
    begin
        while True loop
            clk <= '0';
            wait for 5 ns;
            clk <= '1';
            wait for 5 ns;
        end loop;
        wait;
    end process clk_proc;

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset pulse
        reset <= '1';
        wait for 10 ns;
        reset <= '0';
        
        -- Apply some test vectors
        A_IN_tb <= "0011"; -- 3
        B_IN_tb <= "0100"; -- 4
        wait for 20 ns;
        
        A_IN_tb <= "1100";
        B_IN_tb <= "1010";
        wait for 20 ns;
        
        A_IN_tb <= "0111";
        B_IN_tb <= "0010";
        wait for 20 ns;
        
        wait;
    end process;

end behavior;
