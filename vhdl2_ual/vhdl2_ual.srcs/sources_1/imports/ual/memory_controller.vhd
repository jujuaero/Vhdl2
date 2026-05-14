library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Memory Controller: orchestrates all buffers, caches, and registers
-- Connects instruction memory -> instruction decoder -> UAL control
entity memory_controller is
    Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        
        -- External inputs
        A_IN        : in  STD_LOGIC_VECTOR(3 downto 0);  -- 4-bit input A
        B_IN        : in  STD_LOGIC_VECTOR(3 downto 0);  -- 4-bit input B
        SR_IN_L     : in  STD_LOGIC;                     -- Left shift input
        SR_IN_R     : in  STD_LOGIC;                     -- Right shift input
        
        -- From UAL
        S_from_ual  : in  STD_LOGIC_VECTOR(7 downto 0);  -- UAL result
        SR_OUT_L    : in  STD_LOGIC;                      -- UAL shift output left
        SR_OUT_R    : in  STD_LOGIC;                      -- UAL shift output right
        
        -- Control signals to UAL (from instruction decoder)
        A_to_ual    : out STD_LOGIC_VECTOR(3 downto 0);
        B_to_ual    : out STD_LOGIC_VECTOR(3 downto 0);
        SEL_FCT     : out STD_LOGIC_VECTOR(3 downto 0);
        SEL_ROUTE   : out STD_LOGIC_VECTOR(3 downto 0);  -- No storage, used immediately
        SEL_OUT     : out STD_LOGIC_VECTOR(1 downto 0);
        
        -- Output data (cache outputs)
        CACHE_1_OUT : out STD_LOGIC_VECTOR(7 downto 0);
        CACHE_2_OUT : out STD_LOGIC_VECTOR(7 downto 0);
        
        -- Program counter visibility
        PC_OUT      : out STD_LOGIC_VECTOR(6 downto 0)
    );
end memory_controller;

architecture Behavioral of memory_controller is
    
    -- Internal signals
    signal instr            : STD_LOGIC_VECTOR(9 downto 0);
    signal sel_fct_instr    : STD_LOGIC_VECTOR(3 downto 0);
    signal sel_route_instr  : STD_LOGIC_VECTOR(3 downto 0);
    signal sel_out_instr    : STD_LOGIC_VECTOR(1 downto 0);
    
    signal buffer_a_out     : STD_LOGIC_VECTOR(3 downto 0);
    signal buffer_b_out     : STD_LOGIC_VECTOR(3 downto 0);
    signal cache_1_buf      : STD_LOGIC_VECTOR(7 downto 0);
    signal cache_2_buf      : STD_LOGIC_VECTOR(7 downto 0);
    
    signal mem_sel_fct      : STD_LOGIC_VECTOR(3 downto 0);
    signal mem_sel_out      : STD_LOGIC_VECTOR(1 downto 0);
    signal mem_sr_in_l      : STD_LOGIC;
    signal mem_sr_in_r      : STD_LOGIC;
    
    -- Route selection decoding (which buffer/cache to update)
    signal route_buf_a      : STD_LOGIC_VECTOR(1 downto 0);
    signal route_buf_b      : STD_LOGIC_VECTOR(1 downto 0);
    signal route_cache_1    : STD_LOGIC_VECTOR(1 downto 0);
    signal route_cache_2    : STD_LOGIC_VECTOR(1 downto 0);
    
