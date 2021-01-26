library IEEE;
use IEEE.std_logic_1164.all;
use work.cpu_lib.all;

entity rv_stage_decode is
    Port (  i_clk : in std_logic;
            i_rst : in std_logic;
            
            i_instr : in std_logic_vector(31 downto 0);
            o_instr : out std_logic_vector(31 downto 0);
            
            i_wb_rd : in std_logic_vector(4 downto 0);
            i_wb_data : in std_logic_vector(31 downto 0);
            i_wb_regwr : in std_logic;
            
            i_clear : in std_logic;
            
            i_stall : in std_logic;
            
            i_halt : in std_logic;
            o_halt : out std_logic;
            
            i_pcu : in std_logic_vector(31 downto 0);
            o_pcu : out std_logic_vector(31 downto 0);
            
            o_rs1 : out std_logic_vector(31 downto 0);
            o_rs2 : out std_logic_vector(31 downto 0);
            
            o_alu_rs1_src : out alu_rs1_src;
            o_alu_rs2_src : out alu_rs2_src;
            
            o_regrd : out std_logic;
            o_jump : out jump_t;
            o_aluop : out aluop_t);
end rv_stage_decode;

architecture Behavioral of rv_stage_decode is
    signal regrd : std_logic;
    signal jump : jump_t;
    signal aluop : aluop_t;
    signal bubble : std_logic;
    signal alu_rs1 : alu_rs1_src;
    signal alu_rs2 : alu_rs2_src;
begin

    o_halt <= i_halt or bubble;

    REGISTER_FILE : entity work.rv_regfile
    port map(
        i_clk => i_clk,
        i_rst => i_rst,
        
        i_rs1 => i_instr(rs1),
        i_rs2 => i_instr(rs2),
        i_rd => i_wb_rd,
        i_rd_data => i_wb_data,
        i_regwr => i_wb_regwr,
        
        o_rs1 => o_rs1,
        o_rs2 => o_rs2
    );
    
    CONTROL_UNIT : entity work.rv_control
    port map(
        i_opcode => i_instr(6 downto 0),
        i_funct3 => i_instr(funct3),
        i_funct7 => i_instr(funct7),
        
        o_alu_rs1_src => alu_rs1,
        o_alu_rs2_src => alu_rs2,
        
        o_regrd => regrd,
        o_bubble => bubble,
        o_jump => jump,
        o_aluop => aluop
    );
    
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if (i_rst or bubble or i_clear) = '1' then
                o_regrd <= '0';
                o_jump <= NONE;
                o_aluop <= OP_ADD;
                o_pcu <= (others => '0');
                o_instr <= (others => '0');
                o_alu_rs1_src <= REG;
                o_alu_rs1_src <= REG;
            elsif (i_halt or i_stall) = '0' then
                o_regrd <= regrd;
                o_jump <= jump;
                o_aluop <= aluop;
                o_pcu <= i_pcu;
                o_instr <= i_instr;
                o_alu_rs1_src <= alu_rs1;
                o_alu_rs2_src <= alu_rs2;
            end if;
        end if;
    end process;


end Behavioral;
