`define WORDSZ 	     32
`define COUNTERSZ     5
`define CLKPHASE    100

// Optionally transmit on negedge/receive on posedge or transmit/receive both on posedge
//`define TX_ON_NEGEDGE 1

`ifdef TX_ON_NEGEDGE
  `define TXEDGE negedge
`else
  `define TXEDGE posedge
`endif
