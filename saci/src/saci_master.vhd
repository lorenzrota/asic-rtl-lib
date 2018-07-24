-------------------------------------------------------------------------------
-- Title      : SACI Master
-------------------------------------------------------------------------------
-- File       : saci_master.vhd
-- Author     : Faisal Abu-Nimeh
-- Created    : 20180620
-- Platform   : Generic
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- Simple SACI master
--
-------------------------------------------------------------------------------
-- License:
-- Copyright (c) 2018 SLAC
-- See LICENSE or
-- https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity saci_master is
  generic(
    g_slaves  : positive := 1; -- Total number of SACI Slaves
    g_timeout : positive := 100; -- Number of clk_i tics to wait before reseting slave

    g_start_width : positive := 1; -- start bit
    g_wr_width    : positive := 1; -- write/read bit
    g_cmd_width   : positive := 7; -- command id
    g_addr_width  : positive := 12; -- address id
    g_data_width  : positive := 32 -- saci data (payload)
  );
  port(
    clk_i        : in std_logic;
    reset_n_i    : in std_logic; -- active low
    start_i      : in std_logic; -- start sending cmds to slaves

    -- slave_mask and data are registered internally
    slave_mask_i : in std_logic_vector((2**g_slaves)-1 downto 0); -- sel_n_o is generated from this
    data_i       : in std_logic_vector(g_start_width+g_wr_width+g_cmd_width+
                                       g_addr_width+g_data_width-1 downto 0);

    clk_o   : out std_logic; -- slave clocks
    cmd_o   : out std_logic; -- MOSI
    rsp_i   : in std_logic; -- MISO
    sel_n_o : out std_logic_vector(g_slaves-1 downto 0) -- chip_select, active low
  );
end entity;

