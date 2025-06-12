//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 13/03/2025
//  File name             : chi_hni_defines.svh
//  Last modified+updates : 13/03/2025 (RM) - Initial version
// 
//  Project               : CHI Protocol Home Node (HNI) VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : chi_hni Verification IP (UVC) Defines
//  ======================================================================================================

//NodeID width in bits
`define NODEID_WIDTH 11

//Request Address Width (RAW) in bits
`define RAW 44 

//Data bus width in bits
`define DWIDTH 128

//RSP bus width in bits
`define RSPWIDTH 20

//Req bus width in bits
`define REQWIDTH 20

//Credit width (MAX 15)
`define NUM_OF_CREDITS 4

//VAR: agent_type_t
//Get the agent nature (MASTER = 0 /SLAVE = 1)
typedef enum {MASTER, SLAVE} agent_type_t;

//VAR: chi_opcode_t
//Opcode enum for selecting the transaction
typedef enum bit [6:0] {
  ReadNoSnp                   = 7'h04,  
  WriteNoSnpZero              = 7'h44,
  WriteNoSnpFullCleanSh       = 7'h50,
  ReadNoSnpSep                = 7'h11,
  WriteNoSnpFullCleanInv      = 7'h51,
  WriteNoSnpFullCleanShPerSep = 7'h52
} chi_opcode_t;

//VAR: chi_hni_req_flit_t
//Request flit packet structure
typedef struct packed {
  bit [3:0]            QoS;       //Quality of Service field
  bit [`NODEID_WIDTH -1: 0] TgtID;     //Target ID field (Initiator ID)
  bit [`NODEID_WIDTH -1: 0] SrcID;     //Source ID field (Completer ID)
  bit [11: 0]          TxnID;     //Transaction ID
  bit [`NODEID_WIDTH -1: 0] ReturnNID; //Return Node ID at which completer sends CompData/DataSepRsp/Persist rsp
                                        //Used only in ReadNoSnp, ReadNoSnpSep, WriteNoSnp, Combined Write, and Atomic requests, in rest value is ''0''.
  /* NOT USED, applicable only in Stash requests, VIP doesn't support
    {(NODEID_WIDTH-7)'b0,StashNID} */
  bit                  StashNIDValid; //Applicable only in stash requests, must be set to ''0'' in other requests.
  /* StashNIDValid substitues (can be used in other req transactions)
  bit                  Endian;        //Determine the endianess of the transaction in Atomic transactions; ''0''- Little Endian/''1''- Big Endian
  bit                  Deep = 1'd0; //Indicates the Persist response must not be sent until earlier writes are written to the final dest.
                                 //Applicable only in CleanSharedPersist request, must be set to ''0'' for other requests
  */
  bit [11: 0]          ReturnTxnID; //Return TxnID. Identifies the value the Completer must use in the TxnID field of the CompData, and DataSepResp response.
                                        //Applicable only in HN -> SN Requests, must be set to ''0'' in other requests.
  /* NOT USED, applicable only in Stash requests, VIP doesn't support
    {6'b0,  //Should be always set to 0.
    1b(StashLPIDValid), //Applicable only in stash transactions and indicates that the StashLPID field has a valid value. In other requests should be ''0''.
    5b(StashLPID)}      //Stash Logical Processor ID. Provides a valid Logical Processor target value within the Request Node specified by StashNID,
                        //Applicable only in stash requests, must be set to ''0'' in other requests.
  */ 
  chi_opcode_t         Opcode;  //Opcode (Request transaction type Read/Write/Other) on 7 bits
  bit [2: 0]           Size; //Specifies the size of the data associated with the transaction, default value 3'b100 - 16 Bytes
  bit [`RAW -1: 0]      Addr; //Request Addr
  bit                  NS;  //Non Secure, determines the secure/non secure address spaces, default value ''1'' - non secure
  bit                  LikelyShared; //Determines if the data is likely to be shared with other RN, default ''0'', not shared
  bit                  AllowRetry; //Indicates that the request is being send withoyut a P-Creidt and the target can request a retry if set (''1'');Retry Ack not permitted/permitted
  bit [1: 0]           Order; //Indicates if the transaction requires order and the order type, by default is set to ''0'' as VIP doesn't support ordered req
  bit [3: 0]           PCrdType; //Indicates the type of P-Creidt being granted or returned
  bit [3: 0]           MemAttr; //Memory attribute associated with the transaction, default 4'b0001 - Not allocate, non-cachable, normal memory type and Early Ack is permitted.
  bit                  SnpAttr; //Specifies the snoop atribute, default value ''0'' means not snoopable.
  /* Alternative for SnpAttr for another trans
  bit                  DoDWT = 1'd0; //Applicable only in WriteNoSnpFull, WriteNoSnpPtl from HN to SN.
  */
  bit [2: 0]           GroupIDExt; // Group ID Extension. A 3-bit REQ channel field, not used, default value ''0''
  bit [4: 0]           LPID; // Logical Processor ID ReadNoSnp/WriteNoSnp Exclusive, Non-snoopable, Non-cacheable, or Device access requests.
  bit                  Excl; // Indicates the coresponding transaction is an Exclusive typpe transaction; Must be used only with some transactions (can be checked in the protocol specs)
                             // ''0'' - Normal trans, ''1'' - Excluisive trans
  bit                  ExpCompAck; //Expect CompAck. Indicates that the transaction will include a CompAck response.
  bit [1: 0]           TagOp; //Tag Operation. Indicates the operation to be performed on the tags present in the corresponding DAT channel, default ''0'' 
  bit                  TraceTag; //A bit in a packet used to tag the packets associated with a transaction for tracing purposes, default ''0''
  // MPAM - no MPAM bus, 0 bits
  // RSVDC - no RSVDC bus, 0 bits
} chi_hni_req_flit_t; //Total bits: 87 to 99 + RAW = 131 to 143 bits

