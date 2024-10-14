package Seq_pkg;
    import uvm_pkg::*;
    import FIFO_item_pkg::*;
    `include "uvm_macros.svh"
    class myseq extends uvm_sequencer #(FIFO_seq_item);
    `uvm_component_utils(myseq)

    function new(string name = "myseq", uvm_component parent =null);
        super.new(name,parent);
    endfunction
        
    endclass
endpackage