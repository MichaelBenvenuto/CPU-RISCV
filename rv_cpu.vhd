library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.cpu_lib.all;

-- Main top level design with generic memory bus.
-- Goal is to interface with Wishbone or AXI depending on the need

entity rv_cpu is
    Port (  i_clk : in STD_LOGIC;
            i_rst : in STD_LOGIC;
           
            o_mem_addr : out std_logic_vector(31 downto 0);
            o_mem_data : out std_logic_vector(31 downto 0);
            o_mem_read_req  : out std_logic;
            o_mem_write_req : out std_logic;
            
            i_mem_data : in std_logic_vector(31 downto 0);
            i_mem_ack : in std_logic);
end rv_cpu;

architecture Behavioral of rv_cpu is
    signal id_pcu, ex_pcu, mem_pcu, wb_pcu, mem_pcu_change_to : std_logic_vector(31 downto 0);
    signal id_instr, ex_instr, mem_instr, wb_instr : std_logic_vector(31 downto 0);
    signal ex_rs1, ex_rs2, mem_addr, mem_data, wb_alu, wb_data : std_logic_vector(31 downto 0);
    signal id_halt, ex_halt, mem_halt : std_logic;
    signal ex_regrd, mem_regrd, wb_regrd, mem_carry, mem_zero, mem_pcu_change : std_logic;
    signal ex_jump, mem_jump : jump_t;
    signal ex_aluop : aluop_t;
    signal ex_alu_rs1_src : alu_rs1_src;
    signal ex_alu_rs2_src : alu_rs2_src;
    
    signal mem2_valid : std_logic;
    signal mem2_rd : std_logic_vector(4 downto 0);
    
    signal wb_id_data : std_logic_vector(31 downto 0);
    
    signal ex_rs1_forward, ex_rs2_forward, mem1_rs2_forward : std_logic;
    signal ex_rs1_forward_data, ex_rs2_forward_data, mem1_rs2_forward_data : std_logic_vector(31 downto 0);
    
    signal stall : std_logic;
begin
    
    with wb_instr(opcode) select wb_id_data <=
        wb_data when "0000011",
        wb_pcu  when "1101111",
        wb_pcu  when "1100111",
        wb_alu when others;
    
    FETCH : entity work.rv_stage_fetch
    port map(
        i_clk => i_clk,
        i_rst => i_rst,
        
        i_stall => stall,
        
        i_halt => id_halt,
        
        i_mem_jump => mem_pcu_change,
        i_mem_jump_addr => mem_pcu_change_to,
        
        o_pcu => id_pcu,
        o_instr => id_instr
    );
    
    DECODE : entity work.rv_stage_decode
    port map(
        i_clk => i_clk,
        i_rst => i_rst,
        
        i_instr => id_instr,
        o_instr => ex_instr,
        
        i_wb_rd => wb_instr(rd),
        i_wb_data => wb_id_data,
        i_wb_regwr => wb_regrd,
        
        i_clear => mem_pcu_change,
        
        i_stall => stall,
        
        i_halt => ex_halt,
        o_halt => id_halt,
        
        i_pcu => id_pcu,
        o_pcu => ex_pcu,
        
        o_rs1 => ex_rs1,
        o_rs2 => ex_rs2,
        
        o_alu_rs1_src => ex_alu_rs1_src,
        o_alu_rs2_src => ex_alu_rs2_src,
        
        o_regrd => ex_regrd,
        o_jump => ex_jump,
        o_aluop => ex_aluop
    );
    
    EXECUTE : entity work.rv_stage_execute
    port map(
        i_clk => i_clk,
        i_rst => i_rst,
        
        i_aluop => ex_aluop,
        
        i_stall => stall,
        
        o_halt => ex_halt,
        
        i_regrd => ex_regrd,
        i_jump => ex_jump,
        o_regrd => mem_regrd,
        o_jump => mem_jump,
        
        i_clear => mem_pcu_change,
        
        i_instr => ex_instr,
        o_instr => mem_instr,
        
        i_pcu => ex_pcu,
        o_pcu => mem_pcu,
        
        i_rs1 => ex_rs1,
        i_rs2 => ex_rs2,
        
        i_rs1_forward => ex_rs1_forward,
        i_rs2_forward => ex_rs2_forward,
        
        i_rs1_forward_data => ex_rs1_forward_data,
        i_rs2_forward_data => ex_rs2_forward_data,
        
        i_alu_rs1_src => ex_alu_rs1_src,
        i_alu_rs2_src => ex_alu_rs2_src,
        
        o_carry => mem_carry,
        o_zero => mem_zero,
        
        o_mem_addr => mem_addr,
        o_rs2 => mem_data
    );
    
    MEMORY : entity work.rv_stage_memory
    port map(
        i_clk => i_clk,
        i_rst => i_rst,
        
        i_stall => stall,
        o_stall => stall,
        
        i_halt => '0', -- Used for additional pipeline stages
        o_halt => mem_halt,
        
        o_pcu_change => mem_pcu_change,
        o_pcu_change_to => mem_pcu_change_to,
        
        i_regrd => mem_regrd,
        o_regrd => wb_regrd,
        
        i_jump => mem_jump,
        
        i_instr => mem_instr,
        o_instr => wb_instr,
        
        i_pcu => mem_pcu,
        o_pcu => wb_pcu,
        
        i_zero => mem_zero,
        i_carry => mem_carry, 
        
        i_mem_addr => mem_addr,
        i_rs2 => mem_data,
        
        i_mem1_rs2_forward => mem1_rs2_forward,
        i_mem1_rs2_forward_data => mem1_rs2_forward_data,
        
        o_mem2_forward_valid => mem2_valid,
        o_mem2_rd => mem2_rd,
        
        o_wb_alu_res => wb_alu,
        o_wb_mem_dat => wb_data,
        
        o_mem_addr => o_mem_addr,
        o_mem_data => o_mem_data,
        o_mem_read_req => o_mem_read_req,
        o_mem_write_req => o_mem_write_req,
        
        i_mem_data => i_mem_data,
        i_mem_ack => i_mem_ack
        
    );
    
    FORWARD : entity work.rv_forward
    port map(
        i_ex_rs1 => ex_instr(rs1),
        i_ex_rs2 => ex_instr(rs2),
        
        i_mem1_rs2 => mem_instr(rs2),
        i_mem1_regrd => mem_regrd,
        i_mem1_rd => mem_instr(rd),
        i_mem1_rd_data => mem_addr,
        
        i_mem2_regrd => mem2_valid,
        i_mem2_rd => mem2_rd,
        i_mem2_rd_data => i_mem_data,
        
        i_wb_regrd => wb_regrd,
        i_wb_rd => wb_instr(rd),
        i_wb_rd_data => wb_id_data,
        
        o_ex_rs1_forward => ex_rs1_forward,
        o_ex_rs2_forward => ex_rs2_forward,
        o_ex_rs1_data => ex_rs1_forward_data,
        o_ex_rs2_data => ex_rs2_forward_data,
        
        o_mem1_rs2_forward => mem1_rs2_forward,
        o_mem1_rs2_data => mem1_rs2_forward_data
    );

end Behavioral;
