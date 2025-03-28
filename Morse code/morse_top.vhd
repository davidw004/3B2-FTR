library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY tlc IS
    PORT ( 
        CLK50MHZ    : IN std_logic;
        reset       : IN std_logic; -- KEY 0
        request     : IN std_logic; --KEY 1
        SW          : IN std_logic_vector(2 downto 0);
        LED         : OUT std_logic);  -- output
END tlc;

ARCHITECTURE behaviour OF tlc IS
    -- Internal signals to connect submodules
    SIGNAL data_in      : std_logic_vector(10 downto 0); -- from letter select
    SIGNAL data_out     : std_logic_vector(10 downto 0); -- from register
    SIGNAL i_length     : integer range 0 to 11; -- input length to length counter module
    SIGNAL o_length     : integer range 0 to 11; -- current length left to display
    SIGNAL half_sec_tick : std_logic; -- Before begin because interconenct components
    SIGNAL register_enable :std_logic;

BEGIN

    -- Morse Code Length Counter
    U_half_counter: entity work.counter(behaviour)
    GENERIC MAP ( n => 25, k => 25000000)
    PORT MAP (
        clk    => CLK50MHZ,
        reset  => reset,
        enable => register_enable,
        start_time => "0000000000000000000100000", -- when loading clock, don't need to go all the way to 250000...
        rollover => half_sec_tick                   -- since this is wasted time before a rising edge.
    );

    -- Letter Selection Module (all aysnchronous)
    U_letter_select: entity work.letter_select(behaviour)
        PORT MAP (
            SW => SW,
            letter_length => i_length,
            data   => data_in
        );
    
    -- Register holding the actual data
    U_morse_reg: entity work.morse_reg(behaviour) 
        PORT MAP (
            clk  =>  CLK50MHZ,
            reset => reset,
            request => request,
            enable => register_enable,
            parallel_in => data_in, -- Parallel input data
            parallel_out => data_out -- Parallel output from 
        ); 

    -- Register holding the length of the data
    U_morse_length: entity work.morse_length(behaviour) --Essentailly a register for length of signal
        PORT MAP (
        clk => CLK50MHZ,
        reset => reset,
        request => request,
        enable => register_enable,
        letter_length => i_length,
        length_out => o_length);

    U_morse_FSM: entity work.morse_FSM(behaviour)
        PORT MAP (
            CLK_HALF_SEC => half_sec_tick,
            reset => reset,
            request => request,
            letter_length => o_length,
            data => data_out,
            LED => LED,
            busy => register_enable);

END behaviour;
