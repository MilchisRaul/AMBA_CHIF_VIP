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
//  Description           : Agent for CHI RN-I Verification IP (UVC) which includes both rx and tx agents
//  ======================================================================================================

class chi_hni_tx_agent extends uvm_agent;
  
  `uvm_component_utils (chi_hni_tx_agent)

  // interfaces declaration (items)
  chi_hni_tx_sequencer                   m_tx_seqr;
  chi_hni_tx_driver                      m_tx_drv;
  chi_hni_tx_monitor                     m_tx_mon;
  chi_hni_tx_config_if                   m_tx_cfg;

  function new (string name = "chi_hni_tx_agent" , uvm_component parent = null); //agent constructor
    super.new (name, parent);
  endfunction: new

  //If Agent Is Active, create Driver and Sequencer, else skip
  //Always create Monitor regardless of the Agent's nature

  virtual function void build_phase (uvm_phase phase);
    super.build_phase (phase);

    //Get the information for the config if object from the cofig global database
    if(!uvm_config_db#(chi_hni_tx_config_if)::get(this, "", "tx_agt_cfg", m_tx_cfg))
      `uvm_fatal("NOCONFIG", {"Config object not set for: %s", get_full_name()})
        
    m_tx_mon = chi_hni_tx_monitor::type_id::create("m_tx_mon",this); // creating the monitor
   
    if(m_tx_cfg.is_active == UVM_ACTIVE) begin
      m_tx_drv = chi_hni_tx_driver::type_id::create("m_tx_drv",this);      
      m_tx_seqr =  chi_hni_tx_sequencer::type_id::create("m_tx_seqr",this);
    end

  endfunction: build_phase

  //Connecting agent components
  virtual function void connect_phase(uvm_phase phase);
    if(m_tx_cfg.is_active == UVM_ACTIVE) begin
      $display("%t DEBUG1, isactive", $time);
      m_tx_drv.seq_item_port.connect(m_tx_seqr.seq_item_export); //Connecting sequencer export port with the master driver port
    end
    //TODO: Add coverage connections
    //TODO: Connect the monitor to coverage
    //TODO: Connect the driver to coverage
  endfunction: connect_phase
  
endclass: chi_hni_tx_agent