// dummy wrapper
module SaciSlave2 (rst, ack, addr, clk, cmd, exec,
       rddata, readl, rstl, rstoutl, sacicmd, sacirsp, sacisell,
       wrdata);
  output [31:0] wrdata;
  output        readl;
  input        sacisell;
  input        sacicmd;
  output        sacirsp;
  input        rst;
  input [31:0] rddata;
  input        ack;
  input        rstl;
  input        clk;
  output [11:0] addr;
  output        rstoutl;
  output [6:0]  cmd;
  output        exec;
endmodule
