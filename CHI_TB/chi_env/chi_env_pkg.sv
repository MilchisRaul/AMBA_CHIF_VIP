//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 12/03/2025
//  File name             : chi_env_pkg.sv
//  Last modified+updates : 12/03/2025 (RM) - Initial Version
//                          
//  Project               : CHI Protocol Test Bench
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Package which contains all environment level files
//  ======================================================================================================

package chi_env_pkg;

  import uvm_pkg::*;

  import chi_hni_pkg::*;   
  import chi_rni_pkg::*;   

  `include "uvm_macros.svh"

  `include "chi_proj_config.svh"
  `include "chi_virtual_sequencer.svh"
  //`include "chi_scoreboard.svh"
  `include "chi_env.svh"

endpackage : chi_env_pkg