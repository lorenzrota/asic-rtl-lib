-------------------------------------------------------------------------------
-- Title      : mux testbench
-------------------------------------------------------------------------------
-- File       : mux_tb.vhd
-- Author     : Faisal Abu-Nimeh
-- Created    : 20171109
-- Platform   : Generic
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- Reads a bit stream from a text file then 14b12bdecodes it.
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
-- file io
use ieee.std_logic_textio.all;
use std.textio.all;

entity mux_tb is
    generic(g_dwidth : positive := 12); -- Encoded data width
end entity;

architecture arch of mux_tb is
    constant c_clk_period : time := 2 ns;


    signal s_clk   : std_logic;
    signal s_rst   : std_logic;
    signal s_rst_n : std_logic;

    signal s_clk_start : std_logic := '0';
    signal s_start : std_logic;

    -- cnt samples from file

    signal s_data_o : std_logic_vector(g_dwidth - 1 downto 0);

    component mux is
        generic(g_dwidth : positive);
        port(
            clk_i   : in  std_logic;
            reset_n_i : in  std_logic;
            start_i : in  std_logic;

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
    end component;

    -- start here
begin
    mm : mux
        generic map(g_dwidth => g_dwidth)
        port map(
            clk_i   => s_clk,
            reset_n_i => s_rst_n,
            start_i => s_start,
            data0_i  => x"008",
            data1_i  => x"009",
            data2_i  => x"00A",
            data3_i  => x"00B",
            data4_i  => x"00C",
            data5_i  => x"00D",
            data6_i  => x"00E",
            data7_i  => x"00F",
            data_o  => s_data_o
        );

    -- generate clock for testbench
    p_clk_gen : process
    begin
        s_clk <= '0';
        if s_clk_start = '0' then
            wait for c_clk_period / 2;
            s_clk_start <= '1';
        end if;
        wait for c_clk_period / 2;
        s_clk <= '1';
        wait for c_clk_period / 2;
    end process p_clk_gen;

    -- generate reset for testbench
    p_rst_gen : process
    begin
        s_start   <= '0';
        s_rst   <= '1';
        s_rst_n <= '0';
        wait for 10 * c_clk_period;     -- hold rest for 10 clock periods
        wait until s_clk = '0';
        s_rst   <= '0';
        s_rst_n <= '1';
        wait until s_clk = '1';
        s_start <= '1';
        wait;
    end process p_rst_gen;
end;