architecture arch of saci_master is
    -- 53 bits of SACI are: (MSB to LSB)
    -- -- Start Bit
    -- -- Write/Read bit
    -- -- 7-bit command id
    -- -- 12-bit address
    -- -- 32-bit data
    constant c_width : positive := g_start_width + g_wr_width + g_cmd_width +
                                   g_addr_width + g_data_width;

    -- 21 bits of SACI WRITE response
    -- -- Start Bit
    -- -- Write/Read bit
    -- -- 7-bit command
    -- -- 12-bit address
    constant c_wwidth : positive := g_start_width + g_wr_width + g_cmd_width + g_addr_width;

    -- generate generic counter width
    constant c_scnt_width  : positive := integer(ceil(log2(real(c_width))));
    constant c_wgcnt_width : positive := integer(ceil(log2(real(g_timeout))));

    signal s_ser_cnt   : unsigned(c_scnt_width - 1 downto 0); -- serialization counter
    signal s_rsp_cnt   : unsigned(c_scnt_width - 1 downto 0); -- serialization counter

    signal s_start_d       : std_logic; -- start delayed
    signal s_rsp_d         : std_logic; -- response delayed
    signal s_rsp_read_flag : std_logic; -- response flag

    signal s_data_o       : std_logic_vector(c_width - 1 downto 0); -- data out (MOSI)
    signal s_sel_n        : std_logic_vector(sel_n_o'range); -- active low select
    signal s_slave_mask_i : std_logic_vector(slave_mask_i'range); -- active low select
    signal s_data_i       : std_logic_vector(data_i'range); -- active low select

    -- for these registers we dont care about start bit and rw bit
    signal s_rdata_i_valid : std_logic_vector(c_width - 3 downto 0); -- read data in (MISO)
    signal s_wdata_i_valid : std_logic_vector(c_wwidth - 3 downto 0); -- write data in (MISO)

    signal s_watchdog_cnt : unsigned(c_wgcnt_width-1 downto 0); -- simulator watchdog counter

    type t_SACI_STATES is (ST_IDLE, ST_COMMIT, ST_RSP_WAIT, ST_RSP_CHK, ST_RSP_STR, ST_RESET);
    signal s_my_state    : t_SACI_STATES;
begin
    clk_o <= clk_i;
    sel_n_o <= s_sel_n or s_slave_mask_i;
    cmd_o <= s_data_o(c_width-1-to_integer(s_ser_cnt)) when s_my_state = ST_COMMIT else '0';

    p_saci_master : process(clk_i, reset_n_i)
    begin
        if reset_n_i = '0' then
            s_ser_cnt      <= (others => '0');
            s_rsp_cnt      <= (others => '0');
            s_watchdog_cnt <= (others => '0');
            s_sel_n        <= (others => '1');
            s_slave_mask_i <= (others => '0');
            s_data_i       <= (others => '0');

            s_rsp_read_flag <= '0';
            s_start_d <= '0';
            s_rsp_d        <= '0';

            s_my_state     <= ST_IDLE;
        elsif rising_edge(clk_i) then
          s_start_d <= start_i;
          s_rsp_d <= rsp_i;

          case s_my_state is
            when ST_IDLE =>
              if start_i = '1' and s_start_d = '0' then
                  s_my_state <= ST_COMMIT;

                  s_slave_mask_i <= slave_mask_i;
                  s_data_i <= data_i;

                  if s_data_i(s_data_i'left-1) = '1' then -- WRITE
                    s_rsp_cnt <= to_unsigned(c_width, s_rsp_cnt'length); -- 53
                  else
                    s_rsp_cnt <= to_unsigned(c_wwidth, s_rsp_cnt'length); -- 21
                  end if;
              end if;

            when ST_COMMIT =>
              s_ser_cnt <= s_ser_cnt + 1;
              if s_ser_cnt = s_rsp_cnt-1 then
                s_ser_cnt <= (others => '0');
                s_watchdog_cnt <= (others => '0');
                s_my_state <= ST_RSP_WAIT;
              end if;

            when ST_RSP_WAIT =>
            -- detect start bit
              if rsp_i = '1' and s_rsp_d = '0' then
                s_my_state <= ST_RSP_CHK;
                -- s_rdata_i_valid <= (others => 'X'); -- reset them for visual
                -- s_wdata_i_valid <= (others => 'X');
              end if;
              -- watchdog to stop simulation
              s_watchdog_cnt <= s_watchdog_cnt + 1;
              if s_watchdog_cnt = g_timeout-1 then
                report "No Response from SACI" severity note;
                s_my_state <= ST_RESET;
                s_sel_n <= (others => '1'); -- FIXME: We need to know which slave is responding
              end if;

            when ST_RSP_CHK =>
            -- state to store slave response in appropriate register
              if rsp_i = '0' then -- Response to a SACI READ
                s_rsp_read_flag <= '1';
                s_rsp_cnt <= to_unsigned(c_width-2, s_rsp_cnt'length); -- 53 -2 = 51
              else
                s_rsp_cnt <= to_unsigned(c_wwidth-2, s_rsp_cnt'length); -- 21 - 2 = 19
                s_rsp_read_flag <= '0';
              end if;
              s_my_state <= ST_RSP_STR;

            when ST_RSP_STR =>
              --  FIXME: SACI PROTOCOL: data is capture on falling edge, see p_test_fall
              -- this should be defined in the design constraints file
              if s_rsp_read_flag = '1' then
                s_rdata_i_valid <= s_rdata_i_valid(s_rdata_i_valid'left-1 downto 0) & rsp_i;
              else
                s_wdata_i_valid <= s_wdata_i_valid(s_wdata_i_valid'left-1 downto 0) & rsp_i;
              end if;
              s_ser_cnt <= s_ser_cnt + 1;
              if s_ser_cnt = s_rsp_cnt-1 then
                s_ser_cnt <= (others => '0');
                s_sel_n <= (others => '1');
                s_my_state <= ST_IDLE;
              end if;

            when ST_RESET =>
              -- toggle chip select to reset slave
              if or_reduce(s_sel_n) = '1' then
                s_sel_n <= (others => '0');
              else
                s_sel_n <= (others => '1');
                s_my_state <= ST_IDLE;
              end if;
          end case;
        end if;
    end process;
end;
