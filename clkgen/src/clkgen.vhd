-------------------------------------------------------------------------------
-- Title      : Cryo Clk Generator
-------------------------------------------------------------------------------
-- File       : clkgen.vhd
-- Author     : Faisal Abu-Nimeh
-- Created    : 20171115
-- Platform   : Generic
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- Generates two divided clocks from master clock
--
-------------------------------------------------------------------------------
-- License:
-- Copyright (c) 2017 SLAC
-- See LICENSE or
-- https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity clkgen is
    port(
        clk_i   : in  std_logic; -- master clock, typically 448MHz

        reset_n_i : in  std_logic;
        clk4_o   : out std_logic; -- divide clk_i by 4
        pulse4_o   : out std_logic; -- clk4_o pulse every 14 tics
        clk7_o   : out std_logic -- divide clk_i by 7
    );
end entity;

architecture rtl of clkgen is
    signal s_clk4: std_logic;

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

    component pulsegen is
        generic(
            g_pc : positive
        );
        port(
            clk_i   : in  std_logic;
            reset_n_i : in  std_logic;

            pulse_o  : out std_logic
        );
    end component;
begin
    clk4_o <= s_clk4;

    div7 : clkdiv
        generic map(
        g_div => 7,
        g_pol => '0'
        )
        port map(
            clk_i   => clk_i,
            reset_n_i => reset_n_i,
            clk_o  => clk7_o
        );

    div4 : clkdiv
        generic map(
        g_div => 4,
        g_pol => '0'
        )
        port map(
            clk_i   => clk_i,
            reset_n_i => reset_n_i,
            clk_o  => s_clk4
        );

    pls4 : pulsegen
        generic map(g_pc => 14)
        port map(
            clk_i   => s_clk4,
            reset_n_i => reset_n_i,
            pulse_o  => pulse4_o
        );

end rtl;
