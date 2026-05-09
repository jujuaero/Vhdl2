library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ual_system_top_tb is
end ual_system_top_tb;

architecture behavior of ual_system_top_tb is

    component ual_system_top
        Port (
            clk         : in  STD_LOGIC;
            reset       : in  STD_LOGIC;
            A_IN        : in  STD_LOGIC_VECTOR(3 downto 0);
            B_IN        : in  STD_LOGIC_VECTOR(3 downto 0);
            SR_IN_L     : in  STD_LOGIC;
            SR_IN_R     : in  STD_LOGIC;
            S_OUT       : out STD_LOGIC_VECTOR(7 downto 0);
            RES_OUT     : out STD_LOGIC_VECTOR(7 downto 0);
            RES_VALID   : out STD_LOGIC;
            CACHE_1_OUT : out STD_LOGIC_VECTOR(7 downto 0);
            CACHE_2_OUT : out STD_LOGIC_VECTOR(7 downto 0);
            PC_OUT      : out STD_LOGIC_VECTOR(6 downto 0);
            INSTR_OUT   : out STD_LOGIC_VECTOR(9 downto 0);
            SEL_FCT_OUT : out STD_LOGIC_VECTOR(3 downto 0);
            SEL_ROUTE_OUT : out STD_LOGIC_VECTOR(3 downto 0);
            SEL_OUT_SIG : out STD_LOGIC_VECTOR(1 downto 0)
        );
    end component;

    signal clk              : STD_LOGIC := '0';
    signal reset            : STD_LOGIC := '1';
    signal A_IN_tb          : STD_LOGIC_VECTOR(3 downto 0) := "0011";
    signal B_IN_tb          : STD_LOGIC_VECTOR(3 downto 0) := "0100";
    signal SR_IN_L_tb       : STD_LOGIC := '0';
    signal SR_IN_R_tb       : STD_LOGIC := '0';
    
    signal S_OUT_sig        : STD_LOGIC_VECTOR(7 downto 0);
    signal RES_OUT_sig      : STD_LOGIC_VECTOR(7 downto 0);
    signal RES_VALID_sig    : STD_LOGIC;
    signal CACHE_1_sig      : STD_LOGIC_VECTOR(7 downto 0);
    signal CACHE_2_sig      : STD_LOGIC_VECTOR(7 downto 0);
    signal PC_sig           : STD_LOGIC_VECTOR(6 downto 0);
    signal INSTR_sig        : STD_LOGIC_VECTOR(9 downto 0);
    signal SEL_FCT_sig      : STD_LOGIC_VECTOR(3 downto 0);
    signal SEL_ROUTE_sig    : STD_LOGIC_VECTOR(3 downto 0);
    signal SEL_OUT_sig      : STD_LOGIC_VECTOR(1 downto 0);

begin

    uut: ual_system_top
        port map (
            clk => clk,
            reset => reset,
            A_IN => A_IN_tb,
            B_IN => B_IN_tb,
            SR_IN_L => SR_IN_L_tb,
            SR_IN_R => SR_IN_R_tb,
            S_OUT => S_OUT_sig,
            RES_OUT => RES_OUT_sig,
            RES_VALID => RES_VALID_sig,
            CACHE_1_OUT => CACHE_1_sig,
            CACHE_2_OUT => CACHE_2_sig,
            PC_OUT => PC_sig,
            INSTR_OUT => INSTR_sig,
            SEL_FCT_OUT => SEL_FCT_sig,
            SEL_ROUTE_OUT => SEL_ROUTE_sig,
            SEL_OUT_SIG => SEL_OUT_sig
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
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset pulse
        reset <= '1';
        wait for 10 ns;
        reset <= '0';
        
        -- Let the system run through some instruction cycles
        report "System started, observing PC and outputs...";
        
        -- Change inputs to test with different values
        A_IN_tb <= "0011";  -- 3
        B_IN_tb <= "0100";  -- 4
        wait for 50 ns;
        
        report "After 50ns: PC=" & integer'image(to_integer(unsigned(PC_sig))) &
                " S_OUT=" & integer'image(to_integer(unsigned(S_OUT_sig))) &
                " RES_OUT=" & integer'image(to_integer(unsigned(RES_OUT_sig))) &
                " RES_VALID=" & std_logic'image(RES_VALID_sig);
        
        A_IN_tb <= "0101";  -- 5
        B_IN_tb <= "0011";  -- 3
        wait for 50 ns;
        
        report "After 100ns: PC=" & integer'image(to_integer(unsigned(PC_sig))) &
                " S_OUT=" & integer'image(to_integer(unsigned(S_OUT_sig))) &
                " RES_OUT=" & integer'image(to_integer(unsigned(RES_OUT_sig))) &
                " RES_VALID=" & std_logic'image(RES_VALID_sig);
        
        A_IN_tb <= "1010";
        B_IN_tb <= "0011";
        wait for 50 ns;
        
        report "After 150ns: PC=" & integer'image(to_integer(unsigned(PC_sig))) &
                " SEL_FCT=" & integer'image(to_integer(unsigned(SEL_FCT_sig))) &
                " RES_OUT=" & integer'image(to_integer(unsigned(RES_OUT_sig))) &
                " RES_VALID=" & std_logic'image(RES_VALID_sig);
        
        wait for 50 ns;
        
        report "System test completed successfully!";
        wait;
    end process;

end behavior;
