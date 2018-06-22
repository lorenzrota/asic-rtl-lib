-------------------------------------------------------------------------------
-- Title      : sync async_i to clk_i
-------------------------------------------------------------------------------
-- File       : sync.vhd
-- Author     : Faisal Abu-Nimeh
-- Created    : 20171120
-- Platform   : Generic
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- Cross clock domain synchronizer for a single signal
-------------------------------------------------------------------------------
-- License:
-- Copyright (c) 2017 SLAC
-- See LICENSE or
-- https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity sync is
    generic(
        g_edge : boolean := true -- true := sync to rising edge
    );
    port(
        clk_i   : in  std_logic;
        reset_n_i : in  std_logic; -- async reset
        async_i : in  std_logic; -- synchronized signal
        syncd_o : out std_logic
    );
end sync;

architecture rtl of sync is
    signal sync, sync_d, sync_d2 : std_logic;
begin
    syncd_o <= sync_d2; -- async_i --> 3 DFF's --> syncd_o

    en_rising : if (g_edge = true) generate
    p_sync_proc : process(clk_i, reset_n_i)
    begin
        if (reset_n_i = '0') then -- async reset is hooked up to ENA on last DFF
            sync    <= '0';
            sync_d  <= '0';
            sync_d2 <= '0';
        elsif rising_edge(clk_i) then
            sync    <= async_i;
            sync_d  <= sync;
            sync_d2 <= sync_d;
        end if;
    end process;
    end generate en_rising;

    en_falling : if (g_edge = false) generate
    p_sync_proc : process(clk_i, reset_n_i)
    begin
        if (reset_n_i = '0') then -- async reset is hooked up to ENA on last DFF
            sync   <= '0';
            sync_d <= '0';
            sync_d2 <= '0';
        elsif falling_edge(clk_i) then
            sync    <= async_i;
            sync_d  <= sync;
            sync_d2 <= sync_d;
        end if;
    end process;
    end generate en_falling;
end rtl;
