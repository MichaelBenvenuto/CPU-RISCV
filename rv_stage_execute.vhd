----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/13/2021 05:32:47 PM
-- Design Name: 
-- Module Name: rv_stage_execute - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.cpu_lib.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rv_stage_execute is
  Port ( 
    i_clk : in std_logic;
    i_rst : in std_logic;
    
    i_aluop : in aluop_t;
    
    i_stall : in std_logic;
    
    o_halt : out std_logic;
    
    i_regrd : in std_logic;
    i_jump : in jump_t;
    o_regrd : out std_logic;
    o_jump : out jump_t;
    
    i_clear : in std_logic;
    
    i_instr : in std_logic_vector(31 downto 0);
    o_instr : out std_logic_vector(31 downto 0);
    
    i_pcu : in std_logic_vector(31 downto 0);
    o_pcu : out std_logic_vector(31 downto 0);
    
    i_rs1 : in std_logic_vector(31 downto 0);
    i_rs2 : in std_logic_vector(31 downto 0);
    
    i_rs1_forward : in std_logic;
    i_rs1_forward_data : in std_logic_vector(31 downto 0);
    
    i_rs2_forward : in std_logic;
    i_rs2_forward_data : in std_logic_vector(31 downto 0);
    
    i_alu_rs1_src : in alu_rs1_src;
    i_alu_rs2_src : in alu_rs2_src;
    
    o_carry : out std_logic;
    o_zero : out std_logic;
    
    o_mem_addr : out std_logic_vector(31 downto 0);
    o_rs2 : out std_logic_vector(31 downto 0)
  );
end rv_stage_execute;

architecture Behavioral of rv_stage_execute is
    signal alu_a, rs1 : std_logic_vector(31 downto 0);
    signal alu_b, rs2 : std_logic_vector(31 downto 0);
    
    signal immediate : std_logic_vector(31 downto 0);
    
    signal alu_res : std_logic_vector(31 downto 0);
    
    signal carry, zero, alu_carry : std_logic;
begin
    
    o_halt <= '0';
    
    rs1 <= i_rs1_forward_data when i_rs1_forward = '1' else i_rs1;
    rs2 <= i_rs2_forward_data when i_rs2_forward = '1' else i_rs2;
    
    -- All immediates except branches are computed in execute
    process(i_instr)
        variable tmp_imm : std_logic_vector(31 downto 0);
    begin
        case i_instr(6 downto 2) is
            when "01101"|"00101" =>
                tmp_imm(31 downto 12) := i_instr(31 downto 12);
                tmp_imm(11 downto 0) := (others => '0');
            when "00000"|"00100"|"11001" =>
                tmp_imm(11 downto 0) := i_instr(31 downto 20);
                tmp_imm(31 downto 12) := (31 downto 12 => i_instr(31));
            when "01000" =>
                tmp_imm(11 downto 5) := i_instr(31 downto 25);
                tmp_imm(4 downto 0) := i_instr(11 downto 7);
                tmp_imm(31 downto 12) := (31 downto 12 => i_instr(31));
            when "11011" =>
                tmp_imm(31 downto 21) := (31 downto 21 => i_instr(31));
                tmp_imm(20) := i_instr(31);
                tmp_imm(10 downto 1) := i_instr(30 downto 21);
                tmp_imm(11) := i_instr(20);
                tmp_imm(0) := '0';
                tmp_imm(19 downto 12) := i_instr(19 downto 12);
            when others =>
                tmp_imm := (others => '-');
        end case;
        immediate <= tmp_imm;
    end process;
    
    process(i_clk) begin
        if rising_edge(i_clk) then
            if (i_rst or i_clear) = '1' then
                o_instr <= (others => '0');
                o_pcu <= (others => '0');
                o_mem_addr <= (others => '0');
                o_rs2 <= (others => '0');
                o_carry <= '0';
                o_zero <= '0';
                o_jump <= NONE;
                o_regrd <= '0';
            elsif i_stall = '0' then
                o_instr <= i_instr;
                o_pcu <= i_pcu;
                o_mem_addr <= alu_res;
                o_rs2 <= i_rs2;
                o_carry <= alu_carry;
                o_zero <= zero;
                
                o_jump <= i_jump;
                o_regrd <= i_regrd;
            end if;
        end if;
    end process;

    with i_alu_rs1_src select alu_a <=
        rs1 when REG,
        i_pcu when PCU,
        (others => '0') when others;
        
    with i_alu_rs2_src select alu_b <=
        rs2 when REG,
        not rs2 when REG_COMP,
        (5 to 31 => '0') & immediate(4 downto 0) when SHAMT,
        immediate when others;
        
    carry <= '1' when i_alu_rs2_src = REG_COMP else '0';
    
    GEN_ALU : entity work.rv_alu
    port map(
        i_aluop => i_aluop,
        
        i_carry => carry,
        
        i_rs1 => alu_a,
        i_rs2 => alu_b,
        
        o_alu_res => alu_res,
        
        o_zero => zero,
        o_carry => alu_carry
    );

end Behavioral;