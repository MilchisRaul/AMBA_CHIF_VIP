//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 12/03/2025
//  File name             : chi_hni_if.sv
//  Last modified+updates : 12/03/2025 (RM) - Initial Version
//                          
//  Project               : CHI Protocl Request Node - I VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Link interface with FLIT type packet for CHI RN-I Verification IP (UVC)
//  ======================================================================================================

import chi_hni_pkg::*;

//Interface definition
interface chi_hni_if #(
  TP          = 0,
  NUM_OF_TXRSP_CREDITS = 4,
  NUM_OF_TXDATA_CREDITS = 4
  )(
    input clk,
    input rst_n
  );

  //importing uvm basics and other sv headers, packages
  import uvm_pkg::*;

  //FSM Signals for RX/TX Channels Link Layer
  logic [1:0] current_state_rx;
  logic [1:0] next_state_rx;

  logic [1:0] current_state_tx;
  logic [1:0] next_state_tx;

  //High level signals to enable RX/TX channels, to enable link layers
  logic chi_hni_txsactive;
  logic chi_hni_rxsactive;

  //LINK HANDSHAKE SIGNALS for RX channels
  logic chi_hni_rxlinkactivereq;
  logic chi_hni_rxlinkactiveack;

  //LINK HANDSHAKE SIGNALS for TX channels
  logic chi_hni_txlinkactivereq;
  logic chi_hni_txlinkactiveack;

  //Credit counters for each channel
  logic [CRDWIDTH - 1: 0] rxreq_crd_cnt;
  logic [CRDWIDTH - 1: 0] txrsp_crd_cnt;
  logic [CRDWIDTH - 1: 0] txdata_crd_cnt;
  logic [CRDWIDTH - 1: 0] rxrsp_crd_cnt;
  logic [CRDWIDTH - 1: 0] rxdata_crd_cnt;
  
  /*********************************************************************************
  *          CHANNEL                                 DIRECTION
  **********************************************************************************/

  //REQUEST (RXREQ) channel signals           HNI (TX)   ->   RNI (RX)
  logic             chi_hni_reqflitpend;      //OUT
  logic             chi_hni_reqflitv;         //OUT
  logic [TX_R-1: 0] chi_hni_reqflit;          //OUT
  logic             chi_hni_reqlcrdv;         //IN
  //RESPONSE (TXRSP) channel signals          HNI (TX)   ->   RNI (RX)
  logic             chi_hni_txrspflitpend;    //OUT
  logic             chi_hni_txrspflitv;       //OUT
  logic [TX_T-1: 0] chi_hni_txrspflit;        //OUT
  logic             chi_hni_txrsplcrdv;       //IN
  //DATA TRANSFER (TXDATA) channel signals    HNI (TX)   ->   RNI (RX)
  logic             chi_hni_txdatflitpend;    //OUT    
  logic             chi_hni_txdatflitv;       //OUT
  logic [TX_D-1: 0] chi_hni_txdatflit;        //OUT
  logic             chi_hni_txdatlcrdv;       //IN
  //RESPONSE (RXRSP) channel signals          HNI (RX)   <-   RNI (TX)
  logic             chi_hni_rxrspflitpend;    //IN 
  logic             chi_hni_rxrspflitv;       //IN
  logic [RX_T-1: 0] chi_hni_rxrspflit;        //IN
  logic             chi_hni_rxrsplcrdv;       //OUT
  //DATA RECEIVE (RXDATA) channel signals     HNI (RX)   <-   RNI (TX)
  logic             chi_hni_rxdatflitpend;    //IN
  logic             chi_hni_rxdatflitv;       //IN
  logic [RX_D-1: 0] chi_hni_rxdatflit;        //IN
  logic             chi_hni_rxdatlcrdv;       //OUT

  //CB DRV

  // Clocking block for the RXREQ channel driver
  clocking rxreq_cb_drv @(posedge clk); // Clockingblock sample at posedge of the clock
    input  chi_hni_reqflitpend;     // VIP input
    input  chi_hni_reqflitv;        // VIP input
    input  chi_hni_reqflit;         // VIP input
    output chi_hni_reqlcrdv;        // VIP output
  endclocking

  // Clocking block for the RXRSP channel driver
  clocking rxrsp_cb_drv @(posedge clk); // Clockingblock sample at posedge of the clock
    input  chi_hni_rxrspflitpend;     // VIP input
    input  chi_hni_rxrspflitv;        // VIP input
    input  chi_hni_rxrspflit;         // VIP input
    output chi_hni_rxrsplcrdv;        // VIP output
  endclocking
  
  // Clocking block for the RXDATA channel driver
  clocking rxdata_cb_drv @(posedge clk); // Clockingblock sample at posedge of the clock
    input  chi_hni_rxdatflitpend;     // VIP input
    input  chi_hni_rxdatflitv;        // VIP input
    input  chi_hni_rxdatflit;         // VIP input
    output chi_hni_rxdatlcrdv;        // VIP output
  endclocking

  // Clocking block for the TXRSP channel driver
  clocking txrsp_cb_drv @(posedge clk); // Clockingblock sample at posedge of the clock
    output chi_hni_txrspflitpend;     // VIP output
    output chi_hni_txrspflitv;        // VIP output
    output chi_hni_txrspflit;         // VIP output
    input  chi_hni_txrsplcrdv;        // VIP input
  endclocking

  // Clocking block for the TXDATA channel driver
  clocking txdata_cb_drv @(posedge clk); // Clockingblock sample at posedge of the clock
    output chi_hni_txdatflitpend;     // VIP output
    output chi_hni_txdatflitv;        // VIP output
    output chi_hni_txdatflit;         // VIP output
    input  chi_hni_txdatlcrdv;        // VIP input
  endclocking

  //CB MON
  // Clocking block for the TXREQ channel driver
  clocking txreq_cb_mon @(posedge clk); // Clockingblock sample at posedge of the clock
    output chi_hni_reqflitpend;     // VIP output
    output chi_hni_reqflitv;        // VIP output
    output chi_hni_reqflit;         // VIP output
    input  chi_hni_reqlcrdv;        // VIP input
  endclocking

  // Clocking block for the RXRSP channel driver
  clocking rxrsp_cb_mon @(posedge clk); // Clockingblock sample at posedge of the clock
    input  chi_hni_rxrspflitpend;     // VIP input
    input  chi_hni_rxrspflitv;        // VIP input
    input  chi_hni_rxrspflit;         // VIP input
    input  chi_hni_rxrsplcrdv;        // VIP output
  endclocking
  
  // Clocking block for the RXDATA channel driver
  clocking rxdata_cb_mon @(posedge clk); // Clockingblock sample at posedge of the clock
    input  chi_hni_rxdatflitpend;     // VIP input
    input  chi_hni_rxdatflitv;        // VIP input
    input  chi_hni_rxdatflit;         // VIP input
    input  chi_hni_rxdatlcrdv;        // VIP output
  endclocking

  // Clocking block for the TXRSP channel driver
  clocking txrsp_cb_mon @(posedge clk); // Clockingblock sample at posedge of the clock
    input chi_hni_txrspflitpend;     // VIP output
    input chi_hni_txrspflitv;        // VIP output
    input chi_hni_txrspflit;         // VIP output
    input chi_hni_txrsplcrdv;        // VIP input
  endclocking

  // Clocking block for the TXDATA channel driver
  clocking txdata_cb_mon @(posedge clk); // Clockingblock sample at posedge of the clock
    input chi_hni_txdatflitpend;     // VIP output
    input chi_hni_txdatflitv;        // VIP output
    input chi_hni_txdatflit;         // VIP output
    input chi_hni_txdatlcrdv;        // VIP input
  endclocking

  //Link Handshake FSM for RX channel
  always @(posedge clk or negedge rst_n)
    if(~rst_n) current_state_rx <= STOP         ;else
               current_state_rx <= next_state_rx;

  //Link Handshake FSM transition for RX channel
  always @(*) begin
    case (current_state_rx)
      STOP: begin
        if (chi_hni_rxlinkactivereq && chi_hni_rxsactive)
          next_state_rx = ACTIVATE;
      end
      ACTIVATE: begin
        if (chi_hni_rxlinkactiveack)
          next_state_rx = RUN;
      end
      RUN: begin
        if (~chi_hni_rxlinkactivereq)
          next_state_rx = DEACTIVATE;
      end
      DEACTIVATE: begin
        if (~chi_hni_rxlinkactiveack)
          next_state_rx = STOP;
      end
      default: next_state_rx = STOP;
    endcase
  end

  //Link Handshake FSM for TX channel
  always @(posedge clk or negedge rst_n)
    if(~rst_n) current_state_tx <= STOP         ;else
               current_state_tx <= next_state_tx;

  //Link Handshake FSM transition for TX channel
  always @(*) begin
    case (current_state_tx)
      STOP: begin
        if (chi_hni_txlinkactivereq && chi_hni_txsactive)
          next_state_tx = ACTIVATE;
      end
      ACTIVATE: begin
        if (chi_hni_txlinkactiveack)
          next_state_tx = RUN;
      end
      RUN: begin
        if (~chi_hni_txlinkactivereq)
          next_state_tx = DEACTIVATE;
      end
      DEACTIVATE: begin
        if (~chi_hni_txlinkactiveack)
          next_state_tx = STOP;
      end
      default: next_state_tx = STOP;
    endcase
  end

endinterface : chi_hni_if