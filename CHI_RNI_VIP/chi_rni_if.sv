//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 21/02/2025
//  File name             : chi_rni_if.sv
//  Last modified+updates : 21/02/2025 (RM)
//  Project               : CHI Protocol RNI VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Interface for chi_rni Verification IP (UVC), containing all signal definitions
//  ======================================================================================================

import chi_rni_pkg::*;

//Interface definition
interface chi_rni_if #(
  TP          = 0,
  NUM_OF_RXRSP_CREDITS = 4,
  NUM_OF_RXDATA_CREDITS = 4
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
  logic chi_rni_txsactive;
  logic chi_rni_rxsactive;

  //LINK HANDSHAKE SIGNALS for RX channels
  logic chi_rni_rxlinkactivereq;
  logic chi_rni_rxlinkactiveack;

  //LINK HANDSHAKE SIGNALS for TX channels
  logic chi_rni_txlinkactivereq;
  logic chi_rni_txlinkactiveack;

  //Credit counters for each channel
  logic [CRDWIDTH - 1: 0] txreq_crd_cnt;
  logic [CRDWIDTH - 1: 0] txrsp_crd_cnt;
  logic [CRDWIDTH - 1: 0] txdata_crd_cnt;
  logic [CRDWIDTH - 1: 0] rxrsp_crd_cnt;
  logic [CRDWIDTH - 1: 0] rxdata_crd_cnt;
  
  /*********************************************************************************
  *          CHANNEL                                 DIRECTION
  **********************************************************************************/

  //REQUEST (TXREQ) channel signals           RNI (TX)   ->   HN (RX)
  logic             chi_rni_reqflitpend;      //OUT
  logic             chi_rni_reqflitv;         //OUT
  logic [TX_R-1: 0] chi_rni_reqflit;          //OUT
  logic             chi_rni_reqlcrdv;         //IN
  //RESPONSE (TXRSP) channel signals          RNI (TX)   ->   HN (RX)
  logic             chi_rni_txrspflitpend;    //OUT
  logic             chi_rni_txrspflitv;       //OUT
  logic [TX_T-1: 0] chi_rni_txrspflit;        //OUT
  logic             chi_rni_txrsplcrdv;       //IN
  //DATA TRANSFER (TXDATA) channel signals    RNI (TX)   ->   HN (RX)
  logic             chi_rni_txdatflitpend;    //OUT    
  logic             chi_rni_txdatflitv;       //OUT
  logic [TX_D-1: 0] chi_rni_txdatflit;        //OUT
  logic             chi_rni_txdatlcrdv;       //IN
  //RESPONSE (RXRSP) channel signals          RNI (RX)   <-   HN (TX)
  logic             chi_rni_rxrspflitpend;    //IN 
  logic             chi_rni_rxrspflitv;       //IN
  logic [RX_T-1: 0] chi_rni_rxrspflit;        //IN
  logic             chi_rni_rxrsplcrdv;       //OUT
  //DATA RECEIVE (RXDATA) channel signals     RNI (RX)   <-   HN (TX)
  logic             chi_rni_rxdatflitpend;    //IN
  logic             chi_rni_rxdatflitv;       //IN
  logic [RX_D-1: 0] chi_rni_rxdatflit;        //IN
  logic             chi_rni_rxdatlcrdv;       //OUT

  //CB DRV

  // Clocking block for the TXREQ channel driver
  clocking txreq_cb_drv @(posedge clk); // Clockingblock sample at posedge of the clock
    output chi_rni_reqflitpend;     // VIP output
    output chi_rni_reqflitv;        // VIP output
    output chi_rni_reqflit;         // VIP output
    input  chi_rni_reqlcrdv;        // VIP input
  endclocking

  // Clocking block for the RXRSP channel driver
  clocking rxrsp_cb_drv @(posedge clk); // Clockingblock sample at posedge of the clock
    input  chi_rni_rxrspflitpend;     // VIP input
    input  chi_rni_rxrspflitv;        // VIP input
    input  chi_rni_rxrspflit;         // VIP input
    output chi_rni_rxrsplcrdv;        // VIP output
  endclocking
  
  // Clocking block for the RXDATA channel driver
  clocking rxdata_cb_drv @(posedge clk); // Clockingblock sample at posedge of the clock
    input  chi_rni_rxdatflitpend;     // VIP input
    input  chi_rni_rxdatflitv;        // VIP input
    input  chi_rni_rxdatflit;         // VIP input
    output chi_rni_rxdatlcrdv;        // VIP output
  endclocking

  // Clocking block for the TXRSP channel driver
  clocking txrsp_cb_drv @(posedge clk); // Clockingblock sample at posedge of the clock
    output chi_rni_txrspflitpend;     // VIP output
    output chi_rni_txrspflitv;        // VIP output
    output chi_rni_txrspflit;         // VIP output
    input  chi_rni_txrsplcrdv;        // VIP input
  endclocking

  // Clocking block for the TXDATA channel driver
  clocking txdata_cb_drv @(posedge clk); // Clockingblock sample at posedge of the clock
    output chi_rni_txdatflitpend;     // VIP output
    output chi_rni_txdatflitv;        // VIP output
    output chi_rni_txdatflit;         // VIP output
    input  chi_rni_txdatlcrdv;        // VIP input
  endclocking

  //CB MON

    // Clocking block for the TXREQ channel driver
  clocking txreq_cb_mon @(posedge clk); // Clockingblock sample at posedge of the clock
    output chi_rni_reqflitpend;     // VIP output
    output chi_rni_reqflitv;        // VIP output
    output chi_rni_reqflit;         // VIP output
    input  chi_rni_reqlcrdv;        // VIP input
  endclocking

  // Clocking block for the RXRSP channel driver
  clocking rxrsp_cb_mon @(posedge clk); // Clockingblock sample at posedge of the clock
    input  chi_rni_rxrspflitpend;     // VIP input
    input  chi_rni_rxrspflitv;        // VIP input
    input  chi_rni_rxrspflit;         // VIP input
    output chi_rni_rxrsplcrdv;        // VIP output
  endclocking
  
  // Clocking block for the RXDATA channel driver
  clocking rxdata_cb_mon @(posedge clk); // Clockingblock sample at posedge of the clock
    input  chi_rni_rxdatflitpend;     // VIP input
    input  chi_rni_rxdatflitv;        // VIP input
    input  chi_rni_rxdatflit;         // VIP input
    output chi_rni_rxdatlcrdv;        // VIP output
  endclocking

  // Clocking block for the TXRSP channel driver
  clocking txrsp_cb_mon @(posedge clk); // Clockingblock sample at posedge of the clock
    output chi_rni_txrspflitpend;     // VIP output
    output chi_rni_txrspflitv;        // VIP output
    output chi_rni_txrspflit;         // VIP output
    input  chi_rni_txrsplcrdv;        // VIP input
  endclocking

  // Clocking block for the TXDATA channel driver
  clocking txdata_cb_mon @(posedge clk); // Clockingblock sample at posedge of the clock
    output chi_rni_txdatflitpend;     // VIP output
    output chi_rni_txdatflitv;        // VIP output
    output chi_rni_txdatflit;         // VIP output
    input  chi_rni_txdatlcrdv;        // VIP input
  endclocking

  //Link Handshake FSM for RX channel
  always @(posedge clk or negedge rst_n)
    if(~rst_n) current_state_rx <= STOP         ;else
               current_state_rx <= next_state_rx;

  //Link Handshake FSM transition for RX channel
  always @(*) begin
    case (current_state_rx)
      STOP: begin
        if (chi_rni_rxlinkactivereq && chi_rni_rxsactive)
          next_state_rx = ACTIVATE;
      end
      ACTIVATE: begin
        if (chi_rni_rxlinkactiveack)
          next_state_rx = RUN;
      end
      RUN: begin
        if (~chi_rni_rxlinkactivereq)
          next_state_rx = DEACTIVATE;
      end
      DEACTIVATE: begin
        if (~chi_rni_rxlinkactiveack)
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
        if (chi_rni_txlinkactivereq && chi_rni_txsactive)
          next_state_tx = ACTIVATE;
      end
      ACTIVATE: begin
        if (chi_rni_txlinkactiveack)
          next_state_tx = RUN;
      end
      RUN: begin
        if (~chi_rni_txlinkactivereq)
          next_state_tx = DEACTIVATE;
      end
      DEACTIVATE: begin
        if (~chi_rni_txlinkactiveack)
          next_state_tx = STOP;
      end
      default: next_state_tx = STOP;
    endcase
  end

endinterface : chi_rni_if