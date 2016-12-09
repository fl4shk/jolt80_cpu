// This file is part of Small Practice CPU.
// 
// Copyright 2016 by Andrew Clark (FL4SHK).
// 
// Small Practice CPU is free software: you can redistribute it and/or
// modify it under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
// 
// Small Practice CPU is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
// 
// You should have received a copy of the GNU General Public License along
// with Small Practice CPU.  If not, see <http://www.gnu.org/licenses/>.


`include "src/alu_defines.svinc"

`include "src/instr_decoder_defines.svinc"
//`include "src/cpu_extras_defines.svinc"


module spcpu_test_bench;
	
	bit clk_gen_reset, tb_half_clk, tb_mem_clk;
	
	bit test_mem_reset;
	
	//// Various test bench reset signals
	//bit alu_tb_reset, 
	//	instr_grp_dec_tb_reset,
	//	instr_dec_tb_reset;
	
	// reset signal for test_cpu
	bit test_cpu_reset;
	
	
	tb_half_clk_gen half_clk_gen( .reset(clk_gen_reset), 
		.half_clk(tb_half_clk) );
	tb_memory_clk_gen mem_clk_gen( .reset(clk_gen_reset), 
		.mem_clk(tb_mem_clk) );
	
	
	//alu_test_bench alu_tb( .tb_clk(tb_clk), .reset(alu_tb_reset) );
	//instr_group_decoder_test_bench instr_grp_dec_tb( .tb_clk(tb_clk), 
	//	.reset(instr_grp_dec_tb_reset) );
	//instr_decoder_test_bench instr_dec_tb( .tb_clk(tb_clk),
	//	.reset(instr_dec_tb_reset) );
	
	
	
	wire [`cpu_data_inout_16_msb_pos:0] tb_mem_read_data_out;
	
	wire [`cpu_data_inout_16_msb_pos:0] test_cpu_data_inout_direct;
	bit [`cpu_addr_msb_pos:0] test_cpu_data_inout_addr;
	bit test_cpu_data_acc_sz, test_cpu_data_inout_we;
	logic [`cpu_data_inout_16_msb_pos:0] test_cpu_data_out;
	
	spcpu test_cpu( .clk(tb_half_clk), .reset(test_cpu_reset),
		.data_inout(test_cpu_data_inout_direct),
		.data_inout_addr(test_cpu_data_inout_addr),
		.data_acc_sz(test_cpu_data_acc_sz),
		.data_inout_we(test_cpu_data_inout_we) );
	
	//tb_memory test_mem( .clk(tb_mem_clk), .reset(test_mem_reset),
	//	.the_inputs(mem_inputs), .read_data_out(tb_mem_read_data_out) );
	tb_memory test_mem( .clk(tb_mem_clk), .reset(test_mem_reset),
		.addr_in(test_cpu_data_inout_addr),
		.write_data_in(test_cpu_data_out),
		.data_acc_sz(test_cpu_data_acc_sz),
		.write_data_we(test_cpu_data_inout_we), 
		.read_data_out(tb_mem_read_data_out) );
	
	
	
	
	
	//assign test_cpu_data_inout_direct = (!test_cpu_data_inout_we) 
	//	? test_cpu_data_in : `cpu_data_inout_16_width'hz;
	assign test_cpu_data_inout_direct = (!test_cpu_data_inout_we) 
		? tb_mem_read_data_out : `cpu_data_inout_16_width'hz;
	//assign test_cpu_data_inout_direct = (!test_cpu_data_inout_we) 
	//	? temp_read_data_out : `cpu_data_inout_16_width'hz;
	
	assign test_cpu_data_out = (test_cpu_data_inout_we)
		? test_cpu_data_inout_direct : `cpu_data_inout_16_width'hz;
	
	
	
	initial
	begin
		clk_gen_reset = 1'b1;
		test_cpu_reset = 1'b0;
		//$display(test_cpu_reset);
		
		#4
		test_cpu_reset = 1'b1;
		//$display(test_cpu_reset);
		
		//{ mem_inputs.write_addr_in, mem_inputs.write_data_in,
		//	mem_inputs.write_data_acc_sz, mem_inputs.write_data_we } = 0;
		
		#4
		test_cpu_reset = 1'b0;
		
	end
	
	
endmodule



`define make_reg_pair( index_hi ) `make_pair( cpu_regs, index_hi )

// Make reg pair with pair index
`define make_reg_pair_w_pi( pair_index ) \
	`make_reg_pair( `make_reg_ind_from_pi(pair_index) )

`define get_cpu_rp_pc `make_reg_pair_w_pi(pkg_cpu::cpu_rp_pc_pind)
`define get_cpu_rp_lr `make_reg_pair_w_pi(pkg_cpu::cpu_rp_lr_pind)



