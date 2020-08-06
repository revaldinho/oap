module rom2048x32 (
                   input         clk,
                   input [10:0]   address,
                   output [31:0] dout
                   );
  
  parameter  ROMFILE="boot.hex";
  
  reg [31:0]                     mem [ 2048:0 ] ;  (* RAM_STYLE="DISTRIBUTED" *)
  reg [10:0]                     address_q ;
  
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
