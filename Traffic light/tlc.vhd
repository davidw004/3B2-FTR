LIBRARY IEEE;
USE ieee.std_logic_1164.all;

ENTITY tlc IS
PORT(
    clk : IN std_logic;
    request : IN std_logic;
    reset : IN std_logic;
    output : OUT std_logic_vector(4 DOWNTO 0);
	 HEX1, HEX0 : OUT std_logic_vector(0 to 6));
END tlc;

ARCHITECTURE tlc_arch OF tlc IS

    -- Build an enumerated type for the state machine
    TYPE state_type IS (G, Y, R, W);
    -- Register to hold the current state
    SIGNAL state : state_type;
	 -- Register to hold the current number
	 SIGNAL display_time : std_logic_vector(7 DOWNTO 0);
	 COMPONENT bcd7seg
		PORT (
          BCD : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
          HEX : OUT STD_LOGIC_VECTOR(0 TO 6));
    END COMPONENT;	 
	 
BEGIN
    -- Logic to advance to the next state
    PROCESS (clk, reset)
        VARIABLE count : INTEGER;
    BEGIN
        IF reset = '0' THEN
            state <= G;
				count := 0;
				
        ELSIF rising_edge(clk) THEN
            CASE state IS
                WHEN G =>
							IF	request = '0' THEN
								state <= Y;
								count := 250000000;
							END IF;
                WHEN Y =>
                    -- Define time constants
                    -- (50MHz clk means 50000000 cycles/s)
                    IF count = 0 THEN
                        state <= R;
                        count := 500000000;
                    ELSE
                        count := count - 1;
                    END IF;
                WHEN R =>
							IF count = 0 THEN
                        state <= W;
                        count := 500000000; -- Look to change this to not reset count
							ELSE
                        count := count - 1;
							END IF;

					WHEN W =>
						IF count = 0 THEN
							state <= G;
					  ELSE
							count := count - 1;
					  END IF;
				END CASE;
				
				IF    count > 450000000 THEN
					 display_time <= "00010000"; --10
				ELSIF count > 400000000 THEN
					 display_time <= "00001001"; --9
				ELSIF count > 350000000 THEN
					 display_time <= "00001000"; --8
				ELSIF count > 300000000 THEN
					 display_time <= "00000111"; --7
				ELSIF count > 250000000 THEN
					 display_time <= "00000110"; --6
				ELSIF count > 200000000 THEN
					 display_time <= "00000101"; --5
				ELSIF count > 150000000 THEN
					 display_time <= "00000100"; --4
				ELSIF count > 100000000 THEN
					 display_time <= "00000011"; --3
				ELSIF count > 50000000 THEN
					 display_time <= "00000010"; --2
				ELSIF count > 0 THEN
					 display_time <= "00000001"; --1
				ELSE	
					 display_time <= "11111111"; -- NULL
				END IF; 
        END IF;


    END PROCESS;
	 
	 -- Instantiate BCD to 7-segment decoder
    digit1: bcd7seg PORT MAP(display_time(7 DOWNTO 4), HEX1);
    digit0: bcd7seg PORT MAP(display_time(3 DOWNTO 0), HEX0);
	 
    -- Output depends solely on the current state
    PROCESS (state)
    BEGIN
        CASE state IS
            WHEN G =>
                output <= "10001";
            WHEN Y =>
                output <= "10010";
            WHEN R =>
                output <= "01100";
				WHEN W =>
                output <= "10001"; 
        END CASE;
    END PROCESS;
	 
END tlc_arch;

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

ENTITY bcd7seg IS
	PORT (
		BCD : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		HEX : OUT STD_LOGIC_VECTOR(0 TO 6));
END bcd7seg;

ARCHITECTURE behavior OF bcd7seg IS
BEGIN
    PROCESS (BCD)
    BEGIN
        CASE BCD IS
            WHEN "0000" => HEX <= "0000001"; -- 0
            WHEN "0001" => HEX <= "1001111"; -- 1
            WHEN "0010" => HEX <= "0010010"; -- 2
            WHEN "0011" => HEX <= "0000110"; -- 3
            WHEN "0100" => HEX <= "1001100"; -- 4
            WHEN "0101" => HEX <= "0100100"; -- 5
            WHEN "0110" => HEX <= "1100000"; -- 6
            WHEN "0111" => HEX <= "0001111"; -- 7
            WHEN "1000" => HEX <= "0000000"; -- 8
            WHEN "1001" => HEX <= "0001100"; -- 9
            WHEN OTHERS => HEX <= "1111111"; -- Blank
        END CASE;
    END PROCESS;
END behavior;
