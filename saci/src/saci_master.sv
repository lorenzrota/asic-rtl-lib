// SACI master
//-------------------------------------------------------------------------------------------------
// Title      : SACI Master
//-------------------------------------------------------------------------------------------------
// File       : saci_master.sv
// Author     : Faisal Abu-Nimeh
// Created    : 20180622
// Standard   : IEEE 1800-2017
//-------------------------------------------------------------------------------------------------
// Description:
// Simple SACI master for full-chip simulations
//
//-------------------------------------------------------------------------------------------------
// License:
// Copyright (c) 2018 SLAC
// See LICENSE or https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html
//-------------------------------------------------------------------------------------------------

module saci_master
    #(parameter
        g_dwidth = 53, // saci data width
        g_timeout = 100, // slave response timeout in clk tics
        g_retries = 3 // number of retires to revive unresponsive slave.
     )(
        input logic clk_i, // saci clk
        input logic reset_n_i, // active-low reset
        input logic start_i, // start sending cmds to slave

        input logic [2:0] slave_mask_i, // slave(s) to communicate with
        input logic [g_dwidth-1:0] data_i, // saci commands

        input logic rsp_i, // MISO (master input slave output)
        output logic clk_o, // exported slave clk
        output logic cmd_o, // MOSI (master output slave input)
        output logic busy_o, // busy signal
        output logic [2:0] sel_n_o // chip_select, active-low
    );

    timeunit 10ns/1ns;

    logic [g_dwidth-1:0] s_data_i; // registered input
    logic [g_dwidth-1:0] s_data_slave; // MISO
    logic [2:0] s_slave_mask_i;
    logic [2:0] s_sel_n;
    logic [2:0] s_sel_n_d; // delayed by 1
    logic s_cmd_o;
    logic s_write_read_flag;

    integer s_rsp_cnt; // response bit counter
    integer s_ser_cnt; // serial in/out counter
    integer s_wg_cnt; // watch dog timer
    integer s_retries;

    typedef enum logic [2:0] {
        ST_IDLE         = 3'b000, // IDLE
        ST_COMMIT       = 3'b001, // commit to slave i.e. SACI request (READ or WRITE) to slave
        ST_RSP_WAIT     = 3'b010, // wait for slave's response
        ST_RSP_STR      = 3'b011, // store slave's response
        ST_RESET        = 3'b100, // reset slave
        XXX             = 'x
    } saci_state;

    saci_state curr_state, next_state;

    assign sel_n_o = s_sel_n || s_slave_mask_i; // pass masked chip select
    assign clk_o = clk_i; // pass clock
    assign cmd_o = (curr_state == ST_COMMIT) ? s_cmd_o : '0; // pass cmd when in ST_COMMIT
    assign busy_o = (curr_state != ST_IDLE) ? '1 : '0;

    always_comb begin
      next_state = XXX;
      case(curr_state)
        ST_IDLE:
            begin
                if (start_i)                    next_state = ST_COMMIT;
                else                            next_state = ST_IDLE;
            end

        ST_COMMIT:
            begin
                if (s_ser_cnt < s_rsp_cnt)      next_state = ST_COMMIT;
                else                            next_state = ST_RSP_WAIT;
            end

        ST_RSP_WAIT:
            begin
                if (rsp_i)                       next_state = ST_RSP_STR;
                else if (s_wg_cnt > g_timeout)   next_state = ST_RESET;
                else                             next_state = ST_RSP_WAIT;
            end

        ST_RESET:
            if (s_retries >= g_retries)
                next_state = ST_IDLE;
            else if (s_retries == 0)
                next_state = ST_RESET;
            else if (s_retries < g_retries)
                next_state = ST_COMMIT;

        ST_RSP_STR:
            begin
                if (s_ser_cnt < s_rsp_cnt)       next_state = ST_RSP_STR;
                else                             next_state = ST_IDLE;
            end
      endcase
    end

    always_ff @(posedge clk_i, negedge reset_n_i) begin
        if (!reset_n_i) begin
            curr_state        <= ST_IDLE;
            s_data_i          <= '0;
            s_rsp_cnt         <= '0;
            s_ser_cnt         <= '0;
            s_wg_cnt          <= '0;
            s_data_slave      <= '0;
            s_sel_n           <= '1;
            s_sel_n_d         <= '1;
            s_slave_mask_i    <= '1;
            s_retries         <= '0;
            s_cmd_o           <= '0;
            s_write_read_flag <= '0;
        end
        else begin
            curr_state <= next_state;

            case(next_state)
                // request state
                ST_COMMIT:
                    if (curr_state == ST_IDLE) begin // first time here
                        //s_retries      <= '0;
                        s_wg_cnt          <= '0;
                        s_ser_cnt         <= '0;
                        s_write_read_flag <= '0;
                        s_data_i          <= data_i; // register data
                        s_slave_mask_i    <= slave_mask_i; // register mask
                        s_sel_n           <= slave_mask_i;

                        if (data_i[g_dwidth-2]) // is saci WRITE?
                            s_rsp_cnt <= g_dwidth;
                        else
                            s_rsp_cnt <= g_dwidth-32; // 21, FIXME make it generic
                    end
                    else
                        s_cmd_o <= s_data_i[g_dwidth-1-s_ser_cnt++];

                // wait for response state
                ST_RSP_WAIT:
                    s_wg_cnt++;
                // stuck slave reset state
                ST_RESET:
                    if (curr_state == ST_RSP_WAIT) begin
                        s_retries++;
                        s_sel_n_d <= s_sel_n; // store
                        s_sel_n   <= '1;
                        s_ser_cnt <= '0;
                        s_wg_cnt  <= '0;
                        s_cmd_o   <= '0;
                    end
                    else
                        s_sel_n <= s_sel_n_d; // restore
                // store response state
                ST_RSP_STR:
                    begin
                        if (curr_state == ST_RSP_WAIT) begin // first time here
                            s_ser_cnt    <= '0;
                            s_data_slave <= '0;
                            s_cmd_o      <= '0;
                        end
                        else begin
                            if (!s_write_read_flag) begin // check for rsp writeread flag
                                s_write_read_flag <= '1;
                                if (rsp_i) // is saci WRITE?
                                    s_rsp_cnt <= g_dwidth-32-2; // 21-2 = 19
                                else
                                    s_rsp_cnt <= g_dwidth-2; // 53-2
                            end
                            else begin
                                s_ser_cnt++;
                                s_data_slave <= {s_data_slave[g_dwidth-2:0], rsp_i};
                            end
                        end
                    end
                // idle state
                ST_IDLE:
                    begin
                        // verify last slave response
                        if (curr_state == ST_RSP_STR) begin
                            s_sel_n   <= '1;
                            if (s_rsp_cnt == g_dwidth-32-2)
                                assert (s_data_slave[18:0] == s_data_i[50:32])
                                    else $error("WRITE response is invalid");
                            else begin
                                assert (s_data_slave[50:32] == s_data_i[50:32])
                                    else $error("READ response CMD/ADDR is invalid");
                                //assert (s_data_slave[31:0] == s_data_i_last[50:32])
                                    //else $error("READ response payload is invalid");
                                $display("\t\tRead SACI Payload=0x%x",s_data_slave[31:0]);
                            end
                        end
                    end
            endcase
        end
    end
endmodule
