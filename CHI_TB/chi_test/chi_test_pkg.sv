//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 12/03/2025
//  File name             : chi_test_pkg.sv
//  Last modified+updates : 12/03/2025 (RM) - Initial Version
//                          
//  Project               : CHI Protocol Test Bench
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Test package, containing all the test related class files
//  ======================================================================================================

package chi_test_pkg;

  import uvm_pkg::*;

  import chi_hni_pkg::*;
  import chi_rni_pkg::*;
  import chi_env_pkg::*;

  `include "uvm_macros.svh"
  `include "chi_vsequence_lib.svh"
  `include "chi_test_lib.svh"

endpackage : chi_test_pkg