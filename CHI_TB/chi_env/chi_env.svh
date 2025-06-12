//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 12/03/2025
//  File name             : chi_env.svh
//  Last modified+updates : 12/03/2025 (RM) - Initial Version
//                          
//  Project               : CHI Protocol Test Bench
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Verification Environment for CHI Verification Environment
//  ======================================================================================================

class chi_env extends uvm_env;

  `uvm_component_utils(chi_env)

  chi_hni_tx_agent  hni_tx_agt;
  chi_rni_rx_agent  rni_rx_agt;

  chi_virtual_sequencer  v_seqr;

  chi_proj_config        m_chi_cfg;

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    m_chi_cfg = new("m_chi_cfg");
    m_chi_cfg.is_active = UVM_ACTIVE;
    m_chi_cfg.build();

    uvm_config_db#(chi_proj_config)::set(null, "*", "m_chi_cfg", m_chi_cfg);

    hni_tx_agt = chi_hni_tx_agent::type_id::create("hni_tx_agt", this);
    uvm_config_db#(chi_hni_tx_config_if)::set(null, "*", "tx_agt_cfg", m_chi_cfg.m_hni_tx_agt_cfg);

    rni_rx_agt = chi_rni_rx_agent::type_id::create("rni_rx_agt", this);
    uvm_config_db#(chi_rni_rx_config_if)::set(null, "*", "rx_agt_cfg", m_chi_cfg.m_rni_rx_agt_cfg);

    v_seqr = chi_virtual_sequencer::type_id::create("v_seqr", this);

  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    //Connect agent sequencers to virtual sequencers so in that way they can be accessed.
    v_seqr.m_hni_tx_seqr = hni_tx_agt.m_tx_seqr;
    v_seqr.m_rni_rx_seqr = rni_rx_agt.m_rx_seqr;

  endfunction : connect_phase

endclass : chi_env