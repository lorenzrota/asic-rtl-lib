-------------------------------------------------------------------------------
-- Title      : 1-to-g_dwidth double data rate deserializer based on a pattern
-------------------------------------------------------------------------------
-- File       : deserializer.vhd
-- Author     : Faisal Abu-Nimeh
-- Created    : 20171113
-- Platform   : Generic
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- Creates a parallel bus from a serial stream
--
-------------------------------------------------------------------------------
-- License:
-- Copyright (c) 2017 SLAC
-- See LICENSE or
-- https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- DDR deserializer
entity deserializer is
    generic(
        g_idle : std_logic_vector := "00" & x"BF8" -- IDLE pattern "00_1011_1111_1000"
    );
    port(
        clk_i   : in  std_logic;
        reset_i : in  std_logic;

        data_i  : in  std_logic;
        data_o  : out  std_logic_vector(g_idle'length-1 downto 0)
    );
end entity;

architecture rtl of deserializer is
    constant c_dwidth : positive := g_idle'length;
    constant c_cnt_width : positive := integer(ceil(log2(real(c_dwidth))));

    signal s_cnt : unsigned(c_cnt_width - 1 downto 0);
    signal s_pdata : std_logic_vector(data_o'range);
    signal s_data_o : std_logic_vector(data_o'range);

    signal s_deser_valid : std_logic; -- just a visual. has no other use
    signal s_aligned : std_logic;

begin
    -- show deser value immediately
    -- keep it til next valid output
    data_o <= s_pdata when s_cnt = (c_dwidth - 1) else s_data_o;

    -- deserializer and aligner process
    deserialize : process(clk_i, reset_i)
    begin
        if reset_i = '1' then
            s_pdata       <= (others => '0');
            s_cnt <= (others => '0');
            s_deser_valid <= '0';
            s_data_o  <= (others => '0');
            s_aligned     <= '0';
        elsif rising_edge(clk_i) then
            -- right shift i.e. LSB 1st
            s_pdata       <= data_i & s_pdata(c_dwidth - 1 downto 1);
            s_deser_valid <= '0';

            if s_aligned = '1' then
                -- incr counter
                s_cnt <= s_cnt + 1;
                if s_cnt >= (c_dwidth - 1) then
                    s_cnt <= (others => '0');
                    s_deser_valid <= '1'; -- deserialization completed
                    s_data_o  <= s_pdata; -- feed decoder good data
                end if;
            else
                -- look for idle pattern
                if s_pdata = g_idle or s_pdata = not g_idle then
                    s_aligned     <= '1';
                    s_cnt <= (others => '0'); -- now we can count properly
                    s_data_o  <= s_pdata; -- feed decoder good data
                end if;
            end if;
        end if;
    end process;

end rtl;
