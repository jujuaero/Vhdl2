library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mem_instructions is
    Port (
        clk      : in  STD_LOGIC;
        reset    : in  STD_LOGIC;
        addr     : in  STD_LOGIC_VECTOR(6 downto 0); -- 128 instructions max
        data_out : out STD_LOGIC_VECTOR(9 downto 0)
    );
end mem_instructions;

architecture Behavioral of mem_instructions is
    type rom_type is array (0 to 127) of STD_LOGIC_VECTOR(9 downto 0);
    signal rom : rom_type := (
        -- Exemple : instruction 0 = NOP (tout à 0)
        0 => "0000000000",
        1 => "0000000000",
        others => (others => '0')
    );
    signal addr_int : integer range 0 to 127;
begin
    addr_int <= to_integer(unsigned(addr));
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                data_out <= (others => '0');
            else
                data_out <= rom(addr_int);
            end if;
        end if;
    end process;
end Behavioral;
