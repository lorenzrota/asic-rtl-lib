-------------------------------------------------------------------------------
-- File       : SspEncoder12b14b.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2014-07-14
-- Last update: 2017-05-01
-------------------------------------------------------------------------------
-- Description: SimpleStreamingProtocol - A simple protocol layer for inserting
-- idle and framing control characters into a raw data stream. This module
-- ties the framing core to an RTL 12b14b encoder.
-------------------------------------------------------------------------------
-- This file is part of 'SLAC Firmware Standard Library'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'SLAC Firmware Standard Library', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.STD_LOGIC_ARITH.all;

use work.StdRtlPkg.all;
use work.Code12b14bPkg.all;

entity SspEncoder12b14b is
    generic(
        RST_POLARITY_G : sl      := '0'; -- active-low reset
        RST_ASYNC_G    : boolean := true;
        AUTO_FRAME_G   : boolean := true;
        FLOW_CTRL_EN_G : boolean := false);
    port(
        clk_i   : in  std_logic;
        rst_n_i : in  std_logic := RST_POLARITY_G; -- active-low reset
        valid_i : in  std_logic;
        data_i  : in  std_logic_vector(11 downto 0);
        
        data_o  : out std_logic_vector(13 downto 0)
    );
end entity SspEncoder12b14b;

architecture rtl of SspEncoder12b14b is

    signal s_frame  : std_logic_vector(11 downto 0); -- := (others => '0');
    signal s_framek : std_logic_vector(0 downto 0); --  := (others => '0');
    signal s_valid  : std_logic;
    signal s_ready  : std_logic;

begin

    SspFramer_1 : entity work.SspFramer
        generic map(
            RST_POLARITY_G  => RST_POLARITY_G,
            RST_ASYNC_G     => RST_ASYNC_G,
            AUTO_FRAME_G    => AUTO_FRAME_G,
            FLOW_CTRL_EN_G  => FLOW_CTRL_EN_G,
            WORD_SIZE_G     => 12,
            K_SIZE_G        => 1,
            SSP_IDLE_CODE_G => K_120_11_C,
            SSP_IDLE_K_G    => "1",
            SSP_SOF_CODE_G  => K_120_0_C,
            SSP_SOF_K_G     => "1",
            SSP_EOF_CODE_G  => K_120_1_C,
            SSP_EOF_K_G     => "1")
        port map(
            clk      => clk_i,
            rst      => rst_n_i,
            validIn  => valid_i,
            readyIn  => open,
            dataIn   => data_i,
            sof      => '0',
            eof      => '0',
            validOut => s_valid,
            readyOut => s_ready,        -- input
            dataOut  => s_frame,
            dataKOut => s_framek
        );

    Encoder12b14b_1 : entity work.Encoder12b14b
        generic map(
            RST_POLARITY_G => RST_POLARITY_G,
            RST_ASYNC_G    => RST_ASYNC_G,
            FLOW_CTRL_EN_G => FLOW_CTRL_EN_G)
        port map(
            clk      => clk_i,
            clkEn    => '1',
            rst      => rst_n_i,
            validIn  => s_valid,
            readyIn  => s_ready,        -- output, always 1?
            dataIn   => s_frame,
            dispIn   => "00",
            dataKIn  => s_framek(0),
            validOut => open,
            readyOut => '1',
            dataOut  => data_o,
            dispOut  => open
        );
end architecture rtl;
