library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rv_stage_fetch is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           
           i_mem_jump : in std_logic;
           i_mem_jump_addr : in std_logic_vector(31 downto 0);
           
           i_halt : in std_logic;
           i_stall : in std_logic;
           
           o_pcu : out STD_LOGIC_VECTOR (31 downto 0);
           o_instr : out STD_LOGIC_VECTOR (31 downto 0));
end rv_stage_fetch;

architecture Behavioral of rv_stage_fetch is
    signal pcu : std_logic_vector(29 downto 0);
    signal instr : std_logic_vector(31 downto 0);
begin
    PROG_COUNTER : entity work.rv_pcu
    port map(
        i_clk => i_clk,
        i_rst => i_rst,
        
        i_pcu_update => i_mem_jump,
        i_pcu_update_value => i_mem_jump_addr,
        
        o_pcu => pcu
    );
    
    INSTRUCTION_MEMORY : entity work.rv_instr_mem
    port map(
        i_clk => i_clk,
        i_rst => i_rst,
        
        i_halt => i_halt,
        
        i_clear => i_mem_jump,
        
        i_pcu => pcu,
        o_instr => o_instr
    );
    
    -- Without this, the program counter output represents the *next* instruction
    process(i_clk) begin
        if rising_edge(i_clk) then
            if (i_rst or i_mem_jump) = '1' then
                o_pcu <= (others => '0');
            elsif (i_halt or i_stall) = '0' then
                o_pcu <= pcu & "00";
            end if;
        end if;
    end process;

end Behavioral;
