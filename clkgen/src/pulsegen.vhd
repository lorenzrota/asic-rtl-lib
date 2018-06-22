-------------------------------------------------------------------------------
-- Title      : Single Pulse Generator
-------------------------------------------------------------------------------
-- File       : pulsegen.vhd
-- Author     : Faisal Abu-Nimeh
-- Created    : 20171115
-- Platform   : Generic
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- Generates a single pulse every g_pc cycles
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

entity pulsegen is
    generic(
        g_pc : positive := 14 -- pulse count
    );
    port(
        clk_i   : in  std_logic;
        reset_n_i : in  std_logic;

        pulse_o  : out std_logic
    );
end entity;

architecture rtl of pulsegen is
    constant c_cnt_width : positive := integer(ceil(log2(real(g_pc))));

    signal s_cnt : unsigned(c_cnt_width - 1 downto 0);
    signal s_pulse : std_logic;
begin
    pulse_o <= s_pulse;

    process(clk_i, reset_n_i)
    begin
        if reset_n_i = '0' then
            s_cnt <= (others => '0');
            s_pulse <= '0';
        elsif rising_edge(clk_i) then
            s_cnt    <= s_cnt + 1;
            s_pulse <= '0';

            if s_cnt = g_pc - 1 then
                s_cnt <= (others => '0');
                s_pulse <= '1';
            end if;
        end if;
    end process;
end rtl;
