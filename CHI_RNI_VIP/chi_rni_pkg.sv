//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 21/02/2025
//  File name             : chi_rni_pkg.sv
//  Last modified+updates : 21/02/2025 (RM)
//  Project               : CHI Protocol RNI VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Package for chi_rni Verification IP (UVC), containing parameters needed and
//                          includes all UVC/VIP files
//  ======================================================================================================

package chi_rni_pkg;
  import uvm_pkg::*;
  //compiled in order
  `include "uvm_macros.svh"
  `include "chi_rni_defines.svh"
  `include "chi_rni_seq_item.svh"
  `include "chi_rni_config_if.sv"
  `include "chi_rni_driver.svh"
  `include "chi_rni_monitor.svh"
  `include "chi_rni_sequencer.svh"
  `include "chi_rni_agent.svh"
  `include "chi_rni_seq_lib.svh"

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
    
endpackage: chi_rni_pkg