`define instr_16_num_bytes 2
`define instr_32_num_bytes 4

// The next value of the PC after a non-PC-changing 16-bit instruction, or
// the next value of data_inout_addr after loading the high 16 bits of a
// 32-bit instruction
`define get_pc_after_reg_instr_16 ( `get_cpu_rp_pc + `instr_16_num_bytes )

// The next value of the PC after a non-PC-changing 32-bit instruction
`define get_pc_after_reg_instr_32 ( `get_cpu_rp_pc + `instr_32_num_bytes )


`define wire_rhs_pc_indices_contain_reg_index( reg_index ) \
	( ( reg_index == pkg_cpu::cpu_rp_pc_hi_rind ) \
	|| ( reg_index == pkg_cpu::cpu_rp_pc_lo_rind ) )
`define wire_rhs_rp_index_is_pc_index( rp_index ) \
	( rp_index == pkg_cpu::cpu_rp_pc_pind )


// The CPU itself
module spcpu
	
	import pkg_cpu::*;
	import pkg_pflags::*;
	import pkg_instr_dec::*;
	import pkg_alu::*;
	
	( input bit clk, input bit reset,
	
	// Data being read in or written out
	inout [`cpu_data_inout_16_msb_pos:0] data_inout,
	
	// The address being loaded from or written to
	output bit [`cpu_addr_msb_pos:0] data_inout_addr,
	
	// Size (8-bit or 16-bit) of data being read/written
	output bit data_acc_sz,
	
	// Write enable, which when low specifies that the CPU wants to read,
	// and when high specifies that the CPU wants to write,
	output bit data_inout_we );
	
	
	
	
	
	
	
	// CPU state stuff
	// For some reason, vvp does weird things when I make cpu_regs part of
	// the misc_cpu_vars struct, so just get rid of that struct for now.
	bit [`cpu_reg_msb_pos:0] cpu_regs[0:`cpu_reg_arr_msb_pos];
	
	bit [ `cpu_reg_width + `cpu_reg_msb_pos : 0 ] prev_pc;
	wire [`cpu_reg_msb_pos:0] prev_r14, prev_r15;
	assign { prev_r14, prev_r15 } = prev_pc;
	
	
	// The entirety of a 16-bit insturction, or the high 16 bits of a
	// 32-bit instruction
	bit [`instr_main_msb_pos:0] instr_in_hi,
	
	// The low 16 bits of a 32-bit instruction
		instr_in_lo;
	
	// The current CPU state
	bit [`cpu_state_msb_pos:0] curr_state;
	
	
	// If the pc was POSSIBLY changed by an instruction, which is used to
	// determine whether or not to change the pc automatically.
	//bit [4:0] temp_ipc_pc_vec;
	bit instr_possibly_changes_pc;
	
	// These are used for communication with the outside world
	wire [`cpu_data_inout_16_msb_pos:0] temp_data_in;
	bit [`cpu_data_inout_16_msb_pos:0] temp_data_out;
	
	
	
	
	`include "src/extra_instr_dec_vars.svinc"
	
	// ALU inputs and outputs
	alu_oper the_alu_op;
	bit [`alu_inout_msb_pos:0] alu_a_in_hi, alu_a_in_lo, alu_b_in,
		alu_out_hi, alu_out_lo;
	bit [`proc_flags_msb_pos:0] alu_proc_flags_in, alu_proc_flags_out;
	
	
	// The CPU flags that the ALU becomes made aware of 
	bit [`proc_flags_msb_pos:0] true_proc_flags;
	bit alu_was_used, alu_dest_reg_was_modded, alu_dest_rpair_was_modded;
	//wire alu_modded_proc_flags;
	
	bit [`cpu_reg_index_ie_msb_pos:0] alu_dest_reg_index;
	bit [`cpu_rp_index_ie_msb_pos:0] alu_dest_rpair_index;
	
	wire init_instr_is_32_bit, final_instr_is_32_bit;
	
	//assign alu_modded_proc_flags = ( true_proc_flags 
	//	!= alu_proc_flags_out );
	
	
	
	// Instruction decoding struct and enum instances
	
	// The instr_group that is the output of the instr_group_decoder module
	// called instr_grp_dec
	instr_group init_instr_grp;
	
	// The instr_group instance that is used after loading the first 16
	// bits of an instruction
	instr_group final_instr_grp;
	
	ig1_dec_outputs ig1d_outputs;
	ig2_dec_outputs ig2d_outputs;
	ig3_dec_outputs ig3d_outputs;
	ig4_dec_outputs ig4d_outputs;
	ig5_dec_outputs ig5d_outputs;
	
	
	
	// Module instances
	instr_group_decoder instr_grp_dec( .instr_hi(temp_data_in),
		.group_out(init_instr_grp) );
	
	instr_grp_1_decoder instr_grp_1_dec( .instr_hi(temp_data_in),
		.ig1d_outputs(ig1d_outputs) );
	instr_grp_2_decoder instr_grp_2_dec( .instr_hi(temp_data_in),
		.ig2d_outputs(ig2d_outputs) );
	instr_grp_3_decoder instr_grp_3_dec( .instr_hi(temp_data_in),
		.ig3d_outputs(ig3d_outputs) );
	instr_grp_4_decoder instr_grp_4_dec( .instr_hi(temp_data_in),
		.ig4d_outputs(ig4d_outputs) );
	instr_grp_5_decoder instr_grp_5_dec( .instr_hi(temp_data_in),
		.ig5d_outputs(ig5d_outputs) );
	
	alu the_alu( .oper(the_alu_op), .a_in_hi(alu_a_in_hi),
		.a_in_lo(alu_a_in_lo), .b_in(alu_b_in), 
		.proc_flags_in(alu_proc_flags_in), .out_hi(alu_out_hi),
		.out_lo(alu_out_lo), .proc_flags_out(alu_proc_flags_out) );
	
	
	// Outside world access assign statements
	assign data_inout = (data_inout_we) ? temp_data_out
		: `cpu_data_inout_16_width'hz;
	assign temp_data_in = (!data_inout_we) ? data_inout
		: `cpu_data_inout_16_width'hz;
	
	
	//assign instr_possibly_changes_pc = ( temp_ipc_pc_vec > 0 );
	assign { init_instr_is_32_bit, final_instr_is_32_bit }
		= { pkg_instr_dec::get_instr_is_32_bit(init_instr_grp),
		pkg_instr_dec::get_instr_is_32_bit(final_instr_grp) };
	
	
	`include "src/extra_wire_assignments.svinc"
	
	
	
	// Tasks
	`include "src/debug_tasks.svinc"
	
	`include "src/state_changing_tasks.svinc"
	
	`include "src/update_instr_possibly_changes_pc_tasks.svinc"
	
	`include "src/extra_instr_dec_tasks_funcs.svinc"
	
	`include "src/debug_disassembly_tasks.svinc"
	
	`include "src/instr_exec_tasks.svinc"
	
	`include "src/alu_control_tasks.svinc"
	
	
	//bit [1:0] ready;
	//initial ready = 0;
	
	bit ready;
	initial ready = 0;
	
	always @ ( posedge clk )
	begin
	
	if (reset)
	begin
		//{ data_inout_addr, data_inout_we } <= 0;
		data_inout_addr <= 0;
		data_inout_we <= 0;
		
		data_acc_sz <= pkg_cpu::cpu_data_acc_sz_16;
		
		
		// Clear every CPU register
		{ cpu_regs[0], cpu_regs[1], cpu_regs[2], cpu_regs[3], 
			cpu_regs[4], cpu_regs[5], cpu_regs[6], cpu_regs[7],
			cpu_regs[8], cpu_regs[9], cpu_regs[10], cpu_regs[11],
			cpu_regs[12], cpu_regs[13], cpu_regs[14], cpu_regs[15] } <= 0;
		
		//curr_state <= pkg_cpu::cpu_st_begin_0;
		curr_state <= 0;
		ready <= 1;
		prep_load_16_no_addr();
		
	end
	
	end
	
	
	
	always @ ( posedge clk )
	begin
		//if ( `get_cpu_rp_pc >= 20 * 2 )
		//if ( ( `get_cpu_rp_pc >= ( 16'h10 * 2 ) )
		////if ( ( `get_cpu_rp_pc >= ( 30 * 2 ) )
		//	&& ( `get_cpu_rp_pc <= ( 200 * 2 ) ) )
		if ( `get_cpu_rp_pc >= ( 16'h8010 ) )
		begin
			$display("\ndone");
			$finish;
		end
	end
	
	
	always @ ( posedge clk )
	begin
	
	if (ready)
	begin
		if ( curr_state == pkg_cpu::cpu_st_begin_0 )
		begin
			curr_state <= curr_state + 1;
			prep_load_16_no_addr();
			//set_pc_and_dio_addr(0);
		end
		
		
		//else if ( curr_state == pkg_cpu::cpu_st_load_instr_hi )
		//begin
		//	//$display( "%h", temp_data_in );
		//	$display( "%h %h", temp_data_in, `get_cpu_rp_pc );
		//	set_pc_and_dio_addr(`get_cpu_rp_pc + 2);
		//	//$finish;
		//end
		
		else if ( curr_state == pkg_cpu::cpu_st_load_instr_hi )
		begin
			debug_disp_regs_and_proc_flags();
			$display();
			
			
			// Back up temp_data_in, init_instr_grp, and pc
			instr_in_hi <= temp_data_in;
			final_instr_grp <= init_instr_grp;
			prev_pc <= `get_cpu_rp_pc;
			
			
			// Back up the decoded instruction contents to be used on
			// cycles after the current one.
			back_up_ig1_instr_contents();
			back_up_ig2_instr_contents();
			back_up_ig3_instr_contents();
			back_up_ig4_instr_contents();
			back_up_ig5_instr_contents();
			
			update_extra_ig1_pc_stuff();
			update_extra_ig2_pc_stuff();
			update_extra_ig3_pc_stuff();
			//update_extra_ig4_pc_stuff();
			update_extra_ig5_pc_stuff();
			
			
			//$display( "%h %h %h", init_instr_grp, final_instr_grp, 
			//	`get_cpu_rp_pc );
			
			//curr_state <= pkg_cpu::cpu_st_start_exec_instr;
			
			
			//if ( init_instr_grp != pkg_instr_dec::instr_grp_5 )
			if (!init_instr_is_32_bit)
			begin
				curr_state <= pkg_cpu::cpu_st_start_exec_instr;
				
				prep_alu_if_needed_init();
				
			end
			
			// Handle 32-bit instructions
			else if ( init_instr_grp == pkg_instr_dec::instr_grp_5 )
			begin
				//curr_state <= pkg_cpu::cpu_st_load_instr_lo;
				
				//advance_dio_addr_for_instr_lo();
				//prep_load_16_no_addr();
				prep_load_instr_lo_reg();
			end
			
			//else if ( init_instr_grp == pkg_instr_dec::instr_grp_... )
			//begin
			//	
			//end
			
			
			else // if ( init_instr_grp 
				// == pkg_instr_dec::instr_grp_unknown )
			begin
				$display("Unknown instruction encoding");
				
				//curr_state <= pkg_cpu::cpu_st_load_instr_hi;
			end
			
		end
		
		else if ( curr_state == pkg_cpu::cpu_st_load_instr_lo )
		begin
			curr_state <= pkg_cpu::cpu_st_start_exec_instr;
			instr_in_lo <= temp_data_in;
			prep_alu_if_needed_final();
		end
		
		
		// Instruction execution states
		else if ( curr_state == pkg_cpu::cpu_st_start_exec_instr )
		begin
			start_exec_instr();
		end
		
		else if ( curr_state == pkg_cpu::cpu_st_finish_exec_instr )
		begin
			finish_exec_instr();
		end
		
		else // if ( curr_state 
			// == pkg_cpu::cpu_st_update_pc_after_instr_possibly_changed )
		begin
			$display("Check whether the pc was actually changed");
			
			//$display( "%h %h", prev_pc, `get_cpu_rp_pc );
			
			prep_load_instr_hi_reg_generic();
			
			// Check if the pc was ACTUALLY changed
			if ( prev_pc == `get_cpu_rp_pc )
			begin
				$display("The pc was not actually changed");
				
				
				//// Do a regular update of the PC and data_inout_addr (don't
				//// let the CPU get stuck executing an instruction
				//// infinitely!)
				//if (!final_instr_is_32_bit)
				//begin
				//	prep_load_instr_hi_reg_after_16();
				//end
				//
				//else // if (final_instr_is_32_bit)
				//begin
				//	prep_load_instr_hi_reg_after_32();
				//end
			end
			
			else
			begin
				$display("The pc WAS changed");
			end
			
			//curr_state <= pkg_cpu::cpu_st_load_instr_hi;
			
		end
		
	end
	
	end
	
	
	
	// Combinational logic for updating instr_possibly_changes_pc
	always @ (*)
	//always @ ( posedge clk )
	begin
		if ( curr_state == pkg_cpu::cpu_st_start_exec_instr )
		begin
			instr_possibly_changes_pc = 0;
			
			if ( final_instr_grp == pkg_instr_dec::instr_grp_1 )
			begin
				update_ipc_pc_for_grp_1_instr();
			end
			
			else if ( final_instr_grp == pkg_instr_dec::instr_grp_2 )
			begin
				update_ipc_pc_for_grp_2_instr();
			end
			
			else if ( final_instr_grp == pkg_instr_dec::instr_grp_3 )
			begin
				update_ipc_pc_for_grp_3_instr();
			end
			
			else if ( final_instr_grp == pkg_instr_dec::instr_grp_4 )
			begin
				update_ipc_pc_for_grp_4_instr();
			end
			
			else if ( final_instr_grp == pkg_instr_dec::instr_grp_5 )
			begin
				update_ipc_pc_for_grp_5_instr();
			end
		end
	end
	
	
	
endmodule


