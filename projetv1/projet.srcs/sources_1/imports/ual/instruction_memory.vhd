library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Instruction memory with auto-incrementing program counter
-- PC increments on every rising_edge(clk) unless reset
entity instruction_memory is
    Port (
        clk          : in  STD_LOGIC;
        reset        : in  STD_LOGIC;
        instr_out    : out STD_LOGIC_VECTOR(9 downto 0);  -- 10-bit instruction
        pc_out       : out STD_LOGIC_VECTOR(6 downto 0)   -- Program counter (0-127)
    );
end instruction_memory;

architecture Behavioral of instruction_memory is
    type rom_type is array (0 to 127) of STD_LOGIC_VECTOR(9 downto 0);
    
    -- Example instruction set (user can fill as needed)
    signal rom : rom_type := (
        -- Instruction format: [SEL_FCT(4)] & [SEL_ROUTE(4)] & [SEL_OUT(2)]
        
        -- Instruction 0: NOP (all zero)
        0 => "0000000000",
        
        -- Instruction 1: A+B, load Buffer_A with input, SEL_OUT=00
        1 => "1001" & "0000" & "00",  -- SEL_FCT=1001(add), route=0000(load from input), out=00
        
        -- Instruction 2: AND A,B, load CACHE_1, SEL_OUT=01
        2 => "0101" & "0001" & "01",  -- SEL_FCT=0101(AND), route=0001, out=01
        
        -- Instruction 3: A-B, load CACHE_2, SEL_OUT=10
        3 => "1010" & "0010" & "10",  -- SEL_FCT=1010(SUB), route=0010, out=10
        
        others => (others => '0')
    );
    
    signal pc : unsigned(6 downto 0) := (others => '0');
    
begin
    
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                pc <= (others => '0');
            else
                -- Auto-increment PC
                if pc = 127 then
                    pc <= (others => '0');  -- Wrap around
                else
                    pc <= pc + 1;
                end if;
            end if;
        end if;
    end process;
    
    -- Combinational output: read instruction at current PC
    instr_out <= rom(to_integer(pc));
    pc_out <= std_logic_vector(pc);
    
end Behavioral;
