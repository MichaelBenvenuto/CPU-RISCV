library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

-- Simple top-level test that outputs data bus writes to the onboard LEDs

entity test_top is
    Port ( 
    i_clk : in std_logic;
    i_rst : in std_logic;
    
    o_leds : out std_logic_vector(15 downto 0));
end test_top;

architecture Behavioral of test_top is
    signal mem_data : std_logic_vector(31 downto 0);
    signal ctr : std_logic_vector(25 downto 0) := (others => '0');
    signal rst, mem_wr, clk : std_logic := '0';
begin
    rst <= not i_rst;
    CPU : entity work.rv_cpu
    port map(
        i_clk => i_clk,
        i_rst => rst,
        
        o_mem_data => mem_data,
        o_mem_write_req => mem_wr,
        
        i_mem_data => (others => '0'),
        i_mem_ack => '1'
    );
    
    -- For now, we dont care about the address
    process(i_clk) begin
        if rising_edge(i_clk) then
            if rst = '1' then
                o_leds <= (others => '0');
            else
                if mem_wr = '1' then
                    o_leds <= mem_data(15 downto 0);
                end if;
            end if;
        end if;
    end process;

end Behavioral;