//VAR: chi_hni_rsp_flit_t
//Response flit packet structure
typedef struct packed {
  bit [3:0]            QoS;       //Quality of Service field
  bit [`NODEID_WIDTH -1: 0] TgtID;     //Target ID field (Initiator ID)
  bit [`NODEID_WIDTH -1: 0] SrcID;     //Source ID field (Completer ID)
  bit [11 :0]          TxnID ;     //Transaction ID
  chi_opcode_t         Opcode;  //Opcode (Request transaction type Read/Write/Other) on 7 bits
  bit [1: 0]           RespErr; //Indicates the error status of the response.
  bit [2: 0]           Resp; //Indicates the snoop response, set to always ''0''
  bit [2: 0]           FwdState; //or DataPull - Not used, always set to ''0'' (used for stash and snoop transactions)
  bit [2: 0]           CBusy; // Indicates that the completer is busy, user defined functionality, always set to ''0'', not used
  bit [11:0]           DBID; //The DBID field value in the response packet from a Completer is used as the TxnID for
                             // CompAck or WriteData sent from the Requester. It can also be used as TagGroupID in WriteNoSnp and ReadNoSnp tag trans
  bit [3: 0]           PCrdType; //Indicates the type of P-Creidt being granted or returned
  bit [1: 0]           TagOp; //Tag Operation. Indicates the operation to be performed on the tags present in the corresponding DAT channel, default ''0'' 
  bit                  TraceTag; //A bit in a packet used to tag the packets associated with a transaction for tracing purposes, default ''0''
} chi_hni_rsp_flit_t; //Total bits: 65 to 73 bits

