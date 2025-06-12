//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 21/02/2025
//  File name             : chi_rni_agent.svh
//  Last modified+updates : 21/02/2025 (RM)
//  Project               : CHI Protocol RNI VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Agent for chi_rni Verification IP (UVC), contains connections, instances of all
//                          modules used to drive/monitor data
//  ======================================================================================================

class chi_rni_rx_agent extends uvm_agent;
  
  `uvm_component_utils (chi_rni_rx_agent)

  // interfaces declaration (items)
  chi_rni_rx_sequencer                   m_rx_seqr;
  chi_rni_rx_driver                      m_rx_drv;
  chi_rni_rx_monitor                     m_rx_mon;
  chi_rni_rx_config_if                   m_rx_cfg;

  function new (string name = "chi_rni_rx_agent" , uvm_component parent = null); //agent constructor
    super.new (name, parent);
  endfunction: new

  //If Agent Is Active, create Driver and Sequencer, else skip
  //Always create Monitor regardless of the Agent's nature

  virtual function void build_phase (uvm_phase phase);
    super.build_phase (phase);
    //Get the information for the config if object from the cofig global database
    if(!uvm_config_db#(chi_rni_rx_config_if)::get(this, "", "rx_agt_cfg", m_rx_cfg))
      `uvm_fatal("NOCONFIG", {"Config object not set for: %s", get_full_name()})

    m_rx_mon = chi_rni_rx_monitor::type_id::create("m_rx_mon",this); // creating the monitor
   
    if(m_rx_cfg.is_active == UVM_ACTIVE) begin
      m_rx_seqr =  chi_rni_rx_sequencer::type_id::create("m_rx_seqr",this);
      m_rx_drv = chi_rni_rx_driver::type_id::create("m_rx_drv",this);      
    end

  endfunction: build_phase

  //Connecting agent components
  virtual function void connect_phase (uvm_phase phase);
    if(m_rx_cfg.is_active == UVM_ACTIVE)
      m_rx_drv.seq_item_port.connect(m_rx_seqr.seq_item_export); //Connecting sequencer export port with the master driver port
    //TODO: Add coverage connections
    //TODO: Connect the monitor to coverage
    //TODO: Connect the driver to coverage
  endfunction: connect_phase
  
endclass: chi_rni_rx_agent