library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Custom operations unit implementing 3 specific functions:
-- RES_OUT_1 = A * B (8-bit result)
-- RES_OUT_2 = A + B
-- RES_OUT_3 = (A xnor B[0]) or (A xnor B[1])
--
-- A result is computed and then held on RES_OUT until next START signal
-- RES_VALID indicates when result is ready (0=computing, 1=result available)

entity custom_operations is
    Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        start       : in  STD_LOGIC;              -- Start computation
        operation   : in  STD_LOGIC_VECTOR(1 downto 0);  -- Select operation (00=mult, 01=add, 10=xnor_logic)
        A           : in  STD_LOGIC_VECTOR(3 downto 0);
        B           : in  STD_LOGIC_VECTOR(3 downto 0);
        RES_OUT     : out STD_LOGIC_VECTOR(7 downto 0);  -- Result (0 while computing)
        RES_VALID   : out STD_LOGIC                      -- 0=computing, 1=result ready
    );
end custom_operations;

architecture Behavioral of custom_operations is
    
    -- State machine for result timing
    type state_type is (IDLE, COMPUTING, RESULT_READY);
    signal state : state_type := IDLE;
    
    -- Stored results
    signal result_buf : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal operation_stored : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
    signal a_stored : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal b_stored : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    
    -- Computed result (combinational)
    signal computed_result : STD_LOGIC_VECTOR(7 downto 0);
    
begin
    
    -- Combinational computation of all 3 operations
    process(operation_stored, a_stored, b_stored)
        variable mult_result : unsigned(7 downto 0);
        variable add_result : unsigned(7 downto 0);
        variable xnor_result : STD_LOGIC_VECTOR(3 downto 0);
        variable final_result : STD_LOGIC_VECTOR(7 downto 0);
    begin
        -- Operation 1: Multiplication (A * B) -> 8 bits
        mult_result := unsigned(a_stored) * unsigned(b_stored);
        
        -- Operation 2: Addition (A + B) -> 8 bits (zero-extended)
        add_result := resize(unsigned(a_stored), 8) + resize(unsigned(b_stored), 8);
        
        -- Operation 3: (A xnor B[0]) or (A xnor B[1])
        -- This is a 4-bit result (A is 4 bits)
        xnor_result := (a_stored xnor (b_stored(0) & b_stored(0) & b_stored(0) & b_stored(0))) or
                       (a_stored xnor (b_stored(1) & b_stored(1) & b_stored(1) & b_stored(1)));
        
        -- Select operation result
        case operation_stored is
            when "00" =>  -- Multiplication
                final_result := std_logic_vector(mult_result);
            when "01" =>  -- Addition
                final_result := std_logic_vector(add_result);
            when "10" =>  -- XNOR logic
                final_result := (others => '0');
                final_result(3 downto 0) := xnor_result;  -- 4-bit result, upper bits = 0
            when others =>
                final_result := (others => '0');
        end case;
        
        computed_result <= final_result;
    end process;
    
    -- State machine: handle START signal and computation timing
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= IDLE;
                result_buf <= (others => '0');
                RES_VALID <= '0';
            else
                case state is
                    when IDLE =>
                        -- Wait for START signal
                        if start = '1' then
                            a_stored <= A;
                            b_stored <= B;
                            operation_stored <= operation;
                            state <= COMPUTING;
                            RES_VALID <= '0';
                            result_buf <= (others => '0');  -- Output is 0 during compute
                        else
                            RES_VALID <= '0';
                            result_buf <= (others => '0');
                        end if;
                    
                    when COMPUTING =>
                        -- Compute takes 1 cycle, then move to RESULT_READY
                        -- On next clock edge, result is available
                        result_buf <= computed_result;
                        state <= RESULT_READY;
                        RES_VALID <= '1';  -- Result is now ready
                    
                    when RESULT_READY =>
                        -- Hold result until next START
                        if start = '1' then
                            a_stored <= A;
                            b_stored <= B;
                            operation_stored <= operation;
                            state <= COMPUTING;
                            RES_VALID <= '0';
                            result_buf <= (others => '0');  -- Output is 0 during compute
                        else
                            -- Maintain current result
                            RES_VALID <= '1';
                        end if;
                    
                    when others =>
                        state <= IDLE;
                        RES_VALID <= '0';
                end case;
            end if;
        end if;
    end process;
    
    -- Output assignment
    RES_OUT <= result_buf;
    
end Behavioral;
