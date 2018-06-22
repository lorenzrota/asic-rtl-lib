-------------------------------------------------------------------------------
-- Title      : clock divider testbench
-------------------------------------------------------------------------------
-- File       : clkdiv_tb.vhd
-- Author     : Faisal Abu-Nimeh
-- Created    : 20171114
-- Platform   : Generic
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- tests if the divider correctly generates desired clock
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

entity clkdiv_tb is
    generic(
    g_div : positive := 7;
    g_pol : std_logic := '1'
    ); -- desired divider
end entity;

architecture arch of clkdiv_tb is
    constant c_clk_period : time := 2 ns; -- 500 MHz

    signal s_clk   : std_logic;
    signal s_rst   : std_logic;
    signal s_rst_n : std_logic;

    signal s_clk_o : std_logic;

    component clkdiv is
        generic(
            g_div : positive;
            g_pol : std_logic
        );
        port(
            clk_i   : in  std_logic;
            reset_n_i : in  std_logic;
            clk_o   : out std_logic
        );
    end component;

    -- start here
begin
    divit : clkdiv
        generic map(
        g_div => g_div,
        g_pol => g_pol
        )
        port map(
            clk_i   => s_clk,
            reset_n_i => s_rst_n,
            clk_o  => s_clk_o
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
