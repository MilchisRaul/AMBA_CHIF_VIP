//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 21/02/2025
//  File name             : chi_rni_driver.svh
//  Last modified+updates : 21/02/2025 (RM)
//  Project               : CHI Protocol RNI VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Driver for chi_rni Verification IP (UVC), implements mechanism to send credits,
//                          to retrieve items from the sequencer and synchronize them in mailboxes, and
//                          to drive acknowledge signal low/high
//  ======================================================================================================

class chi_rni_rx_driver extends uvm_driver#(chi_rni_rx_item);
  
  `uvm_component_utils (chi_rni_rx_driver)

  //Mailboxes instances
  mailbox#(chi_rni_rx_item) rxrsp_credit_item_mb;
  mailbox#(chi_rni_rx_item) rxdata_credit_item_mb;
  //Mailbox to put in it ACTIVATE->RUN item for the link hs fsm
  mailbox#(chi_rni_rx_item) linkactive_ack_run_item_mb;
  //Mailbox to put in it DEACTIVATE->STOP item for the link hs fsm
  mailbox#(chi_rni_rx_item) linkactive_ack_stop_item_mb;

  //Events to control the synchronization between mailboxex 
  //RXRSP and RXDATA received items events
  event rcvd_rxrsp_cred_ev;
  event rcvd_rxdata_cred_ev;
  //Event to specify that one ACTIVATE->RUN item is available for link hs fsm
  event rcvd_linkactiveack_run_ev;
  //Event to specify that one DEACTIVATE->STOP item is available for link hs fsm
  event rcvd_linkactiveack_stop_ev;

  //Items retrieved from mb and used in drive tasks
  chi_rni_rx_item rxrsp_itm_from_mb;
  chi_rni_rx_item rxdata_itm_from_mb;
  chi_rni_rx_item linkactive_ack_run_itm_from_mb;
  chi_rni_rx_item linkactive_ack_stop_itm_from_mb;

  //Process for the component reset awareness
  process p_drive_t;
  process p_rst_th;
  process p_rxrsp_th;
  process p_rxdata_th;
  process p_link_run_th;
  process p_link_stop_th;

  //Config if
  chi_rni_rx_config_if rx_agt_cfg_if;

  //class constructor
  function new (string name = "chi_rni_rx_driver" , uvm_component parent = null);
    super.new (name, parent);
  endfunction: new

  virtual function void build_phase (uvm_phase phase);
    super.build_phase (phase);
    //get agt config and virtual interface information from config db
    if(!uvm_config_db#(chi_rni_rx_config_if)::get(this, "", "rx_agt_cfg", rx_agt_cfg_if))
      `uvm_fatal("NOCONFIG", {"Config object must be set for: ", get_full_name(), ".rx_agt_cfg"})
    //Initialise mailboxes
    rxrsp_credit_item_mb = new();
    rxdata_credit_item_mb = new();
    linkactive_ack_run_item_mb = new();
    linkactive_ack_stop_item_mb = new();
  endfunction: build_phase

  task run_phase(uvm_phase phase);
    //Init all the mbx, items, signals, counters
    init();
    //Wait reset posedge (when reset, wait for it to finish) and consume clocks
    while(rx_agt_cfg_if.v_if.rst_n) 
      @(posedge rx_agt_cfg_if.v_if.clk);
    //Wait posedge of reset
    @(posedge rx_agt_cfg_if.v_if.rst_n);
    fork 
      begin : main_activity_t
        fork 
        //Drive flits
        begin : get_items_from_seq_item_port_t
          p_drive_t = process::self();
          get_and_drive();
        end
        begin : drive_rsp_channel_t
          p_rxrsp_th = process::self();
          drive_rsp_channel();
        end
        begin : drive_data_channel_t
          p_rxdata_th = process::self();
          drive_data_channel();
        end
        begin : drive_link_ack_run_t
          p_link_run_th = process::self();
          drive_rxlinkactiveack_run_channel();
        end
        begin : drive_link_ack_stop_t
          p_link_stop_th = process::self();
          drive_rxlinkactiveack_stop_channel();
        end
        join
      end
      begin : handle_reset_t
        p_rst_th = process::self();  
        @(negedge rx_agt_cfg_if.v_if.rst_n) begin
          //interrupt the current item at reset
          if(p_drive_t.status() != "FINISHED") 
            p_drive_t.kill();
          if(p_rxrsp_th.status() != "FINISHED") 
            p_rxrsp_th.kill();
          if(p_rxdata_th.status() != "FINISHED") 
            p_rxdata_th.kill();
          if(p_link_run_th.status() != "FINISHED") 
            p_link_run_th.kill();
          if(p_link_stop_th.status() != "FINISHED") 
            p_link_stop_th.kill();
          init();
        end
      end
    join_any
    if(p_rst_th.status() == "FINISHED") p_rst_th.kill();

  endtask: run_phase

  task get_and_drive();
    forever begin
      $display("%t DEBUG1 bfr get_next_item rni driver", $time);
      seq_item_port.get_next_item(req); //getting transaction data from TLM sequencer port
      $display($sformatf("%t DEBUG2 after get_next_item rni driver, item contents: %s", $time, req.sprint()));

      //Put the corresponding items in maibloxes, to future retrieve the needed depending of the item scope
      //set from the sequence level
      if (req.resp_flit_scope)
        rxrsp_credit_item_mb.put(req);
      if (req.data_flit_scope)
        rxdata_credit_item_mb.put(req);
      if (req.link_active_ack_run_scope)
        linkactive_ack_run_item_mb.put(req);
      if (req.link_active_ack_stop_scope)
        linkactive_ack_stop_item_mb.put(req);
      //Foreach of the items below, if there is an item available in the mailbox, get it and 
      //consume it and get back to the get_next_item to receive the next item
      fork  
        begin : trigger_rxrsp_ev
          @(rcvd_rxrsp_cred_ev);
          $display("%t, rcvd_rxrsp_cred_ev happened", $time);
        end
        begin : trigger_rxdata_ev
          @(rcvd_rxdata_cred_ev);
          $display("%t, rcvd_rxdata_cred_ev happened", $time);
        end
        begin : trigger_linkack_run_ev
          @(rcvd_linkactiveack_run_ev);
          $display("%t, rcvd_linkactiveack_run_ev happened", $time);
        end
        begin : trigger_linkack_stop_ev
          @(rcvd_linkactiveack_stop_ev);
          $display("%t, rcvd_linkactiveack_stop_ev happened", $time);
        end
      join_any
      $display("%t, Item done, getting next item...", $time);
      seq_item_port.item_done(); //all requested transaction data was successfully driven to the virtual interface that 
                                 //communicates with the DUT
    end
  endtask: get_and_drive
  //Function: init
  //Desc: Function to initialise the signals
  task init();

    rx_agt_cfg_if.v_if.chi_rni_rxlinkactiveack <= 1'b0;
    rx_agt_cfg_if.v_if.chi_rni_rxrsplcrdv <= 1'b0;
    rx_agt_cfg_if.v_if.chi_rni_rxdatlcrdv <= 1'b0;
    //Pre-load the counters with the maximum avail credit values, in that way rx module
    //can send credits to the other tx side
    rx_agt_cfg_if.v_if.rxrsp_crd_cnt = rx_agt_cfg_if.v_if.NUM_OF_RXRSP_CREDITS;
    rx_agt_cfg_if.v_if.rxdata_crd_cnt = rx_agt_cfg_if.v_if.NUM_OF_RXDATA_CREDITS;
    mb_flush();
  endtask : init

  function mb_flush();
    //Temp item to help to flush mb
    chi_rni_rx_item temp_data;
    //Flush all the mailboxes at reset/initialization
    while(rxrsp_credit_item_mb.try_get(temp_data));
    while(rxdata_credit_item_mb.try_get(temp_data));
    while(linkactive_ack_run_item_mb.try_get(temp_data));
    while(linkactive_ack_stop_item_mb.try_get(temp_data));
  endfunction

  //Function: drive_rxrsp_credit
  //Desc: Function to drive rx resp credits to the TX side
  //The task drives credits with a configurable delay, from the sequence item and it drives until
  //the credit counter reaches the maximum credit number 
  task drive_rxrsp_credit(chi_rni_rx_item rxrsp_crd_item);
    $display("%t, Start of drive_rxrsp_credit task", $time);
    begin 
      fork 
        begin : INCREMENT_RXRSPCRED_CNT_T
          @(posedge rx_agt_cfg_if.v_if.clk iff (rx_agt_cfg_if.v_if.rxrsp_crd_cnt < rx_agt_cfg_if.v_if.NUM_OF_RXRSP_CREDITS) && (rx_agt_cfg_if.v_if.current_state_rx == RUN));
            repeat(rxrsp_crd_item.rxrsp_cred_dly) @(rx_agt_cfg_if.v_if.rxrsp_cb_drv);
            rx_agt_cfg_if.v_if.chi_rni_rxrsplcrdv <= 1'b1;
            @(rx_agt_cfg_if.v_if.rxrsp_cb_drv);
            rx_agt_cfg_if.v_if.chi_rni_rxrsplcrdv <= 1'b0;
            rx_agt_cfg_if.v_if.rxrsp_crd_cnt++;
          if (rx_agt_cfg_if.v_if.rxrsp_crd_cnt > rx_agt_cfg_if.v_if.NUM_OF_RXRSP_CREDITS)
            `uvm_error (get_type_name() , $sformatf("rxrsp_crd_cnt credit counter incremented over the upper limit which is %d", rx_agt_cfg_if.v_if.NUM_OF_RXRSP_CREDITS))
        end
        begin : DECREMENT_RXRSPCRD_CNT_T
          @(posedge rx_agt_cfg_if.v_if.clk iff rx_agt_cfg_if.v_if.chi_rni_rxrsplcrdv);
          if(rx_agt_cfg_if.v_if.rxrsp_crd_cnt > 0)
            rx_agt_cfg_if.v_if.rxrsp_crd_cnt--;
          else if(rx_agt_cfg_if.v_if.rxrsp_crd_cnt < 0)
            `uvm_error (get_type_name() , $sformatf("rxrsp_crd_cnt credit counter decremented under the lower limit which is 0"))
        end
      join_any 
    end
    $display("%t, End of drive_rxrsp_credit task", $time);
  endtask

  //Function: drive_rxdata_credit
  //Desc: Function to drive data rx credits to the TX side
  //The task drives credits with a configurable delay, from the sequence item and it drives when
  //the credit counter reaches the maximum credit number, it stops driving credits
  task drive_rxdata_credit(chi_rni_rx_item rxdata_crd_item);
    $display("%t, Start of drive_rxdata_credit task", $time);
    fork 
      begin : INCREMENT_RXDATCRED_CNT_T
        @(posedge rx_agt_cfg_if.v_if.clk iff (rx_agt_cfg_if.v_if.rxdata_crd_cnt < rx_agt_cfg_if.v_if.NUM_OF_RXDATA_CREDITS) && (rx_agt_cfg_if.v_if.current_state_rx == RUN));
          repeat(rxdata_crd_item.rxdata_cred_dly) @(rx_agt_cfg_if.v_if.rxdata_cb_drv);
          rx_agt_cfg_if.v_if.chi_rni_rxdatlcrdv <= 1'b1;
          @(rx_agt_cfg_if.v_if.rxdata_cb_drv);
          rx_agt_cfg_if.v_if.chi_rni_rxdatlcrdv <= 1'b0;
          rx_agt_cfg_if.v_if.rxdata_crd_cnt++;
        if (rx_agt_cfg_if.v_if.rxdata_crd_cnt > rx_agt_cfg_if.v_if.NUM_OF_RXDATA_CREDITS)
          `uvm_error (get_type_name() , $sformatf("rxdata_crd_cnt credit counter incremented over the upper limit which is %d", rx_agt_cfg_if.v_if.NUM_OF_RXDATA_CREDITS))
      end
      begin : DECREMENT_RXDATCRD_CNT_T
        @(posedge rx_agt_cfg_if.v_if.clk iff rx_agt_cfg_if.v_if.chi_rni_rxdatlcrdv);
        if(rx_agt_cfg_if.v_if.rxdata_crd_cnt > 0)
          rx_agt_cfg_if.v_if.rxdata_crd_cnt--;
        else if(rx_agt_cfg_if.v_if.rxdata_crd_cnt < 0)
          `uvm_error (get_type_name() , $sformatf("rxdata_crd_cnt credit counter decremented under the lower limit which is 0"))
      end
    join_any
    $display("%t, End of drive_rxdata_credit task", $time);
  endtask

  //Function: drive_rxlinkactiveack
  //Desc: Task to drive/control rxlinkactiveack signal
  task drive_rxlinkactiveack_run(chi_rni_rx_item m_chi_rx_item);
    $display("%t, Start of drive_rxlinkactiveack_run task", $time);
    //FROM STOP -> ACTIVATE
    @(posedge rx_agt_cfg_if.v_if.chi_rni_rxlinkactivereq);
    if(!rx_agt_cfg_if.v_if.chi_rni_rxsactive)
      repeat(m_chi_rx_item.rx_linkack_activate_delay) @(posedge rx_agt_cfg_if.v_if.clk);
    //FROM ACTIVATE -> RUN
    @(posedge rx_agt_cfg_if.v_if.clk);
    rx_agt_cfg_if.v_if.chi_rni_rxlinkactiveack <= 1'b1;
    $display("%t, End of drive_rxlinkactiveack_run task", $time);
  endtask

  task drive_rxlinkactiveack_stop(chi_rni_rx_item m_chi_rx_item);
    //FROM RUN -> DEACTIVATE
    @(negedge rx_agt_cfg_if.v_if.chi_rni_rxlinkactivereq);
    wait(rx_agt_cfg_if.v_if.rxrsp_crd_cnt == 0 && rx_agt_cfg_if.v_if.rxdata_crd_cnt == 0);
    repeat(m_chi_rx_item.rx_linkack_deactivate_delay) @(posedge rx_agt_cfg_if.v_if.clk);
    //FROM DEACTIVATE -> STOP
    rx_agt_cfg_if.v_if.chi_rni_rxlinkactiveack <= 1'b0;
  endtask

  task drive_rsp_channel();
    forever begin
      rxrsp_credit_item_mb.get(rxrsp_itm_from_mb);
      $display("%t, Got an rxrsp credit item form mb!", $time);
      drive_rxrsp_credit(rxrsp_itm_from_mb);
      $display("%t, Finish rxrsp credit item form mb!", $time);
      ->rcvd_rxrsp_cred_ev;
    end
  endtask

  task drive_data_channel();
    forever begin
      $display("%t, Got an rxdata credit item form mb!", $time);
      rxdata_credit_item_mb.get(rxdata_itm_from_mb);
      $display("%t, Finish rxdata credit item form mb!", $time);
      drive_rxdata_credit(rxdata_itm_from_mb);
      ->rcvd_rxdata_cred_ev;
    end
  endtask

  task drive_rxlinkactiveack_run_channel();
    forever begin
      $display("%t, Got an link_ack_run item form mb!", $time);
      linkactive_ack_run_item_mb.get(linkactive_ack_run_itm_from_mb);
      $display("%t, Finish link_ack_run item form mb!", $time);
      drive_rxlinkactiveack_run(linkactive_ack_run_itm_from_mb);
      ->rcvd_linkactiveack_run_ev;
    end
  endtask

  task drive_rxlinkactiveack_stop_channel();
    forever begin
      linkactive_ack_stop_item_mb.get(linkactive_ack_stop_itm_from_mb);
      $display("%t, Got an link_ack_stop item form mb!", $time);
      drive_rxlinkactiveack_stop(linkactive_ack_stop_itm_from_mb);
      $display("%t, Finish link_ack_stop item form mb!", $time);
      ->rcvd_linkactiveack_stop_ev;
    end
  endtask

endclass : chi_rni_rx_driver