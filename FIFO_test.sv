package FIFO_test_pkg;
    import FIFO_env_pkg::*;
    import uvm_pkg::*;
    import FIFO_cfg_pkg::*;
    import FIFO_agent_pkg::*;
    import Seq_pkg::*;
    import FIFO_driver_pkg::*;
    import FIFO_seq_pkg::*;
    `include "uvm_macros.svh"
    class fifo_test extends uvm_test;
    `uvm_component_utils(fifo_test)
    fifo_env env;
    fifo_config_obj fifo_config_obj_test;
    virtual fifo_if fifo_test_vif;
    write_sequence write_seq;
    fifo_reset_seq reset_seq;
    read_sequence read_seq;
    read_write_sequence read_write_seq;

    function new(string name ="fifo_test",uvm_component parent = null);
        super.new(name,parent);
    endfunction 

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = fifo_env::type_id::create("env",this);
        fifo_config_obj_test = fifo_config_obj::type_id::create("cfg");
        write_seq = write_sequence::type_id::create("write_seq");
        reset_seq = fifo_reset_seq::type_id::create("reset_seq");
        read_seq = read_sequence::type_id::create("read_seq");
        read_write_seq = read_write_sequence::type_id::create("read_write_seq");
        if(!uvm_config_db#(virtual fifo_if)::get(this,"","FIFO_IF",fifo_config_obj_test.fifo_config_vif))
            `uvm_fatal("build phase","Test unable to get the virtual interface of the FIFO ");
        uvm_config_db#(fifo_config_obj)::set(this,"*","CFG",fifo_config_obj_test);
    endfunction
    task run_phase (uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);

        `uvm_info("run_phase","Reset Asserted",UVM_LOW);
        reset_seq.start(env.agt.sqr);
        `uvm_info("run_phase","Reset Deasserted",UVM_LOW);

        `uvm_info("run_phase","Stimulus Generation Started",UVM_LOW);
        write_seq.start(env.agt.sqr);
        read_seq.start(env.agt.sqr);
        read_write_seq.start(env.agt.sqr);
        `uvm_info("run_phase","Stimulus Generation Ended",UVM_LOW);

        phase.drop_objection(this);
    endtask : run_phase
endclass
endpackage