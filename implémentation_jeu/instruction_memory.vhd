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
    
    -- Instruction memory: repeat the shift-right-A microinstruction
    -- to implement the 4-bit LFSR on the UAL.
    -- Instruction format: [SEL_FCT(4)] & [SEL_ROUTE(4)] & [SEL_OUT(2)]
    -- SEL_FCT = 1100 (shift right A), SEL_ROUTE = 0000 (load A from A_IN, B from B_IN), SEL_OUT = 00
    signal rom : rom_type := (others => "1100000000");
    
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
