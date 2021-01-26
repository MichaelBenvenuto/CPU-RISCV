----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/10/2021 04:23:32 PM
-- Design Name: 
-- Module Name: rv_regfile - Behavioral
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
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity rv_regfile is
    Port (  i_clk : in std_logic;
            i_rst : in std_logic;
            
            i_rs1 : in std_logic_vector(4 downto 0);
            i_rs2 : in std_logic_vector(4 downto 0);
            i_rd : in std_logic_vector(4 downto 0);
            i_rd_data : in std_logic_vector(31 downto 0);
            i_regwr : in std_logic;
            
            o_rs1 : out std_logic_vector(31 downto 0);
            o_rs2 : out std_logic_vector(31 downto 0));
end rv_regfile;

architecture Behavioral of rv_regfile is
    type registers is array(0 to 31) of std_logic_vector(31 downto 0);
    signal regfile : registers := (others => x"00000000");
begin
    process(i_clk) begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                o_rs1 <= (others => '0');
                o_rs2 <= (others => '0');
            else
                if i_regwr = '1' and (i_rd /= "00000") then
                    regfile(to_integer(unsigned(i_rd))) <= i_rd_data;
                end if;
                
                if i_rs1 = i_rd and i_rd /= "00000" then
                    o_rs1 <= i_rd_data;
                else
                    o_rs1 <= regfile(to_integer(unsigned(i_rs1)));
                end if;
                
                if i_rs2 = i_rd and i_rd /= "00000" then
                    o_rs2 <= i_rd_data;
                else
                    o_rs2 <= regfile(to_integer(unsigned(i_rs2)));
                end if;
            end if;
        end if; 
    end process;  
end Behavioral;