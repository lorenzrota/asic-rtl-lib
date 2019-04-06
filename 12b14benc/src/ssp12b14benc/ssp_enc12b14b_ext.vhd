----------------------------------------------------------------------------------------------------
-- Title      : 12b14b ssp encoder wrapper with test pattern generation
----------------------------------------------------------------------------------------------------
-- File       : ssp_enc12b14b_ext.vhd
-- Author     : Faisal Abu-Nimeh
-- Created    : 20180425
-- Platform   : Generic
-- Standard   : VHDL'93/02
----------------------------------------------------------------------------------------------------
-- Description:
-- 12b14b Encoder wrapper with test pattern and bypass options.
----------------------------------------------------------------------------------------------------
-- License:
-- Copyright (c) 2018 SLAC
-- See LICENSE or
-- https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ssp_enc12b14b_ext is
    port(
        clk_i   : in  std_logic; -- input clock
        fclk_i  : in  std_logic; -- frame clock to align test pattern
        rst_n_i : in  std_logic; -- active-low reset
        valid_i : in  std_logic; -- valid input for encoder
        mode_i  : in  std_logic_vector(2 downto 0); -- mode of operation
        data_i  : in  std_logic_vector(11 downto 0); -- data to be encoded

        data_o  : out std_logic_vector(13 downto 0) -- output data
    );
end entity ssp_enc12b14b_ext;

architecture rtl of ssp_enc12b14b_ext is
    -- test pattern constants
    constant c_patterna : std_logic_vector(13 downto 0) := "10" & x"AAA"; -- "10_1010_1010_1010"
    constant c_patternb : std_logic_vector(13 downto 0) := "01" & x"555"; -- "01_0101_0101_0101"

    signal s_pattern  : std_logic_vector(13 downto 0); -- wire, choosing any of the patterns below

    signal s_pattern0  : std_logic_vector(13 downto 0); -- sampled fclk_i
    signal s_pattern1  : std_logic_vector(13 downto 0); -- 0xA's followed by 0x5's
    signal s_pattern2  : std_logic_vector(13 downto 0); -- 000's followed by 111's
    signal s_pattern3  : std_logic_vector(13 downto 0); -- wire, LSB to MSB incremental ramp

    signal s_cnt_ramp : unsigned(13 downto 0); -- pattern3 ramp counter

    signal s_data_i  : std_logic_vector(11 downto 0);  -- data_i
    signal s_data_o  : std_logic_vector(13 downto 0);  -- data_out
    signal s_valid_i : std_logic; -- encoder data_i valid
    signal s_evenodd : std_logic; -- toggle flag

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
            rst_n_i : in  std_logic;
            valid_i : in  std_logic;
            data_i  : in  std_logic_vector(11 downto 0);

            data_o  : out std_logic_vector(13 downto 0)
        );
    end component;
begin
    -- component instantiation
    U_SspEncoder12b14b : SspEncoder12b14b
        generic map(
            RST_POLARITY_G => '0',
            RST_ASYNC_G    => true,
            AUTO_FRAME_G   => true,
            FLOW_CTRL_EN_G => false)
        port map(
            clk_i   => clk_i,
            rst_n_i => rst_n_i,
            valid_i => s_valid_i,
            data_i  => s_data_i,
            data_o  => s_data_o
        );

    -- Test Patterns:
    -- Test Pattern0: frame clk (receiver uses LSB to recover frame clk)
    -- Test Pattern1: 0xA's followed by 0x5's
    -- Test Pattern2: 000's followed by 111's
    -- Test Pattern3: Ramp 0x0000 to 0x3FFF (or 0xFFF when encoded)

    s_pattern1 <= c_patterna when s_evenodd = '0' else c_patternb;
    s_pattern2 <= (others => '0') when s_evenodd = '0' else (others => '1');
    s_pattern3 <= std_logic_vector(s_cnt_ramp);

    -- modes of operation
    -- M2 M1 M0 | Description
    -- -------- | -----------
    -- 0  0  0  | Normal: ADC -> DMUX -> ENC -> Serializer
    -- 0  0  1  | Test Pattern1 -> ENC -> Serializer
    -- 0  1  0  | Test Pattern2 -> ENC -> Serializer
    -- 0  1  1  | Test Pattern3 -> ENC -> Serializer
    -- 1  0  0  | Test Pattern0 (frame clk) -> Serializer
    -- 1  0  1  | Test Pattern1 -> Serializer
    -- 1  1  0  | Test Pattern2 -> Serializer
    -- 1  1  1  | Test Pattern3 -> Serializer

    s_pattern <= s_pattern0 when mode_i(1 downto 0) = "00" else
                 s_pattern1 when mode_i(1 downto 0) = "01" else
                 s_pattern2 when mode_i(1 downto 0) = "10" else
                 s_pattern3 when mode_i(1 downto 0) = "11" else
                 (others => '0');

    s_data_i  <= data_i when mode_i = "000" else s_pattern(11 downto 0);
    s_valid_i <= valid_i when mode_i(2) = '0' else '0';

    data_o <= s_data_o when mode_i(2) = '0' else s_pattern;

    -- generate s_patterns
    tpattern : process(clk_i, rst_n_i)
    begin
        if rst_n_i = '0' then -- async reset
            s_pattern0 <= (others => '0');
            s_cnt_ramp <= (others => '0');
            s_evenodd <= '0';
        elsif rising_edge(clk_i) then
            -- pattern0
            s_pattern0 <= s_pattern0(12 downto 0) & fclk_i; -- MSB is oldest in time

            -- toggle flag for pattern1 and 2
            s_evenodd <= not s_evenodd;

            -- pattern3
            s_cnt_ramp <= s_cnt_ramp + 1; -- will auto wrap
            -- wrap early if we are feeding encoder i.e. 12 bits only
            if mode_i(2) = '0' and s_cnt_ramp >= x"FFF" then
                s_cnt_ramp <= (others => '0');
            end if;
        end if;
    end process;
end architecture rtl;
