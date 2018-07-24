// SACI master test bench
//-------------------------------------------------------------------------------------------------
// Title      : SACI Master Test Bench
//-------------------------------------------------------------------------------------------------
// File       : saci_master_tb.sv
// Author     : Faisal Abu-Nimeh
// Created    : 20180622
// Standard   : IEEE 1800-2017
//-------------------------------------------------------------------------------------------------
// Description:
// Simple SACI master test for full-chip simulations. Uses STIMFILE to drive SACI commands.
//
//-------------------------------------------------------------------------------------------------
// License:
// Copyright (c) 2018 SLAC
// See LICENSE or https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html
//-------------------------------------------------------------------------------------------------

`define CYCLE 100
`define STIMFILE "saci.stim"

module saci_master_tb;
    timeunit 10ns/1ns;
    bit clk = '1;
    bit rst_n = '0;
    bit start = '0;
    logic saci_clk;
    logic saci_rsp;
    logic saci_cmd;
    logic saci_busy;
    logic [2:0] saci_sel_n;
    logic [2:0] saci_slavemask;
    logic [52:0] saci_datain;

    parameter DRIVE_TIME = `CYCLE*0.2;

    saci_master #(.g_dwidth(53)) t1 (
        .clk_i(clk),
        .reset_n_i(rst_n),
        .start_i(start),
        .slave_mask_i(saci_slavemask),
        .data_i(saci_datain),
        .rsp_i(saci_rsp),
        .clk_o(saci_clk),
        .cmd_o(saci_cmd),
        .busy_o(saci_busy),
        .sel_n_o(saci_sel_n)
    );

    SaciSlaveWrapper sslave (
      .asicRstL(rst_n),
      .saciClk(saci_clk),
      .saciSelL(saci_sel_n[0]),
      .saciCmd(saci_cmd),
      .saciRsp(saci_rsp)
    );


    task tCYCLE;
        @(posedge clk) #DRIVE_TIME;
    endtask

    // taks to gen custom reset pulse
    task RESET (int cnt=1);
        rst_n  = '0;
        saci_slavemask = '1;
        repeat (cnt) @(posedge clk); #DRIVE_TIME;
        rst_n  = '1;
        tCYCLE;
    endtask

    // gen tb clk
    initial begin
        clk <= '0;
        forever #(`CYCLE/2) clk = ~clk;
    end

    // start saci transactions
    always @(posedge clk) begin
        if (rst_n == 1 && saci_busy == 0) begin
            start <= '1;
            saci_slavemask <= '0;
        end
        else begin
            start <= '0;
            saci_slavemask <= '1;
        end
    end

    // reset
    initial begin
        RESET(50);  // reset for 5 clk TCYCLES
    end

    // read stim file content
    initial begin
        integer stimfile = $fopen(`STIMFILE, "r");
        logic [51:0] saci_stimuli;
        int i=0;
        int fret;

        if (!stimfile)
            $display("Could not open stimfile");
        else begin
            while(!$feof(stimfile)) begin
                @(negedge saci_busy); // wait for busy to clear
                fret = $fscanf(stimfile, "%h", saci_stimuli);
                if (fret == 1) begin
                    $display("\tValue of saci_stimuli[%0d]=0x%x",i,saci_stimuli);
                    saci_datain = {1'b1, saci_stimuli}; // prepend start_bit
                    i++;
                end
            end
            $fclose(stimfile);
            $display("stim completed");
            #1 $finish;
        end
    end
endmodule
