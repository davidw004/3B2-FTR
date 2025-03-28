library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY morse_FSM IS
    PORT (
        CLK_HALF_SEC: IN std_logic; -- half sec tick
        reset       : IN std_logic; -- KEY 0
        request     : IN std_logic; -- Asynchronous enter LOAD state, wait for half sec tick
		  letter_length: IN integer range 0 to 11;  -- letter_length from register
        data        : IN STD_LOGIC_VECTOR(10 downto 0);
        busy        : OUT std_logic;
        LED         : OUT std_logic
        );
END morse_FSM;

ARCHITECTURE behaviour OF morse_FSM IS
    
    -- State transition stuff:
    -- State type declaration
    type state_type is (IDLE, LOAD, DISPLAY);
    signal state : state_type; --Set to idle

    -- Internal counters
    signal symbol_count : integer; -- To track which symbol we're displaying
    signal current_length : integer; -- To track remaining symbols
    -- Signal to enable registers and counters
    signal busy_signal : std_logic := '0';

begin

    -- Next state and output logic
    fsm_logic: process(CLK_HALF_SEC, reset, request)
    begin
        if reset = '0' then
            state           <= IDLE;
            symbol_count    <= 0;
            current_length  <= 0;
            LED             <= '0';
            busy_signal     <= '0';
				
        elsif state = IDLE then
            if request = '0' then
                state <= LOAD;
                busy_signal <= '1';
            else
                state <= IDLE;
            end if;
            
        elsif rising_edge(CLK_HALF_SEC) then
            case state is
                when IDLE =>
							if request = '0' then
                        state <= LOAD;
                        busy_signal <= '1';
                    end if;
                    LED <= '0';
                
					 when LOAD => -- not taking a full cycle to reach here since start time not 25000000
                    current_length <= letter_length;
                    symbol_count <= 0;
                    state <= DISPLAY; 
                    -- Wait for register to be loaded and start on the next CLK rising edge
                
                when DISPLAY =>
                    if data(symbol_count) = '1' then
                        LED <= '1';
                    else 
                        LED <= '0';
                    end if;
						  
                    -- Move to next symbol
                    symbol_count <= symbol_count + 1;

                    -- Decrementletter_length counter
                    current_length <= current_length - 1;

                    if current_length = 0 then
                        state <= IDLE;
								busy_signal <= '0';
                    else 
                        state <= DISPLAY;
                    end if;
            end case;
        end if;
    end process;
    busy <= busy_signal; --mirror busy signal
end behaviour;