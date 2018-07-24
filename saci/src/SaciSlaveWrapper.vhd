-------------------------------------------------------------------------------
-- File       : SaciSlaveWrapper.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2016-06-17
-- Last update: 2016-06-17
-------------------------------------------------------------------------------
-- Description: Simulation testbed for SaciSlaveWrapper
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
use work.StdRtlPkg.all;

entity SaciSlaveWrapper is
  generic (
    TPD_G : time := 1 ns);
  port (
    asicRstL : in  sl;
    saciClk  : in  sl;
    saciSelL : in  sl;                  -- chipSelect
    saciCmd  : in  sl;
    saciRsp  : out sl);

end entity SaciSlaveWrapper;

architecture rtl of SaciSlaveWrapper is

  signal saciSlaveRstL : sl;
  signal exec          : sl;
  signal ack           : sl;
  signal readL         : sl;
  signal cmd           : slv(6 downto 0);
  signal addr          : slv(11 downto 0);
  signal wrData        : slv(31 downto 0);
  signal rdData        : slv(31 downto 0);
  signal saciRspInt : sl;

  component SaciSlave2 is
    port (
      rstL : in sl;                       -- ASIC global reset

      -- Serial Interface
      clk  : in  sl;
      saciSelL : in  sl;                  -- chipSelect
      saciCmd  : in  sl;
      saciRsp  : out sl;

      -- Silly reset hack to get saciSelL | rst onto dedicated reset bar
      rstOutL : out sl;
      rst  : in  sl;

      -- Detector (Parallel) Interface
      exec   : out sl;
      ack    : in  sl;
      readL  : out sl;
      cmd    : out slv(6 downto 0);
      addr   : out slv(11 downto 0);
      wrData : out slv(31 downto 0);
      rdData : in  slv(31 downto 0));
  end component;
begin

  saciRsp <= saciRspInt when saciSelL = '0' else 'Z';

  SaciSlave_i : SaciSlave2
    port map (
      rstL     => asicRstL,
      clk  => saciClk,
      saciSelL => saciSelL,
      saciCmd  => saciCmd,
      saciRsp  => saciRspInt,
      rstOutL  => saciSlaveRstL,
      rst   => saciSlaveRstL,
      exec     => exec,
      ack      => ack,
      readL    => readL,
      cmd      => cmd,
      addr     => addr,
      wrData   => wrData,
      rdData   => rdData);

  SaciSlaveRam_1 : entity work.SaciSlaveRam
    port map (
      saciClkOut => saciClk,
      exec       => exec,
      ack        => ack,
      readL      => readL,
      cmd        => cmd,
      addr       => addr,
      wrData     => wrData,
      rdData     => rdData);

end architecture rtl;
