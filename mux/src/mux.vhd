-------------------------------------------------------------------------------
-- Title      : Sequential Multiplexer
-------------------------------------------------------------------------------
-- File       : mux.vhd
-- Author     : Faisal Abu-Nimeh
-- Created    : 20171113
-- Platform   : Generic
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- A Multiplexer with an output that is sequentially selected.
-- Input is registered
-------------------------------------------------------------------------------
-- License:
-- Copyright (c) 2017 SLAC
-- See LICENSE or
-- https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux is
    generic(
        g_dwidth : positive := 12       -- bus width
    );
    port(
        clk_i     : in  std_logic;
        reset_n_i : in  std_logic;
        start_i   : in  std_logic;

        data0_i : in  std_logic_vector(g_dwidth - 1 downto 0);
        data1_i : in  std_logic_vector(g_dwidth - 1 downto 0);
        data2_i : in  std_logic_vector(g_dwidth - 1 downto 0);
        data3_i : in  std_logic_vector(g_dwidth - 1 downto 0);
        data4_i : in  std_logic_vector(g_dwidth - 1 downto 0);
        data5_i : in  std_logic_vector(g_dwidth - 1 downto 0);
        data6_i : in  std_logic_vector(g_dwidth - 1 downto 0);
        data7_i : in  std_logic_vector(g_dwidth - 1 downto 0);

        data_o  : out std_logic_vector(g_dwidth - 1 downto 0)
    );
end entity;

architecture rtl of mux is
    signal s_cnt  : unsigned(2 downto 0);

    signal s_data0 : std_logic_vector(g_dwidth - 1 downto 0);
    signal s_data1 : std_logic_vector(g_dwidth - 1 downto 0);
    signal s_data2 : std_logic_vector(g_dwidth - 1 downto 0);
    signal s_data3 : std_logic_vector(g_dwidth - 1 downto 0);
    signal s_data4 : std_logic_vector(g_dwidth - 1 downto 0);
    signal s_data5 : std_logic_vector(g_dwidth - 1 downto 0);
    signal s_data6 : std_logic_vector(g_dwidth - 1 downto 0);
    signal s_data7 : std_logic_vector(g_dwidth - 1 downto 0);

begin

    data_o <= s_data0 when s_cnt = "000" else
              s_data1 when s_cnt = "001" else
              s_data2 when s_cnt = "010" else
              s_data3 when s_cnt = "011" else
              s_data4 when s_cnt = "100" else
              s_data5 when s_cnt = "101" else
              s_data6 when s_cnt = "110" else
              s_data7 when s_cnt = "111";

    -- sequence generator
    process(clk_i, reset_n_i)
    begin
        if reset_n_i = '0' then
            s_cnt <= (others => '0');

            s_data0 <= (others => '0');
            s_data1 <= (others => '0');
            s_data2 <= (others => '0');
            s_data3 <= (others => '0');
            s_data4 <= (others => '0');
            s_data5 <= (others => '0');
            s_data6 <= (others => '0');
            s_data7 <= (others => '0');

        elsif rising_edge(clk_i) then
            s_cnt <= s_cnt + 1; -- will wrap around
            -- adc data is gauranteed to be stable at this point
            s_data0 <= data0_i;
            s_data1 <= data1_i;
            s_data2 <= data2_i;
            s_data3 <= data3_i;
            s_data4 <= data4_i;
            s_data5 <= data5_i;
            s_data6 <= data6_i;
            s_data7 <= data7_i;

            if start_i = '0' then
                s_cnt <= (others => '0');
            end if;
        end if;
    end process;
end rtl;
