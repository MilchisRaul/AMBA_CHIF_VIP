//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : axi4wr_seq_lib.svh
//  Last modified+updates : 16/02/2023 (RM)
//                          26/04/2023 (RM) - Modified ACE Structure into
//                                            Read and Write separate ACE UVC's
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Sequences Library for chi_hni Verification IP (UVC)
//  ======================================================================================================

class chi_hni_rx_base_sequence extends uvm_sequence;

  `uvm_object_utils (chi_hni_rx_base_sequence)

  `uvm_declare_p_sequencer(chi_hni_tx_sequencer)

  rand int rx_trans_no = 1;

  //typedef chi_hni_item axi4wr_item_t; //for parametrizable item

  function new (string name = "chi_hni_rx_base_sequence");
    super.new(name);
  endfunction: new
endclass: chi_hni_rx_base_sequence

class chi_hni_tx_base_sequence extends uvm_sequence;

  `uvm_object_utils (chi_hni_tx_base_sequence)

  `uvm_declare_p_sequencer(chi_hni_tx_sequencer)

  rand int tx_trans_no = 1;
  rand int tx_rsp_trans_no = 1;
  rand int tx_data_trans_no = 1;

  //typedef chi_hni_item axi4wr_item_t; //for parametrizable item

  function new (string name = "chi_hni_tx_base_sequence");
    super.new(name);
  endfunction: new
endclass: chi_hni_tx_base_sequence

////////////////////////////////////////////////////////////////////////////////////////////////
//                                     
//                               
//                              
//
////////////////////////////////////////////////////////////////////////////////////////////////

class chi_hni_linkactive_req_activate_state_sequence extends chi_hni_tx_base_sequence;

  `uvm_object_utils(chi_hni_linkactive_req_activate_state_sequence)

  rand int unsigned tx_linkreq_activate_min_delay_seq;
  rand int unsigned tx_linkreq_activate_max_delay_seq;

  function new (string name= "chi_hni_linkactive_req_activate_state_sequence");
    super.new(name);
  endfunction: new

  virtual task body();
    chi_hni_tx_item chi_tx_item;
    chi_tx_item = chi_hni_tx_item::type_id::create("chi_tx_item"); //creating AXI4WR item for signals
      start_item(chi_tx_item); //starting getting the data for item
        if(!(chi_tx_item.randomize() with {
                                    //Activate req delay
                                      tx_linkreq_activate_min_delay == tx_linkreq_activate_min_delay_seq;
                                      tx_linkreq_activate_max_delay == tx_linkreq_activate_max_delay_seq;
                                      link_active_req_run_scope == 1;
                                      resp_flit_scope == 0;
                                      data_flit_scope == 0;
                                      link_active_req_stop_scope == 0;
                                   })) //giving values to axi4wr signals
          `uvm_error(get_type_name(), "Rand error!")
       finish_item(chi_tx_item); //all data is on transaction item
  endtask: body

endclass: chi_hni_linkactive_req_activate_state_sequence

////////////////////////////////////////////////////////////////////////////////////////////////
//                                     
//                               
//                              
//
////////////////////////////////////////////////////////////////////////////////////////////////

class chi_hni_linkactive_req_deactivate_state_sequence extends chi_hni_tx_base_sequence;

  `uvm_object_utils(chi_hni_linkactive_req_deactivate_state_sequence)

  rand int unsigned tx_linkreq_deactivate_min_delay_seq;
  rand int unsigned tx_linkreq_deactivate_max_delay_seq;

  function new (string name= "chi_hni_linkactive_req_deactivate_state_sequence");
    super.new(name);
  endfunction: new

  virtual task body();
    chi_hni_tx_item chi_tx_item;
    chi_tx_item = chi_hni_tx_item::type_id::create("chi_tx_item"); //creating AXI4WR item for signals
      start_item(chi_tx_item); //starting getting the data for item
        if(!(chi_tx_item.randomize() with {
                                      //Deactivate req delay
                                      tx_linkreq_deactivate_min_delay == tx_linkreq_deactivate_min_delay_seq;
                                      tx_linkreq_deactivate_max_delay == tx_linkreq_deactivate_max_delay_seq;
                                      link_active_req_stop_scope == 1;
                                      link_active_req_run_scope == 0;
                                      resp_flit_scope == 0;
                                      data_flit_scope == 0;
                                   })) //giving values to axi4wr signals
          `uvm_error(get_type_name(), "Rand error!")
       finish_item(chi_tx_item); //all data is on transaction item
  endtask: body

