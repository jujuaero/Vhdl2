library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

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
    
    signal rom : rom_type := (
        0 => "0000001000", -- NOP, Load A_IN to Buf_A, Hold Buf_B
        1 => "0001011000", -- S=A, Load S to Buf_A & Cache_1
        
        -- Start LFSR loop
        2 => "1100100100", -- SRA, Hold Buf_A, Load Buf_B
        3 => "0111100100", -- A XOR B, Load Buf_B
        4 => "1110100100", -- SRB, Load Buf_B
        5 => "1110100100", -- SRB, Load Buf_B
        6 => "1111100100", -- SLB, Load Buf_B
        7 => "1111100100", -- SLB, Load Buf_B
        8 => "1111100100", -- SLB, Load Buf_B
        9 => "1110100100", -- SRB, Load Buf_B
        10=> "1110100100", -- SRB, Load Buf_B
        11=> "1110100100", -- SRB, Load Buf_B
        12=> "1101011000", -- SLA, Load Buf_A & Cache_1
        13=> "0110011000", -- A OR B, Load Buf_A & Cache_1
        
        others => "0000000000"
    );
    
    signal pc : unsigned(6 downto 0) := (others => '0');
    
begin
    
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                pc <= (others => '0');
            else
                if pc = 13 then
                    pc <= to_unsigned(2, 7); -- Loop back
                else
                    pc <= pc + 1;
                end if;
            end if;
        end if;
    end process;
    
    instr_out <= rom(to_integer(pc));
    pc_out <= std_logic_vector(pc);
    
end Behavioral;