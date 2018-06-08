



class ddr3_tb_driver extends uvm_driver#(ddr3_seq_item);
	`uvm_component_utils(ddr3_tb_driver)

	string m_name = "DDR3_TB_DRIVER";

	virtual ddr3_interface m_intf;
	ddr3_tb_reg_model reg_model_h;

    function new(string name = m_name, uvm_component parent = null);
	    super.new(name,parent);
    endfunction //new()

    function void build_phase(uvm_phase phase);
	    super.build_phase(phase);
 
	    assert(uvm_config_db #(virtual ddr3_interface)::get(null,"uvm_test_top","DDR3_interface",m_intf)) `uvm_info(m_name,"Got the interface in driver",UVM_HIGH)
	    assert(uvm_config_db #(ddr3_tb_reg_model)::get(this,"","reg_model",reg_model_h)) `uvm_info(m_name,"Got the handle for REG MODEL",UVM_HIGH)

    endfunction

    task run_phase(uvm_phase phase);

	    ddr3_seq_item ddr3_tran;

	    forever begin //{

		    seq_item_port.get_next_item(ddr3_tran);
		    phase.raise_objection(this,$sformatf("%s:Got a transaction from the sequencer",m_name));
			`uvm_info(m_name,ddr3_tran.conv_to_str(),UVM_HIGH)
			case (ddr3_tran.CMD)
				
				RESET: begin		// Reset and Poer up performs the same function; -Kirtan
					m_intf.power_up();
				end

				PRECHARGE: begin
					m_intf.precharge(ddr3_tran.bank_sel,ddr3_tran.row_addr);	
					end 
				
				ZQ_CAL_L: begin		// This is Z_cal_long given in subtest.vh
					m_intf.zq_calibration(1);
				end

				MSR: begin
					reg_model_h.load_model(ddr3_tran.mode_cfg);
					m_intf.load_mode(ddr3_tran.mode_cfg.ba, ddr3_tran.mode_cfg.bus_addr);
					reg_model_h.conv_to_str();
				end

				NOP: begin
					m_intf.nop(10);
					$display("inside nop case in driver");
				end

				WRITE: begin
					m_intf.write(ddr3_tran.bank_sel, ddr3_tran.col_addr,0,0,0,ddr3_tran.row_addr);
				end

		    endcase 


// We will implement this sequence..
//////////////////////////////////////////////////////////////////////////
//
			// power up();										// reset
			// zq_calibration  (1);                            // perform Long ZQ Calibration

			// load_mode       (3, 14'b00000000000000);        // Extended Mode Register (3)
			// nop             (tmrd-1);
			
			// load_mode       (2, {14'b00001000_000_000} | mr_cwl<<3); // Extended Mode Register 2 with DCC Disable
			// nop             (tmrd-1);
			
			// load_mode       (1, 14'b0000010110);            // Extended Mode Register with DLL Enable, AL=CL-1
			// nop             (tmrd-1);
			
			// load_mode       (0, {14'b0_0_000_1_0_000_1_0_00} | mr_wr<<9 | mr_cl<<2); // Mode Register with DLL Reset
	
			// nop             (max(TDLLK,TZQINIT));
			// odt_out         <= 1;                           // turn on odt
			// nop (10);

		// r_bank = $urandom_range (8);
        // r_row  = $urandom_range (1<<ROW_BITS);
        // r_col  = $urandom_range (1<<COL_BITS);
        // r_data = {$urandom,$urandom,$urandom,$urandom,$urandom,$urandom,$urandom,$urandom};

        // activate        (r_bank, r_row);
        // nop (trcd);

        // write           (r_bank, r_col, 0, 0, 0, r_data);
        // nop (wl + bl/2 + twtr);

        // read            (r_bank, r_col, 0, 0);
        // nop (rl + bl/2);

        // precharge       (r_bank, 0);
        // nop (trp);

//
////////////////////////////////////////////////////

		    seq_item_port.item_done();

		    phase.drop_objection(this,$sformatf("%s:Done Transfer",m_name));

	    end //}

    endtask 

	


endclass //ddr3_tb_driver extends uvm_drive
