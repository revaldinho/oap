`include "osl.h"

module osl_rxtx(
              input clk,
              input resetb,              

              input rx,
              output tx,

              input  host_rd,
              output [ `WORDSZ-1: 0] host_dout,
              output host_dor,

              input  host_wr,
              input [ `WORDSZ-1: 0] host_din,
              output host_dir           
           );

  parameter RXIDLE=2'b00, RXDATA=2'b10, RXREQACK=2'b11, RXWAITACK=2'b01;
  parameter TXIDLE=3'b000, TXDATA=3'b010, TXWAITACK=3'b011, TXRDY=3'b001, 
    TXHEADER0=3'b100, TXHEADER1=3'b101, TXSENDACK0=3'b110, TXSENDACK1=3'b111;

`ifdef TX_ON_NEGEDGE  
  reg [1:0]		din_q;
`else
  reg	                din_q;
`endif  
  reg [`WORDSZ-1:0]     ser2par_q;
  reg [`COUNTERSZ-1:0] 	rx_count_q;
  reg [1:0]             rx_state_q;
  reg	                rx_ready_q;
  reg [`WORDSZ-1:0]     par2ser_q;
  reg [`COUNTERSZ-1:0] 	tx_count_q;
  reg [2:0]             tx_state_q;
  reg	                tx_ready_q; 
  reg                   tx_r;
  reg			tx_ack_rcvd_q;
  reg 			rx_ack_req_q;
  reg 			rx_ack_sent_q;  
  wire [1:0]            din_w;

  
  assign host_dor = !rx_ready_q;
  assign host_dout = ser2par_q;
  assign host_dir = !tx_ready_q;
  assign tx = tx_r;

`ifdef TX_ON_NEGEDGE
  assign din_w = din_q;
`else  
  assign din_w = {din_q, rx};
`endif
  
  always @ ( * ) 
    case (tx_state_q)
      TXSENDACK0: tx_r = 1'b1;
      TXSENDACK1: tx_r = 1'b0;
      TXHEADER0: tx_r = 1'b1;
      TXHEADER1: tx_r = 1'b1;
      TXDATA: tx_r = par2ser_q[`WORDSZ-1];
      default: tx_r = 1'b0;
    endcase

  always @ ( posedge clk or negedge resetb)
    if ( !resetb)
      tx_state_q <= TXIDLE;
    else
      case (tx_state_q) 
        TXIDLE: tx_state_q <= ( rx_ack_req_q) ? TXSENDACK0 : (tx_ready_q) ?  TXHEADER0 : TXIDLE;
        TXHEADER0: tx_state_q <= TXHEADER1;
        TXHEADER1: tx_state_q <= TXDATA;
        TXDATA: tx_state_q <= ( tx_count_q != `WORDSZ-1 ) ? TXDATA : ( tx_ready_q ) ? TXWAITACK : TXIDLE ;
        TXWAITACK: tx_state_q <= (!tx_ack_rcvd_q) ? TXWAITACK: TXRDY;
        TXRDY: tx_state_q <= TXIDLE;
        TXSENDACK0: tx_state_q <= TXSENDACK1;
        TXSENDACK1: tx_state_q <= TXIDLE;
        default: tx_state_q <= TXIDLE;
      endcase
  
  always @ ( posedge clk or negedge resetb)
    if ( !resetb)
      tx_ready_q <= 1'b0;
    else if (tx_state_q==TXRDY) 
      tx_ready_q <= 1'b0;
    else if (host_wr )
      tx_ready_q <= 1'b1;      
  
  always @ ( posedge clk or negedge resetb)
    if (!resetb)
      tx_count_q <= 0;
    else	
      tx_count_q <= (tx_state_q == TXDATA) ? tx_count_q +1: (tx_state_q==TXIDLE) ? 0 : tx_count_q; 

  always @ ( posedge clk or negedge resetb)
    if ( !resetb)
      rx_state_q <= RXIDLE;
    else
      case (rx_state_q)
        RXIDLE: rx_state_q <= (&din_w) ?  RXDATA : RXIDLE;
        RXDATA: rx_state_q <= ( rx_count_q != `WORDSZ-1 ) ? RXDATA : ( rx_ready_q ) ? RXREQACK : RXIDLE ;
        RXREQACK: rx_state_q <= RXWAITACK;
        RXWAITACK: rx_state_q <= RXIDLE;
        default: rx_state_q <= RXIDLE;
      endcase

  always @ ( posedge clk or negedge resetb)
    if ( !resetb) begin
      tx_ack_rcvd_q <= 0;
      rx_ack_req_q <= 0;
    end  
    else begin
      if ( tx_state_q == TXHEADER0 )
        tx_ack_rcvd_q <= 0;
      else if (rx_state_q==RXIDLE && din_w==2'b10)
        tx_ack_rcvd_q <= 1;

      if ( rx_state_q == RXREQACK )
        rx_ack_req_q <= 1;
      else if ( tx_state_q == TXSENDACK1)
        rx_ack_req_q <= 0;
    end
  
  always @ ( posedge clk or negedge resetb)
    if ( !resetb)
      rx_ready_q <= 1'b1;
    else if (rx_state_q == RXREQACK) 
      rx_ready_q <= 1'b0;
    else if (host_rd )
      rx_ready_q <= 1'b1;      
  
  always @ ( posedge clk or negedge resetb)
    if (!resetb)
      rx_count_q <= 0;
    else	
      rx_count_q <= (rx_state_q == RXDATA) ? rx_count_q +1: (rx_state_q==RXIDLE) ? 0 : rx_count_q;

  always @ ( `TXEDGE clk or negedge resetb)
    if ( !resetb) begin
      ser2par_q <= 0;      
      par2ser_q <= 0;
      din_q <= 0;
    end 
    else begin
      if ( host_wr && tx_state_q==TXIDLE)
        par2ser_q <= host_din;
      else
        par2ser_q <= ( tx_ready_q & (tx_state_q==TXDATA) ) ? (par2ser_q << 1) : par2ser_q;
      ser2par_q <= ( rx_ready_q & (rx_state_q==RXDATA)) ? (ser2par_q<<1) | rx  : ser2par_q ;
`ifdef TX_ON_NEGEDGE      
      din_q <= {din_q[0], rx} ;
`else      
      din_q <= rx ;
`endif      
    end
  
endmodule
