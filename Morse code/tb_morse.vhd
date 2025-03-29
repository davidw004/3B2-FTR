LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_morse IS
END tb_morse;

ARCHITECTURE tb OF tb_morse IS
    SIGNAL CLK50MHZ   : std_logic := '0';
    SIGNAL reset      : std_logic := '1';
    SIGNAL request    : std_logic := '1';
    SIGNAL SW         : std_logic_vector(2 downto 0) := "101";
    SIGNAL LED        : std_logic;
    
    CONSTANT CLK_PERIOD : time := 20 ns; -- 50 MHz clock
BEGIN
    
    -- Instantiate DUT
    DUT: ENTITY work.morse_top(behaviour)
    PORT MAP (
        CLK50MHZ => CLK50MHZ,
        reset    => reset,
        request  => request,
        SW       => SW,
        LED      => LED
    );
    
    -- Clock process
    clk_process : PROCESS
    BEGIN
        WHILE TRUE LOOP
            CLK50MHZ <= '0';
            WAIT FOR CLK_PERIOD / 2;
            CLK50MHZ <= '1';
            WAIT FOR CLK_PERIOD / 2;
        END LOOP;
        WAIT;
    END PROCESS;
    
    -- Stimulus process
    stim_process : PROCESS
    BEGIN
        
        WAIT FOR 5 * CLK_PERIOD;
        
        SW <= "101";
        
        request <= '0';
        WAIT FOR 2 * CLK_PERIOD;
        request <= '1';
        
        -- Allow time for simulation
        WAIT FOR 5 sec;
        
        -- Finish simulation
        WAIT;
    END PROCESS;
    
END tb;