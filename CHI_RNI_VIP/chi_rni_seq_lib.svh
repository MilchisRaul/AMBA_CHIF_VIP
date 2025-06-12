//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 21/02/2025
//  File name             : chi_rni_seq_lib.svh
//  Last modified+updates : 21/02/2025 (RM)
//  Project               : CHI Protocol RNI VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Sequence library for chi_rni Verification IP (UVC), contains all needed seq
//                          to drive credits on both channels and the acknowledge signal manipulation
//  ======================================================================================================

class chi_rni_rx_base_sequence extends uvm_sequence;

  `uvm_object_utils (chi_rni_rx_base_sequence)

  `uvm_declare_p_sequencer(chi_rni_rx_sequencer)

  rand int rx_trans_no = 1;

  //typedef chi_rni_item axi4wr_item_t; //for parametrizable item

  function new (string name = "chi_rni_rx_base_sequence");
    super.new(name);
  endfunction: new
endclass: chi_rni_rx_base_sequence

////////////////////////////////////////////////////////////////////////////////////////////////
//                                     
//                               
//                              
//
////////////////////////////////////////////////////////////////////////////////////////////////

class chi_rni_linkactive_ack_run_state_sequence extends chi_rni_rx_base_sequence;

  `uvm_object_utils(chi_rni_linkactive_ack_run_state_sequence)

  rand int unsigned rx_linkack_activate_delay_seq;

  function new (string name= "chi_rni_linkactive_ack_run_state_sequence");
    super.new(name);
  endfunction: new

  virtual task body();
    chi_rni_rx_item chi_rx_item;
    chi_rx_item = chi_rni_rx_item::type_id::create("chi_rx_item"); //creating AXI4WR item for signals
      start_item(chi_rx_item); //starting getting the data for item
        if(!(chi_rx_item.randomize() with {
                                    //Addr channel
                                      rx_linkack_activate_delay == rx_linkack_activate_delay_seq;
                                      link_active_ack_run_scope == 1;
                                      resp_flit_scope == 0;
                                      data_flit_scope == 0;
                                      link_active_ack_stop_scope == 0;
                                   })) //giving values to axi4wr signals
          `uvm_error(get_type_name(), "Rand error!")
       finish_item(chi_rx_item); //all data is on transaction item
  endtask: body

endclass: chi_rni_linkactive_ack_run_state_sequence

////////////////////////////////////////////////////////////////////////////////////////////////
//                                     
//                               
//                              
//
////////////////////////////////////////////////////////////////////////////////////////////////

class chi_rni_rsp_credit_send_state_sequence extends chi_rni_rx_base_sequence;

  `uvm_object_utils(chi_rni_rsp_credit_send_state_sequence)

  rand int unsigned rxrsp_cred_dly_seq;
  rand int unsigned rxrsp_credits_send_no_seq;
  function new (string name= "chi_rni_rsp_credit_send_state_sequence");
    super.new(name);
  endfunction: new

  virtual task body();
    chi_rni_rx_item chi_rx_item;
    chi_rx_item = chi_rni_rx_item::type_id::create("chi_rx_item"); //creating AXI4WR item for signals
    repeat(rxrsp_credits_send_no_seq) begin
      start_item(chi_rx_item); //starting getting the data for item
        if(!(chi_rx_item.randomize() with {
                                      rxrsp_cred_dly == rxrsp_cred_dly_seq;
                                      resp_flit_scope == 1;
                                      link_active_ack_run_scope == 0;
                                      data_flit_scope == 0;
                                      link_active_ack_stop_scope == 0;
                                   })) //giving values to axi4wr signals
          `uvm_error(get_type_name(), "Rand error!")
       finish_item(chi_rx_item); //all data is on transaction item
    end
  endtask: body

endclass: chi_rni_rsp_credit_send_state_sequence

////////////////////////////////////////////////////////////////////////////////////////////////
//                                     
//                               
//                              
//
////////////////////////////////////////////////////////////////////////////////////////////////

class chi_rni_data_credit_send_state_sequence extends chi_rni_rx_base_sequence;

  `uvm_object_utils(chi_rni_data_credit_send_state_sequence)

  rand int unsigned rxdata_cred_dly_seq;
  rand int unsigned rxdata_credits_send_no_seq;


  function new (string name= "chi_rni_data_credit_send_state_sequence");
    super.new(name);
  endfunction: new

  virtual task body();
    chi_rni_rx_item chi_rx_item;
    chi_rx_item = chi_rni_rx_item::type_id::create("chi_rx_item"); //creating AXI4WR item for signals
    repeat(rxdata_credits_send_no_seq) begin
      start_item(chi_rx_item); //starting getting the data for item
        if(!(chi_rx_item.randomize() with {
                                      rxdata_cred_dly == rxdata_cred_dly_seq;
                                      data_flit_scope == 1;
                                      link_active_ack_run_scope == 0;
                                      resp_flit_scope == 0;
                                      link_active_ack_stop_scope == 0;
                                   })) //giving values to axi4wr signals
          `uvm_error(get_type_name(), "Rand error!")
       finish_item(chi_rx_item); //all data is on transaction item
    end
  endtask: body

