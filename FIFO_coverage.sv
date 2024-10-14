package coverage_pkg;
    import uvm_pkg::*;
    import FIFO_driver_pkg::*;
    import FIFO_item_pkg::*;
    import FIFO_monitor_pkg::*;
    import FIFO_cfg_pkg::*;
    import Seq_pkg::*;
    `include "uvm_macros.svh"
    class FIFO_coverage extends uvm_component;
    `uvm_component_utils(FIFO_coverage)
    uvm_analysis_export #(FIFO_seq_item) cov_export;
    uvm_tlm_analysis_fifo #(FIFO_seq_item) cov_fifo;
    FIFO_seq_item seq_item_cov;

    covergroup cvr_gp; 


    cp_wr_en : coverpoint seq_item_cov.wr_en {
        bins wr_en_0 = {0};
        bins wr_en_1 = {1};
    }

    cp_rd_en : coverpoint seq_item_cov.rd_en {
        bins rd_en_0 = {0};
        bins rd_en_1 = {1};
    }

    cp_underflow : coverpoint seq_item_cov.underflow{
        bins underflow_0 = {0};
        bins underflow_1 = {1};
    }

    cp_overflow : coverpoint seq_item_cov.overflow{
        bins overflow_0 = {0};
        bins overflow_1 = {1};
    }
    cp_empty : coverpoint seq_item_cov.empty{
        bins empty_0 = {0};
        bins empty_1 = {1};
    }

    cross_cvr_full : cross seq_item_cov.wr_en, seq_item_cov.rd_en, seq_item_cov.full;
    cross_cvr_almostfull : cross seq_item_cov.wr_en, seq_item_cov.rd_en, seq_item_cov.almostfull;
    cross_cvr_empty : cross cp_wr_en, cp_rd_en, cp_empty{
        illegal_bins ignore_empty_invalid = binsof(cp_rd_en) intersect {1} && binsof(cp_wr_en) intersect {0}
                                            && binsof(cp_empty) intersect {1};
    }
    cross_cvr_almostempty : cross seq_item_cov.wr_en, seq_item_cov.rd_en, seq_item_cov.almostempty;

    
    cross_cvr_overflow : cross cp_wr_en, cp_rd_en, cp_overflow {
        ignore_bins ignore_overflow_invalid = binsof(cp_wr_en) intersect {0} &&
                                            binsof(cp_overflow) intersect {1};
    }

    
    cross_cvr_underflow : cross cp_wr_en, cp_rd_en, cp_underflow {
        ignore_bins ignore_underflow_invalid = binsof(cp_rd_en) intersect {0} &&
                                            binsof(cp_underflow) intersect {1};
    }

endgroup



    function new(string name ="FIFO_coverage",uvm_component parent = null);
        super.new(name,parent);
        cvr_gp =new();
    endfunction 


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cov_export = new("cov_export",this);
        cov_fifo = new("cov_fifo",this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        cov_export.connect(cov_fifo.analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
        cov_fifo.get(seq_item_cov);
        cvr_gp.sample();
    end
    endtask
    endclass 
    
endpackage