-------------------------------------------------------------------------------
-- Title      : clock generator testbench
-------------------------------------------------------------------------------
-- File       : clkdiv_tb.vhd
-- Author     : Faisal Abu-Nimeh
-- Created    : 20171115
-- Platform   : Generic
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- tests if the divider correctly generates desired clocks
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

entity clkgen_tb is
     -- desired divider
end entity;

architecture arch of clkgen_tb is
    constant c_clk_period : time := 2 ns; -- 500 MHz

    signal s_clk   : std_logic;
    signal s_rst   : std_logic;
    signal s_rst_n : std_logic;

    signal s_clk7_o : std_logic;
    signal s_clk4_o : std_logic;
    signal s_pulse_o : std_logic;

    component clkgen is
        port(
        clk_i   : in  std_logic; -- master clock, typically 448MHz
        reset_n_i : in  std_logic;
        clk4_o   : out std_logic; -- divide clk_i by 4
        pulse4_o   : out std_logic;
        clk7_o   : out std_logic -- divide clk_i by 7
        );
    end component;

    -- start here
begin
    divit : clkgen
        port map(
            clk_i   => s_clk,
            reset_n_i => s_rst_n,
            clk4_o  => s_clk4_o,
            pulse4_o  => s_pulse_o,
            clk7_o  => s_clk7_o
        );

    -- generate clock for testbench
    p_clk_gen : process
    begin
        s_clk <= '0';
        wait for c_clk_period / 2;
        s_clk <= '1';
        wait for c_clk_period / 2;
    end process p_clk_gen;

    -- generate reset for testbench
    p_rst_gen : process
    begin
        s_rst   <= '1';
        s_rst_n <= '0';
        wait for 10 * c_clk_period;     -- hold rest for 10 clock periods
        wait until s_clk = '1';
        s_rst   <= '0';
        s_rst_n <= '1';
        wait;
    end process p_rst_gen;
end;
