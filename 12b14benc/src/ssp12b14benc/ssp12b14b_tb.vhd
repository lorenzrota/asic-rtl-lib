-------------------------------------------------------------------------------
-- Title      : SSP 12b14b encoder/decoder test bench
-------------------------------------------------------------------------------
-- File       : ssp12b14b_tb.vhd
-- Author     : Faisal Abu-Nimeh
-- Created    : 20171005
-- Platform   : Generic
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- Test bench for SSP 12b14b encoder/decoder, mainly for encoder's
-- ASIC synthesis.
--
-- This is a loose replication of Ssp12b14bTb.vhd but using prbs.
-------------------------------------------------------------------------------
-- License:
-- Copyright (c) 2017 SLAC
-- See LICENSE or
-- https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity ssp12b14b_tb is
    -- nothing here
end entity;

architecture arch of ssp12b14b_tb is
    constant clk_period : time := 10 ns;

    -- constants to interface with SLAC's modules
    constant c_tpd          : time      := 1 ns; -- SLAC's timing
    constant c_rst_polarity : std_logic := '1'; -- active high
    constant c_rst_async    : boolean   := true; -- synchronize reset
    constant c_num_tests    : positive  := 2**20; -- Number of PRBS to generate

    -- signals
    signal s_clk : std_logic;
    signal s_rst : std_logic;

    signal s_enc_valid_i : std_logic := '0';
    signal s_enc_valid_o : std_logic := '0';

    signal s_enc_ready : std_logic := '0';
    signal s_enc_sof   : std_logic := '0';
    signal s_enc_eof   : std_logic := '0';

    signal s_enc_data_i : std_logic_vector(11 downto 0) := (others => '0');
    signal s_enc_data_o : std_logic_vector(13 downto 0) := (others => '0');

    signal s_dec_data_i : std_logic_vector(13 downto 0) := (others => '0');
    signal s_dec_data_o : std_logic_vector(11 downto 0) := (others => '0');

    signal s_dec_valid   : std_logic;
    signal s_dec_sof     : std_logic;
    signal s_dec_eof     : std_logic;
    signal s_dec_eofe    : std_logic;
    signal s_dec_coderr  : std_logic;
    signal s_dec_disperr : std_logic;

    signal s_prbs_dout    : std_logic_vector(11 downto 0);
    signal s_prbs_dout_d7 : std_logic_vector(11 downto 0);

    -- components:
    -- PRBS generator
    component lfsr_prbs_gen is
        generic(
            DATA_WIDTH : positive
        );
        port(
            clk      : in  std_logic;
            rst      : in  std_logic;
            enable   : in  std_logic;
            data_out : out std_logic_vector(11 downto 0)
        );
    end component;

    -- syncbus is used to delay output
    component syncbus is
        generic(
            g_stages : positive := 7;
            g_width  : positive := 12
        );
        port(
            clk_i   : in  std_logic;
            reset_i : in  std_logic;
            async_i : in  std_logic_vector(g_width - 1 downto 0);
            syncd_o : out std_logic_vector(g_width - 1 downto 0)
        );
    end component;

    -- SSP 12b14b Enconder
    -- uses SLAC's naming convention
    component SspEncoder12b14b is
        generic(
            RST_POLARITY_G : std_logic;
            RST_ASYNC_G    : boolean;
            AUTO_FRAME_G   : boolean;
            FLOW_CTRL_EN_G : boolean
        );
        port(
            clk_i   : in  std_logic;
            rst_i   : in  std_logic;
            valid_i : in  std_logic;
            data_i  : in  std_logic_vector(11 downto 0);
            valid_o : out std_logic;
            ready_o : out std_logic;
            data_o  : out std_logic_vector(13 downto 0)
        );
    end component;

    -- SSP 12b14b Decoder
    -- uses SLAC's naming convention
    component SspDecoder12b14b is
        generic(
            TPD_G          : time;
            RST_POLARITY_G : std_logic;
            RST_ASYNC_G    : boolean
        );
        port(
            clk       : in  std_logic;
            rst       : in  std_logic;
            validIn   : in  std_logic;
            dataIn    : in  std_logic_vector(13 downto 0);
            validOut  : out std_logic;
            dataOut   : out std_logic_vector(11 downto 0);
            valid     : out std_logic;
            sof       : out std_logic;
            eof       : out std_logic;
            eofe      : out std_logic;
            codeError : out std_logic;
            dispError : out std_logic
        );
    end component;

    -- start here
