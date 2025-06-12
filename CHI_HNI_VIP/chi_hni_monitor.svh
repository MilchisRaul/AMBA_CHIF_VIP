//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : chi_hni_monitor.svh
//  Last modified+updates : 16/02/2023 (RM)
//                          26/04/2023 (RM) - Modified ACE Structure into
//                                            Read and Write separate ACE UVC's
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Monitor for chi_hni Verification IP (UVC)
//  ======================================================================================================

class chi_hni_tx_monitor extends uvm_monitor;

  `uvm_component_utils (chi_hni_tx_monitor)

  
  //monitor constructor
  function new (string name = "chi_hni_tx_monitor" , uvm_component parent = null);
    super.new (name, parent);
  endfunction: new

  chi_hni_tx_item m_item;
  int unsigned num_of_txdata_credits = `NUM_OF_CREDITS;
  int unsigned num_of_txrsp_credits = `NUM_OF_CREDITS;

  chi_hni_tx_config_if tx_agt_cfg_if;

  uvm_analysis_port #(chi_hni_tx_item) mon_rxdat_analysis_port; //data analysis port input for monitor
  uvm_analysis_port #(chi_hni_tx_item) mon_rxdat_request_port; // partial data request analysis port for monitor

  uvm_analysis_port #(chi_hni_tx_item) mon_rxrsp_analysis_port; //data analysis port input for monitor
  uvm_analysis_port #(chi_hni_tx_item) mon_rxrsp_request_port; // partial data request analysis port for monitor

  //Defines the maximum number of credits, which is 15 according to the CHI-F protocol spec
  constraint num_of_maximum_credit_values {
    num_of_txrsp_credits <= 15;
    num_of_txdata_credits <= 15;
  }

  virtual function void build_phase (uvm_phase phase);
    super.build_phase (phase);

    if(!uvm_config_db#(chi_hni_tx_config_if)::get(this, "", "tx_agt_cfg", tx_agt_cfg_if))
      `uvm_fatal("NOCONFIG", {"Config object must be set for: ", get_full_name(), ".tx_agt_cfg"})
    //Creation of declared analysis port
    mon_rxdat_analysis_port = new ("mon_rxdat_analysis_port", this);
    mon_rxdat_request_port = new ("mon_rxdat_request_port", this);

    mon_rxrsp_analysis_port = new ("mon_rxrsp_analysis_port", this);
    mon_rxrsp_request_port = new ("mon_rxrsp_request_port", this);
  endfunction: build_phase

   virtual task run_phase(uvm_phase phase);
    process reset_thread;
    process txrsp_cred_thread;
    process txdata_cred_thread;

    // Wait for reset de-assertion
    @(negedge tx_agt_cfg_if.v_if.rst_n);
    init();
    fork
      begin : handle_txrsp_credit_t
        txrsp_cred_thread = process::self();
        // Manage and update response credits continuously
        handle_txrsp_credit_cnt();
      end
      begin : handle_txdata_credit_t
        txdata_cred_thread = process::self();
        // Manage and update data credits continuously
        handle_txdata_credit_cnt();
      end
      begin : reset_t
        reset_thread = process::self();
        // Wait for reset event, then stop credit threads and reset monitor
        @(negedge tx_agt_cfg_if.v_if.rst_n);
        if(txrsp_cred_thread.status() != "FINISHED")
          txrsp_cred_thread.kill();
        if(txdata_cred_thread.status() != "FINISHED")
          txdata_cred_thread.kill();
        reset_monitor();
      end
    join_any
    // Ensure reset thread is terminated
    if(reset_thread.status() != "FINISHED")
      reset_thread.kill();

  endtask : run_phase

  task init();
    tx_agt_cfg_if.v_if.txrsp_crd_cnt = 0;
    tx_agt_cfg_if.v_if.txdata_crd_cnt = 0;
  endtask : init

  //Function: handle_txrsp_credit_cnt
  //Desc: Monitor the credit valid and increment the counter when this signal is "1"
  task handle_txrsp_credit_cnt();
    forever begin : increment_rsp_cred_cnt
      @(tx_agt_cfg_if.v_if.txrsp_cb_mon iff tx_agt_cfg_if.v_if.chi_hni_txrsplcrdv && (tx_agt_cfg_if.v_if.current_state_tx != STOP));
      tx_agt_cfg_if.v_if.txrsp_crd_cnt++;
      if(tx_agt_cfg_if.v_if.txrsp_crd_cnt > num_of_txrsp_credits)
        `uvm_error (get_type_name() , $sformatf("txrsp_crd_cnt credit counter incremented over the upper limit which is %d", num_of_txrsp_credits))
      `uvm_info(get_type_name(), $sformatf ("Incremented txrsp_credit_cnt = %d, valid credit observed on mon", tx_agt_cfg_if.v_if.txrsp_crd_cnt), UVM_HIGH)
    end
  endtask

  //Function: handle_txdata_credit_cnt
  //Desc: Monitor the credit valid and increment the counter when this signal is "1"
  task handle_txdata_credit_cnt();
    forever begin : increment_data_cred_cnt
      @(tx_agt_cfg_if.v_if.txdata_cb_mon iff tx_agt_cfg_if.v_if.chi_hni_txdatlcrdv && (tx_agt_cfg_if.v_if.current_state_tx != STOP));
      tx_agt_cfg_if.v_if.txdata_crd_cnt++;
      if(tx_agt_cfg_if.v_if.txdata_crd_cnt > num_of_txdata_credits)
         `uvm_error (get_type_name() , $sformatf("txdata_crd_cnt credit counter incremented over the upper limit which is %d", num_of_txdata_credits))
      `uvm_info(get_type_name(), $sformatf ("Incremented txdata_credit_cnt =%d, valid credit observed on mon", tx_agt_cfg_if.v_if.txdata_crd_cnt), UVM_HIGH)
    end
  endtask

  virtual function void reset_monitor();
    //TODO: Reset monitor specific state variables (cnt, flags, buffers etc.)
    tx_agt_cfg_if.v_if.rxrsp_crd_cnt = 0;
    tx_agt_cfg_if.v_if.rxdata_crd_cnt = 0;
  endfunction

endclass : chi_hni_tx_monitor