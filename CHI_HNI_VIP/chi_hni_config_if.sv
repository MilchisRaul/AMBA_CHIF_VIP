//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 12/03/2025
//  File name             : chi_hni_agent.svh
//  Last modified+updates : 12/03/2025 (RM) - Initial Version
//                          
//  Project               : CHI Protocol Home Node (HNI) VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Config object for CHI RN-I Verification IP (UVC)
//  ======================================================================================================

class chi_hni_tx_config_if extends uvm_object;

  uvm_active_passive_enum is_active = UVM_ACTIVE;
  
  agent_type_t agent_type = MASTER;

  virtual chi_hni_if v_if;

  bit coverage_en = 1;
  bit assertions_en = 1;

  `uvm_object_utils_begin(chi_hni_tx_config_if)
    `uvm_field_enum(uvm_active_passive_enum, is_active,    UVM_DEFAULT)
    `uvm_field_enum(agent_type_t,           agent_type,   UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "chi_hni_tx_config_if");
    super.new(name);
   //Get the information into the config_if virtual interface from the config global database
    if(!uvm_config_db #(virtual chi_hni_if)::get(null, "*" , "chi_hni_if" , v_if))
      `uvm_fatal (get_type_name() , "Didn't get handle to virtual interface v_if for the config if")
  endfunction : new

endclass : chi_hni_tx_config_if

class chi_hni_rx_config_if extends uvm_object;

  uvm_active_passive_enum is_active = UVM_ACTIVE;
  
  agent_type_t agent_type = MASTER;

  virtual chi_hni_if v_if;

  bit coverage_en;
  bit assertions_en;

  `uvm_object_utils_begin(chi_hni_rx_config_if)
    `uvm_field_enum(uvm_active_passive_enum, is_active,    UVM_DEFAULT)
    `uvm_field_enum(agent_type_t,           agent_type,   UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "chi_hni_rx_config_if");
    super.new(name);
    //Create the virtual interface
  endfunction : new

endclass : chi_hni_rx_config_if