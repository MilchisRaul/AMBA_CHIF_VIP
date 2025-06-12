//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 21/02/2025
//  File name             : chi_rni_seq_item.svh
//  Last modified+updates : 21/02/2025 (RM)
//  Project               : CHI Protocol RNI VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Transaction item for chi_rni Verification IP (UVC), contains all flit structures
//                          and some meta-data informations for delay and other functionalities.
//  ======================================================================================================

class chi_rni_reqflit_item extends uvm_sequence_item;
  
  rand bit [3:0]            QoS;       //Quality of Service field
  rand bit [`NODEID_WIDTH -1: 0] TgtID;     //Target ID field (Completer ID)
  rand bit [`NODEID_WIDTH -1: 0] SrcID;     //Source ID field (Initiator ID)
  rand bit [11: 0]          TxnID;     //Transaction ID
  rand bit [`NODEID_WIDTH -1: 0] RetrunNID; //Return Node ID at which completer sends CompData/DataSepRsp/Persist rsp
                                        //Used only in ReadNoSnp, ReadNoSnpSep, WriteNoSnp, Combined Write, and Atomic requests, in rest value is ''0''.
  /* NOT USED, applicable only in Stash requests, VIP doesn't support
    {(NODEID_WIDTH-7)'b0,StashNID} */
  rand bit                  StashNIDValid; //Applicable only in stash requests, must be set to ''0'' in other requests.
  /* StashNIDValid substitues (can be used in other req transactions)
  rand bit                  Endian;        //Determine the endianess of the transaction in Atomic transactions; ''0''- Little Endian/''1''- Big Endian
  rand bit                  Deep = 1'd0; //Indicates the Persist response must not be sent until earlier writes are written to the final dest.
                                 //Applicable only in CleanSharedPersist request, must be set to ''0'' for other requests
  */
  rand bit [11: 0]          ReturnTxnID; //Return TxnID. Identifies the value the Completer must use in the TxnID field of the CompData, and DataSepResp response.
                                        //Applicable only in HN -> SN Requests, must be set to ''0'' in other requests.
  /* NOT USED, applicable only in Stash requests, VIP doesn't support
    {6'b0,  //Should be always set to 0.
    1b(StashLPIDValid), //Applicable only in stash transactions and indicates that the StashLPID field has a valid value. In other requests should be ''0''.
    5b(StashLPID)}      //Stash Logical Processor ID. Provides a valid Logical Processor target value within the Request Node specified by StashNID,
                        //Applicable only in stash requests, must be set to ''0'' in other requests.
  */ 
  rand chi_opcode_t         Opcode;  //Opcode (Request transaction type Read/Write/Other) on 7 bits
  rand bit [2: 0]           Size; //Specifies the size of the data associated with the transaction, default value 3'b100 - 16 Bytes
  rand bit [`RAW -1: 0]      Addr; //Request Addr
  rand bit                  NS;  //Non Secure, determines the secure/non secure address spaces, default value ''1'' - non secure
  rand bit                  LikelyShared; //Determines if the data is likely to be shared with other RN, default ''0'', not shared
  rand bit                  AllowRetry; //Indicates that the request is being send withoyut a P-Creidt and the target can request a retry if set (''1'');Retry Ack not permitted/permitted
  rand bit [1: 0]           Order; //Indicates if the transaction requires order and the order type, by default is set to ''0'' as VIP doesn't support ordered req
  rand bit [3: 0]           PCrdType; //Indicates the type of P-Creidt being granted or returned
  rand bit [3: 0]           MemAttr; //Memory attribute associated with the transaction, default 4'b0001 - Not allocate, non-cachable, normal memory type and Early Ack is permitted.
  rand bit                  SnpAttr; //Specifies the snoop atribute, default value ''0'' means not snoopable.
  /* Alternative for SnpAttr for another trans
  rand bit                  DoDWT = 1'd0; //Applicable only in WriteNoSnpFull, WriteNoSnpPtl from HN to SN.
  */
  rand bit [2: 0]           GroupIDExt; // Group ID Extension. A 3-bit REQ channel field, not used, default value ''0''
  rand bit [4: 0]           LPID; // Logical Processor ID ReadNoSnp/WriteNoSnp Exclusive, Non-snoopable, Non-cacheable, or Device access requests.
  rand bit                  Excl; // Indicates the coresponding transaction is an Exclusive typpe transaction; Must be used only with some transactions (can be checked in the protocol specs)
                             // ''0'' - Normal trans, ''1'' - Excluisive trans
  rand bit                  ExpCompAck; //Expect CompAck. Indicates that the transaction will include a CompAck response.
  rand bit [1: 0]           TagOp; //Tag Operation. Indicates the operation to be performed on the tags present in the corresponding DAT channel, default ''0'' 
  rand bit                  TraceTag; //A bit in a packet used to tag the packets associated with a transaction for tracing purposes, default ''0''
  // MPAM - no MPAM bus, 0 bits
  // RSVDC - no RSVDC bus, 0 bits
  //Total bits: 87 to 99 + RAW = 131 to 143 bits

  constraint fixed_value_rni_req_flit{
    soft RetrunNID == 'd0;
    soft StashNIDValid == 1'd0;
    soft ReturnTxnID == 12'd0;
    soft Size == 3'd4;
    soft NS == 1'd1;
    soft LikelyShared == 1'd0;
    soft Order == 2'd0;
    soft MemAttr == 4'd1;
    soft SnpAttr == 1'd0;
    soft GroupIDExt == 3'd0;
    soft TagOp == 2'd0;
    soft TraceTag == 1'd0;
  };

  //Utility and Field macros including parameters
  `uvm_object_utils_begin(chi_rni_reqflit_item)
    `uvm_field_int  (QoS,   UVM_DEFAULT)
    `uvm_field_int  (TgtID,   UVM_DEFAULT)  
    `uvm_field_int  (SrcID,   UVM_DEFAULT)  
    `uvm_field_int  (TxnID,   UVM_DEFAULT)  
    `uvm_field_int  (RetrunNID,   UVM_DEFAULT)  
    `uvm_field_int  (StashNIDValid,   UVM_DEFAULT)  
    `uvm_field_int  (ReturnTxnID,   UVM_DEFAULT)
    `uvm_field_enum (chi_opcode_t, Opcode, UVM_DEFAULT)
    `uvm_field_int  (Size,   UVM_DEFAULT)  
    `uvm_field_int  (Addr,   UVM_DEFAULT)  
    `uvm_field_int  (NS,   UVM_DEFAULT)  
    `uvm_field_int  (LikelyShared,   UVM_DEFAULT)  
    `uvm_field_int  (AllowRetry,   UVM_DEFAULT)  
    `uvm_field_int  (Order,   UVM_DEFAULT)  
    `uvm_field_int  (PCrdType,   UVM_DEFAULT)  
    `uvm_field_int  (MemAttr,   UVM_DEFAULT)  
    `uvm_field_int  (SnpAttr,   UVM_DEFAULT)  
    `uvm_field_int  (GroupIDExt,   UVM_DEFAULT)  
    `uvm_field_int  (LPID,   UVM_DEFAULT)  
    `uvm_field_int  (Excl,   UVM_DEFAULT)  
    `uvm_field_int  (ExpCompAck,   UVM_DEFAULT)  
    `uvm_field_int  (TagOp,   UVM_DEFAULT)  
    `uvm_field_int  (TraceTag,   UVM_DEFAULT)  
 `uvm_object_utils_end
  
  //Constructor
  function new(string name = "chi_rni_reqflit_item");
    super.new(name);
  endfunction: new

endclass: chi_rni_reqflit_item

class chi_rni_rspflit_item extends uvm_sequence_item;

  rand bit [3:0]            QoS;       //Quality of Service field
  rand bit [`NODEID_WIDTH -1: 0] TgtID;     //Target ID field (Completer ID)
  rand bit [`NODEID_WIDTH -1: 0] SrcID;     //Source ID field (Initiator ID)
  rand bit [11 :0]          TxnID;     //Transaction ID
  rand chi_opcode_t         Opcode;  //Opcode (Request transaction type Read/Write/Other) on 7 bits
  rand bit [1: 0]           RespErr; //Indicates the error status of the response.
  rand bit [2: 0]           Resp; //Indicates the snoop response, set to always ''0''
  rand bit [2: 0]           FwdState; //or DataPull - Not used, always set to ''0'' (used for stash and snoop transactions)
  rand bit [2: 0]           CBusy; // Indicates that the completer is busy, user defined functionality, always set to ''0'', not used
  rand bit [11:0]           DBID; //The DBID field value in the response packet from a Completer is used as the TxnID for
                                  // CompAck or WriteData sent from the Requester. It can also be used as TagGroupID in WriteNoSnp and ReadNoSnp tag trans
  rand bit [3: 0]           PCrdType; //Indicates the type of P-Credit being granted or returned
  rand bit [1: 0]           TagOp; //Tag Operation. Indicates the operation to be performed on the tags present in the corresponding DAT channel, default ''0'' 
  rand bit                  TraceTag; //A bit in a packet used to tag the packets associated with a transaction for tracing purposes, default ''0''
  //Total bits: 65 to 73 bits

  constraint fixed_value_rni_rsp_flit{
    soft Resp == 3'd0;
    soft FwdState == 3'd0;
    soft CBusy == 2'd0;
    soft TagOp == 2'd0;
    soft TraceTag == 1'd0;
  };

  //Utility and Field macros including parameters
  `uvm_object_utils_begin(chi_rni_rspflit_item)
    `uvm_field_int  (QoS,   UVM_DEFAULT)
    `uvm_field_int  (TgtID,   UVM_DEFAULT)
    `uvm_field_int  (SrcID,   UVM_DEFAULT)
    `uvm_field_int  (TxnID,   UVM_DEFAULT)
    `uvm_field_enum (chi_opcode_t, Opcode, UVM_DEFAULT)
    `uvm_field_int  (RespErr,   UVM_DEFAULT)
    `uvm_field_int  (Resp,   UVM_DEFAULT)
    `uvm_field_int  (FwdState,   UVM_DEFAULT)
    `uvm_field_int  (CBusy,   UVM_DEFAULT)
    `uvm_field_int  (DBID,   UVM_DEFAULT)
    `uvm_field_int  (PCrdType,   UVM_DEFAULT)
    `uvm_field_int  (TagOp,   UVM_DEFAULT)
    `uvm_field_int  (TraceTag,   UVM_DEFAULT)
  `uvm_object_utils_end
  
  //Constructor
  function new(string name = "chi_rni_rspflit_item");
    super.new(name);
  endfunction: new

endclass: chi_rni_rspflit_item

class chi_rni_dataflit_item extends uvm_sequence_item;
  
  rand bit [3:0]                QoS;       //Quality of Service field
  rand bit [`NODEID_WIDTH -1: 0]     TgtID;     //Target ID field (Completer ID)
  rand bit [`NODEID_WIDTH -1: 0]     SrcID;     //Source ID field (Initiator ID)
  rand bit [11: 0]              TxnID;     //Transaction ID
  rand bit [`NODEID_WIDTH -1: 0]     HomeNID; //The Requester uses the value in this field to determine the TgtID of the CompAck to be sent in response to CompData
                                    //Applicable in CompData and DataSepResp from SN and HN, must be ''0'' in all other data messages.
  rand chi_opcode_t             Opcode;  //Opcode (Request transaction type Read/Write/Other) on 7 bits
  rand bit [1: 0]               RespErr; //Indicates the error status of the response.
  rand bit [2: 0]               Resp; //Indicates the snoop response, set to always ''0''
  rand bit [3: 0]               DataSource; //Indicates Data source in a response, feature not used, set to ''0'' 
  rand bit [2: 0]               CBusy; // Indicates that the completer is busy, user defined functionality, always set to ''0'', not used
  rand bit [11:0]               DBID; //The DBID field value in the response packet from a Completer is used as the TxnID for
                                 // CompAck or WriteData sent from the Requester. It can also be used as TagGroupID in WriteNoSnp and ReadNoSnp tag trans
  rand bit [1: 0]               CCID; // The CCID indicates the critical 128-bit chunk of the data that is being requested.
  rand bit [1: 0]               DataID; //The DataID indicates the relative position of the data chunk within the 512-bit cache line that is being transferred.
  rand bit [1: 0]               TagOp; //Tag Operation. Indicates the operation to be performed on the tags present in the corresponding DAT channel, default ''0'' 
  rand bit [(`DWIDTH/32) -1: 0]  Tag; //Provides n sets of 4-bit tags, each associated with a 16-byte, aligned address location
                            // [Tag[((4∗n)-1) : 4∗(n-1)] corresponds to Data[((128∗n)-1) : 128∗(n-1)]
  rand bit [(`DWIDTH/128) -1: 0] TU; //Tag Update. Indicates which of the Allocation Tags must be updated, used only in snoop trans. Must be set to ''0'' in other trans.
  rand bit                      TraceTag; //A bit in a packet used to tag the packets associated with a transaction for tracing purposes, default ''0''
  // RSVDC - no RSVDC bus, 0 bits
  rand bit [(`DWIDTH/8) -1: 0]   BE; //Byte Enable. Indicates if the byte of data corresponding to this byte enable bit is valid, valid only for Write trans.
                               //For read or other trans, this can take any value, so it is a reserved field.
  rand bit [`DWIDTH -1: 0]       Data; //Data payload. This is the data payload that is being transported in a Data packet. It can be 128, 256, 512 bits width
  //bit [(DWIDTH/8) -1: 0]     DataCheck; //Data Check. Used to supply the DataCheck bit for the corresponding byte of Data, not used, can be excluded
  rand bit [(`DWIDTH/64) -1: 0]  Poison; // Indicates if the 64-bit chunk of data corresponding to a Poison bit is poisoned, that is, has an error, and must not be consumed.
  // Total bits: 221 to 233 + P = 223 to 235 - with DWIDTH 128 bits
  //             370 to 382 + P = 374 to 386 - with DWIDTH 256 bits
  //             668 to 680 + P = 676 to 688 - with DWIDTH 512 bits


  constraint fixed_value_rni_data_flit{
    soft Resp == 3'd0;
    soft DataSource == 3'd0;
    soft CBusy == 2'd0;
    soft DataID == 2'd0;
    soft TagOp == 2'd0;
    soft TraceTag == 1'd0;
  };

  //Utility and Field macros including parameters
  `uvm_object_utils_begin(chi_rni_dataflit_item)
    `uvm_field_int  (QoS,   UVM_DEFAULT)
    `uvm_field_int  (TgtID,   UVM_DEFAULT)
    `uvm_field_int  (SrcID,   UVM_DEFAULT)
    `uvm_field_int  (TxnID,   UVM_DEFAULT)
    `uvm_field_int  (HomeNID,   UVM_DEFAULT)
    `uvm_field_enum (chi_opcode_t, Opcode, UVM_DEFAULT)
    `uvm_field_int  (RespErr,   UVM_DEFAULT)
    `uvm_field_int  (Resp,   UVM_DEFAULT)
    `uvm_field_int  (DataSource,   UVM_DEFAULT)
    `uvm_field_int  (CBusy,   UVM_DEFAULT)
    `uvm_field_int  (DBID,   UVM_DEFAULT)
    `uvm_field_int  (CCID,   UVM_DEFAULT)
    `uvm_field_int  (DataID,   UVM_DEFAULT)
    `uvm_field_int  (TagOp,   UVM_DEFAULT)
    `uvm_field_int  (Tag,   UVM_DEFAULT)
    `uvm_field_int  (TU,   UVM_DEFAULT)
    `uvm_field_int  (TraceTag,   UVM_DEFAULT)
    `uvm_field_int  (BE,   UVM_DEFAULT)
    `uvm_field_int  (Data,   UVM_DEFAULT)
    `uvm_field_int  (Poison,   UVM_DEFAULT)
  `uvm_object_utils_end
  
  //Constructor
  function new(string name = "chi_rni_dataflit_item");
    super.new(name);
  endfunction: new

