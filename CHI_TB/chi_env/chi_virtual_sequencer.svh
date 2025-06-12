//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 12/03/2025
//  File name             : chi_virtual_sequencer.svh
//  Last modified+updates : 12/03/2025 (RM) - Initial Version
//                          
//  Project               : CHI Protocol Test Bench
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Virtual Sequencer for CHI Verification Environment
//  ======================================================================================================

class chi_virtual_sequencer extends uvm_sequencer;

  `uvm_component_utils(chi_virtual_sequencer)

  chi_proj_config m_chi_cfg;

  chi_hni_tx_sequencer m_hni_tx_seqr;
  chi_rni_rx_sequencer m_rni_rx_seqr;
  
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //Get the information into the m_chi_cfg for the project configuration from the config global database
    if(!uvm_config_db#(chi_proj_config)::get(this, "" , "m_chi_cfg" , m_chi_cfg))
      `uvm_fatal (get_type_name() , "Didn't get handle to chi_proj_config!")
  endfunction : build_phase

endclass : chi_virtual_sequencer
