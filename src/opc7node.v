module opc7node (
                 input clk,
                 input resetb,
                 input [3:0] rx,
                 output [3:0] tx
                 );

  wire [19:0]  address ;
  wire [31:0]  cpu_dout, ram_dout;

  wire [31:0]  link_dout [3:0];
  wire [3:0]   link_dor, link_dir, link_cs;
  wire         link_we, link_rd;

  reg          vio_q, rnw_q;
  reg [19:0]   address_q;
  reg [31:0]   cpu_dout_q;
  reg [31:0]   cpu_din_r;  
  
  assign link_cs[0] = vio_q & (address_q & 19'h0FF) == 19'h010;
  assign link_cs[1] = vio_q & (address_q & 19'h0FF) == 19'h020;
  assign link_cs[2] = vio_q & (address_q & 19'h0FF) == 19'h030;
  assign link_cs[3] = vio_q & (address_q & 19'h0FF) == 19'h040;

  always @ (posedge clk or negedge resetb)
    if ( !resetb ) begin
      {vio_q, rnw_q}  <= 4'b0;
      address_q <= 20'h0;
      cpu_dout_q <= 31'h0;      
    end
    else begin  
      {vio_q, rnw_q}  <= {vio, rnw };
      address_q <= address;
      cpu_dout_q <= cpu_dout;      
    end
  
  always @ ( * ) begin
    if ( vio_q ) begin
      if ( (address_q & 19'h0FF)==19'h010)
        cpu_din_r = link_dout[0];
      else if ( (address_q & 19'h0FF)==19'h011)
        cpu_din_r = {30'b0, link_dor[0], link_dir[0]} ;
      else if ( (address_q & 19'h0FF)==19'h020)
        cpu_din_r = link_dout[1];
      else if ( (address_q & 19'h0FF)==19'h021)
        cpu_din_r = {30'b0, link_dor[1], link_dir[1]} ;
      else if ( (address_q & 19'h0FF)==19'h030)
        cpu_din_r = link_dout[2];
      else if ( (address_q & 19'h0FF)==19'h031)
        cpu_din_r = {30'b0, link_dor[2], link_dir[2]} ;
      else if ( (address_q & 19'h0FF)==19'h040)
        cpu_din_r = link_dout[3];
      else // if ( (address_q & 19'h0FF)==19'h041)
        cpu_din_r = {30'b0, link_dor[3], link_dir[3]} ;
      
    end
    else
      cpu_din_r = ram_dout;
  end
  
  opc7cpu  CPU_0 (
                   .din(cpu_din_r), 
                   .clk(clk), 
                   .reset_b(resetb), 
                   .int_b(2'b11), 
                   .clken(1'b1), 
                   .address(address), 
                   .dout(cpu_dout), 
                   .rnw(rnw), 
                   .vpa(vpa), 
                   .vda(vda), 
                   .vio(vio)
                   );

  ram8192x32 RAM_0 (
                    .clk(clk),
                    .address(address[12:0]),
                    .resetb(resetb),
                    .din(cpu_dout),
                    .cs(vpa|vda),
                    .rnw(rnw),
                    .dout(ram_dout)
                   );

  
  osl_rxtx UA_N_0 (
                   .clk(clk),
                   .resetb(resetb),
                   .rx(rx[0]),
                   .tx(tx[0]),
                   .chip_sel(link_cs[0]),
                   .host_rd(rnw_q),
                   .host_dout(link_dout[0]),
                   .host_dor(link_dor[0]),
                   .host_wr(!rnw_q),
                   .host_din(cpu_dout_q),
                   .host_dir(link_dir[0])
                   );

  osl_rxtx UB_E_1 (
                   .clk(clk),
                   .resetb(resetb),
                   .rx(rx[1]),
                   .tx(tx[1]),
                   .chip_sel(link_cs[1]),
                   .host_rd(rnw_q),
                   .host_dout(link_dout[1]),
                   .host_dor(link_dor[1]),
                   .host_wr(!rnw_q),
                   .host_din(cpu_dout_q),
                   .host_dir(link_dir[1])
                   );

  osl_rxtx UA_S_2 (
                   .clk(clk),
                   .resetb(resetb),
                   .rx(rx[2]),
                   .tx(tx[2]),
                   .chip_sel(link_cs[2]),
                   .host_rd(rnw_q),
                   .host_dout(link_dout[2]),
                   .host_dor(link_dor[2]),
                   .host_wr(!rnw_q),
                   .host_din(cpu_dout_q),
                   .host_dir(link_dir[2])
                   );

  osl_rxtx UB_W_3 (
                   .clk(clk),
                   .resetb(resetb),
                   .rx(rx[3]),
                   .tx(tx[3]),
                   .chip_sel(link_cs[3]),
                   .host_rd(rnw_q),
                   .host_dout(link_dout[3]),
                   .host_dor(link_dor[3]),
                   .host_wr(!rnw_q),
                   .host_din(cpu_dout_q),
                   .host_dir(link_dir[3])
                   );


endmodule
  
