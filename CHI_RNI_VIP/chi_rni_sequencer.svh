//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 21/02/2025
//  File name             : chi_rni_sequencer.svh
//  Last modified+updates : 21/02/2025 (RM)
//  Project               : CHI Protocol RNI VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Sequencer for chi_rni Verification IP (UVC)
//  ======================================================================================================

class chi_rni_rx_sequencer extends uvm_sequencer#(chi_rni_rx_item);

  `uvm_component_utils(chi_rni_rx_sequencer)

  chi_rni_rx_config_if m_chi_rni_rx_cfg;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(chi_rni_rx_config_if)::get(this, "", "rx_agt_cfg", m_chi_rni_rx_cfg))
      `uvm_fatal("NOCONFIG", {"Config object not set for: %s", get_full_name()})
  endfunction : build_phase

endclass : chi_rni_rx_sequencer

