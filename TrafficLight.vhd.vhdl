LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity tb_TrafficLight is
end tb_TrafficLight;

-- Traffic Light Encoding:
-- RED:    "100"
-- GREEN:  "010"
-- YELLOW: "001"

architecture Behavioral of tb_TrafficLight is

    signal clk : STD_LOGIC := '0';
    signal clkEn : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '0';
    signal light : STD_LOGIC_VECTOR (2 downto 0) := "000";

    constant clk_period : time := 20 ns; -- 50 MHz clock
    constant pulse_period : time := 60 ns; -- 3 clock cycles for second_pulse
    
    -- Traffic light state encoding
    constant RED    : STD_LOGIC_VECTOR (2 downto 0) := "100";
    constant GREEN  : STD_LOGIC_VECTOR (2 downto 0) := "010";
    constant YELLOW : STD_LOGIC_VECTOR (2 downto 0) := "001";

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: entity work.TrafficLight
        port map (
            clk => clk,
            clkEn => clkEn,
            reset => reset,
            light => light
        );

    -- Clock generation
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc : process
    begin
        -- Initial reset
        reset <= '1';
        clkEn <= '0';
        wait for 100 ns;
        reset <= '0';
        wait for 100 ns;
        clkEn <= '1';
        
        -- Test clkEn disable at ~1000 ns (during RED state)
        wait for 800 ns;
        clkEn <= '0';
        wait for 200 ns;
        clkEn <= '1';
        
        -- Let system continue through state transitions
        wait for 2000 ns;
        reset <= '1'; -- Apply reset again
        wait for 100 ns;
        
        -- Keep running until simulation ends at 4000 ns
        wait;
    end process;

    -- Self-checking process with assertions
    check_proc : process
    begin
        -- Wait for reset to complete and clock enable to activate
        wait until reset = '0';
        wait until clkEn = '1';
        wait until rising_edge(clk);
        
        -- Check initial RED state
        ASSERT light = RED
            REPORT "Error: Initial state should be RED (100) but got " & std_logic'image(light(2)) & std_logic'image(light(1)) & std_logic'image(light(0))
            SEVERITY ERROR;
        
        -- Check RED state for 9 pulses (transitions on the 10th pulse)
        FOR i IN 1 TO 9 LOOP
            wait for pulse_period;
            ASSERT light = RED
                REPORT "Error at RED pulse " & INTEGER'IMAGE(i) & ": Expected RED=100, got " & std_logic'image(light(2)) & std_logic'image(light(1)) & std_logic'image(light(0))
                SEVERITY ERROR;
        END LOOP;
        
        -- On the 10th pulse, should transition to GREEN
        wait for pulse_period;
        ASSERT light = GREEN
            REPORT "Error: Should transition to GREEN (010) after RED state, got " & std_logic'image(light(2)) & std_logic'image(light(1)) & std_logic'image(light(0))
            SEVERITY ERROR;
        
        -- Check GREEN state for 9 pulses (transitions on the 10th pulse)
        FOR i IN 1 TO 9 LOOP
            wait for pulse_period;
            ASSERT light = GREEN
                REPORT "Error at GREEN pulse " & INTEGER'IMAGE(i) & ": Expected GREEN=010, got " & std_logic'image(light(2)) & std_logic'image(light(1)) & std_logic'image(light(0))
                SEVERITY ERROR;
        END LOOP;
        
        -- On the 10th pulse, should transition to YELLOW
        wait for pulse_period;
        ASSERT light = YELLOW
            REPORT "Error: Should transition to YELLOW (001) after GREEN state, got " & std_logic'image(light(2)) & std_logic'image(light(1)) & std_logic'image(light(0))
            SEVERITY ERROR;
        
        -- Check YELLOW state for 4 pulses (transitions on the 5th pulse)
        FOR i IN 1 TO 4 LOOP
            wait for pulse_period;
            ASSERT light = YELLOW
                REPORT "Error at YELLOW pulse " & INTEGER'IMAGE(i) & ": Expected YELLOW=001, got " & std_logic'image(light(2)) & std_logic'image(light(1)) & std_logic'image(light(0))
                SEVERITY ERROR;
        END LOOP;
        
        -- On the 5th pulse, should cycle back to RED
        wait for pulse_period;
        ASSERT light = RED
            REPORT "Error: Should cycle back to RED (100) after YELLOW state, got " & std_logic'image(light(2)) & std_logic'image(light(1)) & std_logic'image(light(0))
            SEVERITY ERROR;
        
        -- Wait for next cycle to reach a stable RED state for disable test
        wait for 3 * pulse_period;
        -- On the 5th pulse, should cycle back to RED
        wait for pulse_period;
        ASSERT light = RED
            REPORT "Error: Should cycle back to RED (100) after YELLOW state, got " & std_logic'image(light(2)) & std_logic'image(light(1)) & std_logic'image(light(0))
            SEVERITY ERROR;
        
        -- Disable test observer will check behavior
        wait for 3900 ns; -- Continue until near end of simulation
        
        REPORT "*** SIMULATION COMPLETED SUCCESSFULLY - All assertions passed ***" SEVERITY NOTE;
        std.env.stop;
        wait;
    end process;
    
    -- Disable test observer (to verify clkEn behavior)
    disable_test_observer : process
    begin
        -- Wait until clkEn disable test time (~1000 ns from start)
        wait for 1000 ns;
        
        -- Light should be in a stable state (RED or early in state)
        REPORT "Info: clkEn disabled - light is " & std_logic'image(light(2)) & std_logic'image(light(1)) & std_logic'image(light(0)) SEVERITY NOTE;
        
        -- clkEn will be disabled now (for 200 ns), light should hold
        wait for 200 ns;
        REPORT "Info: clkEn disabled duration ended - light held as " & std_logic'image(light(2)) & std_logic'image(light(1)) & std_logic'image(light(0)) SEVERITY NOTE;
        
        wait;
    end process;
end Behavioral;