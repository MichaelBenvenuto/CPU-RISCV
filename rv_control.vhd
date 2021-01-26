library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.cpu_lib.all;

entity rv_control is
    Port ( 
        i_opcode : in std_logic_vector(6 downto 0);
        i_funct3 : in std_logic_vector(2 downto 0);
        i_funct7 : in std_logic_vector(6 downto 0);
        
        o_regrd : out std_logic;
        o_bubble : out std_logic;
        o_jump : out jump_t;
        
        o_alu_rs1_src : out alu_rs1_src;
        o_alu_rs2_src : out alu_rs2_src;
        
        o_aluop : out aluop_t);
end rv_control;

architecture Behavioral of rv_control is
begin

    process(i_opcode) begin
        case i_opcode is
            when "0000011" =>
                o_regrd <= '1';
                o_jump <= NONE;
                o_bubble <= '1';
            when "1101111" =>
                o_regrd <= '1';
                o_jump <= UNCONDITIONAL;
                o_bubble <= '0';
            when "1100111" =>
                o_regrd <= '1';
                o_jump <= INDIRECT;
                o_bubble <= '0';
            when "1100011" =>
                o_regrd <= '0';
                o_jump <= CONDITIONAL;
                o_bubble <= '0';
            when "0100011" =>
                o_regrd <= '0';
                o_jump <= NONE;
                o_bubble <= '0';
            when "0001111" =>
                o_regrd <= '0';
                o_jump <= NONE;
                o_bubble <= '0';
            when "1110011" =>
                o_regrd <= '0';
                o_jump <= NONE;
                o_bubble <= '0';
            when others =>
                o_regrd <= '1';
                o_jump <= NONE;
                o_bubble <= '0';
        end case;
    end process;
    
    process(i_opcode, i_funct3, i_funct7) begin
        case i_opcode is
            when "0010011"|"0110011" =>
                o_alu_rs1_src <= REG;
                if i_opcode(5) = '1' then
                    o_alu_rs2_src <= REG;
                    if i_funct7 = "0100000" then
                        o_alu_rs2_src <= REG_COMP;
                    end if;
                else
                    o_alu_rs2_src <= IMM;
                    if i_funct3 = "001" or i_funct3 = "101" then
                        o_alu_rs2_src <= SHAMT;
                    end if;
                end if;
                case i_funct3 is
                    when "001" =>
                        o_aluop <= OP_SLL;
                    when "101" =>
                        o_aluop <= OP_SRL;
                        if i_funct7 = "0100000" then
                            o_aluop <= OP_SRA;
                        end if;
                    when "100" =>
                        o_aluop <= OP_XOR;
                    when "110" =>
                        o_aluop <= OP_OR;
                    when others =>
                        o_aluop <= OP_ADD;
                end case;
            when "0110111" =>
                o_aluop <= OP_ADD;
                o_alu_rs2_src <= IMM;
                o_alu_rs1_src <= NUL;
            when "1100111" =>
                o_aluop <= OP_ADD;
                o_alu_rs1_src <= REG;
                o_alu_rs2_src <= IMM;
            when "1101111" =>
                o_aluop <= OP_ADD;
                o_alu_rs1_src <= PCU;
                o_alu_rs2_src <= IMM;
            when "1100011" =>
                o_aluop <= OP_ADD;
                o_alu_rs1_src <= REG;
                o_alu_rs2_src <= REG_COMP;
            when "0010111" =>
                o_aluop <= OP_ADD;
                o_alu_rs2_src <= IMM;
                o_alu_rs1_src <= PCU;
            when "0000011"|"0100011" =>
                o_aluop <= OP_ADD;
                o_alu_rs1_src <= REG;
                o_alu_rs2_src <= IMM;
            when others =>
                o_aluop <= OP_ADD;
                o_alu_rs1_src <= REG;
                o_alu_rs2_src <= REG;
        end case;
    end process;

end Behavioral;
