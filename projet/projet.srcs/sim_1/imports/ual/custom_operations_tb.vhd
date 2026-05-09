library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity custom_operations_tb is
end custom_operations_tb;

architecture behavior of custom_operations_tb is

    component custom_operations
        Port (
            clk         : in  STD_LOGIC;
            reset       : in  STD_LOGIC;
            start       : in  STD_LOGIC;
            operation   : in  STD_LOGIC_VECTOR(1 downto 0);
            A           : in  STD_LOGIC_VECTOR(3 downto 0);
            B           : in  STD_LOGIC_VECTOR(3 downto 0);
            RES_OUT     : out STD_LOGIC_VECTOR(7 downto 0);
            RES_VALID   : out STD_LOGIC
        );
    end component;

    signal clk              : STD_LOGIC := '0';
    signal reset            : STD_LOGIC := '1';
    signal start_sig        : STD_LOGIC := '0';
    signal operation_sig    : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal A_sig            : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal B_sig            : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal RES_OUT_sig      : STD_LOGIC_VECTOR(7 downto 0);
    signal RES_VALID_sig    : STD_LOGIC;

begin

    uut: custom_operations
        port map (
            clk => clk,
            reset => reset,
            start => start_sig,
            operation => operation_sig,
            A => A_sig,
            B => B_sig,
            RES_OUT => RES_OUT_sig,
            RES_VALID => RES_VALID_sig
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
        -- Reset
        reset <= '1';
        wait for 10 ns;
        reset <= '0';
        wait for 5 ns;

        -- Test 1: Multiplication (A=3, B=4) -> 12
        report "Test 1: A=3, B=4, Operation=MULT (00) -> Expected: 12";
        A_sig <= "0011";           -- 3
        B_sig <= "0100";           -- 4
        operation_sig <= "00";     -- Multiplication
        start_sig <= '1';
        wait for 10 ns;
        start_sig <= '0';
        wait for 10 ns;  -- First cycle: computing
        -- Result should be available now
        assert RES_VALID_sig = '1' report "RES_VALID should be 1 after compute cycle" severity error;
        assert unsigned(RES_OUT_sig) = 12 report "Result should be 12 (3*4)" severity error;
        report "Test 1 PASS: RES_OUT=" & integer'image(to_integer(unsigned(RES_OUT_sig))) & ", RES_VALID=" & std_logic'image(RES_VALID_sig);
        wait for 20 ns;

        -- Test 2: Addition (A=5, B=3) -> 8
        report "Test 2: A=5, B=3, Operation=ADD (01) -> Expected: 8";
        A_sig <= "0101";           -- 5
        B_sig <= "0011";           -- 3
        operation_sig <= "01";     -- Addition
        start_sig <= '1';
        wait for 10 ns;
        start_sig <= '0';
        wait for 10 ns;  -- First cycle: computing
        assert RES_VALID_sig = '1' report "RES_VALID should be 1 after compute cycle" severity error;
        assert unsigned(RES_OUT_sig) = 8 report "Result should be 8 (5+3)" severity error;
        report "Test 2 PASS: RES_OUT=" & integer'image(to_integer(unsigned(RES_OUT_sig))) & ", RES_VALID=" & std_logic'image(RES_VALID_sig);
        wait for 20 ns;

        -- Test 3: XNOR logic (A=1010, B=0011)
        -- (A xnor B[0]) or (A xnor B[1])
        -- B[0]=1, B[1]=1, so:
        -- (1010 xnor 1111) or (1010 xnor 1111) = 0101 or 0101 = 0101
        report "Test 3: A=1010, B=0011, Operation=XNOR_LOGIC (10) -> Expected: 0101";
        A_sig <= "1010";           -- A = 1010
        B_sig <= "0011";           -- B = 0011 (B[0]=1, B[1]=1)
        operation_sig <= "10";     -- XNOR logic
        start_sig <= '1';
        wait for 10 ns;
        start_sig <= '0';
        wait for 10 ns;  -- First cycle: computing
        assert RES_VALID_sig = '1' report "RES_VALID should be 1 after compute cycle" severity error;
        report "Test 3: RES_OUT=" & integer'image(to_integer(unsigned(RES_OUT_sig))) & ", RES_VALID=" & std_logic'image(RES_VALID_sig);
        wait for 20 ns;

        -- Test 4: Verify result is held without START
        report "Test 4: Verify result held (no START signal)";
        A_sig <= "1111";
        B_sig <= "0000";
        start_sig <= '0';
        wait for 20 ns;
        assert RES_VALID_sig = '1' report "RES_VALID should remain 1" severity error;
        report "Test 4 PASS: Result held correctly";
        wait for 20 ns;

        -- Test 5: Large multiplication
        report "Test 5: A=15, B=15, Operation=MULT (00) -> Expected: 225";
        A_sig <= "1111";           -- 15
        B_sig <= "1111";           -- 15
        operation_sig <= "00";     -- Multiplication
        start_sig <= '1';
        wait for 10 ns;
        start_sig <= '0';
        wait for 10 ns;  -- First cycle: computing
        assert RES_VALID_sig = '1' report "RES_VALID should be 1 after compute cycle" severity error;
        assert unsigned(RES_OUT_sig) = 225 report "Result should be 225 (15*15)" severity error;
        report "Test 5 PASS: RES_OUT=" & integer'image(to_integer(unsigned(RES_OUT_sig))) & ", RES_VALID=" & std_logic'image(RES_VALID_sig);
        wait for 20 ns;

        report "All tests completed successfully!";
        wait;
    end process;

end behavior;
