library ieee;
use ieee.std_logic_1164.all;

entity morse_reg is -- Only required to be PISO, no need for SISO or PIPO etc
    generic ( N : integer := 11) ; --By default will be N but can be changed
    port (
        clk             : in std_logic ; -- 50MHz clock (loaded once when request hit)
        reset           : in std_logic; -- global, asynchronous reset
        request         : in std_logic ; -- this is read when request is hit, acts as enable for register
        enable          : in std_logic; -- created by FSM to signal whether busy or not
        parallel_in     : in std_logic_vector(N-1 DOWNTO 0) ; -- Parallel input data
        parallel_out    : out std_logic_vector(N-1 DOWNTO 0)) ; -- Serial output
end morse_reg ;

architecture behaviour of morse_reg is
    signal temp_reg: std_logic_vector(N-1 DOWNTO 0) := (OTHERS => '0');
begin
    process(clk, reset)
    begin
        if (reset = '0') then -- check active low and high reset
            temp_reg <= (OTHERS => '0');
        elsif rising_edge(clk) then
            if (enable = '0') then
                temp_reg <= parallel_in;
            end if;
        end if ;
    end process ;

    -- Output is always connected to the register
    parallel_out <= temp_reg;
end behaviour ;