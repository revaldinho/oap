`timescale 1ns/1ns
`include "osl.h"

module osl_tb;
  reg clk_r;
  reg rstb_r;
  reg tx_r;
  reg hostA_rd_r;
  reg hostB_rd_r;
  reg hostA_wr_r;
  reg hostB_wr_r;
  wire [`WORDSZ-1:0] hostA_dout_w;
  reg [`WORDSZ-1:0] hostA_din_r;
  wire [`WORDSZ-1:0] hostB_dout_w;
  reg [`WORDSZ-1:0] hostB_din_r;

  wire data0_w;
  wire data1_w;
  wire hostA_dir_w;
  wire hostA_dor_w;
  wire hostB_dir_w;
  wire hostB_dor_w;

  task transmitAB;
    input [`WORDSZ-1:0] data;
    begin
      hostA_din_r = data;
      // Wait for transmitter to be ready
      while ( !hostA_dir_w )
        @(posedge clk_r);
      // Write data into the TX unit
      @(posedge clk_r);
      hostA_wr_r = 1'b1;
      @(posedge clk_r);
      hostA_wr_r = 1'b0;
      // wait for data ready at the RX unit
      while ( !hostB_dor_w )
        @( posedge clk_r);
      // Read data from the RX unit and compare
      @(posedge clk_r);
      hostB_rd_r = 1'b1;
      if ( hostB_dout_w == data)
        $display ("PASS: RX matches TX data, expected 0x%4H, actual 0x%04H", data, hostB_dout_w) ;
      else
        $display("FAIL: RX, TX mismatch, expected 0x%4H, actual 0x%4H", data, hostB_dout_w);
      @(posedge clk_r);
      hostB_rd_r = 1'b0;
    end
  endtask

  task transmitBA;
    input [`WORDSZ-1:0] data;
    begin
      hostB_din_r = data;
      // Wait for transmitter to be ready
      while ( !hostB_dir_w )
        @(posedge clk_r);
      // Write data into the TX unit
      @(posedge clk_r);
      hostB_wr_r = 1'b1;
      @(posedge clk_r);
      hostB_wr_r = 1'b0;
      // wait for data ready at the RX unit
      while ( !hostA_dor_w )
        @( posedge clk_r);
      // Read data from the RX unit and compare
      @(posedge clk_r);
      hostA_rd_r = 1'b1;
      if ( hostA_dout_w == data)
        $display ("PASS: RX matches TX data, expected 0x%4H, actual 0x%04H", data, hostA_dout_w) ;
      else
        $display("FAIL: RX, TX mismatch, expected 0x%4H, actual 0x%4H", data, hostA_dout_w);
      @(posedge clk_r);
      hostA_rd_r = 1'b0;
    end
  endtask

  initial
    begin

`ifdef TX_ON_NEGEDGE
       $dumpfile("osl_tb_neg.vcd");
`else
       $dumpfile("osl_tb.vcd");
`endif
      $dumpvars();
      clk_r = 0;
      rstb_r = 0;
      tx_r = 0;
      hostA_rd_r = 0;
      hostA_wr_r = 1'b0;
      hostB_rd_r = 0;
      hostB_wr_r = 1'b0;
      # 1000;
      @ (posedge clk_r );
      rstb_r = 1;
      # 1000;
      $display("Sending data from A to B");
      transmitAB( `WORDSZ'h01234567);
      transmitAB( `WORDSZ'h89ABCDEF);
      transmitAB( `WORDSZ'h00112233);
      transmitAB( `WORDSZ'h44556677);

      $display("Sending data from B to A");
      transmitBA( `WORDSZ'h01234567);
      transmitBA( `WORDSZ'h89ABCDEF);
      transmitBA( `WORDSZ'h00112233);
      transmitBA( `WORDSZ'h44556677);
      #10000 $finish();
    end

  always
    #`CLKPHASE  clk_r <= !clk_r;

  osl_rxtx UA_0 (
                 .clk(clk_r),
                 .resetb(rstb_r),
                 .rx(data0_w),
                 .tx(data1_w),
                 .chip_sel(1'b1),
                 .host_rd(hostA_rd_r),
                 .host_dout(hostA_dout_w),
                 .host_dor(hostA_dor_w),
                 .host_wr(hostA_wr_r),
                 .host_din(hostA_din_r),
                 .host_dir(hostA_dir_w)
                 );
  osl_rxtx UB_1 (
                 .clk(clk_r),
                 .resetb(rstb_r),
                 .rx(data1_w),
                 .tx(data0_w),
                 .chip_sel(1'b1),
                 .host_rd(hostB_rd_r),
                 .host_dout(hostB_dout_w),
                 .host_dor(hostB_dor_w),
                 .host_wr(hostB_wr_r),
                 .host_din(hostB_din_r),
                .host_dir(hostB_dir_w)
                 );
endmodule
