library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.cpu_lib.all;

-- Addition, Shifts, AND and OR are only implemented because most RV32I arith ops can be implemented using just these
-- XOR = (NOT rs1 AND rs2) and (rs1 OR rs2);
-- SUB = (rs1 + (-rs2))
-- SLT = SUB(31)
-- SLTU = carry

entity rv_alu is
  Port ( 
    i_aluop : in aluop_t;
    
    i_carry : in std_logic;
    
    i_rs1 : in std_logic_vector(31 downto 0);
    i_rs2 : in std_logic_vector(31 downto 0);
    
    o_alu_res : out std_logic_vector(31 downto 0);
    
    o_zero : out std_logic;
    o_carry : out std_logic
  );
end rv_alu;

architecture Behavioral of rv_alu is
    signal alu_res : std_logic_vector(32 downto 0);
begin
    
    o_alu_res <= alu_res(31 downto 0);
    o_zero <= '1' when alu_res(31 downto 0) = x"00000000" else '0';
    o_carry <= alu_res(32);

    process(i_aluop, i_rs1, i_rs2, i_carry) begin
        case i_aluop is
            when OP_ADD =>
                alu_res <= ('0' & i_rs1) + ('0' & i_rs2) + i_carry;
            when OP_XOR =>
                alu_res <= '0' & (i_rs1 xor i_rs2);
            when OP_OR =>
                alu_res <= '0' & (i_rs1 or i_rs2);
            when OP_AND =>
                alu_res <= '0' & (i_rs1 and i_rs2);
            when OP_SRA =>
                alu_res <= '0' & std_logic_vector(shift_right(signed(i_rs1), to_integer(unsigned(i_rs2))));
            when OP_SRL =>
                alu_res <= '0' & std_logic_vector(shift_right(unsigned(i_rs1), to_integer(unsigned(i_rs2))));
            when OP_SLL =>
                alu_res <= '0' & std_logic_vector(shift_left(unsigned(i_rs1), to_integer(unsigned(i_rs2))));
        end case;
    end process;
end Behavioral;
