//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : chi_hni_sequencer.svh
//  Last modified+updates : 16/02/2023 (RM)
//                          26/04/2023 (RM) - Modified ACE Structure into
//                                            Read and Write separate ACE UVC's
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Sequencer for chi_hni Verification IP (UVC)
//  ======================================================================================================

class chi_hni_tx_sequencer extends uvm_sequencer#(chi_hni_tx_item);

  `uvm_component_utils(chi_hni_tx_sequencer)

  chi_hni_tx_config_if m_chi_hni_tx_cfg;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(chi_hni_tx_config_if)::get(this, "", "tx_agt_cfg", m_chi_hni_tx_cfg))
      `uvm_fatal("NOCONFIG", {"Config object not set for: %s", get_full_name()})
  endfunction : build_phase

endclass : chi_hni_tx_sequencer