begin
    uprbs : lfsr_prbs_gen
        generic map(
            DATA_WIDTH => 12)
        port map(
            clk      => s_clk,
            rst      => s_rst,
            enable   => '1',
            data_out => s_prbs_dout
        );

    usync : syncbus
        generic map(
            g_stages => 7,
            g_width  => 12)
        port map(
            clk_i   => s_clk,
            reset_i => s_rst,
            async_i => s_prbs_dout,
            syncd_o => s_prbs_dout_d7
        );

    -- component instantiation
    U_SspEncoder12b14b : SspEncoder12b14b
        generic map(
            RST_POLARITY_G => c_rst_polarity,
            RST_ASYNC_G    => c_rst_async,
            AUTO_FRAME_G   => true,
            FLOW_CTRL_EN_G => false)
        port map(
            clk_i   => s_clk,
            rst_i   => s_rst,
            valid_i => s_enc_valid_i,
            data_i  => s_enc_data_i,
            valid_o => s_enc_valid_o,
            ready_o => s_enc_ready,
            data_o  => s_enc_data_o
        );

    s_dec_data_i <= s_enc_data_o when s_enc_valid_o = '1' else (others => '0');
    U_SspDecoder12b14b_1 : SspDecoder12b14b
        generic map(
            TPD_G          => c_tpd,
            RST_POLARITY_G => c_rst_polarity,
            RST_ASYNC_G    => c_rst_async)
        port map(
            clk       => s_clk,
            rst       => s_rst,
            validIn   => '1',
            dataIn    => s_dec_data_i,
            dataOut   => s_dec_data_o,
            validOut  => s_dec_valid,
            sof       => s_dec_sof,
            eof       => s_dec_eof,
            eofe      => s_dec_eofe,
            codeError => s_dec_coderr,
            dispError => s_dec_disperr);

    -- generate clock for testbench
    p_clk_gen : process is
    begin
        s_clk <= '0';
        wait for clk_period / 2;
        s_clk <= '1';
        wait for clk_period / 2;
    end process p_clk_gen;

    -- generate reset for testbench
    p_rst_gen : process is
    begin
        s_rst <= '1';
        wait for 30 * clk_period;       -- hold rest for 30 clock periods
        wait until s_clk = '1';
        s_rst <= '0';
        wait;
    end process p_rst_gen;

    -- generate prbs31 data for encoder
    p_data_gen : process is
    begin
        wait until s_clk = '1';
        wait until s_rst = '0';
        wait until s_clk = '1';

        report "Number of random iterations to test: " & positive'image(c_num_tests);

        for j in 0 to c_num_tests loop
            wait until s_clk = '1';
            if s_enc_ready = '1' then
                s_enc_valid_i <= '1';
                s_enc_data_i  <= s_prbs_dout;
            end if;
        end loop;
        s_enc_valid_i <= '0';
        wait until s_dec_valid = '0';

        report "Simulation finished successfully" severity failure;
    end process p_data_gen;

    -- verify prbs31 data from encoder
    p_data_chk : process is
    begin
        for j in 0 to c_num_tests loop
            wait until s_rst = '0';
            wait until s_dec_valid = '1';
            wait until s_clk = '1';
            assert (s_dec_sof = '1' or j /= 0) report "No SOF" severity failure;
            assert (s_dec_data_o = s_prbs_dout_d7) report "Bad decode" severity failure;
            assert (s_dec_disperr = '0') report "Bad disparity" severity warning;
            assert (s_dec_coderr = '0') report "Bad Code" severity warning;
        end loop;
    end process p_data_chk;
end;
