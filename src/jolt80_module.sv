// This file is part of Jolt80 CPU.
// 
// Copyright 2016 by Andrew Clark (FL4SHK).
// 
// Jolt80 CPU is free software: you can redistribute it and/or
// modify it under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
// 
// Jolt80 CPU is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
// 
// You should have received a copy of the GNU General Public License along
// with Jolt80 CPU.  If not, see <http://www.gnu.org/licenses/>.


`include "src/alu_defines.svinc"

`include "src/instr_decoder_defines.svinc"
//`include "src/cpu_extras_defines.svinc"




`define make_reg_pair( index_hi ) `make_pair( cpu_regs, index_hi )

// Make reg pair with pair index
`define make_reg_pair_w_pi( pair_index ) \
	`make_reg_pair( `make_reg_ind_from_pi(pair_index) )

`define get_cpu_rp_pc `make_reg_pair_w_pi(pkg_cpu::cpu_rp_pc_pind)
`define get_cpu_rp_lr `make_reg_pair_w_pi(pkg_cpu::cpu_rp_lr_pind)



`define instr_16_num_bytes 2
`define instr_32_num_bytes 4

//// The next value of the PC after a non-PC-changing 16-bit instruction, or
//// the next value of data_inout_addr after loading the high 16 bits of a
// 32-bit instruction
//`define get_pc_after_reg_instr_16 ( `get_cpu_rp_pc + `instr_16_num_bytes )
//`define get_pc_after_reg_instr ( `get_cpu_rp_pc + `instr_16_num_bytes )

//// The next value of the PC after a non-PC-changing 32-bit instruction
//`define get_pc_after_reg_instr_32 ( `get_cpu_rp_pc + `instr_32_num_bytes )


`define wire_rhs_pc_indices_contain_reg_index( reg_index ) \
	( ( reg_index == pkg_cpu::cpu_rp_pc_hi_rind ) \
	|| ( reg_index == pkg_cpu::cpu_rp_pc_lo_rind ) )
`define wire_rhs_rp_index_is_pc_index( rp_index ) \
	( rp_index == pkg_cpu::cpu_rp_pc_pind )


`define get_alu_out_8 ( alu_out_lo )
`define get_alu_out_16 ( { alu_out_hi, alu_out_lo } )

// The CPU itself
module jolt80
	
	( input bit clk, reset, data_ready, interrupt,
	
	// Data being read in or written out
	//inout [`cpu_data_inout_16_msb_pos:0] data_inout,
	
	input bit [`cpu_data_inout_16_msb_pos:0] temp_data_in,
	output bit [`cpu_data_inout_16_msb_pos:0] temp_data_out,
	
	
	// The address being loaded from or written to
	output bit [`cpu_addr_msb_pos:0] data_inout_addr,
	
	// Size (8-bit or 16-bit) of data being read/written
	output bit data_acc_sz,
	
	// Write enable, which when low specifies that the CPU wants to read,
	// and when high specifies that the CPU wants to write,
	output bit data_inout_we,
	
	// Request Read or Write
	output bit req_rdwr,
	
	output wire [`cpu_reg_msb_pos:0] debug_vec );
	
	import pkg_cpu::*;
	import pkg_pflags::*;
	import pkg_instr_dec::*;
	import pkg_alu::*;
	
	
	
	
	
	
	
	// CPU state stuff
	// For some reason, vvp does weird things when I make cpu_regs part of
	// the misc_cpu_vars struct, so just get rid of that struct for now.
	
	// 16 programmer-visible CPU regs and 2 registers ONLY for internal use
	// (mainly for internal ALU usage)
	bit [`cpu_reg_msb_pos:0] cpu_regs[0:`cpu_reg_arr_msb_pos];
	
	// Interrupt return address (can be accessed by some instructions)
	bit [`cpu_addr_msb_pos:0] int_ret_addr;
	
	// Whether interrupts are enabled or not
	bit ints_enabled;
	
	
	//bit [`cpu_reg_msb_pos:0] temp_pc[0:1];
	//bit did_prep_ldst_instr;
	//bit [`cpu_addr_msb_pos:0] temp_store_addr;
	
	
	
	//bit [ `cpu_reg_width + `cpu_reg_msb_pos : 0 ] prev_pc;
	bit [`cpu_imm_value_16_msb_pos:0] prev_pc, second_prev_pc,
		third_prev_pc;
	//wire [`cpu_reg_msb_pos:0] prev_r14, prev_r15;
	//assign { prev_r14, prev_r15 } = prev_pc;
	
	
	// The entirety of a 16-bit insturction, or the high 16 bits of a
	// 32-bit instruction
	bit [`instr_main_msb_pos:0] instr_in_hi,
	
	// The low 16 bits of a 32-bit instruction
		instr_in_lo;
	
	// The current CPU state
	bit [`cpu_state_msb_pos:0] curr_state;
	
	
	
	//// These are used for communication with the outside world
	//wire [`cpu_data_inout_16_msb_pos:0] temp_data_in;
	//bit [`cpu_data_inout_16_msb_pos:0] temp_data_out;
	
	
	
	assign debug_vec = cpu_regs[0];
	//assign debug_vec = cpu_regs[1];
	//assign debug_reg_0 = 3;
	
	//assign debug_vec = true_proc_flags;
	//assign debug_vec = cpu_regs[15];
	
	
	
	`include "src/extra_instr_dec_vars.svinc"
	`include "src/alu_vars.svinc"
	wire final_branch_was_taken;
	
	
	
	
	// Instruction decoding struct and enum instances
	
	// The instr_group that is the output of the instr_group_decoder module
	// called instr_grp_dec
	instr_group init_instr_grp;
	
	// The instr_group instance that is used after loading the first 16
	// bits of an instruction
	instr_group final_instr_grp;
	
	
	
	
	// Module instances
	instr_group_decoder instr_grp_dec( .instr_hi(temp_data_in),
		.group_out(init_instr_grp) );
	
	instr_grp_1_decoder instr_grp_1_dec( .instr_hi(temp_data_in),
		.opcode(ig1_opcode), .ra_index(ig1_ra_index),
		.imm_value_8(ig1_imm_value_8),
		.ra_index_is_for_pair(ig1_ra_index_is_for_pair) );
	instr_grp_2_decoder instr_grp_2_dec( .instr_hi(temp_data_in),
		.opcode(ig2_opcode), 
		.ra_index(ig2_ra_index),
		.rb_index(ig2_rb_index),
		.ra_index_is_for_pair(ig2_ra_index_is_for_pair),
		.rb_index_is_for_pair(ig2_rb_index_is_for_pair) );
	instr_grp_3_decoder instr_grp_3_dec( .instr_hi(temp_data_in),
		.opcode(ig3_opcode), 
		.ra_index(ig3_ra_index),
		.rbp_index(ig3_rbp_index), 
		.rcp_index(ig3_rcp_index) );
	instr_grp_4_decoder instr_grp_4_dec( .instr_hi(temp_data_in),
		.opcode(ig4_opcode), 
		.imm_value_8(ig4_imm_value_8) );
	instr_grp_5_decoder instr_grp_5_dec( .instr_hi(temp_data_in),
		.opcode(ig5_opcode), 
		.ra_index(ig5_ra_index),
		.rbp_index(ig5_rbp_index),
		.ra_index_is_for_pair(ig5_ra_index_is_for_pair) );
	
	
	//// This is used for adjusting the program counter
	//pc_incrementer the_pc_incrementer( .pc_in(`get_cpu_rp_pc),
	//	.offset_in(the_pc_inc_offset_in), .pc_out(the_pc_inc_pc_out) );
	
	
	// These are used for adjusting the program counter
	pc_incrementer the_pc_incrementer( .pc_in(the_pc_inc_pc_in),
		.offset_in(the_pc_inc_offset_in), .pc_out(the_pc_inc_pc_out) );
	
	sign_extend_adder branch_pc_adjuster
		( .a_in_hi(pc_adjuster_a_in_hi), .a_in_lo(pc_adjuster_a_in_lo), 
		.b_in_hi(pc_adjuster_b_in_hi), .b_in_lo(pc_adjuster_b_in_lo),
		.out_hi(pc_adjuster_out_hi), .out_lo(pc_adjuster_out_lo), 
		.proc_flags_out(pc_adjuster_proc_flags_out) );
	//adder_subtractor branch_pc_adjuster( .oper(pc_adjuster_op),
	//	.a_in_hi(pc_adjuster_a_in_hi), .a_in_lo(pc_adjuster_a_in_lo), 
	//	.b_in_hi(pc_adjuster_b_in_hi), .b_in_lo(pc_adjuster_b_in_lo),
	//	.proc_flags_in(dummy_pc_adjuster_proc_flags_in),
	//	.out_hi(pc_adjuster_out_hi), .out_lo(pc_adjuster_out_lo), 
	//	.proc_flags_out(pc_adjuster_proc_flags_out) );
	
	alu the_alu( .oper(the_alu_op), 
		.a_in_hi(alu_a_in_hi), .a_in_lo(alu_a_in_lo), 
		.b_in_hi(alu_b_in_hi), .b_in_lo(alu_b_in_lo),
		.proc_flags_in(alu_proc_flags_in), 
		.out_hi(alu_out_hi), .out_lo(alu_out_lo), 
		.proc_flags_out(alu_proc_flags_out) );
	
	
	//// Outside world access assign statements
	//assign data_inout = (data_inout_we) ? temp_data_out
	//	: `cpu_data_inout_16_width'hz;
	//assign temp_data_in = (!data_inout_we) ? data_inout
	//	: `cpu_data_inout_16_width'hz;
	
	
	
	
	
	
	`include "src/extra_wire_assignments.svinc"
	
	
	
	
	// Tasks
	`include "src/state_changing_tasks.svinc"
	
	`include "src/instr_g1_tasks.svinc"
	`include "src/instr_g2_tasks.svinc"
	`include "src/instr_g3_tasks.svinc"
	`include "src/instr_g4_tasks.svinc"
	`include "src/instr_g5_tasks.svinc"
	
	// 1, 2, 3, 4, 5
	`include "src/debug_tasks.svinc"
	
	// 1, 2, 3, 4, 5
	`include "src/alu_control_tasks.svinc"
	
	// 1, 2, 3, 4, 5
	`include "src/instr_exec_tasks.svinc"
	
	
	
	
	
	// This is used to determine when to stop simulation
	logic [5:0] data_in_is_0_counter;
	
	logic [3:0] wait_counter;
	initial wait_counter = 0;
	
	//always @ ( posedge clk )
	////always
	//begin
	//	#1
	//	$display( "curr_state:  %h", curr_state );
	//	
	//end
	
	
	
	// End CPU simulation if there are a bunch of 0000's in a row (this
	// applies to the included testbench, but not the rest of the CPU)
	always @ ( posedge clk )
	begin
		wait_counter <= wait_counter + 1;
		//$display( "wait_counter:  %d", wait_counter );
		
		//if (!do_stall)
		if (data_ready)
		begin
		
		if ( curr_state == pkg_cpu::cpu_st_load_instr_hi )
		begin
			if ( temp_data_in == 0 )
			begin
				data_in_is_0_counter <= data_in_is_0_counter + 1;
			end
			
			else
			begin
				data_in_is_0_counter <= 0;
			end
			
			//if ( `get_cpu_rp_pc >= 16'h0004 
			//	&& `get_cpu_rp_pc < 16'h7ff0 )
			//begin
			//	$display("\ndone");
			//	$finish;
			//end
			//else 
			if ( data_in_is_0_counter >= 4 )
			begin
				$display("\ndone");
				$finish;
			end
		end
		
		end
	end
	
	
	always @ ( posedge clk )
	//always_ff @ ( posedge clk )
	begin
	
	
	if (reset)
	begin
		//{ data_inout_addr, data_inout_we } <= 0;
		data_inout_addr <= 0;
		data_inout_we <= 0;
		
		data_acc_sz <= pkg_cpu::cpu_data_acc_sz_16;
		
		
		//// Clear every CPU register
		//{ cpu_regs[0], cpu_regs[1], cpu_regs[2], cpu_regs[3], 
		//	cpu_regs[4], cpu_regs[5], cpu_regs[6], cpu_regs[7],
		//	cpu_regs[8], cpu_regs[9], cpu_regs[10], cpu_regs[11],
		//	cpu_regs[12], cpu_regs[13], cpu_regs[14], cpu_regs[15] } <= 0;
		
		// Clear every non-PC CPU register
		{ cpu_regs[0], cpu_regs[1], cpu_regs[2], cpu_regs[3], 
			cpu_regs[4], cpu_regs[5], cpu_regs[6], cpu_regs[7],
			cpu_regs[8], cpu_regs[9], cpu_regs[10], cpu_regs[11],
			cpu_regs[12], cpu_regs[13] } <= 0;
		
		//did_prep_ldst_instr <= 0;
		
		
		//curr_state <= pkg_cpu::cpu_st_begin_0;
		//curr_state <= 0;
		
		//curr_state <= 0;
		set_curr_state(0);
		
		// Disable interrupts to start with (require the program to enable
		// interrupts)
		int_ret_addr <= 0;
		ints_enabled <= 0;
		
		
		//data_in_is_0_counter <= 0;
		
		prep_load_16_no_addr();
	end
	
	else //if (!reset)
	begin
		if ( curr_state == pkg_cpu::cpu_st_after_reset )
		begin
			if (data_ready)
			begin
				//curr_state <= pkg_cpu::cpu_st_begin_0;
				set_curr_state(pkg_cpu::cpu_st_begin_0);
				
				// Hardcoded address
				prep_load_16_with_addr(`cpu_reset_start_addr_storage_addr);
			end
			
			else // if (!data_ready)
			begin
				$display("cpu_st_after_reset:  Data NOT ready");
			end
		end
		
		else if ( curr_state == pkg_cpu::cpu_st_after_interrupt )
		begin
			if (data_ready)
			begin
				//curr_state <= pkg_cpu::cpu_st_load_instr_hi;
				set_curr_state(pkg_cpu::cpu_st_load_instr_hi);
				
				prep_load_16_no_addr();
				set_pc_and_dio_addr(temp_data_in);
				
				ints_enabled <= 0;
			end
			
			else // if (!data_ready)
			begin
				$display("cpu_st_after_interrupt:  Data NOT ready");
			end
		end
		
		else if ( curr_state == pkg_cpu::cpu_st_begin_0 )
		begin
			if (data_ready)
			begin
				//curr_state <= pkg_cpu::cpu_st_load_instr_hi;
				set_curr_state(pkg_cpu::cpu_st_load_instr_hi);
				
				set_pc_and_dio_addr(temp_data_in);
				prep_load_16_no_addr();
			end
			
			else // if (!data_ready)
			begin
				$display("cpu_st_begin_0:  Data NOT ready");
			end
		end
		
		else if ( curr_state == pkg_cpu::cpu_st_load_instr_hi )
		begin
			if (data_ready)
			begin
				//if ( interrupt && ints_enabled )
				if ( !( interrupt && ints_enabled ) )
				begin
					debug_disp_regs_and_proc_flags();
					$display();
					$display();
					
					
					// Back up temp_data_in, init_instr_grp, and pc
					instr_in_hi <= temp_data_in;
					final_instr_grp <= init_instr_grp;
					prev_pc <= `get_cpu_rp_pc;
					second_prev_pc <= the_pc_inc_pc_out;
					
					
					// Back up the decoded instruction contents to be used
					// on cycles after the current one.
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
					
					
					
					if (!init_instr_is_32_bit)
					begin
						//curr_state <= pkg_cpu::cpu_st_start_exec_instr;
						set_curr_state(pkg_cpu::cpu_st_start_exec_instr);
						req_rdwr <= 0;
						
						
						prep_alu_if_needed_init();
						seq_logic_grab_pc_inc_outputs();
					end
					
					// Handle 32-bit instructions
					else if ( init_instr_grp 
						== pkg_instr_dec::instr_grp_5 )
					begin
						//$display("Instruction is 32-bit");
						//req_rdwr <= 1;
						seq_logic_grab_pc_inc_outputs();
						prep_load_instr_lo_reg();
					end
					
					//else if ( init_instr_grp 
					//	== pkg_instr_dec::instr_grp_... )
					//begin
					//	
					//end
					
					
					else // if ( init_instr_grp 
						// == pkg_instr_dec::instr_grp_unknown )
					begin
						$display("Unknown instruction encoding");
						
					end
					
				end
				
				
				else // if ( interrupt && ints_enabled )
				begin
					$display("Starting interrupt");
					int_ret_addr <= `get_cpu_rp_pc;
					//curr_state <= pkg_cpu::cpu_st_after_interrupt;
					set_curr_state(pkg_cpu::cpu_st_after_interrupt);
					
					// Hardcoded address
					prep_load_16_with_addr
						(`cpu_int_start_addr_storage_addr);
				end
			end
			
			else // if (!data_ready)
			begin
				$display( "Load Instruction High:  Data NOT ready" );
				$display();
			end
		end
		
		
		else if ( curr_state == pkg_cpu::cpu_st_load_instr_lo )
		begin
			if (data_ready)
			begin
				req_rdwr <= 0;
				//curr_state <= pkg_cpu::cpu_st_start_exec_instr;
				set_curr_state(pkg_cpu::cpu_st_start_exec_instr);
				instr_in_lo <= temp_data_in;
				third_prev_pc <= the_pc_inc_pc_out;
				
				seq_logic_grab_pc_inc_outputs();
				
				prep_alu_if_needed_final();
			end
			
			else // if (!data_ready)
			begin
				$display("Load Instruction Low:  Data NOT ready");
				$display();
			end
		end
		
		
		// Instruction execution states
		else if ( curr_state == pkg_cpu::cpu_st_start_exec_instr )
		begin
			start_exec_instr();
		end
		
		else if ( curr_state == pkg_cpu::cpu_st_finish_exec_ldst_instr )
		begin
			finish_exec_ldst_instr();
		end
		
		
		
		
	end
	
	end
	
	
	
	// Latch logic for various PC-changing stuffs
	always @ (*)
	//always @ ( curr_state )
	//always_latch
	begin
		if ( curr_state == pkg_cpu::cpu_st_load_instr_hi )
		begin
			latch_logic_prep_pc_inc_during_load_instr_portion();
		end
		else if ( curr_state == pkg_cpu::cpu_st_load_instr_lo )
		begin
			latch_logic_prep_pc_inc_during_load_instr_portion();
		end
		
		else if ( curr_state == pkg_cpu::cpu_st_start_exec_instr )
		begin
			// Just do this every time
			latch_logic_prep_pc_adjuster_for_branch(final_ig4_imm_value_8);
			
			{ instr_is_branch_or_call, non_bc_instr_possibly_changes_pc }
				= 0;
			
			if ( final_instr_grp == pkg_instr_dec::instr_grp_1 )
			begin
				update_instr_is_bc_for_grp_1_instr();
			end
			
			else if ( final_instr_grp == pkg_instr_dec::instr_grp_2 )
			begin
				update_instr_is_bc_for_grp_2_instr();
			end
			
			else if ( final_instr_grp == pkg_instr_dec::instr_grp_3 )
			begin
				update_instr_is_bc_for_grp_3_instr();
			end
			
			else if ( final_instr_grp == pkg_instr_dec::instr_grp_4 )
			begin
				update_instr_is_bc_for_grp_4_instr();
			end
			
			else if ( final_instr_grp == pkg_instr_dec::instr_grp_5 )
			begin
				update_instr_is_bc_for_grp_5_instr();
			end
		end
	end
	
	
	
endmodule


