library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity rv_pcu is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_pcu_update : in STD_LOGIC;
           i_pcu_update_value : in STD_LOGIC_VECTOR (31 downto 0);
           o_pcu : out STD_LOGIC_VECTOR (29 downto 0));
end rv_pcu;

architecture Behavioral of rv_pcu is
    signal pcu : std_logic_vector(29 downto 0);
begin
    
    o_pcu <= pcu;
    
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                pcu <= (others => '0');
            else
                if i_pcu_update = '1' then
                    pcu <= i_pcu_update_value(31 downto 2);
                else
                    pcu <= pcu + '1';
                end if;
            end if;
        end if;
    end process;

end Behavioral;