endclass: chi_hni_linkactive_req_deactivate_state_sequence

////////////////////////////////////////////////////////////////////////////////////////////////
//                                     
//                               
//                              
//
////////////////////////////////////////////////////////////////////////////////////////////////

class chi_hni_txrespflit_always_valid_after_pending_sequence extends chi_hni_tx_base_sequence;

  `uvm_object_utils(chi_hni_txrespflit_always_valid_after_pending_sequence)

  rand int unsigned txrsp_flitpend_up_min_dly_seq;
  rand int unsigned txrsp_flitpend_up_max_dly_seq;

  rand int unsigned txrsp_flitpend_down_min_dly_seq;
  rand int unsigned txrsp_flitpend_down_max_dly_seq;

  rand bit [3:0]                QoS_seq;
  rand bit [`NODEID_WIDTH -1: 0] TgtID_seq;
  rand bit [`NODEID_WIDTH -1: 0] SrcID_seq;
  rand bit [11: 0]              TxnID_seq;
  rand chi_opcode_t             Opcode_seq;
  rand bit [1: 0]               RespErr_seq;
  rand bit [11:0]               DBID_seq;
  rand bit [3: 0]               PCrdType_seq;

  function new (string name= "chi_hni_txrespflit_always_valid_after_pending_sequence");
    super.new(name);
  endfunction: new

  virtual task body();
    chi_hni_tx_item chi_tx_item;
    chi_tx_item = chi_hni_tx_item::type_id::create("chi_tx_item"); //creating AXI4WR item for signals
      start_item(chi_tx_item); //starting getting the data for item
        if(!(chi_tx_item.randomize() with {
                                      txrsp_flitpend_up_min_dly   == txrsp_flitpend_up_min_dly_seq;
                                      txrsp_flitpend_up_max_dly   == txrsp_flitpend_up_max_dly_seq;
                                      txrsp_flitpend_down_min_dly == txrsp_flitpend_down_min_dly_seq;
                                      txrsp_flitpend_down_max_dly == txrsp_flitpend_down_max_dly_seq;
                              ////                 RESP FLIT FIELDS                ////
                                        tx_rsp_flit_i.QoS      == QoS_seq     ;    ////
                                        tx_rsp_flit_i.TgtID    == TgtID_seq   ;    ////
                                        tx_rsp_flit_i.SrcID    == SrcID_seq   ;    ////
                                        tx_rsp_flit_i.TxnID    == TxnID_seq   ;    ////
                                        tx_rsp_flit_i.Opcode   == Opcode_seq  ;    ////
                                        tx_rsp_flit_i.RespErr  == RespErr_seq ;    ////
                                        tx_rsp_flit_i.DBID     == DBID_seq    ;    ////
                                        tx_rsp_flit_i.PCrdType == PCrdType_seq;    ////
                              ////                 RESP FLIT FIELDS                ////
                                      always_set_txvalid_when_pending_resp == 1; //Always send flit after pending
                                      resp_flit_scope == 1;
                                      link_active_req_stop_scope == 0;
                                      link_active_req_run_scope == 0;
                                      data_flit_scope == 0;
                                   })) //giving values to axi4wr signals
          `uvm_error(get_type_name(), "Rand error!")
       finish_item(chi_tx_item); //all data is on transaction item
  endtask: body

endclass: chi_hni_txrespflit_always_valid_after_pending_sequence

////////////////////////////////////////////////////////////////////////////////////////////////
//                                     
//                               
//                              
//
////////////////////////////////////////////////////////////////////////////////////////////////

class chi_hni_txdataflit_always_valid_after_pending_sequence extends chi_hni_tx_base_sequence;

  `uvm_object_utils(chi_hni_txdataflit_always_valid_after_pending_sequence)

  rand int unsigned txdata_flitpend_up_min_dly_seq;
  rand int unsigned txdata_flitpend_up_max_dly_seq;

  rand int unsigned txdata_flitpend_down_min_dly_seq;
  rand int unsigned txdata_flitpend_down_max_dly_seq;

  rand bit [3:0]                 QoS_seq;
  rand bit [`NODEID_WIDTH -1: 0] TgtID_seq;
  rand bit [`NODEID_WIDTH -1: 0] SrcID_seq;
  rand bit [11: 0]               TxnID_seq;
  rand bit [`NODEID_WIDTH -1: 0] HomeNID_seq;
  rand chi_opcode_t              Opcode_seq;
  rand bit [1: 0]                RespErr_seq;
  rand bit [11:0]                DBID_seq;
  rand bit [1: 0]                CCID_seq;
  rand bit [1: 0]                DataID_seq;
  rand bit [(`DWIDTH/32) -1: 0]  Tag_seq;
  rand bit [(`DWIDTH/128) -1: 0] TU_seq;
  rand bit [(`DWIDTH/8) -1: 0]   BE_seq;
  rand bit [(`DWIDTH -1): 0]     Data_seq;
  rand bit [(`DWIDTH/64) -1: 0]  Poison_seq;

  function new (string name= "chi_hni_txdataflit_always_valid_after_pending_sequence");
    super.new(name);
  endfunction: new

  virtual task body();
    chi_hni_tx_item chi_tx_item;
    chi_tx_item = chi_hni_tx_item::type_id::create("chi_tx_item"); //creating AXI4WR item for signals

      start_item(chi_tx_item); //starting getting the data for item
        if(!(chi_tx_item.randomize() with {
                                      txdata_flitpend_up_min_dly   == txdata_flitpend_up_min_dly_seq;
                                      txdata_flitpend_up_max_dly   == txdata_flitpend_up_max_dly_seq;
                                      txdata_flitpend_down_min_dly == txdata_flitpend_down_min_dly_seq;
                                      txdata_flitpend_down_max_dly == txdata_flitpend_down_max_dly_seq;
                              ////                 DATA FLIT FIELDS                 ////
                                        tx_data_flit_i.QoS     == QoS_seq    ;      ////
                                        tx_data_flit_i.TgtID   == TgtID_seq  ;      ////
                                        tx_data_flit_i.SrcID   == SrcID_seq  ;      ////
                                        tx_data_flit_i.TxnID   == TxnID_seq  ;      ////
                                        tx_data_flit_i.HomeNID == HomeNID_seq;      ////
                                        tx_data_flit_i.Opcode  == Opcode_seq ;      ////
                                        tx_data_flit_i.RespErr == RespErr_seq;      ////
                                        tx_data_flit_i.DBID    == DBID_seq   ;      ////
                                        tx_data_flit_i.CCID    == CCID_seq   ;      ////
                                        tx_data_flit_i.DataID  == DataID_seq ;      ////
                                        tx_data_flit_i.Tag     == Tag_seq    ;      ////
                                        tx_data_flit_i.TU      == TU_seq     ;      ////
                                        tx_data_flit_i.BE      == BE_seq     ;      ////
                                        tx_data_flit_i.Data    == Data_seq   ;      ////
                                        tx_data_flit_i.Poison  == Poison_seq ;      ////
                              ////                 DATA FLIT FIELDS                 ////
                                      always_set_txvalid_when_pending_data == 1; //Always send flit after pending
                                      data_flit_scope == 1;
                                      resp_flit_scope == 0;
                                      link_active_req_stop_scope == 0;
                                      link_active_req_run_scope == 0;
                                   })) //giving values to axi4wr signals
          `uvm_error(get_type_name(), "Rand error!")
       finish_item(chi_tx_item); //all data is on transaction item
  endtask: body

endclass: chi_hni_txdataflit_always_valid_after_pending_sequence



