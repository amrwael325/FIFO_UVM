package FIFO_scoreboard_pkg;
    import uvm_pkg::*;
	import FIFO_item_pkg::*;
    `include "uvm_macros.svh"
    class FIFO_scoreboard extends uvm_scoreboard;
		`uvm_component_utils(FIFO_scoreboard)
		uvm_analysis_export #(FIFO_seq_item) sb_export;
		uvm_tlm_analysis_fifo #(FIFO_seq_item) sb_fifo;
		FIFO_seq_item seq_item_sb;

        localparam FIFO_WIDTH = 16;
        localparam FIFO_DEPTH = 8;
        localparam max_fifo_addr = $clog2(FIFO_DEPTH);

        bit [FIFO_WIDTH-1:0] mem[FIFO_DEPTH-1:0];  
        bit [max_fifo_addr-1:0] wr_ptr, rd_ptr;    
        bit [max_fifo_addr:0] count;               

    // Reference outputs
        logic full_ref, empty_ref, almostfull_ref, almostempty_ref;
        logic overflow_ref, underflow_ref;

		integer correct_counter=0;
		integer error_counter=0;		

		function new(string name = "FIFO_scoreboard", uvm_component parent = null);
			super.new(name,parent);
		endfunction

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			sb_export =new("sb_export",this);
			sb_fifo =new("sb_fifo",this);
		endfunction : build_phase

        function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);
			sb_export.connect(sb_fifo.analysis_export);
		endfunction : connect_phase

        task run_phase(uvm_phase phase);
			super.run_phase(phase);
			forever begin
				sb_fifo.get(seq_item_sb);
				ref_model(seq_item_sb);
				if (seq_item_sb.data_out != seq_item_sb.data_out_ref) begin
					`uvm_error("run_phase", $sformatf("There is an error!!, Transacton received by the DUT is: %s whilethe refernce output is: 0b%0b",
					seq_item_sb.convert2string(), seq_item_sb.data_out_ref));
					error_counter++;
				end 
				else begin
					`uvm_info("run_phase", $sformatf("Correct Transacton received, Output is: %s",
								seq_item_sb.convert2string()),UVM_HIGH)
					correct_counter++;
				end
			end
		endtask : run_phase


        task ref_model(FIFO_seq_item seq_item_chk);
        if(!seq_item_chk.rst_n) begin
        wr_ptr =0;
        overflow_ref =0;
        end
        else if (seq_item_chk.wr_en && !full_ref) begin
            mem[wr_ptr] = seq_item_chk.data_in;
            wr_ptr = wr_ptr + 1;
            overflow_ref=0;
        end else begin
        if (seq_item_chk.wr_en && full_ref) 
            overflow_ref = 1;
        else 
            overflow_ref = 0;
        end

        if(!seq_item_chk.rst_n) begin
        rd_ptr =0;
        underflow_ref =0;
        end
        else if (seq_item_chk.rd_en && !empty_ref) begin
        seq_item_chk.data_out_ref = mem[rd_ptr];
        rd_ptr = rd_ptr + 1;
        underflow_ref =0;
        end else begin
        if (seq_item_chk.rd_en && empty_ref) 
            underflow_ref = 1;
        else 
            underflow_ref = 0;
        end

        if(!seq_item_chk.rst_n)begin 
        count =0;
        end
        else begin
        if(seq_item_chk.wr_en && seq_item_chk.rd_en && empty_ref)
			count <= count + 1 ;	
		else if(seq_item_chk.wr_en && seq_item_chk.rd_en && full_ref)
			count <= count - 1 ;	
        else if (seq_item_chk.wr_en && !full_ref)
            count = count +1;
        else if (seq_item_chk.rd_en && !empty_ref)
            count =count -1 ;
        end
		
        full_ref = (count == FIFO_DEPTH) ? 1 : 0;
        empty_ref = (count == 0) ? 1 : 0;
        almostfull_ref = (count == FIFO_DEPTH - 1) ? 1 : 0;
        almostempty_ref = (count == 1) ? 1 : 0;


        endtask
        function void report_phase(uvm_phase phase);
			super.report_phase(phase);
			`uvm_info("report_phase", $sformatf("Total correct counts is: %0d",correct_counter),UVM_LOW)
			`uvm_info("report_phase", $sformatf("Total error counts is: %0d",error_counter),UVM_LOW)
		endfunction : report_phase

	endclass   
endpackage