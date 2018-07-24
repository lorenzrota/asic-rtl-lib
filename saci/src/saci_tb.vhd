-------------------------------------------------------------------------------
-- Title      : SACI slave test bench
-------------------------------------------------------------------------------
-- File       : serializer_tb.vhd
-- Author     : Faisal Abu-Nimeh
-- Created    : 20180620
-- Platform   : Generic
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- Uses SaciSlaveWrapper deeloped by TID-AIR-ES to stimulate SACI slave
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

entity saci_tb is
end entity;

architecture arch of saci_tb is
    constant c_clk_period : time := 10 ns;

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


    type t_SACI_DATA_O is array (0 to g_cmds - 1) of std_logic_vector(c_width - 1 downto 0);
    signal s_saci_data_o      : t_SACI_DATA_O := (
    "11" & "1111111" & x"FED" & x"DEAD_BEEF", -- write
    "10" & "1111111" & x"FED" & x"0000_0000", -- read
    "11" & "1010101" & x"DEF" & x"BEAD_DAAD", -- write
    "10" & "1010101" & x"DEF" & x"0000_0000", -- read
    "0"  & x"0_0000_0000_0000" -- null
    );

    signal s_watchdog_cnt : unsigned(31 downto 0); -- simulator watchdog counter

    constant c_ccnt_with : positive := integer(ceil(log2(real(g_cmds))));
    signal s_tran_cnt   : unsigned(c_ccnt_with - 1 downto 0); -- transactions counter

    -- generate generic width
    constant c_scnt_width : positive := integer(ceil(log2(real(c_width))));
    signal s_ser_cnt   : unsigned(c_scnt_width - 1 downto 0); -- serialization counter
    signal s_rsp_cnt   : unsigned(c_scnt_width - 1 downto 0); -- serialization counter

    signal s_clk   : std_logic;
    signal s_rst_n : std_logic;

    signal s_sel_n     : std_logic; -- chip select
    signal s_cmd       : std_logic; -- command
    signal s_rsp       : std_logic; -- response
    signal s_rsp_d     : std_logic; -- response delayed

    signal s_rsp_read_flag     : std_logic; -- response delayed

    signal s_data_o : std_logic_vector(c_width - 1 downto 0); -- data out (MOSI)

    -- for these registers we dont care about start bit and rw bit
    signal s_rdata_i_valid : std_logic_vector(c_width - 3 downto 0); -- read data in (MISO)
    signal s_wdata_i_valid : std_logic_vector(c_wwidth - 3 downto 0); -- write data in (MISO)


    type t_SACI_STATES is (ST_IDLE, ST_COMMIT, ST_RSP_WAIT, ST_RSP_CHK, ST_RSP_STR, ST_RESET);
    signal s_my_state    : t_SACI_STATES;


    component saci_master is
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
    end component;

    component SaciSlaveWrapper is
      generic (TPD_G : time);
      port (
        asicRstL : in  std_logic;
        saciClk  : in  std_logic;
        saciSelL : in  std_logic; -- chip select
        saciCmd  : in  std_logic;
        saciRsp  : out std_logic);
    end component;

    -- start here
