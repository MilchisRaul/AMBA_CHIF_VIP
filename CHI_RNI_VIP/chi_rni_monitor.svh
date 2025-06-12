//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 21/02/2025
//  File name             : chi_rni_monitor.svh
//  Last modified+updates : 21/02/2025 (RM)
//  Project               : CHI Protocol RNI VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Monitor for chi_rni Verification IP (UVC), samples both resp and data channels
//                          for CHI_RNI RX vip 
//  ======================================================================================================

class chi_rni_rx_monitor extends uvm_monitor;

  `uvm_component_utils (chi_rni_rx_monitor)

  
  //monitor constructor
  function new (string name = "chi_rni_rx_monitor" , uvm_component parent = null);
    super.new (name, parent);
  endfunction: new

  chi_rni_rx_item m_item;

  chi_rni_rx_config_if rx_agt_cfg_if;

  uvm_analysis_port #(chi_rni_rx_item) mon_rxdat_analysis_port; //data analysis port input for monitor
  uvm_analysis_port #(chi_rni_rx_item) mon_rxdat_request_port; // partial data request analysis port for monitor

  uvm_analysis_port #(chi_rni_rx_item) mon_rxrsp_analysis_port; //data analysis port input for monitor
  uvm_analysis_port #(chi_rni_rx_item) mon_rxrsp_request_port; // partial data request analysis port for monitor

  chi_rni_rx_item m_chi_rx_data_item;
  chi_rni_rx_item m_chi_rx_rsp_item;

  virtual function void build_phase (uvm_phase phase);
    super.build_phase (phase);

    if(!uvm_config_db#(chi_rni_rx_config_if)::get(this, "", "rx_agt_cfg", rx_agt_cfg_if))
      `uvm_fatal("NOCONFIG", {"Config object must be set for: ", get_full_name(), ".rx_agt_cfg"})
    //Creation of declared analysis port
    mon_rxdat_analysis_port = new ("mon_rxdat_analysis_port", this);
    mon_rxdat_request_port = new ("mon_rxdat_request_port", this);

    mon_rxrsp_analysis_port = new ("mon_rxrsp_analysis_port", this);
    mon_rxrsp_request_port = new ("mon_rxrsp_request_port", this);

    m_chi_rx_data_item = chi_rni_rx_item::type_id::create("m_chi_rx_data_item"); 
    m_chi_rx_rsp_item = chi_rni_rx_item::type_id::create("m_chi_rx_rsp_item"); 


  endfunction: build_phase

  virtual task run_phase(uvm_phase phase);
    process reset_thread;
    process monitor_rxdat_thread;
    process monitor_rxrsp_thread;
    //process timeout_thread;
    @(negedge rx_agt_cfg_if.v_if.rst_n);
    do begin 
      @(posedge rx_agt_cfg_if.v_if.clk);
    end while (rx_agt_cfg_if.v_if.rst_n != 1);
    forever begin
      fork
        begin
          monitor_rxdat_thread= process::self();  
          rcv_read_rxdat_flit();  
        end
        begin
          monitor_rxrsp_thread= process::self();  
          rcv_rxrsp_flit();  
        end
        begin
          reset_thread= process::self();  
          @(negedge rx_agt_cfg_if.v_if.rst_n) begin
            //interrupt the current item at reset
            if(monitor_rxdat_thread || monitor_rxrsp_thread) begin
              monitor_rxdat_thread.kill();
              monitor_rxrsp_thread.kill();
            end
            reset_monitor();
          end
        end
      join_any

      if(reset_thread.status() == "FINISHED") reset_thread.kill();
    end
  endtask : run_phase

  //Function: rcv_read_rxdat_flit
  //Desc: This task monitors when a valid flit is coming on the rxdat interface and samples the content of the flit
  //then sends it to the rxdat analysis port
  task rcv_read_rxdat_flit();
    bit [RX_D-1:0]       unpacked_flit;

    @(negedge rx_agt_cfg_if.v_if.chi_rni_rxdatflitpend);
    @(rx_agt_cfg_if.v_if.rxdata_cb_drv iff rx_agt_cfg_if.v_if.chi_rni_rxdatflitv);
    unpacked_flit = rx_agt_cfg_if.v_if.chi_rni_rxdatflit;
    pack_rx_data_flit(m_chi_rx_data_item.rx_data_flit_i, unpacked_flit);
    mon_rxdat_analysis_port.write(m_chi_rx_data_item);
    `uvm_info(get_type_name(), $sformatf ("RX monitor sampled a valid data flit"), UVM_HIGH)
  endtask

  //Function: rcv_rxrsp_flit
  //Desc: This task monitors when a valid flit is coming on the rxrsp interface and samples the content of the flit
  //then sends it to the rxrsp analysis port
  task rcv_rxrsp_flit();
    bit [RX_T-1:0]       unpacked_flit;

    @(negedge rx_agt_cfg_if.v_if.chi_rni_rxrspflitpend);
    @(rx_agt_cfg_if.v_if.rxrsp_cb_drv iff rx_agt_cfg_if.v_if.chi_rni_rxrspflitv);
    unpacked_flit = rx_agt_cfg_if.v_if.chi_rni_rxrspflit;
    pack_rx_rsp_flit(m_chi_rx_rsp_item.rx_rsp_flit_i, unpacked_flit);
    mon_rxrsp_analysis_port.write(m_chi_rx_rsp_item);
    `uvm_info(get_type_name(), $sformatf ("RX monitor sampled a valid response flit"), UVM_HIGH)
  endtask

  virtual function void reset_monitor();
    //TODO: Reset monitor specific state variables (cnt, flags, buffers etc.)
  endfunction

  //Pack the tx_data_flit seen on the interface
  function pack_rx_data_flit(
    output chi_rni_dataflit_item packed_flit,
    input  bit [RX_D-1:0]        unpacked_flit
  );
    int idx;
    idx = RX_D;

    packed_flit = chi_rni_dataflit_item::type_id::create("packed_flit"); 

    idx -= (`DWIDTH/64);  packed_flit.Poison     = unpacked_flit[idx +: (`DWIDTH/64)];
    idx -= `DWIDTH;       packed_flit.Data       = unpacked_flit[idx +: `DWIDTH];
    idx -= (`DWIDTH/8);   packed_flit.BE         = unpacked_flit[idx +: (`DWIDTH/8)];
    idx -= 1;             packed_flit.TraceTag   = unpacked_flit[idx];
    idx -= (`DWIDTH/128); packed_flit.TU         = unpacked_flit[idx +: (`DWIDTH/128)];
    idx -= (`DWIDTH/32);  packed_flit.Tag        = unpacked_flit[idx +: (`DWIDTH/32)];
    idx -= 2;             packed_flit.TagOp      = unpacked_flit[idx +: 2];
    idx -= 2;             packed_flit.DataID     = unpacked_flit[idx +: 2];
    idx -= 2;             packed_flit.CCID       = unpacked_flit[idx +: 2];
    idx -= 12;            packed_flit.DBID       = unpacked_flit[idx +: 12];
    idx -= 3;             packed_flit.CBusy      = unpacked_flit[idx +: 3];
    idx -= 4;             packed_flit.DataSource = unpacked_flit[idx +: 4];
    idx -= 3;             packed_flit.Resp       = unpacked_flit[idx +: 3];
    idx -= 2;             packed_flit.RespErr    = unpacked_flit[idx +: 2];
    //PackOpcode
    idx -= 7;             packed_flit.Opcode     = chi_opcode_t'(unpacked_flit[idx +: 7]);
    idx -= `NODEID_WIDTH; packed_flit.HomeNID    = unpacked_flit[idx +: `NODEID_WIDTH];
    idx -= 12;            packed_flit.TxnID      = unpacked_flit[idx +: 12];
    idx -= `NODEID_WIDTH; packed_flit.SrcID      = unpacked_flit[idx +: `NODEID_WIDTH];
    idx -= `NODEID_WIDTH; packed_flit.TgtID      = unpacked_flit[idx +: `NODEID_WIDTH];
    idx -= 4;             packed_flit.QoS        = unpacked_flit[idx +: 4];
  endfunction

  //Pack the rx_rsp_flit seen on the interface
  function pack_rx_rsp_flit(
    output chi_rni_rspflit_item packed_flit,
    input  bit [RX_T-1:0]       unpacked_flit
  );
    int idx;
    idx = RX_T;

    packed_flit = chi_rni_rspflit_item::type_id::create("packed_flit"); 

    idx -= 1;             packed_flit.TraceTag = unpacked_flit[idx];
    idx -= 2;             packed_flit.TagOp    = unpacked_flit[idx +: 2];
    idx -= 4;             packed_flit.PCrdType = unpacked_flit[idx +: 4];
    idx -= 12;            packed_flit.DBID     = unpacked_flit[idx +: 12];
    idx -= 3;             packed_flit.CBusy    = unpacked_flit[idx +: 3];
    idx -= 3;             packed_flit.FwdState = unpacked_flit[idx +: 3];
    idx -= 3;             packed_flit.Resp     = unpacked_flit[idx +: 3];
    idx -= 2;             packed_flit.RespErr  = unpacked_flit[idx +: 2];
    idx -= 7;             packed_flit.Opcode   = chi_opcode_t'(unpacked_flit[idx +: 7]);
    idx -= 12;            packed_flit.TxnID    = unpacked_flit[idx +: 12];
    idx -= `NODEID_WIDTH; packed_flit.SrcID    = unpacked_flit[idx +: `NODEID_WIDTH];
    idx -= `NODEID_WIDTH; packed_flit.TgtID    = unpacked_flit[idx +: `NODEID_WIDTH];
    idx -= 4;             packed_flit.QoS      = unpacked_flit[idx +: 4];
  endfunction

endclass : chi_rni_rx_monitor