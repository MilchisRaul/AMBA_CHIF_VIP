//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : chi_hni_master_driver.svh
//  Last modified+updates : 16/02/2023 (RM)
//                          26/04/2023 (RM) - Modified ACE Structure into
//                                            Read and Write separate ACE UVC's
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Master Driver for chi_hni Verification IP (UVC)
//  ======================================================================================================

class chi_hni_tx_driver extends uvm_driver#(chi_hni_tx_item);
  
  `uvm_component_utils (chi_hni_tx_driver)

  //Mailboxes instances
  mailbox#(chi_hni_tx_item) txrsp_pending_item_mb;
  mailbox#(chi_hni_tx_item) txdata_pending_item_mb;
  //Mailbox to put in it STOP -> ACTIVATE item for the link hs fsm
  mailbox#(chi_hni_tx_item) linkactive_req_run_item_mb;
  //Mailbox to put in it RUN -> DEACTIVATE item for the link hs fsm
  mailbox#(chi_hni_tx_item) linkactive_req_stop_item_mb;

  //Events to control the synchronization between mailboxex 
  //TXRSP and TXDATA flitpending received items events
  event drive_txrsp_pend_ev;
  event drive_txdata_pend_ev;
  //Event to specify that one STOP -> ACTIVATE item is available for link hs fsm
  event drive_linkactivereq_run_ev;
  //Event to specify that one RUN -> DEACTIVATE item is available for link hs fsm
  event drive_linkactivereq_stop_ev;

  //Items retrieved from mb and used in drive tasks
  chi_hni_tx_item txrsp_itm_from_mb;
  chi_hni_tx_item txdata_itm_from_mb;
  chi_hni_tx_item linkactive_req_run_itm_from_mb;
  chi_hni_tx_item linkactive_req_stop_itm_from_mb;

  //Link request activate and deactivate delay intervals
  int unsigned tx_linkreq_deactivate_delay;
  int unsigned tx_linkreq_activate_delay;

  //Data pending signal delay - up(HIGH) and down (LOW)
  int unsigned txdata_pending_up_delay;
  int unsigned txdata_pending_down_delay;
  //Resp pending signal delay - up(HIGH) and down (LOW)
  int unsigned txrsp_pending_up_delay;
  int unsigned txrsp_pending_down_delay;
  
  //Process for the component reset awareness
  process p_drive_t;
  process p_rst_th;
  process p_txrsp_fltpend_th;
  process p_txdata_fltpend_th;
  process p_link_run_th;
  process p_link_stop_th;

  //Config if
  chi_hni_tx_config_if tx_agt_cfg_if;

  //class constructor
  function new (string name = "chi_hni_tx_driver" , uvm_component parent = null);
    super.new (name, parent);

  endfunction: new

  virtual function void build_phase (uvm_phase phase);
    super.build_phase (phase);
    //Initialise mailboxes
    txrsp_pending_item_mb = new();
    txdata_pending_item_mb = new();
    linkactive_req_run_item_mb = new();
    linkactive_req_stop_item_mb = new();

    //get agt config and virtual interface information from config db
    if(!uvm_config_db#(chi_hni_tx_config_if)::get(null, "", "tx_agt_cfg", tx_agt_cfg_if))
      `uvm_fatal("NOCONFIG", {"Config object must be set for: ", get_full_name(), ".tx_agt_cfg"})
  endfunction: build_phase

  task run_phase(uvm_phase phase);
    //Init all the mbx, items, signals, counters
    init();
    //Wait reset posedge (when reset, wait for it to finish) and consume clocks
    while(tx_agt_cfg_if.v_if.rst_n) 
      @(posedge tx_agt_cfg_if.v_if.clk);
    //Wait posedge of reset
    @(posedge tx_agt_cfg_if.v_if.rst_n);
    $display("%t DEBUG3 enter the run_phase of hni driver", $time);
    fork 
      begin : main_activity_t
        fork 
        //Drive flits
        begin : get_items_from_seq_item_port_t
          p_drive_t = process::self();
          get_and_drive();
        end
        begin : drive_rsp_channel_t
          p_txrsp_fltpend_th = process::self();
          drive_rsp_channel();
        end
        begin : drive_data_channel_t
          p_txdata_fltpend_th = process::self();
          drive_data_channel();
        end
        begin : drive_link_req_run_t
          p_link_run_th = process::self();
          drive_rxlinkactivereq_run_channel();
        end
        begin : drive_link_req_stop_t
          p_link_stop_th = process::self();
          drive_rxlinkactivereq_stop_channel();
        end
        join
      end
      begin : handle_reset_t
        p_rst_th = process::self();  
        @(negedge tx_agt_cfg_if.v_if.rst_n) begin
          //interrupt the current item at reset
          if(p_drive_t.status() != "FINISHED") 
            p_drive_t.kill();
          if(p_txrsp_fltpend_th.status() != "FINISHED") 
            p_txrsp_fltpend_th.kill();
          if(p_txdata_fltpend_th.status() != "FINISHED") 
            p_txdata_fltpend_th.kill();
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
      $display("%t DEBUG4 bfr get_next_item hni driver", $time);
      seq_item_port.get_next_item(req); //getting transaction data from TLM sequencer port
      $display($sformatf("%t DEBUG5 after get_next_item hni driver, item %s", $time, req.sprint()));
      //Put the corresponding items in maibloxes, to future retrieve the needed depending of the item scope
      //set from the sequence level
      if(req.resp_flit_scope)
        txrsp_pending_item_mb.put(req);
      if (req.data_flit_scope)
        txdata_pending_item_mb.put(req);
      if (req.link_active_req_run_scope)
        linkactive_req_run_item_mb.put(req);
      if (req.link_active_req_stop_scope)
        linkactive_req_stop_item_mb.put(req);
      //Foreach of the items below, if there is an item available in the mailbox, get it and 
      //consume it and get back to the get_next_item to receive the next item
      fork  
        begin : trigger_rxrsp_ev
          @(drive_txrsp_pend_ev);
        end
        begin : trigger_rxdata_ev
          @(drive_txdata_pend_ev);
        end
        begin : trigger_linkack_run_ev
          @(drive_linkactivereq_run_ev);
        end
        begin : trigger_linkack_stop_ev
          @(drive_linkactivereq_stop_ev);
        end
      join_any

      seq_item_port.item_done(); //all requested transaction data was successfully driven to the virtual interface that 
                                 //communicates with the DUT
    end
  endtask: get_and_drive

  //Function: init
  //Desc: Function to initialise the signals
  task init();
    tx_agt_cfg_if.v_if.chi_hni_txlinkactivereq <= 1'b0;
    tx_agt_cfg_if.v_if.chi_hni_txsactive <= 1'b0;
    //RSP channel init
    tx_agt_cfg_if.v_if.chi_hni_txrspflitpend <= 1'b0;
    tx_agt_cfg_if.v_if.chi_hni_txrspflitv <= 1'b0;
    tx_agt_cfg_if.v_if.chi_hni_txrspflit <= 1'b0;
    //Data channel init
    tx_agt_cfg_if.v_if.chi_hni_txdatflitpend <= 1'b0;
    tx_agt_cfg_if.v_if.chi_hni_txdatflitv <= 1'b0;
    tx_agt_cfg_if.v_if.chi_hni_txdatflit <= 1'b0;

    tx_agt_cfg_if.v_if.current_state_tx <= STOP;
    //Pre-load the counters with the maximum avail credit values, in that way rx module
    //can send credits to the other tx side
    mb_flush();
  endtask : init

  function mb_flush();
    //Temp item to help to flush mb
    chi_hni_tx_item temp_data;
    //Flush all the mailboxes at reset/initialization
    while(txrsp_pending_item_mb.try_get(temp_data));
    while(txdata_pending_item_mb.try_get(temp_data));
    while(linkactive_req_run_item_mb.try_get(temp_data));
    while(linkactive_req_stop_item_mb.try_get(temp_data));
  endfunction

  //Function: drive_txresp_flit_pending
  //Desc: Function to drive tx resp pending to the RX side
  //The task drives pending with a configurable delay, configurable from the sequence item for the up and down periods
  task drive_txresp_flit_pending(chi_hni_tx_item txrsp_valid_item);
    bit put_valid_resp_flit;
    //If the 
    $display("%t, Start of drive_txresp_flit_pending task", $time);

    @(posedge tx_agt_cfg_if.v_if.clk iff (tx_agt_cfg_if.v_if.current_state_tx != STOP) && tx_agt_cfg_if.v_if.chi_hni_txsactive);
    tx_agt_cfg_if.v_if.chi_hni_txrspflitpend = 1'b1;
    //Randomize delay for txlink req deactivation between min and max values given in the sequence item
    txrsp_pending_up_delay = $urandom_range(txrsp_valid_item.txrsp_flitpend_up_max_dly, txrsp_valid_item.txrsp_flitpend_up_min_dly);
    if(txrsp_pending_up_delay > 0) 
      repeat(txrsp_pending_up_delay) @(tx_agt_cfg_if.v_if.txrsp_cb_drv);
    else 
      @(tx_agt_cfg_if.v_if.txrsp_cb_drv);
    tx_agt_cfg_if.v_if.chi_hni_txrspflitpend = 1'b0;
    #0;
    //If this bit is set from the sequence item, always send the valid flit, else it can be either a valid flit, either a flitpend without valid
    if(txrsp_valid_item.always_set_txvalid_when_pending_resp)
      drive_txrsp_flit_valid(txrsp_valid_item);
    else begin
      assert(std::randomize(put_valid_resp_flit)) else
        `uvm_error("DRV", "Randomization of put_valid_resp_flit failed");
      if(put_valid_resp_flit == 1'b1)
        drive_txrsp_flit_valid(txrsp_valid_item);
    end
    //Randomize delay for txlink req deactivation between min and max values given in the sequence item
    txrsp_pending_down_delay = $urandom_range(txrsp_valid_item.txrsp_flitpend_down_max_dly, txrsp_valid_item.txrsp_flitpend_down_min_dly);
    repeat(txrsp_pending_down_delay) @(tx_agt_cfg_if.v_if.txrsp_cb_drv);

    $display("%t, End of drive_txresp_flit_pending task", $time);
  endtask

  //Function: drive_txdata_flit_pending
  //Desc: Function to drive tx resp pending to the RX side
  //The task drives pending with a configurable delay, configurable from the sequence item for the up and down periods
  task drive_txdata_flit_pending(chi_hni_tx_item txdata_valid_item);
    bit put_valid_data_flit;
    $display("%t, Start of drive_txdata_flit_pending task", $time);
    @(posedge tx_agt_cfg_if.v_if.clk iff (tx_agt_cfg_if.v_if.current_state_tx == RUN) && tx_agt_cfg_if.v_if.chi_hni_txsactive);
    $display("%t, Before setting data pending value %d", $time, tx_agt_cfg_if.v_if.chi_hni_txdatflitpend);
    tx_agt_cfg_if.v_if.chi_hni_txdatflitpend = 1'b1;
    $display("%t, After setting data pending value %d", $time, tx_agt_cfg_if.v_if.chi_hni_txdatflitpend);
    //Randomize delay for txlink req deactivation between min and max values given in the sequence item
    txdata_pending_up_delay = $urandom_range(txdata_valid_item.txdata_flitpend_up_max_dly, txdata_valid_item.txdata_flitpend_up_min_dly);
    $display("%t, TXData delay %d, min = %d, max = %d", $time, txdata_pending_up_delay, txdata_valid_item.txdata_flitpend_up_max_dly, txdata_valid_item.txdata_flitpend_up_min_dly);
    if(txdata_pending_up_delay > 0) 
      repeat(txdata_pending_up_delay) @(tx_agt_cfg_if.v_if.txdata_cb_drv);
    else 
      @(tx_agt_cfg_if.v_if.txdata_cb_drv);
    tx_agt_cfg_if.v_if.chi_hni_txdatflitpend = 1'b0;
    $display("%t, After setting data pending value v2%d", $time, tx_agt_cfg_if.v_if.chi_hni_txdatflitpend);
    //If this bit is set from the sequence item, always send the valid flit, else it can be either a valid flit, either a flitpend without valid
    $display("%t, rx_data_always_valid_value %d", $time, txdata_valid_item.always_set_txvalid_when_pending_data);
    if(txdata_valid_item.always_set_txvalid_when_pending_data == 1) begin
      drive_txdata_flit_valid(txdata_valid_item);
      $display("%t, HERE 1", $time);
    end
    else begin
      $display("%t, HERE 2", $time);
      assert(std::randomize(put_valid_data_flit)) else 
        `uvm_error("DRV", "Randomization of put_valid_data_flit failed");
      if(put_valid_data_flit == 1'b1)
        drive_txdata_flit_valid(txdata_valid_item);
    end
    //Randomize delay for txlink req deactivation between min and max values given in the sequence item
    txdata_pending_down_delay = $urandom_range(txdata_valid_item.txdata_flitpend_down_max_dly, txdata_valid_item.txdata_flitpend_down_min_dly);
    $display("%t, HERE 3, delay value %d", $time, txdata_pending_down_delay);
    repeat(txdata_pending_down_delay) @(tx_agt_cfg_if.v_if.txdata_cb_drv);

    $display("%t, End of drive_txdata_flit_pending task", $time);
  endtask

  //Function: drive_txrsp_flit_valid
  //Desc: Function to drive tx resp valid to the RX side
  //The task drives valid and valid response flits with a configurable delay, from the sequence item and it drives until
  //it has a credit stored in the counter.
  task drive_txrsp_flit_valid(chi_hni_tx_item txrsp_valid_item);
    bit [TX_T-1:0] unpacked_rsp_flit;

      $display("%t, Start of drive_txrsp_flit_valid task", $time);
      if((tx_agt_cfg_if.v_if.txrsp_crd_cnt > 0) && (tx_agt_cfg_if.v_if.current_state_tx == RUN)) begin
        unpack_tx_rsp_flit(txrsp_valid_item.tx_rsp_flit_i, unpacked_rsp_flit);
        //wait for the clock posedge and credit counter has more than one credit + in run state events to send valid flits
        tx_agt_cfg_if.v_if.chi_hni_txrspflitv = 1'b1;
        tx_agt_cfg_if.v_if.chi_hni_txrspflit <= unpacked_rsp_flit;
        tx_agt_cfg_if.v_if.txrsp_crd_cnt--;
        @(tx_agt_cfg_if.v_if.txrsp_cb_drv);
        tx_agt_cfg_if.v_if.chi_hni_txrspflitv = 1'b0;
        $display("%t, End of drive_txrsp_flit_valid task", $time);
      end
  endtask 

  //Function: drive_txdata_flit_valid
  //Desc: Function to drive tx data valid to the RX side
  //The task drives valid and valid data flits with a configurable delay, from the sequence item and it drives until
  //it has a credit stored in the counter.
  task drive_txdata_flit_valid(chi_hni_tx_item txdata_valid_item);
    bit [TX_D-1:0] unpacked_data_flit;
      $display("%t, Start of drive_txdata_flit_valid task, txdata_crd_cnt %d", $time, tx_agt_cfg_if.v_if.txdata_crd_cnt);
      if((tx_agt_cfg_if.v_if.txdata_crd_cnt > 0) && (tx_agt_cfg_if.v_if.current_state_tx == RUN)) begin
        unpack_tx_data_flit(txdata_valid_item.tx_data_flit_i, unpacked_data_flit);
        //wait for the clock posedge and credit counter has more than one credit + in run state events to send valid flits
        tx_agt_cfg_if.v_if.chi_hni_txdatflitv = 1'b1;
        tx_agt_cfg_if.v_if.chi_hni_txdatflit <= unpacked_data_flit;
        tx_agt_cfg_if.v_if.txdata_crd_cnt--;
        @(tx_agt_cfg_if.v_if.txdata_cb_drv);
        tx_agt_cfg_if.v_if.chi_hni_txdatflitv = 1'b0;
        $display("%t, End of drive_txdata_flit_valid task", $time);
      end
  endtask

  //Function: drive_rxlinkactiveack
  //Desc: Task to drive/control rxlinkactiveack signal
  task drive_txlinkactivereq_activate(chi_hni_tx_item m_chi_tx_item);
    $display("%t, Start of drive_txlinkactivereq_activate task", $time);

    //FROM STOP -> ACTIVATE
    //Randomize delay for txlink req activation between min and max values given in the sequence item
    tx_linkreq_activate_delay = $urandom_range(m_chi_tx_item.tx_linkreq_activate_max_delay, m_chi_tx_item.tx_linkreq_activate_min_delay);
    $display("%t, Activation of txsactive %d, delay %d", $time, tx_agt_cfg_if.v_if.chi_hni_txsactive, tx_linkreq_activate_delay);
    // if(!tx_agt_cfg_if.v_if.chi_hni_txsactive) begin
      $display("%t, Activation of txsactive %d", $time, tx_agt_cfg_if.v_if.chi_hni_txsactive);
      repeat(tx_linkreq_activate_delay) @(posedge tx_agt_cfg_if.v_if.clk);
     //FROM RUN -> DEACTIVATE
      tx_agt_cfg_if.v_if.chi_hni_txsactive = 1'b1;
      $display("%t, Set txslinkactive %d", $time, tx_agt_cfg_if.v_if.chi_hni_txsactive);
    // end
    // else begin
      // repeat(tx_linkreq_activate_delay) @(posedge tx_agt_cfg_if.v_if.clk);
      tx_agt_cfg_if.v_if.chi_hni_txlinkactivereq = 1'b1;
      $display("%t, Set chi_hni_txlinkactivereq %d", $time, tx_agt_cfg_if.v_if.chi_hni_txlinkactivereq);
    // end
    $display("%t, End of drive_txlinkactivereq_activate task", $time);

  endtask

  task drive_txlinkactivereq_deactivate(chi_hni_tx_item m_chi_tx_item);
    $display("%t, Start of drive_txlinkactivereq_deactivate task", $time);
    //FROM RUN -> DEACTIVATE
    //Randomize delay for txlink req deactivation between min and max values given in the sequence item
    tx_linkreq_deactivate_delay = $urandom_range(m_chi_tx_item.tx_linkreq_deactivate_max_delay, m_chi_tx_item.tx_linkreq_deactivate_min_delay);
    repeat(tx_linkreq_deactivate_delay) @(posedge tx_agt_cfg_if.v_if.clk);
    //FROM DEACTIVATE -> STOP
    tx_agt_cfg_if.v_if.chi_hni_txlinkactivereq = 1'b0;
    $display("%t, End of drive_txlinkactivereq_deactivate task", $time);

  endtask

  //Drive tasks. Wait for the maibox to have contents from the sequence item port, then when the item is consumed, request the next item by 
  //triggering the event on that specific thread.
  task drive_rsp_channel();
    forever begin
      txrsp_pending_item_mb.get(txrsp_itm_from_mb);
      $display("%t, Got item from txrsp_pending_item_mb", $time);
      drive_txresp_flit_pending(txrsp_itm_from_mb);
      ->drive_txrsp_pend_ev;
      $display("%t, Trigger drive_txrsp_pend_ev event", $time);
    end
  endtask

  task drive_data_channel();
    forever begin
      txdata_pending_item_mb.get(txdata_itm_from_mb);
      $display("%t, Got item from txdata_pending_item_mb", $time);
      drive_txdata_flit_pending(txdata_itm_from_mb);
      ->drive_txdata_pend_ev;
      $display("%t, Trigger drive_txdata_pend_ev event", $time);

    end
  endtask

  task drive_rxlinkactivereq_run_channel();
    forever begin
      linkactive_req_run_item_mb.get(linkactive_req_run_itm_from_mb);
      $display("%t, Got item from drive_rxlinkactivereq_run_channel", $time);
      drive_txlinkactivereq_activate(linkactive_req_run_itm_from_mb);
      ->drive_linkactivereq_run_ev;
      $display("%t, Trigger drive_linkactivereq_run_ev event", $time);

    end
  endtask

  task drive_rxlinkactivereq_stop_channel();
    forever begin
      linkactive_req_stop_item_mb.get(linkactive_req_stop_itm_from_mb);
      $display("%t, Got item from drive_rxlinkactivereq_stop_channel", $time);

      drive_txlinkactivereq_deactivate(linkactive_req_stop_itm_from_mb);
      ->drive_linkactivereq_stop_ev;
      $display("%t, Trigger drive_linkactivereq_stop_ev event", $time);

    end
  endtask

  //Pack the tx_data_flit that is coming from the monitor
  function unpack_tx_data_flit(
    input  chi_hni_dataflit_item packed_flit,
    output bit [TX_D-1:0]        unpacked_flit
  );
    int idx;
    idx = TX_D;

    idx -= 1;
    idx -= (`DWIDTH/64);  unpacked_flit[idx +: (`DWIDTH/64)]  = packed_flit.Poison;
    idx -= `DWIDTH;       unpacked_flit[idx +: `DWIDTH]       = packed_flit.Data;
    idx -= (`DWIDTH/8);   unpacked_flit[idx +: (`DWIDTH/8)]   = packed_flit.BE;
    idx -= 1;             unpacked_flit[idx]                  = packed_flit.TraceTag;
    idx -= (`DWIDTH/128); unpacked_flit[idx +: (`DWIDTH/128)] = packed_flit.TU;
    idx -= (`DWIDTH/32);  unpacked_flit[idx +: (`DWIDTH/32)]  = packed_flit.Tag;
    idx -= 2;             unpacked_flit[idx +: 2]             = packed_flit.TagOp;
    idx -= 2;             unpacked_flit[idx +: 2]             = packed_flit.DataID;
    idx -= 2;             unpacked_flit[idx +: 2]             = packed_flit.CCID;
    idx -= 12;            unpacked_flit[idx +: 12]            = packed_flit.DBID;
    idx -= 3;             unpacked_flit[idx +: 3]             = packed_flit.CBusy;
    idx -= 4;             unpacked_flit[idx +: 4]             = packed_flit.DataSource;
    idx -= 3;             unpacked_flit[idx +: 3]             = packed_flit.Resp;
    idx -= 2;             unpacked_flit[idx +: 2]             = packed_flit.RespErr;
    idx -= 7;             unpacked_flit[idx +: 7]             = packed_flit.Opcode;
    idx -= `NODEID_WIDTH; unpacked_flit[idx +: `NODEID_WIDTH] = packed_flit.HomeNID;
    idx -= 12;            unpacked_flit[idx +: 12]            = packed_flit.TxnID;
    idx -= `NODEID_WIDTH; unpacked_flit[idx +: `NODEID_WIDTH] = packed_flit.SrcID;
    idx -= `NODEID_WIDTH; unpacked_flit[idx +: `NODEID_WIDTH] = packed_flit.TgtID;
    idx -= 4;             unpacked_flit[idx +: 4]             = packed_flit.QoS;
  endfunction

  //Pack the tx_rsp_flit that is coming from the monitor
  function unpack_tx_rsp_flit(
    input  chi_hni_rspflit_item packed_flit,
    output bit [TX_T-1:0]       unpacked_flit
  );
    int idx;
    idx = TX_T;
    
    idx -= 1;
    idx -= 1;             unpacked_flit[idx]                  = packed_flit.TraceTag;
    idx -= 2;             unpacked_flit[idx +: 2]             = packed_flit.TagOp;
    idx -= 4;             unpacked_flit[idx +: 4]             = packed_flit.PCrdType;
    idx -= 12;            unpacked_flit[idx +: 12]            = packed_flit.DBID;
    idx -= 3;             unpacked_flit[idx +: 3]             = packed_flit.CBusy;
    idx -= 3;             unpacked_flit[idx +: 3]             = packed_flit.FwdState;
    idx -= 3;             unpacked_flit[idx +: 3]             = packed_flit.Resp;
    idx -= 2;             unpacked_flit[idx +: 2]             = packed_flit.RespErr;
    idx -= 7;             unpacked_flit[idx +: 7]             = packed_flit.Opcode;
    idx -= 12;            unpacked_flit[idx +: 12]            = packed_flit.TxnID;
    idx -= `NODEID_WIDTH; unpacked_flit[idx +: `NODEID_WIDTH] = packed_flit.SrcID;
    idx -= `NODEID_WIDTH; unpacked_flit[idx +: `NODEID_WIDTH] = packed_flit.TgtID;
    idx -= 4;             unpacked_flit[idx +: 4]             = packed_flit.QoS;
  endfunction

endclass : chi_hni_tx_driver