endclass: chi_rni_data_credit_send_state_sequence

////////////////////////////////////////////////////////////////////////////////////////////////
//                                     
//                               
//                             
//
////////////////////////////////////////////////////////////////////////////////////////////////

class chi_rni_linkactive_ack_run_and_rxrsp_credit_send_state_sequence extends chi_rni_rx_base_sequence;

  `uvm_object_utils(chi_rni_linkactive_ack_run_and_rxrsp_credit_send_state_sequence)

  rand int unsigned rx_linkack_activate_delay_seq;
  rand int unsigned rxrsp_cred_dly_seq;

  function new (string name= "chi_rni_linkactive_ack_run_and_rxrsp_credit_send_state_sequence");
    super.new(name);
  endfunction: new

  virtual task body();
    chi_rni_rx_item chi_rx_item;
    chi_rx_item = chi_rni_rx_item::type_id::create("chi_rx_item"); //creating AXI4WR item for signals
      start_item(chi_rx_item); //starting getting the data for item
        if(!(chi_rx_item.randomize() with {
                                    //Addr channel
                                      rx_linkack_activate_delay == rx_linkack_activate_delay_seq;
                                      rxrsp_cred_dly == rxrsp_cred_dly_seq;
                                      resp_flit_scope == 1;
                                      link_active_ack_run_scope == 1;                                      
                                      data_flit_scope == 0;
                                      link_active_ack_stop_scope == 0;
                                   })) //giving values to axi4wr signals
          `uvm_error(get_type_name(), "Rand error!")
       finish_item(chi_rx_item); //all data is on transaction item
  endtask: body

endclass: chi_rni_linkactive_ack_run_and_rxrsp_credit_send_state_sequence

////////////////////////////////////////////////////////////////////////////////////////////////
//                                     
//                               
//                              
//
////////////////////////////////////////////////////////////////////////////////////////////////

class chi_rni_linkactive_ack_run_and_rxdata_credit_send_state_sequence extends chi_rni_rx_base_sequence;

  `uvm_object_utils(chi_rni_linkactive_ack_run_and_rxdata_credit_send_state_sequence)

  rand int unsigned rx_linkack_activate_delay_seq;
  rand int unsigned rxdata_cred_dly_seq;

  function new (string name= "chi_rni_linkactive_ack_run_and_rxdata_credit_send_state_sequence");
    super.new(name);
  endfunction: new

  virtual task body();
    chi_rni_rx_item chi_rx_item;
    chi_rx_item = chi_rni_rx_item::type_id::create("chi_rx_item"); //creating AXI4WR item for signals
      start_item(chi_rx_item); //starting getting the data for item
        if(!(chi_rx_item.randomize() with {
                                    //Addr channel
                                      rx_linkack_activate_delay == rx_linkack_activate_delay_seq;
                                      rxdata_cred_dly == rxdata_cred_dly_seq;
                                      data_flit_scope == 1;
                                      link_active_ack_run_scope == 1;                                      
                                      resp_flit_scope == 0;
                                      link_active_ack_stop_scope == 0;
                                   })) //giving values to axi4wr signals
          `uvm_error(get_type_name(), "Rand error!")
       finish_item(chi_rx_item); //all data is on transaction item
  endtask: body

endclass: chi_rni_linkactive_ack_run_and_rxdata_credit_send_state_sequence

////////////////////////////////////////////////////////////////////////////////////////////////
//                                     
//                               
//                              
//
////////////////////////////////////////////////////////////////////////////////////////////////

class chi_rni_linkactive_ack_stop_state_sequence extends chi_rni_rx_base_sequence;

  `uvm_object_utils(chi_rni_linkactive_ack_stop_state_sequence)

  rand int unsigned rx_linkack_deactivate_delay_seq;

  function new (string name= "chi_rni_linkactive_ack_stop_state_sequence");
    super.new(name);
  endfunction: new

  virtual task body();
    chi_rni_rx_item chi_rx_item;
    chi_rx_item = chi_rni_rx_item::type_id::create("chi_rx_item"); //creating AXI4WR item for signals
      start_item(chi_rx_item); //starting getting the data for item
        if(!(chi_rx_item.randomize() with {
                                    //Addr channel
                                      rx_linkack_deactivate_delay == rx_linkack_deactivate_delay_seq;
                                      link_active_ack_stop_scope == 1;
                                      data_flit_scope == 0;
                                      link_active_ack_run_scope == 0;                                      
                                      resp_flit_scope == 0;
                                   })) //giving values to axi4wr signals
          `uvm_error(get_type_name(), "Rand error!")
       finish_item(chi_rx_item); //all data is on transaction item
  endtask: body

endclass: chi_rni_linkactive_ack_stop_state_sequence



