//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 12/03/2025
//  File name             : chi_top.sv
//  Last modified+updates : 12/03/2025 (RM) - Initial Version
//                          
//  Project               : CHI Protocol Test Bench
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Testbench top of the CHI project
//  ======================================================================================================

module chi_top;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import chi_env_pkg::*;
  import chi_test_pkg::*;

  import chi_rni_pkg::*;
  import chi_hni_pkg::*;

  reg clk;
  reg rst_n;

  localparam NUM_OF_TXDATA_CREDITS_TB = 4;
  localparam NUM_OF_TXRSP_CREDITS_TB = 4;

  localparam NUM_OF_RXDATA_CREDITS_TB = 4;
  localparam NUM_OF_RXRSP_CREDITS_TB = 4;
  chi_hni_if #(
    .TP          (0),
    .NUM_OF_TXDATA_CREDITS(NUM_OF_TXDATA_CREDITS_TB),
    .NUM_OF_TXRSP_CREDITS(NUM_OF_TXRSP_CREDITS_TB)
  ) i_chi_hni_if (
    .clk  (clk),
    .rst_n(rst_n)
  );

  chi_rni_if #(
    .TP          (0),
    .NUM_OF_RXDATA_CREDITS(NUM_OF_RXDATA_CREDITS_TB),
    .NUM_OF_RXRSP_CREDITS(NUM_OF_RXRSP_CREDITS_TB)
  ) i_chi_rni_if (
    .clk  (clk),
    .rst_n(rst_n)
  );
  
  assign i_chi_rni_if.chi_rni_rxsactive = i_chi_hni_if.chi_hni_txsactive;
  //RXRSP RNI <-> TXRSP HNI channels connections
  assign i_chi_rni_if.chi_rni_rxrspflitpend = i_chi_hni_if.chi_hni_txrspflitpend;
  assign i_chi_rni_if.chi_rni_rxrspflitv    = i_chi_hni_if.chi_hni_txrspflitv;
  assign i_chi_rni_if.chi_rni_rxrspflit     = i_chi_hni_if.chi_hni_txrspflit;
  assign i_chi_hni_if.chi_hni_txrsplcrdv    = i_chi_rni_if.chi_rni_rxrsplcrdv;
  //RXDAT RNI <-> TXDAT HNI channels connections
  assign i_chi_rni_if.chi_rni_rxdatflitpend = i_chi_hni_if.chi_hni_txdatflitpend;
  assign i_chi_rni_if.chi_rni_rxdatflitv    = i_chi_hni_if.chi_hni_txdatflitv;
  assign i_chi_rni_if.chi_rni_rxdatflit     = i_chi_hni_if.chi_hni_txdatflit;
  assign i_chi_hni_if.chi_hni_txdatlcrdv    = i_chi_rni_if.chi_rni_rxdatlcrdv;

  //Connect FSM signals
  assign i_chi_rni_if.chi_rni_rxlinkactivereq = i_chi_hni_if.chi_hni_txlinkactivereq;
  assign i_chi_hni_if.chi_hni_txlinkactiveack = i_chi_rni_if.chi_rni_rxlinkactiveack;

  initial begin
    clk = 1'b0;
    forever begin
      #10;
      clk = ~clk; 
    end
  end

  initial begin
    rst_n = 1'b1;
    #100;
    @(posedge clk);
    `uvm_info("TB_TOP", "Reset asserted!", UVM_NONE)
    rst_n = 1'b0;
    #100;
    @(posedge clk);
    `uvm_info("TB_TOP", "Reset deasserted!", UVM_NONE)
    rst_n = 1'b1;
  end

  initial begin
    uvm_config_db #(virtual chi_hni_if)::set (null, "*", "chi_hni_if", i_chi_hni_if);
    uvm_config_db #(virtual chi_rni_if)::set (null, "*", "chi_rni_if", i_chi_rni_if);
    run_test("chi_read_no_snoop_sanity_test");
  end


endmodule : chi_top
