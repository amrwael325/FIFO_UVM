package FIFO_driver_pkg;
import uvm_pkg::*;
import FIFO_cfg_pkg::*;
import FIFO_item_pkg::*;
`include "uvm_macros.svh"
class fifo_driver extends uvm_driver #(FIFO_seq_item);
    `uvm_component_utils(fifo_driver)
    virtual fifo_if fifo_driver_vif;
    FIFO_seq_item seq_item;

    function new(string name = "fifo_driver", uvm_component parent =null);
        super.new(name,parent);
    endfunction 
    

    task run_phase (uvm_phase phase);
        super.run_phase(phase);

        fifo_driver_vif.rst_n= 0;
        @(negedge fifo_driver_vif.clk);
        #10
        fifo_driver_vif.rst_n = 1;
        
        forever begin
            seq_item = FIFO_seq_item::type_id::create("seq_item",this);
            seq_item_port.get_next_item(seq_item);
            fifo_driver_vif.rst_n = seq_item.rst_n;
            fifo_driver_vif.wr_en = seq_item.wr_en;
            fifo_driver_vif.rd_en = seq_item.rd_en;
            fifo_driver_vif.data_in = seq_item.data_in;
            @(negedge fifo_driver_vif.clk);
            seq_item_port.item_done();
            `uvm_info("run_phase",seq_item.convert2string(),UVM_HIGH)
        end
    endtask 
endclass 
endpackage