library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY morse_top IS
    PORT ( 
        CLK50MHZ       : IN  std_logic;
        reset          : IN  std_logic; -- KEY 0
        request        : IN  std_logic; -- KEY 1
        SW             : IN  std_logic_vector(2 downto 0);
        LED            : OUT std_logic;  -- output
        counter_out    : OUT std_logic_vector(24 downto 0); -- Expose counter value (25 bits as per n=25)
        half_sec_tick_out : OUT std_logic  -- Expose half_sec_tick (rollover)
    );
END morse_top;

ARCHITECTURE behaviour OF morse_top IS
    -- Signals to connect submodules
    SIGNAL data_in      : std_logic_vector(10 downto 0); -- from letter select
    SIGNAL data_out     : std_logic_vector(10 downto 0); -- from register
    SIGNAL i_length     : integer; -- input length to length counter module
    SIGNAL length       : integer; -- current length left to display
    SIGNAL half_sec_tick : std_logic; -- Before begin because interconnect components
    SIGNAL counter_value : std_logic_vector(24 downto 0); -- To capture counter's count output

BEGIN
    -- Morse Code Length Counter
    U_half_counter: entity work.counter(behaviour)
    GENERIC MAP ( n => 25, k => 250000000)
    PORT MAP (
        clk    => CLK50MHZ,
        reset  => reset,
        enable => '1',
        load   => request,
        start_time => "0000000000000000000100000", -- when loading clock, don't need to go all the way to 250000...
        count  => counter_value,  -- Capture the counter's count value
        rollover => half_sec_tick -- since this is wasted time before a rising edge.
    );

    -- Expose counter signals to top-level outputs
    counter_out <= counter_value;
    half_sec_tick_out <= half_sec_tick;

    -- Letter Selection Module
    U_letter_select: entity work.letter_select(behaviour)
        PORT MAP (
            SW => SW,
            length => i_length,
            data   => data_in
        );

    U_morse_reg: entity work.morse_reg(behaviour)
        PORT MAP (
            clk  => half_sec_tick,
            reset => reset,
            request => request,
            parallel_in => data_in, -- Parallel input data
            parallel_out => data_out -- Parallel output from 
        ); 

    U_morse_length: entity work.morse_length(behaviour)
        PORT MAP (
            clk => half_sec_tick,
            reset => reset,
            request => request,
            letter_length => i_length,
            length_out => length
        );

    U_morse_FSM: entity work.morse_FSM(behaviour)
        PORT MAP (
            CLK_HALF_SEC => half_sec_tick,
            reset => reset,
            request => request,
            length => length,
            data => data_out,
            LED => LED
        );

END behaviour;