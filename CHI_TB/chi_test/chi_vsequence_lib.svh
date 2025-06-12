//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 12/03/2025
//  File name             : chi_vsequence_lib.sv
//  Last modified+updates : 12/03/2025 (RM) - Initial Version
//                          
//  Project               : CHI Protocol Test Bench
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Virtual sequence library for CHI protocol verification project
//  ======================================================================================================

class chi_base_vsequence extends uvm_sequence;

  `uvm_object_utils(chi_base_vsequence)

  `uvm_declare_p_sequencer(chi_virtual_sequencer)

  function new(string name = "chi_base_vsequence");
    super.new(name);
  endfunction : new

  chi_rni_rx_sequencer m_vseq_rni_rx_seqr;
  chi_hni_tx_sequencer m_vseq_hni_tx_seqr;

  virtual task body();
    m_vseq_rni_rx_seqr = p_sequencer.m_rni_rx_seqr;
    m_vseq_hni_tx_seqr = p_sequencer.m_hni_tx_seqr;
  endtask

endclass : chi_base_vsequence

class chi_sanity_read_no_snoop_hni_vseq extends chi_base_vsequence;

  `uvm_object_utils(chi_sanity_read_no_snoop_hni_vseq)
  
  function new(string name = "chi_sanity_read_no_snoop_hni_vseq");
    super.new(name);
  endfunction : new

  task body();

    chi_hni_linkactive_req_activate_state_sequence chi_req_activate_with_delay;
    chi_hni_txdataflit_always_valid_after_pending_sequence chi_send_read_data_flit;
    chi_rni_linkactive_ack_run_and_rxrsp_credit_send_state_sequence chi_ack_and_send_one_rxrsp_credit;
    chi_rni_rsp_credit_send_state_sequence chi_send_rsp_channel_credit;
    chi_rni_data_credit_send_state_sequence chi_send_data_channel_credit;
    
    chi_req_activate_with_delay = chi_hni_linkactive_req_activate_state_sequence::type_id::create("chi_req_activate_with_delay");
    chi_send_read_data_flit = chi_hni_txdataflit_always_valid_after_pending_sequence::type_id::create("chi_send_read_data_flit");
    chi_ack_and_send_one_rxrsp_credit = chi_rni_linkactive_ack_run_and_rxrsp_credit_send_state_sequence::type_id::create("chi_ack_and_send_one_rxrsp_credit");
    chi_send_rsp_channel_credit = chi_rni_rsp_credit_send_state_sequence::type_id::create("chi_send_rsp_channel_credit");
    chi_send_data_channel_credit = chi_rni_data_credit_send_state_sequence::type_id::create("chi_send_data_channel_credit");

    super.body();

    fork 
      begin
        //Raise acknowledge and send first credit
        if(!chi_ack_and_send_one_rxrsp_credit.randomize() with {
          rx_linkack_activate_delay_seq == 1;
          rxrsp_cred_dly_seq == 1;
        }) `uvm_error("VSEQ", "Randomization of chi_ack_and_send_one_rxrsp_credit failed");
        chi_ack_and_send_one_rxrsp_credit.start(m_vseq_rni_rx_seqr, this);
        //In parallel, send 2 credits for both channels
      end
    join_none
    #0;
      $display("%t DDDDEBUG1 randomize 1", $time);
      //Start the request from the hni data and rsp tx side
      chi_req_activate_with_delay.randomize() with {
        tx_linkreq_activate_min_delay_seq == 1;
        tx_linkreq_activate_max_delay_seq == 1;
      };
      $display("%t DDDDEBUG2 after randomize 1, bfr start", $time);
      // Start and wait for completion by providing `this` as parent sequence (blocking)
      chi_req_activate_with_delay.start(m_vseq_hni_tx_seqr, this);
      $display("%t DDDDEBUG3 After start", $time);
    fork
      begin : send_two_data_credits
        $display("%t DDDDEBUG4 After start", $time);
        chi_send_data_channel_credit.randomize() with {
          rxdata_cred_dly_seq == 1;
          rxdata_credits_send_no_seq == 2;
        };
        chi_send_data_channel_credit.start(m_vseq_rni_rx_seqr, this);
      end
      begin : send_two_resp_credits
        $display("%t DDDDEBUG5 After start", $time);
        chi_send_rsp_channel_credit.randomize() with {
          rxrsp_cred_dly_seq == 1;
          rxrsp_credits_send_no_seq == 2;
        };
        chi_send_rsp_channel_credit.start(m_vseq_rni_rx_seqr, this);
      end
    join
    $display("%t DDDDEBUG6 After start", $time);
    repeat(2) begin
      //Send two RDATA packets on txchannel
      chi_send_read_data_flit.randomize() with {
        txdata_flitpend_up_min_dly_seq == 3;
        txdata_flitpend_up_max_dly_seq == 6;
        txdata_flitpend_down_min_dly_seq == 3;
        txdata_flitpend_down_max_dly_seq == 6;
        //DATA FLIT FIELDS
        QoS_seq == 0;
        Data_seq == 'hDEAD_BEEF;
        TgtID_seq == 1;
        SrcID_seq == 2;
        TxnID_seq inside {[0:1]};
        HomeNID_seq == 2; //equal to SrcID (HNI sender ID)
        BE_seq == 0;
        Opcode_seq == 6'h4; //ReadNoSnoop
        Poison_seq == 0;
        TU_seq == 0;
        Tag_seq == 0;
        CCID_seq == 0;
        DBID_seq == 2;
        RespErr_seq == 0;
      };
      chi_send_read_data_flit.start(m_vseq_hni_tx_seqr, this);
    end
  endtask : body

endclass : chi_sanity_read_no_snoop_hni_vseq


