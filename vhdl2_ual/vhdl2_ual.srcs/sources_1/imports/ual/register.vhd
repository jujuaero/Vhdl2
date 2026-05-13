library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Generic synchronous register: memorizes input on clock rising edge if enabled
entity register_sync is
    generic (
        WIDTH : positive := 8  -- Width of data
    );
    Port (
        clk    : in  STD_LOGIC;
        reset  : in  STD_LOGIC;
        enable : in  STD_LOGIC;
        data_in : in  STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        data_out: out STD_LOGIC_VECTOR(WIDTH-1 downto 0)
    );
end register_sync;

architecture Behavioral of register_sync is
    signal reg : STD_LOGIC_VECTOR(WIDTH-1 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                reg <= (others => '0');
            elsif enable = '1' then
                reg <= data_in;
            end if;
        end if;
    end process;

    data_out <= reg;

end Behavioral;
