library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity timeout is
    Port(
        clk : in std_logic;
        res : in std_logic;
        sta : in std_logic;
        sw_level : in std_logic_vector(1 downto 0);
        time_out : out std_logic
    );
end timeout;

architecture Behavioral of timeout is
    signal running  : std_logic := '0';
    signal compteur : unsigned(29 downto 0) := (others => '0');
begin
    process(clk,res)
    begin
        if res='1' then
            time_out <= '0';
            compteur <= (others => '0');
            running <= '0';
        elsif rising_edge(clk) then
            if sta='1' then
                running <= '1';
                compteur <= (others => '0');
                time_out <= '0';
            elsif running='1' then
                compteur <= compteur + 1;
                case sw_level is
                    when "00" =>
                        if compteur = to_unsigned(500_000_000, 30) then
                            time_out <= '1';
                            compteur <= (others => '0');
                        end if;
                    when "01" =>
                        if compteur = to_unsigned(200_000_000, 30) then
                            time_out <= '1';
                            compteur <= (others => '0');
                        end if;
                    when "10" =>
                        if compteur = to_unsigned(100_000_000, 30) then
                            time_out <= '1';
                            compteur <= (others => '0');
                        end if;
                    when "11" =>
                        if compteur = to_unsigned(50_000_000, 30) then
                            time_out <= '1';
                            compteur <= (others => '0');
                        end if;
                    when others =>
                        if compteur = to_unsigned(50_000_000, 30) then
                            time_out <= '1';
                            compteur <= (others => '0');
                        end if;
                end case;
            end if;
        end if;
    end process;
end Behavioral;
