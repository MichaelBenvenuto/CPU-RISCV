----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/14/2021 06:10:35 PM
-- Design Name: 
-- Module Name: rv_stage_memory - Behavioral
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
use IEEE.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
use work.cpu_lib.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rv_stage_memory is
  Port ( 
    i_clk : in std_logic;
    i_rst : in std_logic;
    
    i_stall : in std_logic;
    o_stall : out std_logic;
    
    i_halt : in std_logic;
    o_halt : out std_logic;
    
    i_regrd : in std_logic;
    o_regrd : out std_logic;
    
    i_jump : in jump_t;
    
    o_pcu_change : out std_logic;
    o_pcu_change_to : out std_logic_vector(31 downto 0);
    
    i_instr : in std_logic_vector(31 downto 0);
    o_instr : out std_logic_vector(31 downto 0);
    
    i_pcu : in std_logic_vector(31 downto 0);
    o_pcu : out std_logic_vector(31 downto 0);
    
    i_zero : in std_logic;
    i_carry : in std_logic;
    
    i_mem_addr : in std_logic_vector(31 downto 0);
    i_rs2 : in std_logic_vector(31 downto 0);
    
    i_mem1_rs2_forward : in std_logic;
    i_mem1_rs2_forward_data : in std_logic_vector(31 downto 0);
    
    o_mem2_forward_valid : out std_logic;
    o_mem2_rd : out std_logic_vector(4 downto 0);
    
    o_wb_alu_res : out std_logic_vector(31 downto 0);
    o_wb_mem_dat : out std_logic_vector(31 downto 0);
    
    o_mem_addr : out std_logic_vector(31 downto 0);
    o_mem_data : out std_logic_vector(31 downto 0);
    o_mem_read_req  : out std_logic;
    o_mem_write_req : out std_logic;
    
    i_mem_data : in std_logic_vector(31 downto 0);
    i_mem_ack : in std_logic
    );
end rv_stage_memory;

architecture Behavioral of rv_stage_memory is
    signal alu_res, instr, pcu, pcu_change_to : std_logic_vector(31 downto 0);
    signal mem_read_req, mem_read_req_x : std_logic;
    signal regrd : std_logic;
    signal condition : std_logic;
begin
    
    o_mem2_forward_valid <= mem_read_req;
    o_mem2_rd <= instr(rd);
    
    o_mem_addr <= i_mem_addr;
    o_mem_data <= i_mem1_rs2_forward_data when i_mem1_rs2_forward = '1' else i_rs2;
    mem_read_req <= '1' when i_instr(6 downto 0) = "0000011" else '0';
    o_mem_write_req <= '1' when i_instr(6 downto 0) = "0100011" else '0';
    
    o_mem_read_req <= mem_read_req;
    
    o_stall <= (mem_read_req_x and not i_mem_ack);
    
    o_halt <= i_halt;
    
    o_pcu_change <= '1' when i_jump = UNCONDITIONAL or i_jump = INDIRECT else
                    condition when i_jump = CONDITIONAL else '0';
                    
    pcu_change_to <= i_pcu + ((31 downto 13 => i_instr(31)) & i_instr(31) & i_instr(7) & i_instr(30 downto 25) & i_instr(11 downto 8) & '0');
    with i_jump select o_pcu_change_to <=
        i_mem_addr when UNCONDITIONAL,
        i_mem_addr when INDIRECT,
        pcu_change_to when CONDITIONAL,
        (others => '-') when others;
                    
    with i_instr(funct3) select condition <=
        i_zero when "000",
        not i_zero when "001",
        i_mem_addr(31) when "100",
        not i_mem_addr(31) when "101",
        i_carry when "110",
        not i_carry when "111",
        '0' when others;
        

    process(i_clk) begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                alu_res <= (others => '0');
                o_wb_alu_res <= (others => '0');
                
                instr <= (others => '0');
                o_instr <= (others => '0');
                
                pcu <= (others => '0');
                o_pcu <= (others => '0');
                
                mem_read_req_x <= '0';
            elsif (i_halt or i_stall) = '0' then
                alu_res <= i_mem_addr;
                o_wb_alu_res <= alu_res;
                
                regrd <= i_regrd;
                o_regrd <= regrd;
                
                instr <= i_instr;
                o_instr <= instr;
                
                pcu <= i_pcu;
                o_pcu <= pcu;
                
                mem_read_req_x <= mem_read_req;
                
                o_wb_mem_dat <= i_mem_data;
            end if;
        end if;
    end process;

end Behavioral;
