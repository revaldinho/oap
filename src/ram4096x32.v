module ram4096x32 (
                   input         clk,
                   input [11:0]  address,
                   input         resetb,
                   input [31:0]  din,
                   input         cs,
                   input         rnw,
                   output [31:0] dout
                   );
  
  reg [31:0]                     mem [4095:0] ;  (* RAM_STYLE="BLOCK" *)
  reg [11:0]                     address_q ;
  reg [31:0]                     din_q;
  reg                            cs_q;
  reg                            rnw_q;  

  assign dout = mem[address_q];  
  
  always @ (posedge clk or negedge resetb ) begin
    // Latch all control and address signals on rising edge
    if ( !resetb ) begin
      cs_q <= 0;
      rnw_q <= 1;      
    end 
    else begin
      cs_q <= cs;
      rnw_q <= rnw;
      address_q <= address;
      din_q <= din;      
    end
  end // always @ (posedge clk or negedge resetb )
  
  always @ (posedge clk) begin
    // Write to RAM on next cycle - whole cycle to complete
    if (cs_q && !rnw_q && resetb ) begin
      mem[address_q] <= din_q;
      // $display(" STORE :  Address : 0x%05x ( %6d )  : Data : 0x%08x ( %d)",address_q,address_q,din_q,din_q);       
    end      
  end
endmodule
