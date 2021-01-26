library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use STD.TEXTIO.ALL;

entity rv_instr_mem is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_halt : in std_logic;
           i_clear : in std_logic;
           i_pcu : in std_logic_vector(29 downto 0);
           o_instr : out std_logic_vector(31 downto 0));
end rv_instr_mem;

architecture Behavioral of rv_instr_mem is

    type memory_t is array(0 to 2048) of std_logic_vector(31 downto 0);

    impure function init_ram_hex(dir : in string) return memory_t is
        file text_file : text open read_mode is dir;
        variable text_line : line;
        variable ram_content : memory_t;
    begin
        for i in memory_t'range loop
            readline(text_file, text_line);
            hread(text_line, ram_content(i));
        end loop;
        return ram_content;
    end function;
    
    signal memory : memory_t := init_ram_hex("./test.txt");
begin
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if (i_rst or i_clear) = '1' then
                o_instr <= (others => '0');
            elsif i_halt = '0' then
                o_instr <= memory(to_integer(unsigned(i_pcu)));
            end if;
        end if;
    end process;

end Behavioral;