//VAR: chi_hni_data_flit_t
//Request flit packet structure
typedef struct packed {
  bit [3:0]                QoS;       //Quality of Service field
  bit [`NODEID_WIDTH -1: 0]     TgtID;     //Target ID field (Initiator ID)
  bit [`NODEID_WIDTH -1: 0]     SrcID;     //Source ID field (Completer ID)
  bit [11: 0]              TxnID;     //Transaction ID
  bit [`NODEID_WIDTH -1: 0]     HomeNID; //he Requester uses the value in this field to determine the TgtID of the CompAck to be sent in response to CompData
                                    //Applicable in CompData and DataSepResp from SN and HN, must be ''0'' in all other data messages.
  chi_opcode_t             Opcode;  //Opcode (Request transaction type Read/Write/Other) on 7 bits
  bit [1: 0]               RespErr; //Indicates the error status of the response.
  bit [2: 0]               Resp; //Indicates the snoop response, set to always ''0''
  bit [3: 0]               DataSource; //Indicates Data source in a response, feature not used, set to ''0'' 
  bit [2: 0]               CBusy; // Indicates that the completer is busy, user defined functionality, always set to ''0'', not used
  bit [11:0]               DBID; //The DBID field value in the response packet from a Completer is used as the TxnID for
                                 // CompAck or WriteData sent from the Requester. It can also be used as TagGroupID in WriteNoSnp and ReadNoSnp tag trans
  bit [1: 0]               CCID; // The CCID indicates the critical 128-bit chunk of the data that is being requested.
  bit [1: 0]               DataID; //The DataID indicates the relative position of the data chunk within the 512-bit cache line that is being transferred.
  bit [1: 0]               TagOp; //Tag Operation. Indicates the operation to be performed on the tags present in the corresponding DAT channel, default ''0'' 
  bit [(`DWIDTH/32) -1: 0]  Tag; //Provides n sets of 4-bit tags, each associated with a 16-byte, aligned address location
                            // [Tag[((4∗n)-1) : 4∗(n-1)] corresponds to Data[((128∗n)-1) : 128∗(n-1)]
  bit [(`DWIDTH/128) -1: 0] TU; //Tag Update. Indicates which of the Allocation Tags must be updated, used only in snoop trans. Must be set to ''0'' in other trans.
  bit                      TraceTag; //A bit in a packet used to tag the packets associated with a transaction for tracing purposes, default ''0''
  // RSVDC - no RSVDC bus, 0 bits
  bit [(`DWIDTH/8) -1: 0]   BE; //Byte Enable. Indicates if the byte of data corresponding to this byte enable bit is valid, valid only for Write trans.
                               //For read or other trans, this can take any value, so it is a reserved field.
  bit [`DWIDTH -1: 0]       Data; //Data payload. This is the data payload that is being transported in a Data packet. It can be 128, 256, 512 bits width
  //bit [(DWIDTH/8) -1: 0]     DataCheck; //Data Check. Used to supply the DataCheck bit for the corresponding byte of Data, not used, can be excluded
  bit [(`DWIDTH/64) -1: 0]  Poison; // Indicates if the 64-bit chunk of data corresponding to a Poison bit is poisoned, that is, has an error, and must not be consumed.
} chi_hni_data_flit_t; // Total bits: 221 to 233 + P = 223 to 235 - with DWIDTH 128 bits
                       //             370 to 382 + P = 374 to 386 - with DWIDTH 256 bits
                       //             668 to 680 + P = 676 to 688 - with DWIDTH 512 bits

/*
==================================================================================
| Opcode[5:0] | Opcode[6] = 0               | Opcode[6] = 1                      |
==================================================================================
| 0x00        | ReqLCrdReturn               | Reserved                           |
| 0x01        | ReadShared                  | MakeReadUnique                     |
| 0x02        | ReadClean                   | WriteEvictOrEvict                  |
| 0x03        | ReadOnce                    | WriteUniqueZero                    |
| 0x04        | ReadNoSnp                   | WriteNoSnpZero                     |
| 0x05        | PCrdReturn                  | Reserved                           |
| 0x06        | Reserved                    | Reserved                           |
| 0x07        | ReadUnique                  | StashOnceSepShared                 |
| 0x08        | CleanShared                 | StashOnceSepUnique                 |
| 0x09        | CleanInvalid                | Reserved                           |
| 0x0A        | MakeInvalid                 | Reserved                           |
| 0x0B        | CleanUnique                 | Reserved                           |
| 0x0C        | MakeUnique                  | ReadPreferUnique                   |
| 0x0D        | Evict                       | Reserved                           |
| 0x0E        | Reserved (EOBarrier)        | Reserved                           |
| 0x0F        | Reserved (ECBarrier)        | Reserved                           |
| 0x10        | Reserved                    | WriteNoSnpFullCleanSh              |
| 0x11        | ReadNoSnpSep                | WriteNoSnpFullCleanInv             |
| 0x12        | Reserved                    | WriteNoSnpFullCleanShPerSep        |
| 0x13        | CleanSharedPersistSep       | Reserved                           |
| 0x14        | DVMOp                       | WriteUniqueFullCleanSh             |
| 0x15        | WriteEvictFull              | Reserved                           |
| 0x16        | Reserved (WriteCleanPtl)    | WriteUniqueFullCleanShPerSep       |
| 0x17        | WriteCleanFull              | Reserved                           |
==================================================================================
*/
