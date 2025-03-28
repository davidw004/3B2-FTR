LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL; 

ENTITY counter IS
    GENERIC ( n : NATURAL := 25; k : INTEGER := 25000000 );
    PORT ( 
            clk, reset: IN  STD_LOGIC;
            enable: IN  STD_LOGIC;
            start_time  : IN  STD_LOGIC_VECTOR(n-1 DOWNTO 0);
            count       : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
            rollover    : OUT STD_LOGIC
            );
END ENTITY;

ARCHITECTURE behaviour OF counter IS
    SIGNAL count_s : STD_LOGIC_VECTOR(n-1 DOWNTO 0) ; -- This acts as a temporary parameter so that changes to count occur irrespective of clock edge
BEGIN
    PROCESS(clk, reset)
    BEGIN
        IF (reset = '0') THEN -- Active low reset
            count_s <= (OTHERS => '0'); -- OTHERS => '0' sets all bits to zero
        ELSIF rising_edge(clk) THEN
            IF (enable = '0') THEN
                    count_s <= start_time;
            ELSIF (count_s = 0) THEN -- modulo-k down counter
					  count_s <= conv_std_logic_vector(k-1, n);
            ELSE
					  count_s <= count_s - 1;
            END IF;
        END IF;
    END PROCESS;
    count <= count_s; -- mirror output
    rollover <= '1' WHEN (count_s = 0) ELSE '0';
END behaviour;