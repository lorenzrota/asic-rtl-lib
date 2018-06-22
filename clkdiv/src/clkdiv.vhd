-------------------------------------------------------------------------------
-- Title      : Integer Clock Divider
-------------------------------------------------------------------------------
-- File       : clkdiv.vhd
-- Author     : Faisal Abu-Nimeh
-- Created    : 20171113
-- Platform   : Generic
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- Divide by n circuit. Works for even and odd divisors.
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

entity clkdiv is
    generic(
        g_div : positive := 2; -- divisor
        g_pol : std_logic  := '1' -- clock polarity
    );
    port(
        clk_i   : in  std_logic;
        reset_n_i : in  std_logic;
        clk_o   : out std_logic
    );
end entity;

architecture rtl of clkdiv is
     -- generate generic width
    constant c_cnt_width : positive := integer(ceil(log2(real(g_div))));

    signal s_cnt_h   : unsigned(c_cnt_width - 1 downto 0); -- rising edge counter
    signal s_cnt_l   : unsigned(c_cnt_width - 1 downto 0); -- falling edge counter
begin
    -- if divisor is less than two, just pass the clock on
    pass_gen : if (g_div < 2) generate
    clk_o <= clk_i;
    end generate pass_gen;

    -- this process is needed for all divisors
    div_pro : if (g_div > 1) generate
    process(clk_i, reset_n_i)
    begin
        if reset_n_i = '0' then
            s_cnt_h <= (others => '0'); -- start from 0
        elsif rising_edge(clk_i) then
            s_cnt_h <= s_cnt_h + 1;
            if s_cnt_h = g_div - 1 then
                s_cnt_h   <= (others => '0'); -- reset counter
            end if;
        end if;
    end process;
    end generate div_pro;

    -- if the divisor is even, we don't need to look at falling edge
    evn_pro : if (g_div mod 2 = 0 and g_div > 1) generate
    clk_o <= g_pol when (s_cnt_h > to_unsigned((g_div-1)/2,c_cnt_width)) = true else not g_pol;
    end generate evn_pro;

    -- if divosr is odd, generate a falling edge counter and update output accordingly
    odd_pro : if (g_div mod 2 = 1 and g_div > 1) generate
    clk_o <= g_pol when (s_cnt_h > to_unsigned(g_div/2,c_cnt_width)) or (s_cnt_l > to_unsigned(g_div/2,c_cnt_width)) = true else not g_pol;
    process(clk_i, reset_n_i)
    begin
        if reset_n_i = '0' then
            s_cnt_l <= (others => '0');
        elsif falling_edge(clk_i) then
            s_cnt_l <= s_cnt_l + 1;
            if s_cnt_l = g_div - 1 then
                s_cnt_l   <= (others => '0'); -- reset counter
            end if;
        end if;
    end process;
    end generate odd_pro;

end rtl;
