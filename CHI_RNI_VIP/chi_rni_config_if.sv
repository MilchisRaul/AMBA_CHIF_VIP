//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 21/02/2025
//  File name             : chi_rni_config_if.sv
//  Last modified+updates : 21/02/2025 (RM)
//  Project               : CHI Protocol RNI VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Agent configuration interface for chi_rni Verification IP (UVC), contains config
//                          items like nature of the agent, type of the agent and the virtual interface 
//  ======================================================================================================

class chi_rni_rx_config_if extends uvm_object;

  uvm_active_passive_enum is_active = UVM_ACTIVE;
  
  agent_type_t agent_type = MASTER;

  virtual chi_rni_if v_if;

  bit coverage_en = 1;
  bit assertions_en = 1;

  `uvm_object_utils_begin(chi_rni_rx_config_if)
    `uvm_field_enum(uvm_active_passive_enum, is_active,    UVM_DEFAULT)
    `uvm_field_enum(agent_type_t,           agent_type,   UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "chi_rni_rx_config_if");
    super.new(name);
    //Get the information into the config_if virtual interface from the config global database
    if(!uvm_config_db #(virtual chi_rni_if)::get(null, "*" , "chi_rni_if" , v_if))
      `uvm_fatal (get_type_name() , "Didn't get handle to virtual interface v_if for the config if")
  endfunction : new

endclass : chi_rni_rx_config_if

class chi_rni_tx_config_if extends uvm_object;

  uvm_active_passive_enum is_active = UVM_ACTIVE;
  
  agent_type_t agent_type = MASTER;

  virtual chi_rni_if v_if;

  bit coverage_en;
  bit assertions_en;

  `uvm_object_utils_begin(chi_rni_tx_config_if)
    `uvm_field_enum(uvm_active_passive_enum, is_active,    UVM_DEFAULT)
    `uvm_field_enum(agent_type_t,           agent_type,   UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "chi_rni_tx_config_if");
    super.new(name);
    //Create the virtual interface
  endfunction : new

endclass : chi_rni_tx_config_if