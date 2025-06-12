//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : chi_hni_pkg.sv
//  Last modified+updates : 16/02/2023 (RM)
//                          26/04/2023 (RM) - Modified ACE Structure into
//                                            Read and Write separate ACE UVC's
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : chi_hni Verification IP (UVC) Package
//  ======================================================================================================

package chi_hni_pkg;
  import uvm_pkg::*;
  //compiled in order
  `include "uvm_macros.svh"
  `include "chi_hni_defines.svh"
  `include "chi_hni_seq_item.svh"
  `include "chi_hni_config_if.sv"
  `include "chi_hni_driver.svh"
  `include "chi_hni_monitor.svh"
  `include "chi_hni_sequencer.svh"
  `include "chi_hni_agent.svh"
  `include "chi_hni_seq_lib.svh"

  //VAR: R
  //Width of the req flit bus in bits
  parameter TX_R = `REQWIDTH;
  //Width of the RX rsp flit bus in bits
  parameter RX_T = `RSPWIDTH;
  //Width of the TX rsp flit bus in bits
  parameter TX_T = `RSPWIDTH;
  //Width of the read (RX) data flit bus in bits
  parameter RX_D = `DWIDTH;
  //Width of the write (TX) data flit bus in bits
  parameter TX_D = `DWIDTH;
  //Width of the number of credits;
  parameter CRDWIDTH = $clog2(`NUM_OF_CREDITS);

  //Internal signals FSM
  parameter STOP = 0;
  parameter ACTIVATE = 1;
  parameter RUN = 2;
  parameter DEACTIVATE = 3;
    
endpackage: chi_hni_pkg