-------------------------------------------------------------------------------
-- Title      : Bus Synchronizer
-------------------------------------------------------------------------------
-- File       : syncbus.vhd
-- Author     : Faisal Abu-Nimeh
-- Created    : 20171005
-- Platform   : Generic
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- Multi-stage bus synchronizer.
-------------------------------------------------------------------------------
-- License:
-- Copyright (c) 2017 SLAC
-- See LICENSE or
-- https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

entity syncbus is
    generic(
        g_stages : positive := 2; -- number of stages to delay
        g_width  : positive := 8 -- width of bus
    );
    port(
        clk_i   : in  std_logic; -- target clock
        reset_i : in  std_logic; -- target sync reset
        async_i : in  std_logic_vector(g_width - 1 downto 0); -- async input data
        syncd_o : out std_logic_vector(g_width - 1 downto 0) -- synd'd output
    );
end syncbus;

architecture rtl of syncbus is
    -- array of stages. each arrage has a size of g_width
    type t_syncd_array is array (0 to g_stages - 1) of std_logic_vector(g_width - 1 downto 0);
    signal syncdbus : t_syncd_array; -- temp var to store delay
begin
    syncd_o <= syncdbus(g_stages - 1);  -- take the last one

    -- p_sync_proc generates a chain of delaychains
    p_sync_proc : process(clk_i)
    begin                               -- process delay_proc
        if rising_edge(clk_i) then
            if reset_i = '1' then
                syncdbus <= (others => (others => '0')); -- reset bus to zeros
            else
                syncdbus(0) <= async_i;
                -- chain bus to create a delayed version
                if (g_stages > 1) then
                    gen_syncd : for i in 0 to g_stages - 1 - 1 loop
                        syncdbus(i + 1) <= syncdbus(i);
                    end loop;
                end if;
            end if;
        end if;
    end process p_sync_proc;
end rtl;