endclass: chi_rni_dataflit_item

class chi_rni_rx_item extends uvm_sequence_item;

  //VARIABLE: rsp_flit_i
  //Item instation of response flit
  rand chi_rni_rspflit_item rx_rsp_flit_i;

  //VARIABLE: data_flit_i
  //Item instation of data flit
  rand chi_rni_dataflit_item rx_data_flit_i;

  //VARIABLE: rxrsp_cred_dly
  //Variable for the delay to send the credit
  rand int unsigned rxrsp_cred_dly;
  //VARIABLE: rxdat_cred_dly
  //Variable for the delay to send the credit
  rand int unsigned rxdata_cred_dly;

  //VARIABLE: rx_linkack_activate_delay
  //Variable for the rxlinkactiveack signal assertion delay
  rand int unsigned rx_linkack_activate_delay;

  //VARIABLE: rx_linkack_deactivate_delay
  //Variable for the rxlinkactiveack signal deassertion delay
  rand int unsigned rx_linkack_deactivate_delay;

  //VARIABLES: *_scope
  //Variables to choose the scope of the flit (protocol or link handhsake flit)
  //and to choose the nature of the flit (for protocol - DATA or RESP flit/for link hsk
  //linkack ACTIVATE->RUN or DEACTIVATE->STOP transitions)
  rand bit resp_flit_scope;
  rand bit data_flit_scope;
  rand bit link_active_ack_run_scope;
  rand bit link_active_ack_stop_scope;

  //Number of LCredits -> Max. 15 credits | Min. 1 credit for each channel
  rand bit unsigned [CRDWIDTH - 1: 0] num_of_rxrsp_credits;
  rand bit unsigned [CRDWIDTH - 1: 0] num_of_rxdata_credits;

  //Defines the maximum number of credits, which is 15 according to the CHI-F protocol spec
  constraint num_of_maximum_credit_values {
    num_of_rxrsp_credits <= 15;
    num_of_rxdata_credits <= 15;
  }

  `uvm_object_utils_begin(chi_rni_rx_item)
    `uvm_field_int    (rxrsp_cred_dly,   UVM_DEFAULT)
    `uvm_field_int    (rxdata_cred_dly,   UVM_DEFAULT)
    `uvm_field_int    (rx_linkack_activate_delay,   UVM_DEFAULT)
    `uvm_field_int    (rx_linkack_deactivate_delay,   UVM_DEFAULT)
    `uvm_field_int    (num_of_rxrsp_credits,   UVM_DEFAULT)
    `uvm_field_int    (num_of_rxdata_credits,   UVM_DEFAULT)
    `uvm_field_int    (resp_flit_scope,   UVM_DEFAULT)
    `uvm_field_int    (data_flit_scope,   UVM_DEFAULT)
    `uvm_field_int    (link_active_ack_run_scope,   UVM_DEFAULT)
    `uvm_field_int    (link_active_ack_stop_scope,   UVM_DEFAULT)
    `uvm_field_object (rx_rsp_flit_i, UVM_DEFAULT)
    `uvm_field_object (rx_data_flit_i, UVM_DEFAULT)
  `uvm_object_utils_end

  //Constructor
  function new(string name = "chi_rni_rx_item");
    super.new(name);
  endfunction: new

