//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 12/03/2025
//  File name             : chi_test_lib.svh
//  Last modified+updates : 12/03/2025 (RM) - Initial Version
//                          
//  Project               : CHI Protocol Test Bench
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Test library for CHI verification project
//  ======================================================================================================

class chi_base_test extends uvm_test;

  `uvm_component_utils(chi_base_test)

  chi_env m_env;

  function new(string name = "chi_base_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_env = chi_env::type_id::create("m_env", this);
  endfunction : build_phase
  
  function void final_phase(uvm_phase phase);
    `uvm_info("@@@@@@@@~~~~~~~~~~~~| TEST PASSED |~~~~~~~~~~~~@@@@@@@@", "No errors detected", UVM_NONE)
  endfunction : final_phase

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction: end_of_elaboration_phase

endclass : chi_base_test

class chi_read_no_snoop_sanity_test extends chi_base_test;
  
  `uvm_component_utils(chi_read_no_snoop_sanity_test)

  chi_sanity_read_no_snoop_hni_vseq m_readnosnoop_vseq;

  function new(string name = "chi_read_no_snoop_sanity_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_readnosnoop_vseq = chi_sanity_read_no_snoop_hni_vseq::type_id::create("m_readnosnoop_vseq");
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    begin
      phase.raise_objection(this);

      m_readnosnoop_vseq.start(m_env.v_seqr);
      
      phase.phase_done.set_drain_time(this, 1000000);
      phase.drop_objection(this);
    end
  endtask : run_phase

endclass : chi_read_no_snoop_sanity_test