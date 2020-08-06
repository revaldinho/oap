module rom1024x32 (
                   input         clk,
                   input [9:0]   address,
                   input [31:0]  din,
                   output [31:0] dout
                   );
  
  parameter  ROMFILE="../firmware/hello.hex";
  
  reg [31:0]                     mem [ 1023:0 ] ;  (* RAM_STYLE="DISTRIBUTED" *)
  reg [9:0]                      address_q ;
  reg [31:0]                     din_q;
  
  assign dout = mem[address_q];

  initial
    begin
      $display ("Loading ROM contents (%m)...");  
      $readmemh(ROMFILE, mem ) ;
      $display ("...done (%m)");  
    end
  
  always @ (posedge clk )
    address_q <= address;
  
endmodule