endclass : chi_rni_rx_item

class chi_rni_tx_item extends uvm_sequence_item;

  //VARIABLE req_flit_i
  //Item instantion of request flit
  rand chi_rni_reqflit_item tx_req_flit_i;

  //VARIABLE: rsp_flit_i
  //Item instation of response flit
  rand chi_rni_rspflit_item tx_rsp_flit_i;

  //VARIABLE: data_flit_i
  //Item instation of data flit
  rand chi_rni_dataflit_item tx_data_flit_i;

  //VARIABLE: tx_valid_snd_delay
  //Variable for the delay to send the credit
  rand int chi_rni_valid_tx_dly;

  //VARIABLE: txsactive_activate_delay_no_rxsactive
  //Variable to activate the txlink for the TX channels
  rand int unsigned txsactive_activate_delay_no_rxsactive;
  //VARIABLE: txsactive_activate_delay_with_rxsactive
  //Variable to activate the txlink for the TX channels
  rand int unsigned txsactive_activate_delay_with_rxsactive;


  //VARIABLE: txlink_activate_req_delay
  //Variable to activate the txlink for the TX channels
  rand int unsigned txlink_activate_req_delay;
  //VARIABLE: txlink_deactivate_req_delay
  //Variable to activate the txlink for the TX channels
  rand int unsigned txlink_deactivate_req_delay;

  `uvm_object_utils_begin(chi_rni_tx_item)
    `uvm_field_int    (chi_rni_valid_tx_dly, UVM_DEFAULT)
    `uvm_field_int    (txlink_activate_req_delay, UVM_DEFAULT)
    `uvm_field_int    (txlink_deactivate_req_delay, UVM_DEFAULT)
    `uvm_field_int    (txsactive_activate_delay_no_rxsactive, UVM_DEFAULT)
    `uvm_field_int    (txsactive_activate_delay_with_rxsactive, UVM_DEFAULT)
    `uvm_field_object (tx_req_flit_i, UVM_DEFAULT)
    `uvm_field_object (tx_rsp_flit_i, UVM_DEFAULT)
    `uvm_field_object (tx_data_flit_i, UVM_DEFAULT)
  `uvm_object_utils_end

  //Constructor
  function new(string name = "chi_rni_tx_item");
    super.new(name);
  endfunction: new

endclass : chi_rni_tx_item
