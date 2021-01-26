library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rv_forward is
  Port ( 
    i_ex_rs1 : in std_logic_vector(4 downto 0);
    i_ex_rs2 : in std_logic_vector(4 downto 0);
    o_ex_rs1_forward : out std_logic;
    o_ex_rs2_forward : out std_logic;
    o_ex_rs1_data : out std_logic_vector(31 downto 0);
    o_ex_rs2_data : out std_logic_vector(31 downto 0);
    
    i_mem1_rs2 : in std_logic_vector(4 downto 0);
    o_mem1_rs2_forward : out std_logic;
    o_mem1_rs2_data : out std_logic_vector(31 downto 0);
    
    i_mem1_regrd : in std_logic;
    i_mem1_rd : in std_logic_vector(4 downto 0);
    i_mem1_rd_data : in std_logic_vector(31 downto 0);
    
    i_mem2_regrd : in std_logic;
    i_mem2_rd : in std_logic_vector(4 downto 0);
    i_mem2_rd_data : in std_logic_vector(31 downto 0);
    
    i_wb_regrd : in std_logic;
    i_wb_rd : in std_logic_vector(4 downto 0);
    i_wb_rd_data : in std_logic_vector(31 downto 0)
  );
end rv_forward;

architecture Behavioral of rv_forward is

begin
        
    process(i_ex_rs1, i_mem1_rd, i_mem2_rd, i_wb_rd, i_ex_rs2, i_mem1_rs2, i_mem1_regrd, i_mem2_regrd, i_wb_regrd, i_mem1_rd_data, i_mem2_rd_data, i_wb_rd_data) begin
        o_ex_rs1_data <= (others => '-');
        o_ex_rs2_data <= (others => '-');
        o_mem1_rs2_data <= (others => '-');
        
        if i_ex_rs1 = "00000" then
            o_ex_rs1_forward <= '0';
        elsif i_ex_rs1 = i_mem1_rd then
            o_ex_rs1_forward <= i_mem1_regrd;
            o_ex_rs1_data <= i_mem1_rd_data;
        elsif i_ex_rs1 = i_mem2_rd then
            o_ex_rs1_forward <= i_mem2_regrd;
            o_ex_rs1_data <= i_mem2_rd_data;
        elsif i_ex_rs1 = i_wb_rd then
            o_ex_rs1_forward <= i_wb_regrd;
            o_ex_rs1_data <= i_wb_rd_data;
        else
            o_ex_rs1_forward <= '0';
        end if;
        
        if i_ex_rs2 = "00000" then
            o_ex_rs2_forward <= '0';
        elsif i_ex_rs2 = i_mem1_rd then
            o_ex_rs2_forward <= i_mem1_regrd;
            o_ex_rs2_data <= i_mem1_rd_data;
        elsif i_ex_rs2 = i_mem2_rd then
            o_ex_rs2_forward <= i_mem2_regrd;
            o_ex_rs2_data <= i_mem2_rd_data;
        elsif i_ex_rs1 = i_wb_rd then
            o_ex_rs2_forward <= i_wb_regrd;
            o_ex_rs2_data <= i_wb_rd_data;
        else
            o_ex_rs2_forward <= '0';
        end if;
        
        if i_mem1_rs2 = "00000" then
            o_mem1_rs2_forward <= '0';
        elsif i_mem1_rs2 = i_mem2_rd then
            o_mem1_rs2_forward <= i_mem2_regrd;
            o_mem1_rs2_data <= i_mem2_rd_data;
        elsif i_mem1_rs2 = i_wb_rd then
            o_mem1_rs2_forward <= i_wb_regrd;
            o_mem1_rs2_data <= i_wb_rd_data;
        else
            o_mem1_rs2_forward <= '0';
        end if;
    end process;

end Behavioral;
