-------------------------------------------------------------------------------
-- Title      : serializer testbench
-------------------------------------------------------------------------------
-- File       : serializer_tb.vhd
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

entity serializer_tb is
    generic(g_dwidth : positive := 14); -- Encoded data width
end entity;

architecture arch of serializer_tb is
    constant c_cnt_width : positive := integer(ceil(log2(real(g_dwidth))));

    constant c_clk_serprd : time := 2 ns; -- serializer clock period
    constant c_clk_period : time := c_clk_serprd/2;

    -- signals
    signal s_ser_clk : std_logic;

    signal s_clk   : std_logic;
    signal s_rst   : std_logic;
    signal s_rst_n : std_logic;

    signal s_clk_start : std_logic := '0';
    signal s_start_readout : std_logic := '0';
    signal s_start_readout_sync : std_logic := '0';

    -- cnt samples from file
    signal s_cnt_samples : unsigned(c_cnt_width - 1 downto 0); -- samples counter
    signal s_cnt_out     : unsigned(c_cnt_width - 1 downto 0); -- serializer output counter

    signal s_data_i : std_logic_vector(g_dwidth - 1 downto 0);
    signal s_data_o : std_logic;

    signal s_pdata      : std_logic_vector(g_dwidth - 1 downto 0);
    signal s_pdata_good : std_logic_vector(g_dwidth - 1 downto 0); -- visual rep

    -- syncbus is used to delay output
    component serializer is
        generic(g_dwidth : positive);
        port(
            clk_i     : in  std_logic;    -- clk
            reset_n_i : in  std_logic;    -- reset

            data_i    : in  std_logic_vector(g_dwidth - 1 downto 0);
            data_o    : out std_logic
        );
    end component;

    component sync is
        generic(
            g_edge : boolean
        );
    	port(
    		clk_i     : in  std_logic;
    		reset_n_i : in  std_logic;
    		async_i   : in  std_logic;
    		syncd_o   : out std_logic
    	);
    end component;

    -- start here
begin

    reset_sync :sync
    generic map(g_edge => true)
    port map(
        clk_i   => s_ser_clk,
        reset_n_i => '1',
        async_i  => s_start_readout,
        syncd_o  => s_start_readout_sync
    );
    ser : serializer
        generic map(g_dwidth => 14)
        port map(
            clk_i     => s_ser_clk,
            reset_n_i => s_rst_n,

            data_i  => s_data_i,
            data_o  => s_data_o
        );

    -- generate clock for testbench
    p_clk_gen : process is
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

    -- generate clock for testbench
    p_serclk_gen : process is
    begin
        s_ser_clk <= '0';
        wait for c_clk_serprd / 2;
        s_ser_clk <= '1';
        wait for c_clk_serprd / 2;
    end process p_serclk_gen;

    -- generate reset for testbench
    p_rst_gen : process is
    begin
        s_rst   <= '1';
        s_rst_n <= '0';
        wait for 10 * c_clk_serprd;     -- hold rest for 10 clock periods
        wait until s_ser_clk = '1';
        s_rst   <= '0';
        s_rst_n <= '1';
        wait;
    end process p_rst_gen;

    p_start : process is
    begin
        s_start_readout <= '0';
        wait for 60 * c_clk_serprd;     -- hold rest for 10 clock periods
        if s_rst = '0' then
            s_start_readout <= '1';
        else
            wait until s_rst = '0';
            s_start_readout <= '1';
        end if;
        wait;
    end process p_start;

    ser_in : process(s_ser_clk, s_rst)
    begin
        if s_rst = '1' then
            s_cnt_samples <= (others => '0');
            s_data_i      <= (others => '0');
        elsif rising_edge(s_ser_clk) then
            if s_start_readout_sync = '1' then
                s_cnt_samples <= s_cnt_samples + 1;
                if s_cnt_samples = g_dwidth/2 - 1 then
                    s_data_i      <= std_logic_vector(unsigned(s_data_i) + 1);
                    s_cnt_samples <= (others => '0');
                end if;
            end if;
        end if;
    end process;

    ser_test : process(s_clk, s_rst)
    begin
        if s_rst = '1' then
            s_cnt_out    <= (others => '0');
            s_pdata      <= (others => '0');
            s_pdata_good <= (others => '0');
        elsif rising_edge(s_clk) then
            if s_start_readout_sync = '1' then
                s_cnt_out <= s_cnt_out + 1;
                -- right shift i.e. LSB 1st
                s_pdata <= s_data_o & s_pdata(g_dwidth - 1 downto 1);
                if s_cnt_out = g_dwidth - 1 then
                    s_cnt_out <= (others => '0');
                end if;

                if s_cnt_out = 9 then
                    s_pdata_good <= s_data_o & s_pdata(g_dwidth - 1 downto 1);
                end if;
            end if;
        end if;
    end process;
end;
