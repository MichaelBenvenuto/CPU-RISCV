library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package cpu_lib is

    type jump_t is (CONDITIONAL, INDIRECT, UNCONDITIONAL, NONE);
    type aluop_t is (OP_ADD, OP_XOR, OP_OR, OP_AND, OP_SRA, OP_SRL, OP_SLL);
    
    type alu_rs1_src is (REG, PCU, NUL);
    type alu_rs2_src is (REG, REG_COMP, IMM, SHAMT);
    
    subtype funct7 is natural range 31 downto 25;
    subtype rs2 is natural range 24 downto 20;
    subtype rs1 is natural range 19 downto 15;
    subtype funct3 is natural range 14 downto 12;
    subtype rd is natural range 11 downto 7;
    subtype opcode is natural range 6 downto 0;
    subtype imm12_i is natural range 31 downto 20;
    subtype imm20_u is natural range 31 downto 12;

end package cpu_lib;