begin
    saci_master_inst: saci_master
    generic map(
    g_slaves => 1, -- Number of Slaves
    g_timeout => 50 -- Number of clk_i tics to wait before reseting slave
    )
    port map(
      clk_i  => s_clk,
      reset_n_i => s_rst_n,
      start_i => ,
      slave_mask_i => ,
      data_i => ,

      clk_o => s_master_clk,
      cmd_o => s_master_cmd,
      rsp_i => s_slave_rsp,
      sel_n_o => s_sel_n
    );

    saci_slave_inst: SaciSlaveWrapper
    generic map(TPD_G => 1 ns)
    port map(
      asicRstL => s_rst_n,
      saciClk  => s_clk,
      saciSelL => s_sel_n,
      saciCmd  => s_cmd,
      saciRsp => s_rsp
    );

    -- generate clock for testbench
    p_clk_gen : process
    begin
        s_clk <= '0';
        wait for c_clk_period / 2;
        s_clk <= '1';
        wait for c_clk_period / 2;
    end process p_clk_gen;

    -- generate reset for testbench
    p_rst_gen : process
    begin
        s_rst_n <= '0';
        wait for 10 * c_clk_period; -- hold rest for 10 clock periods
        wait until s_clk = '0';
        s_rst_n <= '1';
        wait until s_clk = '1';
        wait;
    end process p_rst_gen;

    -- test starts here
    s_data_o <= s_saci_data_o(to_integer(s_tran_cnt));
    s_cmd <= s_data_o(c_width-1-to_integer(s_ser_cnt)) when s_my_state = ST_COMMIT else '0';

    p_test : process(s_clk, s_rst_n)
    begin
        if s_rst_n = '0' then
            s_ser_cnt      <= (others => '0');
            s_tran_cnt     <= (others => '0');
            s_rsp_cnt      <= (others => '0');
            s_watchdog_cnt <= (others => '0');

            s_rsp_read_flag <= '0';
            s_sel_n        <= '1';
            s_my_state     <= ST_IDLE;
            s_rsp_d        <= '0';
        elsif rising_edge(s_clk) then
          s_rsp_d <= s_rsp;

          case s_my_state is
            when ST_IDLE =>
            --if s_tran_cnt > 0 then
            --  assert () report "Bad response" severity failure;
            --end if;

            if s_tran_cnt = g_cmds-1 then
              report "SACI cmds completed." severity note;
            else
              -- give it a moment to transition to next
              if s_sel_n = '1' then
                s_sel_n <= '0';
                s_my_state <= ST_COMMIT;
                if s_data_o(s_data_o'left-1) = '1' then -- WRITE
                  s_rsp_cnt <= to_unsigned(c_width, s_rsp_cnt'length); -- 53
                else
                  s_rsp_cnt <= to_unsigned(c_wwidth, s_rsp_cnt'length); -- 21
                end if;
              end if;
            end if;

            when ST_COMMIT =>
              s_ser_cnt <= s_ser_cnt + 1;
              if s_ser_cnt = s_rsp_cnt-1 then
                s_tran_cnt <= s_tran_cnt + 1;
                s_ser_cnt <= (others => '0');
                s_watchdog_cnt <= (others => '0');
                s_my_state <= ST_RSP_WAIT;
              end if;

            when ST_RSP_WAIT =>
            -- detect start bit
              if s_rsp = '1' and s_rsp_d = '0' then
                s_my_state <= ST_RSP_CHK;
                -- s_rdata_i_valid <= (others => 'X'); -- reset them for visual
                -- s_wdata_i_valid <= (others => 'X');
              end if;
              -- watchdog to stop simulation
              s_watchdog_cnt <= s_watchdog_cnt + 1;
              if s_watchdog_cnt = x"FFFF_0000" then -- FIXME: harcoded sim timeout
                report "No Response from SACI" severity failure;
                s_my_state <= ST_RESET;
                s_sel_n <= '1';
              end if;

            when ST_RSP_CHK =>
            -- state to store slave response in appropriate register
              if s_rsp = '0' then -- Response to a SACI READ
                s_rsp_read_flag <= '1';
                s_rsp_cnt <= to_unsigned(c_width-2, s_rsp_cnt'length); -- 53 -2 = 51
              else
                s_rsp_cnt <= to_unsigned(c_wwidth-2, s_rsp_cnt'length); -- 21 - 2 = 19
                s_rsp_read_flag <= '0';
              end if;
              s_my_state <= ST_RSP_STR;

            when ST_RSP_STR =>
              --  SACI PROTOCOL: data is capture on falling edge, see p_test_fall
              if s_rsp_read_flag = '1' then
                s_rdata_i_valid <= s_rdata_i_valid(s_rdata_i_valid'left-1 downto 0) & s_rsp;
              else
                s_wdata_i_valid <= s_wdata_i_valid(s_wdata_i_valid'left-1 downto 0) & s_rsp;
              end if;
              s_ser_cnt <= s_ser_cnt + 1;
              if s_ser_cnt = s_rsp_cnt-1 then
                s_ser_cnt <= (others => '0');
                s_sel_n <= '1';
                s_my_state <= ST_IDLE;
              end if;

            when ST_RESET =>
              -- toggle select to reset slave
              if s_sel_n = '1' then
                s_sel_n <= '0';
              else
                s_sel_n <= '1';
                s_my_state <= ST_IDLE;
              end if;
          end case;
        end if;
    end process;

    -- p_test_fall : process(s_clk)
    -- begin
    --     if rising_edge(s_clk) then
    --       if s_my_state = ST_RSP_STR then
    --         if s_rsp_read_flag = '1' then
    --           s_rdata_i_valid <= s_rdata_i_valid(s_rdata_i_valid'left-1 downto 0) & s_rsp;
    --         else
    --           s_wdata_i_valid <= s_wdata_i_valid(s_wdata_i_valid'left-1 downto 0) & s_rsp;
    --         end if;
    --       end if;
    --     end if;
    -- end process;

end;
