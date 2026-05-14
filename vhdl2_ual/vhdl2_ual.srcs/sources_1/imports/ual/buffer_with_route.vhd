library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Buffer with route selection: can be loaded from input or from output (feedback)
-- sel_route controls which source is written on rising_edge(clk)
-- sel_route = "00": load from input_data (e.g., A_IN or B_IN)
-- sel_route = "01": load from UAL output S
-- sel_route = "10": hold current value
-- sel_route = "11": clear
entity buffer_with_route is
    generic (
        WIDTH : positive := 8
    );
    Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        input_data  : in  STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        ual_output  : in  STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        sel_route   : in  STD_LOGIC_VECTOR(1 downto 0);
        buffer_out  : out STD_LOGIC_VECTOR(WIDTH-1 downto 0)
    );
end buffer_with_route;

architecture Behavioral of buffer_with_route is
    signal buf : STD_LOGIC_VECTOR(WIDTH-1 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                buf <= (others => '0');
            else
                case sel_route is
                    when "00" =>   -- Load from input_data
                        buf <= input_data;
                    when "01" =>   -- Load from UAL output
                        buf <= ual_output;
                    when "10" =>   -- Hold
                        buf <= buf;
                    when "11" =>   -- Clear
                        buf <= (others => '0');
                    when others =>
                        buf <= (others => '0');
                end case;
            end if;
        end if;
    end process;

    buffer_out <= buf;

end Behavioral;
