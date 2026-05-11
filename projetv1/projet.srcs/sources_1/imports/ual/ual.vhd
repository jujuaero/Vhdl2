library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UAL is
    Port (
        A        : in  STD_LOGIC_VECTOR(3 downto 0);
        B        : in  STD_LOGIC_VECTOR(3 downto 0);
        SEL_FCT  : in  STD_LOGIC_VECTOR(3 downto 0);
        SEL_ROUTE: in  STD_LOGIC_VECTOR(3 downto 0);
        SEL_OUT  : in  STD_LOGIC_VECTOR(1 downto 0);
        SR_IN_L  : in  STD_LOGIC;
        SR_IN_R  : in  STD_LOGIC;
        S        : out STD_LOGIC_VECTOR(7 downto 0);
        SR_OUT_L : out STD_LOGIC;
        SR_OUT_R : out STD_LOGIC
    );
end UAL;

architecture Behavioral of UAL is
begin
    process(A, B, SEL_FCT, SEL_ROUTE, SEL_OUT, SR_IN_L, SR_IN_R)
        variable a_signed : signed(3 downto 0);
        variable b_signed : signed(3 downto 0);
        variable a_unsigned : unsigned(3 downto 0);
        variable b_unsigned : unsigned(3 downto 0);
    begin
        -- Initialisation par défaut pour éviter les verrous (latches)
        S <= (others => '0');
        SR_OUT_L <= '0';
        SR_OUT_R <= '0';

        -- Conversion pour les opérations arithmétiques signées
        a_signed := signed(A);
        b_signed := signed(B);
        a_unsigned := unsigned(A);
        b_unsigned := unsigned(B);

        case SEL_FCT is
            when "0000" => -- nop [cite: 169-174]
                S <= (others => '0');

            when "0001" => -- S = A [cite: 175-179]
                S <= std_logic_vector(resize(a_signed, 8));

            when "0010" => -- S = not A [cite: 180-185]
                S <= std_logic_vector(resize(not a_unsigned, 8));

            when "0011" => -- S = B [cite: 186-191]
                S <= std_logic_vector(resize(b_signed, 8));

            when "0100" => -- S = not B [cite: 192-196]
                S <= std_logic_vector(resize(not b_unsigned, 8));

            when "0101" => -- S = A and B [cite: 197-202]
                S <= std_logic_vector(resize(a_unsigned and b_unsigned, 8));

            when "0110" => -- S = A or B [cite: 203-208]
                S <= std_logic_vector(resize(a_unsigned or b_unsigned, 8));

            when "0111" => -- S = A xor B [cite: 209-213]
                S <= std_logic_vector(resize(a_unsigned xor b_unsigned, 8));

            when "1000" => -- S = A + B avec retenue d'entrée [cite: 214-218]
                if SR_IN_R = '1' then
                    S <= std_logic_vector(resize(a_signed + b_signed + 1, 8));
                else
                    S <= std_logic_vector(resize(a_signed + b_signed, 8));
                end if;

            when "1001" => -- S = A + B sans retenue [cite: 219-223]
                S <= std_logic_vector(resize(a_signed + b_signed, 8));

            when "1010" => -- S = A - B [cite: 224-228]
                S <= std_logic_vector(resize(a_signed - b_signed, 8));

            when "1011" => -- S = A * B [cite: 229-233]
                -- La multiplication de deux nombres de 4 bits donne naturellement un résultat sur 8 bits
                S <= std_logic_vector(a_signed * b_signed);

            when "1100" => -- Décalage droite A sur 4 bits [cite: 234-239]
                S(3) <= SR_IN_L;
                S(2 downto 0) <= A(3 downto 1);
                SR_OUT_R <= A(0);

            when "1101" => -- Décalage gauche A sur 4 bits [cite: 240-245]
                S(3 downto 1) <= A(2 downto 0);
                S(0) <= SR_IN_R;
                SR_OUT_L <= A(3);

            when "1110" => -- Décalage droite B sur 4 bits [cite: 246-250]
                S(3) <= SR_IN_L;
                S(2 downto 0) <= B(3 downto 1);
                SR_OUT_R <= B(0);

            when "1111" => -- Décalage gauche B sur 4 bits [cite: 251-255]
                S(3 downto 1) <= B(2 downto 0);
                S(0) <= SR_IN_R;
                SR_OUT_L <= B(3);

            when others =>
                S <= (others => '0');
        end case;
    end process;
end Behavioral;