begin
    
    -- ========================================
    -- 1. Instruction Memory (ROM with auto PC)
    -- ========================================
    instr_mem: entity work.instruction_memory
        port map (
            clk => clk,
            reset => reset,
            instr_out => instr,
            pc_out => PC_OUT
        );
    
    -- Decode instruction: [SEL_FCT(4)][SEL_ROUTE(4)][SEL_OUT(2)]
    sel_fct_instr   <= instr(9 downto 6);
    sel_route_instr <= instr(5 downto 2);
    sel_out_instr   <= instr(1 downto 0);
    
    -- ========================================
    -- 2. Synchronous Registers (always updated)
    -- ========================================
    
    -- MEM_SEL_FCT: stores selected function
    reg_sel_fct: entity work.register_sync
        generic map (WIDTH => 4)
        port map (
            clk => clk,
            reset => reset,
            enable => '1',
            data_in => sel_fct_instr,
            data_out => mem_sel_fct
        );
    
    -- MEM_SEL_OUT: stores output selection
    reg_sel_out: entity work.register_sync
        generic map (WIDTH => 2)
        port map (
            clk => clk,
            reset => reset,
            enable => '1',
            data_in => sel_out_instr,
            data_out => mem_sel_out
        );
    
    -- MEM_SR_IN_L: stores left shift input
    reg_sr_in_l: entity work.register_sync
        generic map (WIDTH => 1)
        port map (
            clk => clk,
            reset => reset,
            enable => '1',
            data_in(0) => SR_IN_L,
            data_out(0) => mem_sr_in_l
        );
    
    -- MEM_SR_IN_R: stores right shift input
    reg_sr_in_r: entity work.register_sync
        generic map (WIDTH => 1)
        port map (
            clk => clk,
            reset => reset,
            enable => '1',
            data_in(0) => SR_IN_R,
            data_out(0) => mem_sr_in_r
        );
    
    -- ========================================
    -- 3. Decode SEL_ROUTE to individual signals
    -- ========================================
    -- sel_route_instr format: [2 bits for buf_a][2 bits for buf_b][2 bits for cache_1][2 bits for cache_2]
    -- Actually, let's keep it simple: each buffer can have its own route code
    -- For now: treat sel_route_instr as follows:
    --   bits[3:2] -> Buffer_A, bits[1:0] -> Buffer_B
    -- Or interpret all 4 bits for multiplexed select
    
    -- Simple approach: bits [3:2] control what loads (00=input, 01=from S, 10=hold, 11=clear)
    route_buf_a <= sel_route_instr(3 downto 2);
    route_buf_b <= sel_route_instr(1 downto 0);
    -- For caches, we'll use different interpretations or duplicate logic
    route_cache_1 <= sel_route_instr(3 downto 2);
    route_cache_2 <= sel_route_instr(1 downto 0);
    
    -- ========================================
    -- 4. Buffers and Caches
    -- ========================================
    
    -- Buffer_A: stores A_IN or can load from UAL output
    buf_a: entity work.buffer_with_route
        generic map (WIDTH => 4)
        port map (
            clk => clk,
            reset => reset,
            input_data => A_IN,
            ual_output => S_from_ual(3 downto 0),  -- Lower 4 bits
            sel_route => route_buf_a,
            buffer_out => buffer_a_out
        );
    
    -- Buffer_B: stores B_IN or can load from UAL output
    buf_b: entity work.buffer_with_route
        generic map (WIDTH => 4)
        port map (
            clk => clk,
            reset => reset,
            input_data => B_IN,
            ual_output => S_from_ual(3 downto 0),  -- Lower 4 bits
            sel_route => route_buf_b,
            buffer_out => buffer_b_out
        );
    
    -- Cache_1: stores result from UAL (8 bits)
    cache_1: entity work.buffer_with_route
        generic map (WIDTH => 8)
        port map (
            clk => clk,
            reset => reset,
            input_data => (others => '0'),  -- Not used for cache
            ual_output => S_from_ual,
            sel_route => route_cache_1,
            buffer_out => cache_1_buf
        );
    
    -- Cache_2: stores result from UAL (8 bits)
    cache_2: entity work.buffer_with_route
        generic map (WIDTH => 8)
        port map (
            clk => clk,
            reset => reset,
            input_data => (others => '0'),  -- Not used for cache
            ual_output => S_from_ual,
            sel_route => route_cache_2,
            buffer_out => cache_2_buf
        );
    
    -- ========================================
    -- 5. Output assignments
    -- ========================================
    
    -- Data to UAL (from buffers)
    A_to_ual <= buffer_a_out;
    B_to_ual <= buffer_b_out;
    
    -- Control signals to UAL (from stored registers)
    SEL_FCT <= mem_sel_fct;
    SEL_ROUTE <= sel_route_instr;  -- SEL_ROUTE not stored, used immediately
    SEL_OUT <= mem_sel_out;
    
    -- Cache outputs
    CACHE_1_OUT <= cache_1_buf;
    CACHE_2_OUT <= cache_2_buf;
    
end Behavioral;
