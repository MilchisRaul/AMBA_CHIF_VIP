//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 12/03/2025
//  File name             : chi_proj_config.svh
//  Last modified+updates : 12/03/2025 (RM) - Initial Version
//                          
//  Project               : CHI Protocol Test Bench
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Environment configuration object for CHI project
//  ======================================================================================================

class chi_proj_config extends uvm_object;

  chi_hni_tx_config_if m_hni_tx_agt_cfg;
  chi_rni_rx_config_if m_rni_rx_agt_cfg;

  uvm_active_passive_enum is_active = UVM_ACTIVE;
  bit                     has_checks = 1;
  bit                     has_coverage = 1;

  `uvm_object_utils_begin(chi_proj_config)
    `uvm_field_int(                          has_checks,   UVM_DEFAULT)
    `uvm_field_int(                          has_coverage, UVM_DEFAULT)
    `uvm_field_enum(uvm_active_passive_enum, is_active,    UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "chi_proj_config");
    super.new(name);
  endfunction : new

  function void build();
  
    m_hni_tx_agt_cfg = chi_hni_tx_config_if::type_id::create("m_hni_tx_agt_cfg");
    m_rni_rx_agt_cfg = chi_rni_rx_config_if::type_id::create("m_rni_rx_agt_cfg");

    if(is_active == UVM_ACTIVE) begin
      //ACE Read
      m_hni_tx_agt_cfg.is_active  = UVM_ACTIVE;
      m_hni_tx_agt_cfg.agent_type = chi_hni_pkg::MASTER;

      m_rni_rx_agt_cfg.is_active = UVM_ACTIVE;
      m_rni_rx_agt_cfg.agent_type = chi_rni_pkg::MASTER;

    end 
    else begin
      m_rni_rx_agt_cfg.is_active  = UVM_PASSIVE;
      m_hni_tx_agt_cfg.is_active = UVM_PASSIVE;
    end
    
  endfunction : build

endclass : chi_proj_config
