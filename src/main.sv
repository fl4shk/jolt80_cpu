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
	
	//bit clk_gen_reset, tb_half_clk, tb_mem_clk;
	bit clk_gen_reset, tb_clk;
	
	bit test_mem_reset;
	
	
	// reset signal for test_cpu
	bit test_cpu_reset;
	
	
	//tb_half_clk_gen half_clk_gen( .reset(clk_gen_reset), 
	//	.half_clk(tb_half_clk) );
	//tb_memory_clk_gen mem_clk_gen( .reset(clk_gen_reset), 
	//	.mem_clk(tb_mem_clk) );
	
	tb_clk_gen clk_gen( .reset(clk_gen_reset), .clk(tb_clk) );
	
	
	
	
	wire test_cpu_data_ready;
	//bit test_cpu_reset;
	//wire [`cpu_data_inout_16_msb_pos:0] test_cpu_data_inout_direct;
	wire [`cpu_addr_msb_pos:0] test_cpu_data_inout_addr;
	wire test_cpu_data_acc_sz, test_cpu_data_inout_we;
	//logic [`cpu_data_inout_16_msb_pos:0] test_cpu_data_out;
	bit [`cpu_data_inout_16_msb_pos:0] test_cpu_temp_data_in;
	wire [`cpu_data_inout_16_msb_pos:0] test_cpu_temp_data_out;
	wire test_cpu_req_rdwr;
	
	wire [`cpu_reg_msb_pos:0] test_cpu_debug_reg_0;
	
	
	
	wire test_mem_data_ready;
	wire [ `cpu_addr_msb_pos - 1 : 0 ] test_mem_addr_2;
	wire [`cpu_data_inout_8_msb_pos:0] test_mem_read_data_out_8;
	wire [`cpu_data_inout_16_msb_pos:0] test_mem_read_data_out_16;
	
	wire [`cpu_data_inout_8_msb_pos:0] test_mem_write_data_in_8;
	wire [`cpu_data_inout_16_msb_pos:0] test_mem_write_data_in_16;
	wire test_mem_write_data_we_8, test_mem_write_data_we_16;
	
	
	
	//initial test_cpu_reset = 1;
	
	//assign test_cpu_data_ready = 1;
	assign test_cpu_data_ready = test_mem_data_ready;
	assign test_mem_addr_2 = ( test_cpu_data_inout_addr >> 1 );
	
	assign test_mem_write_data_we_8
		= ( ( test_cpu_data_acc_sz == pkg_cpu::cpu_data_acc_sz_8 )
		? test_cpu_data_inout_we : 0 );
	assign test_mem_write_data_we_16
		= ( ( test_cpu_data_acc_sz == pkg_cpu::cpu_data_acc_sz_16 )
		? test_cpu_data_inout_we : 0 );
	
	//assign test_cpu_data_inout_direct = ( (!test_cpu_data_inout_we) 
	//	? ( ( test_cpu_data_acc_sz == pkg_cpu::cpu_data_acc_sz_8 )
	//	? test_mem_read_data_out_8 : test_mem_read_data_out_16 )
	//	: `cpu_data_inout_16_width'hz );
	
	assign test_cpu_temp_data_in
		= ( ( test_cpu_data_acc_sz == pkg_cpu::cpu_data_acc_sz_8 )
		? test_mem_read_data_out_8 : test_mem_read_data_out_16 );
	
	//assign test_cpu_data_out = (test_cpu_data_inout_we)
	//	? test_cpu_data_inout_direct : `cpu_data_inout_16_width'hz;
	//
	//assign test_mem_write_data_in_8
	//	= test_cpu_data_out[`cpu_data_inout_8_msb_pos:0];
	//assign test_mem_write_data_in_16 = test_cpu_data_out;
	assign test_mem_write_data_in_8
		= test_cpu_temp_data_out[`cpu_data_inout_8_msb_pos:0];
	assign test_mem_write_data_in_16 = test_cpu_temp_data_out;
	
	
	
	
	//test_memory test_mem( .clk(clk), .req_rdwr(test_cpu_req_rdwr),
	//	.addr_in(test_cpu_data_inout_addr),
	//	.write_data_in_8(test_mem_write_data_in_8),
	//	.write_data_in_16(test_mem_write_data_in_16),
	//	.write_data_we_8(test_mem_write_data_we_8),
	//	.write_data_we_16(test_mem_write_data_we_16),
	//	.read_data_out_8(test_mem_read_data_out_8),
	//	.read_data_out_16(test_mem_read_data_out_16),
	//	.data_ready(test_cpu_data_ready) );
	
	
	
	
	
	//// This needs to have a wrapper put around it when I actually use 
	//// SPCPU in my FPGA board
	//mixed_width_true_dual_port_ram #(8,16,15) dedotated_wam
	//	( .addr1(test_cpu_data_inout_addr),
	//	.addr2(test_mem_addr_2),
	//	.data_in1(test_mem_write_data_in_8),
	//	.data_in2(test_mem_write_data_in_16),
	//	.we1(test_mem_write_data_we_8),
	//	.we2(test_mem_write_data_we_16),
	//	.clk(clk),
	//	.data_out1(test_mem_read_data_out_8),
	//	.data_out2(test_mem_read_data_out_16) );
	
	
	tb_memory test_mem( .clk(tb_clk), .reset(test_mem_reset), 
		.req_rdwr(test_cpu_req_rdwr),
		.addr_in(test_cpu_data_inout_addr),
		.write_data_in_8(test_mem_write_data_in_8),
		.write_data_in_16(test_mem_write_data_in_16),
		.data_acc_sz(test_cpu_data_acc_sz),
		.write_data_we_8(test_mem_write_data_we_8),
		.write_data_we_16(test_mem_write_data_we_16),
		.read_data_out_8(test_mem_read_data_out_8),
		.read_data_out_16(test_mem_read_data_out_16),
		.data_ready(test_mem_data_ready) );
	
	
	spcpu test_cpu( .clk(tb_clk), .reset(test_cpu_reset),
		.data_ready(test_cpu_data_ready),
		.temp_data_in(test_cpu_temp_data_in),
		.temp_data_out(test_cpu_temp_data_out),
		.data_inout_addr(test_cpu_data_inout_addr),
		.data_acc_sz(test_cpu_data_acc_sz),
		.data_inout_we(test_cpu_data_inout_we),
		.req_rdwr(test_cpu_req_rdwr),
		.debug_reg_0(test_cpu_debug_reg_0) );
	
	
	
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
	
	////always @ ( posedge tb_half_clk )
	//always @ ( posedge tb_clk )
	//begin
	//	////$display( "%h %h %h %h", test_cpu_data_inout_direct,
	//	////	test_cpu_data_inout_addr, test_cpu_data_acc_sz, 
	//	////	test_cpu_data_inout_we );
	//	//$display( "In Test bench:  %h %h\t\t%h %h %h", 
	//	//	test_cpu_temp_data_in, test_cpu_temp_data_out, 
	//	//	test_cpu_data_inout_addr, test_cpu_data_acc_sz, 
	//	//	test_cpu_data_inout_we );
	//end
	
	
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
//`define get_pc_after_reg_instr_16 ( `get_cpu_rp_pc + `instr_16_num_bytes )
//`define get_pc_after_reg_instr ( `get_cpu_rp_pc + `instr_16_num_bytes )

// The next value of the PC after a non-PC-changing 32-bit instruction
//`define get_pc_after_reg_instr_32 ( `get_cpu_rp_pc + `instr_32_num_bytes )


`define wire_rhs_pc_indices_contain_reg_index( reg_index ) \
	( ( reg_index == pkg_cpu::cpu_rp_pc_hi_rind ) \
	|| ( reg_index == pkg_cpu::cpu_rp_pc_lo_rind ) )
`define wire_rhs_rp_index_is_pc_index( rp_index ) \
	( rp_index == pkg_cpu::cpu_rp_pc_pind )


`define get_alu_out_8 ( alu_out_lo )
`define get_alu_out_16 ( { alu_out_hi, alu_out_lo } )

// The CPU itself
module spcpu
	
	( input bit clk, input bit reset, input bit data_ready,
	
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
	
	output wire [`cpu_reg_msb_pos:0] debug_reg_0 );
	
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
	//bit [`cpu_reg_msb_pos:0] temp_pc[0:1];
	bit did_prep_ldst_instr;
	
	
	
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
	
	
	
	assign debug_reg_0 = cpu_regs[0];
	//assign debug_reg_0 = 3;
	
	
	
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
	
	//always @ ( posedge clk )
	////always
	//begin
	//	#1
	//	$display( "curr_state:  %h", curr_state );
	//	
	//end
	
	
	
	// End CPU simulation if there are a bunch of 0000's in a row
	always @ ( posedge clk )
	begin
		
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
	
	//$display( "do_stall:  %h", do_stall );
	
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
		
		did_prep_ldst_instr <= 0;
		
		
		//curr_state <= pkg_cpu::cpu_st_begin_0;
		curr_state <= 0;
		
		//data_in_is_0_counter <= 0;
		
		prep_load_16_no_addr();
	end
	
	//else if ( do_stall && !reset )
	//begin
	//	req_rdwr <= 0;
	//	
	//	$display( "do_stall && !reset:  %h %h %h %h", curr_state, 
	//		temp_data_in, `get_cpu_rp_pc, data_inout_addr );
	//end
	
	//else if ( !do_stall && !reset )
	else //if (!reset)
	begin
		//$display( "req_rdwr, data_ready:  %h %h", req_rdwr, 
		//	data_ready );
		
		if ( curr_state == pkg_cpu::cpu_st_begin_0 )
		begin
			//curr_state <= curr_state + 1;
			curr_state <= pkg_cpu::cpu_st_load_instr_hi;
			//prep_load_16_no_addr();
			prep_load_16_with_addr(`get_cpu_rp_pc);
		end
		
		else if ( curr_state == pkg_cpu::cpu_st_load_instr_hi )
		begin
			//debug_disp_regs_and_proc_flags();
			//$display();
			//$display();
			
			if (data_ready)
			begin
				debug_disp_regs_and_proc_flags();
				$display();
				$display();
				
				
				//$display( "Load Instruction High:  %h %h %h", temp_data_in,
				//	`get_cpu_rp_pc, data_inout_addr );
				//$display();
				
				// Back up temp_data_in, init_instr_grp, and pc
				instr_in_hi <= temp_data_in;
				final_instr_grp <= init_instr_grp;
				prev_pc <= `get_cpu_rp_pc;
				second_prev_pc <= the_pc_inc_pc_out;
				
				
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
				
				
				
				//if ( init_instr_grp != pkg_instr_dec::instr_grp_5 )
				if (!init_instr_is_32_bit)
				begin
					curr_state <= pkg_cpu::cpu_st_start_exec_instr;
					//$display( "Instruction is 16-bit, so don't request ",
					//	"another 16 bits of data." );
					req_rdwr <= 0;
					
					
					prep_alu_if_needed_init();
					seq_logic_grab_pc_inc_outputs();
					
					
					//if ( init_instr_grp == pkg_instr_dec::instr_grp_2 )
					//begin
					//	$display( "Barebones ig2 disassemble:  %h %h %h", 
					//		ig2_opcode, ig2_ra_index, ig2_rb_index );
					//end
				end
				
				// Handle 32-bit instructions
				else if ( init_instr_grp == pkg_instr_dec::instr_grp_5 )
				begin
					//$display("Instruction is 32-bit");
					//req_rdwr <= 1;
					seq_logic_grab_pc_inc_outputs();
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
					
				end
				
			end
			
			else // if (!data_ready)
			begin
				//$display();
				//$display();
				//$display();
				//$display();
				//$display("Load Instruction High:  Data NOT ready");
				////$display();
			end
			
		end
		
		
		else if ( curr_state == pkg_cpu::cpu_st_load_instr_lo )
		begin
			if (data_ready)
			begin
				req_rdwr <= 0;
				curr_state <= pkg_cpu::cpu_st_start_exec_instr;
				instr_in_lo <= temp_data_in;
				//set_pc_and_dio_addr(`get_pc_adjuster_outputs);
				//seq_logic_grab_pc_adjuster_outputs();
				third_prev_pc <= the_pc_inc_pc_out;
				
				//$display( "Load Instruction Low:  %h %h %h %h", 
				//	instr_in_hi, temp_data_in, `get_cpu_rp_pc, 
				//	data_inout_addr );
				//$display();
				
				//$display( "nice curr_state.  the_pc_inc_pc_out:  %h", 
				//	the_pc_inc_pc_out );
				seq_logic_grab_pc_inc_outputs();
				
				prep_alu_if_needed_final();
			end
			
			else // if (!data_ready)
			begin
				//$display("Load Instruction Low:  Data NOT ready");
				////$display();
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
		
		
		
		else // if ( curr_state 
			// == pkg_cpu::cpu_st_update_pc_after_non_bc_ipc )
		begin
			$display( "Check whether the pc was actually changed by a ",
				 "non-branch, non-call instruction" );
			
			
			// Check if the pc was ACTUALLY changed
			//if ( prev_pc == `get_cpu_rp_pc )
			if ( ( !final_instr_is_32_bit 
				&& ( prev_pc == `get_cpu_rp_pc ) )
				|| ( final_instr_is_32_bit
				&& ( second_prev_pc == `get_cpu_rp_pc ) ) )
			begin
				$display("The pc was not actually changed");
				//seq_logic_grab_pc_inc_outputs();
			end
			
			else
			begin
				//seq_logic_grab_pc_inc_outputs();
				$display("The pc WAS changed");
			end
			
			//prep_load_instr_hi_generic();
			//seq_logic_grab_pc_adjuster_outputs();
			
			//seq_logic_grab_pc_
			//set_pc_and_dio_addr(
			curr_state <= pkg_cpu::cpu_st_load_instr_hi;
			seq_logic_grab_pc_inc_outputs();
			//prep_load_16_no_addr();
			req_rdwr <= 1;
			
			//prep_load_instr_hi_after_reg();
			
		end
		
	end
	
	end
	
	
	
	//// Combinational logic for various PC-changing stuffs
	// Latch logic for various PC-changing stuffs
	always @ (*)
	//always @ ( curr_state )
	//always_latch
	begin
		
		if ( curr_state == pkg_cpu::cpu_st_begin_0 )
		begin
			//pc_adjuster_op = pkg_alu::addsub_op_addp;
			
			//// This is for branches
			//pc_adjuster_op = pkg_alu::addsub_op_addpsnx;
			//$display("latch logic begin_0");
		end
		
		else if ( curr_state == pkg_cpu::cpu_st_load_instr_hi )
		begin
			//latch_logic_prep_pc_inc_during_load_instr_hi();
			latch_logic_prep_pc_inc_during_load_instr_portion();
			//pc_adjuster_op = pkg_alu::addsub_op_follow;
		end
		else if ( curr_state == pkg_cpu::cpu_st_load_instr_lo )
		begin
			//latch_logic_prep_pc_inc_during_load_instr_lo();
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
		
		//else if ( curr_state == pkg_cpu::cpu_st_finish_exec_ldst_instr )
		//begin
		//	//latch_logic_prep_pc_
		//	$display("latch_logic in finish_exec_ldst_instr");
		//end
		
		else if ( curr_state 
			== pkg_cpu::cpu_st_update_pc_after_non_bc_ipc )
		begin
			latch_logic_prep_pc_inc_after_non_bc_ipc();
		end
		
		
		//else
		//begin
		//	$display( "comb logic else:  %h %h %h %h %h",
		//		`get_cpu_rp_pc, `get_temp_pc, 
		//		{ pc_adjuster_out_hi, pc_adjuster_out_lo }, 
		//		instr_in_hi, temp_data_in );
		//	//debug_disp_regs_and_proc_flags();
		//	
		//	//if ( `get_cpu_rp_pc >= 16'h8010 )
		//	//begin
		//	//	$finish;
		//	//end
		//	
		//end
	end
	
	
	
endmodule


