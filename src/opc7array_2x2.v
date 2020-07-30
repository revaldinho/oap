module opc7array_2x2 (
                      input        clk,
                      input        resetb,
                      input [7:0]  rx,
                      output [7:0] tx
                      );


  wire [7:0]                       int_data;

  opc7node node_00 (
                    .clk(clk),
                    .resetb(resetb),
                    .rx({rx[0], int_data[0], int_data[2], rx[7]}),
                    .tx({tx[0], int_data[1], int_data[3], tx[7]})
                    );
  opc7node node_01 (
                    .clk(clk),
                    .resetb(resetb),
                    .rx({rx[1], rx[2], int_data[5], int_data[1]}),
                    .tx({tx[1], tx[2], int_data[4], int_data[0]})
                    );
  opc7node node_10 (
                    .clk(clk),
                    .resetb(resetb),
                    .rx({int_data[4], rx[3], rx[4], int_data[6]}),
                    .tx({int_data[5], tx[3], tx[4], int_data[7]})
                    );
  opc7node node_11 (
                    .clk(clk),
                    .resetb(resetb),
                    .rx({int_data[3], int_data[7], rx[5], rx[6]}),
                    .tx({int_data[2], int_data[6], tx[5], tx[6]})
                    );

endmodule
  
