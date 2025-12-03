library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TrafficLight is
    Port ( clk : in STD_LOGIC;
           clkEn : in STD_LOGIC;
           reset : in STD_LOGIC;
           light : out STD_LOGIC_VECTOR (2 downto 0));
end TrafficLight;

architecture Behavioral of TrafficLight is
    type state_type is (RED, GREEN, YELLOW);
    signal current_state : state_type := RED;
    signal counter : integer := 0;
    constant freq : integer := 3; -- Clock frequency divider
    signal clkCounter : integer := 0;
    signal second_pulse : STD_LOGIC := '0';

begin
    -- Sequential process: state transitions and counter
    process(second_pulse, reset)
    begin
        if reset = '1' then
            current_state <= RED;
            counter <= 0;
        elsif rising_edge(second_pulse) then
            if clkEn = '1' then
                case current_state is
                    when RED =>
                        if counter >= 9 then
                            current_state <= GREEN;
                            counter <= 0;
                        else
                            counter <= counter + 1;
                        end if;
                    when GREEN =>
                        if counter >= 9 then
                            current_state <= YELLOW;
                            counter <= 0;
                        else
                            counter <= counter + 1;
                        end if;
                    when YELLOW =>
                        if counter >= 4 then
                            current_state <= RED;
                            counter <= 0;
                        else
                            counter <= counter + 1;
                        end if;
                end case;
            end if;
        end if;
    end process;

    -- Combinational process: output assignment only
    process(current_state)
    begin
        case current_state is
            when RED =>
                light <= "100"; -- Red light on
            when GREEN =>
                light <= "010"; -- Green light on
            when YELLOW =>
                light <= "001"; -- Yellow light on
        end case;
    end process;

    process(clk)
    begin
        if (clkEn = '1') then
            if rising_edge(clk) then
                if clkCounter = freq - 1 then
                    clkCounter <= 0;
                    second_pulse <= '1';
                else
                    clkCounter <= clkCounter + 1;
                    second_pulse <= '0';
                end if;
            end if;
        end if;
    end process;

end Behavioral;