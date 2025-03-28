library ieee;
use ieee.std_logic_1164.all;

ENTITY letter_select IS
    PORT ( 
        SW : IN std_logic_vector (2 downto 0) ;
        letter_length    : OUT integer range 0 to 11; 
        -- no dependence on clk, purely combinational
        data   : OUT std_logic_vector(10 downto 0)) ;
END letter_select ;

ARCHITECTURE behaviour OF letter_select IS

BEGIN
    process(SW)
    begin
    -- len will be shifted right
    -- # of 1s matchletter_length of code
        case SW is
            when "000" =>letter_length <= 5;  -- A: .-
            when "001" =>letter_length <= 9;  -- B: -...
            when "010" =>letter_length <= 11; -- C: -.-.
            when "011" =>letter_length <= 7;  -- D: -..
            when "100" =>letter_length <= 1;  -- E: .
            when "101" =>letter_length <= 9;  -- F: ..-.
            when "110" =>letter_length <= 9;  -- G: --.
            when "111" =>letter_length <= 7;  -- H: ....
            when others =>letter_length <= 0; -- Default case for completeness
        end case;
    end process;

    WITH SW SELECT data <=
        -- 1 for light on, 0 for light off.
        "00000011101" when "000",  --  2 when .- (dot gap pulse(3))
        "00101010111" when "001", --  4 when -... (pulse gap dot gap dot gap dot)
        "10111010111" when "010", -- -.-. etc
        "00001010111" when "011", -- -..
        "00000000001" when "100", -- .
        "00101110101" when "101", -- ..-.
        "00101110111" when "110", -- --.
        "00001010101" when "111", -- ....
        "00000000000" when others; -- default
end behaviour ;