library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity morse_length is
    port (
        clk             : IN std_logic ; -- This will be 50MHZ clock
        reset           : in  std_logic;  -- Active low reset
        request         : in  std_logic; -- triggered by enable set to high in morse_FSM
        enable          : in std_logic; -- From FSM to tell if busy
        letter_length   : IN integer range 0 to 11; -- From letter_select module
        length_out      : OUT integer range 0 to 11); -- Output value form register
end morse_length ;

architecture behaviour of morse_length is
    signal stored_length : integer range 0 to 11 := 0;
begin

    process(clk, reset)
    begin
        if reset = '0' then -- asynchronous reset
            stored_length <= 0;
        elsif rising_edge(clk) then -- synchronous request
            if (enable = '0') then
                stored_length <= letter_length;
            end if;
        end if;
    end process;
    
    length_out <= stored_length;
end behaviour;