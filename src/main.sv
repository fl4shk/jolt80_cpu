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
	
	bit clk_gen_reset, tb_clk;
	
	bit test_mem_reset;
	
	//// Various test bench reset signals
	//bit alu_tb_reset, 
	//	instr_grp_dec_tb_reset,
	//	instr_dec_tb_reset;
	
	// reset signal for test_cpu
	bit test_cpu_reset;
	
	
	tb_clk_gen clk_gen( .reset(clk_gen_reset), .clk(tb_clk) );
	
	
	//alu_test_bench alu_tb( .tb_clk(tb_clk), .reset(alu_tb_reset) );
	//instr_group_decoder_test_bench instr_grp_dec_tb( .tb_clk(tb_clk), 
	//	.reset(instr_grp_dec_tb_reset) );
	//instr_decoder_test_bench instr_dec_tb( .tb_clk(tb_clk),
	//	.reset(instr_dec_tb_reset) );
	
	tb_mem_inputs mem_inputs;
	//logic [`cpu_data_inout_16_msb_pos:0] tb_mem_read_data_out ;
	wire [`cpu_data_inout_16_msb_pos:0] tb_mem_read_data_out ;
	
	tb_memory test_mem( .write_clk(tb_clk), .reset(test_mem_reset),
		.the_inputs(mem_inputs), .read_data_out(tb_mem_read_data_out) );
	
	`include "src/test_mem_tasks.svinc"
	
	
	wire [`cpu_data_inout_16_msb_pos:0] test_cpu_data_inout_direct;
	bit [`cpu_addr_msb_pos:0] test_cpu_data_inout_addr;
	bit test_cpu_data_acc_sz, test_cpu_data_inout_we;
	
	spcpu test_cpu( .clk(tb_clk), .reset(test_cpu_reset),
		.data_inout(test_cpu_data_inout_direct),
		.data_inout_addr(test_cpu_data_inout_addr),
		.data_acc_sz(test_cpu_data_acc_sz),
		.data_inout_we(test_cpu_data_inout_we) );
	
	//logic [`cpu_data_inout_16_msb_pos:0] test_cpu_data_in, 
	//	test_cpu_data_out;
	logic [`cpu_data_inout_16_msb_pos:0] test_cpu_data_out;
	
	
	//assign test_cpu_data_inout_direct = (!test_cpu_data_inout_we) 
	//	? test_cpu_data_in : `cpu_data_inout_16_width'hz;
	assign test_cpu_data_inout_direct = (!test_cpu_data_inout_we) 
		? tb_mem_read_data_out : `cpu_data_inout_16_width'hz;
	
	assign test_cpu_data_out = (test_cpu_data_inout_we)
		? test_cpu_data_inout_direct : `cpu_data_inout_16_width'hz;
	
	
	initial
	begin
		clk_gen_reset = 1'b0;
		test_cpu_reset = 1'b0;
		
		{ mem_inputs.write_addr_in, mem_inputs.write_data_in,
			mem_inputs.write_data_acc_sz, mem_inputs.write_data_we } = 0;
		
		#2
		test_cpu_reset = 1'b1;
		
		#2
		clk_gen_reset = 1'b1;
		
	end
	
	
	always @ ( posedge tb_clk )
	begin
		
		// If the CPU wants to read or write 8-bit data
		if ( test_cpu_data_acc_sz == pkg_cpu::cpu_data_acc_sz_8 )
		begin
			// If the CPU wants to read 8-bit data
			if (!test_cpu_data_inout_we)
			begin
				read_test_mem_8(test_cpu_data_inout_addr);
				
				//$display( "%h", test_cpu_data_in );
			end
			
			// If the CPU wants to write 8-bit data
			else // if (test_cpu_data_inout_we)
			begin
				write_test_mem_8( test_cpu_data_inout_addr, 
					test_cpu_data_out );
			end
		end
		
		
		// If the CPU wants to read or write 16-bit data
		else // if ( test_cpu_data_acc_sz == pkg_cpu::cpu_data_acc_sz_16 )
		begin
			// If the CPU wants to read 16-bit data (for Small Practice
			// CPU, it's used for loading either a 16-bit instruction or
			// a 16-bit half of a 32-bit instruction)
			if (!test_cpu_data_inout_we)
			begin
				read_test_mem_16(test_cpu_data_inout_addr);
			end
			
			// If the CPU wants to write 16-bit data (which should NOT 
			// happen with the current design of Small Practice CPU)
			else // if (test_cpu_data_inout_we)
			begin
				$display( "spcpu_test_bench:  Uh oh!  The CPU module ",
					"wants to store a 16-bit value!  That should NOT ",
					"happen!" );
			end
		end
		
	end
	
	
endmodule



`define make_reg_pair( index_hi ) `make_pair( cpu_regs, index_hi )

// Make reg pair with pair index
`define make_reg_pair_w_pi( pair_index ) `make_pair( cpu_regs, \
	pair_index << 1 )

`define get_cpu_rp_pc `make_reg_pair_w_pi(pkg_cpu::cpu_rp_pc_pind)
`define get_cpu_rp_lr `make_reg_pair_w_pi(pkg_cpu::cpu_rp_lr_pind)

// The next value of the PC after a non-PC-changing 16-bit instruction, or
// the next value of data_inout_addr after loading the high 16 bits of a
// 32-bit instruction
`define get_pc_after_reg_instr_16 ( `get_cpu_rp_pc + 2 )

// The next value of the PC after a non-PC-changing 32-bit instruction
`define get_pc_after_reg_instr_32 ( `get_cpu_rp_pc + 4 )


`define wire_rhs_pc_indices_contain_reg_index( reg_index ) \
	( ( reg_index == pkg_cpu::cpu_rp_pc_hi_rind ) \
	|| ( reg_index == pkg_cpu::cpu_rp_pc_lo_rind ) )

`define wire_rhs_rp_index_is_pc_index( rp_index ) \
	( rp_index == pkg_cpu:: cpu_rp_pc_pind )


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
	
	
	
	
	
	// For some reason, vvp does weird things when I make cpu_regs part of
	// the misc_cpu_vars struct, so just get rid of that struct for now.
	bit [`cpu_reg_msb_pos:0] cpu_regs[0:`cpu_reg_arr_msb_pos];
	
	// The entirety of a 16-bit insturction, or the high 16 bits of a
	// 32-bit instruction
	bit [`instr_main_msb_pos:0] instr_in_hi,
	
	// The low 16 bits of a 32-bit instruction
		instr_in_lo;
	
	// The current CPU state
	bit [`cpu_state_msb_pos:0] curr_state;
	
	wire [`cpu_data_inout_16_msb_pos:0] temp_data_in;
	bit [`cpu_data_inout_16_msb_pos:0] temp_data_out;
	
	
	
	// Instruction Group 1 Instruction Execution Things
	// Get rid of some boilerplate
	wire [`instr_g1_op_msb_pos:0] ig1_opcode;
	wire [`instr_g1_ra_index_msb_pos:0] ig1_ra_index;
	wire [`instr_g1_imm_value_msb_pos:0] ig1_imm_value_8;
	
	wire ig1_instr_changes_pc, ig1_pc_contains_ra;
	
	
	
	// Instruction Group 2 Instruction Execution Things
	// Get rid of some boilerplate
	wire [`instr_g2_op_msb_pos:0] ig2_opcode;
	wire [`instr_g2_ra_index_msb_pos:0] ig2_ra_index;
	wire [`instr_g2_rb_index_msb_pos:0] ig2_rb_index;
	wire ig2_ra_index_is_for_pair, ig2_rb_index_is_for_pair;
	
	wire ig2_instr_changes_pc, ig2_pc_contains_ra, ig2_pc_contains_rb,
		ig2_rap_is_pc, ig2_rbp_is_pc;
	
	
	
	// Instruction Group 3 Instruction Execution Things
	// Get rid of some boilerplate
	wire [`instr_g3_op_msb_pos:0] ig3_opcode;
	wire [`instr_g3_ra_index_msb_pos:0] ig3_ra_index;
	wire [`instr_g3_rbp_index_msb_pos:0] ig3_rbp_index;
	wire [`instr_g3_rcp_index_msb_pos:0] ig3_rcp_index;
	
	wire ig3_instr_changes_pc, ig3_pc_contains_ra, ig3_rbp_is_pc,
		ig3_rcp_is_pc;
	
	
	
	// Instruction Group 4 Instruction Execution Things
	// ALL Instructions in group 4 change the PC
	// Get rid of some boilerplate
	wire [`instr_g4_op_msb_pos:0] ig4_opcode;
	wire [`instr_g4_imm_value_msb_pos:0] ig4_imm_value_8;
	
	
	
	// Instruction Group 5 Instruction Execution Things
	// Get rid of some boilerplate
	wire [`instr_g5_op_msb_pos:0] ig5_opcode;
	wire [`instr_g5_ihi_ra_index_msb_pos:0] ig5_ra_index;
	wire [`instr_g5_ihi_rbp_index_msb_pos:0] ig5_rbp_index;
	
	wire ig5_instr_changes_pc, ig5_pc_contains_ra, ig5_rbp_is_pc;
	
	
	
	
	
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
	
	
	
	// Instruction decoder modules
	instr_group_decoder instr_grp_dec( .instr_hi(temp_data_in),
		.group_out(init_instr_grp) );
	
	
	instr_grp_1_decoder instr_grp_1_dec( .instr_hi(instr_in_hi),
		.ig1d_outputs(ig1d_outputs) );
	instr_grp_2_decoder instr_grp_2_dec( .instr_hi(instr_in_hi),
		.ig2d_outputs(ig2d_outputs) );
	instr_grp_3_decoder instr_grp_3_dec( .instr_hi(instr_in_hi),
		.ig3d_outputs(ig3d_outputs) );
	instr_grp_4_decoder instr_grp_4_dec( .instr_hi(instr_in_hi),
		.ig4d_outputs(ig4d_outputs) );
	instr_grp_5_decoder instr_grp_5_dec( .instr_hi(instr_in_hi),
		.ig5d_outputs(ig5d_outputs) );
	
	
	// Outside world access assign statements
	assign data_inout = (data_inout_we) ? temp_data_out
		: `cpu_data_inout_16_width'hz;
	assign temp_data_in = (!data_inout_we) ? data_inout
		: `cpu_data_inout_16_width'hz;
	
	
	
	// Instruction Group 1 Instruction Execution Things
	assign { ig1_opcode, ig1_ra_index, ig1_imm_value_8 } 
		= { ig1d_outputs.opcode, ig1d_outputs.ra_index, 
		ig1d_outputs.imm_value_8 };
	
	assign ig1_pc_contains_ra 
		= `wire_rhs_pc_indices_contain_reg_index(ig1d_outputs.ra_index);
	
	assign ig1_instr_changes_pc = ( ig1_pc_contains_ra 
		// Arithmetic instructions:
		? ( ( ig1_opcode == pkg_instr_dec::instr_g1_op_addi )
		|| ( ig1_opcode == pkg_instr_dec::instr_g1_op_adci )
		
		// Skip instr_g1_op_cmpi because it CAN'T change registers
		
		//Copy instructions:
		
		// (CoPY Immediate)
		|| ( ig1_opcode == pkg_instr_dec::instr_g1_op_cpyi ) )
		: 0 );
	
	
	
	// Instruction Group 2 Instruction Execution Things
	assign ig2_pc_contains_ra
		= `wire_rhs_pc_indices_contain_reg_index(ig2d_outputs.ra_index);
	assign ig2_pc_contains_rb
		= `wire_rhs_pc_indices_contain_reg_index(ig2d_outputs.rb_index);
	assign ig2_rap_is_pc = ( ig2d_outputs.ra_index_is_for_pair
		&& `wire_rhs_rp_index_is_pc_index(ig2d_outputs.ra_index) );
	assign ig2_rbp_is_pc = ( ig2d_outputs.rb_index_is_for_pair
		&& `wire_rhs_rp_index_is_pc_index(ig2d_outputs.rb_index) );
	
	
	
	// Instruction Group 3 Instruction Execution Things
	assign ig3_pc_contains_ra
		= `wire_rhs_pc_indices_contain_reg_index(ig3d_outputs.ra_index);
	assign ig3_rbp_is_pc 
		= `wire_rhs_rp_index_is_pc_index(ig3d_outputs.rbp_index);
	assign ig3_rcp_is_pc 
		= `wire_rhs_rp_index_is_pc_index(ig3d_outputs.rcp_index);
	
	
	
	// Instruction Group 4 Instruction Execution Things
	
	// Instruction Group 5 Instruction Execution Things
	assign ig5_pc_contains_ra
		= `wire_rhs_pc_indices_contain_reg_index(ig5d_outputs.ra_index);
	assign ig5_rbp_is_pc 
		= `wire_rhs_rp_index_is_pc_index(ig5d_outputs.rbp_index);
	
	
	
	// Tasks
	`include "src/spcpu_debug_tasks.svinc"
	
	
	
	// This task exists to help reduce bugs fro
	task set_pc_and_dio_addr;
		input [`cpu_addr_msb_pos:0] val;
		
		`get_cpu_rp_pc <= val;
		data_inout_addr <= val;
	endtask
	
	// Advance the PC and data_inout_addr after a 16-bit non-PC-changing
	// instruction, which is also known as a "regular" 16-bit instruction
	task advance_pc_etc_after_reg_instr_16;
		set_pc_and_dio_addr(`get_pc_after_reg_instr_16);
	endtask
	
	// Advance the PC and data_inout_addr after a 32-bit non-PC-changing
	// instruction, which is also known as a "regular" 32-bit instruction
	task advance_pc_etc_after_reg_instr_32;
		set_pc_and_dio_addr(`get_pc_after_reg_instr_32);
	endtask
	
	
	// Advance data_inout_addr by two bytes so the low 16 bits of a 32-bit
	// instruction can be loaded on the next cycle
	task advance_dio_addr_for_instr_lo;
		data_inout_addr <= `get_pc_after_reg_instr_16;
	endtask
	
	
	task disable_dio_we;
		data_inout_we <= 1'b0;
	endtask
	
	task enable_dio_we;
		data_inout_we <= 1'b1;
	endtask
	
	// Prepare to, on the next cycle, load an 8-bit value
	task prepare_to_load_8_with_addr;
		input [`cpu_addr_msb_pos:0] read_addr;
		
		data_inout_addr <= read_addr;
		data_acc_sz <= pkg_cpu::cpu_data_acc_sz_8;
		disable_dio_we();
	endtask
	task prepare_to_load_8_no_addr;
		data_acc_sz <= pkg_cpu::cpu_data_acc_sz_8;
		disable_dio_we();
	endtask
	
	// Prepare to, on the next cycle, write an 8-bit value
	task prepare_to_store_8_with_addr;
		input [`cpu_addr_msb_pos:0] write_addr;
		
		data_inout_addr <= write_addr;
		data_acc_sz <= pkg_cpu::cpu_data_acc_sz_8;
		enable_dio_we();
	endtask
	task prepare_to_store_8_no_addr;
		data_acc_sz <= pkg_cpu::cpu_data_acc_sz_8;
		enable_dio_we();
	endtask
	
	// Prepare to, on the next cycle, load a 16-bit value
	task prepare_to_load_16_with_addr;
		input [`cpu_addr_msb_pos:0] read_addr;
		
		data_inout_addr <= read_addr;
		data_acc_sz <= pkg_cpu::cpu_data_acc_sz_16;
		disable_dio_we();
	endtask
	task prepare_to_load_16_no_addr;
		data_acc_sz <= pkg_cpu::cpu_data_acc_sz_16;
		disable_dio_we();
	endtask
	
	`include "src/spcpu_instr_exec_tasks.svinc"
	
	
	
	logic ready;
	
	always @ (reset)
	begin
	
	if (reset)
	begin
		//{ data_inout_addr, data_inout_we } = 0;
		data_inout_addr <= 0;
		data_inout_we <= 0;
		
		data_acc_sz <= pkg_cpu::cpu_data_acc_sz_16;
		
		
		// Clear every CPU register
		{ cpu_regs[0], cpu_regs[1], cpu_regs[2], cpu_regs[3], 
			cpu_regs[4], cpu_regs[5], cpu_regs[6], cpu_regs[7],
			cpu_regs[8], cpu_regs[9], cpu_regs[10], cpu_regs[11],
			cpu_regs[12], cpu_regs[13], cpu_regs[14], cpu_regs[15] } <= 0;
		
		curr_state <= pkg_cpu::cpu_st_load_instr_hi;
		
		ready <= 0;
	end
	
	end
	
	
	
	always @ ( posedge clk )
	begin
		if ( `get_cpu_rp_pc >= 20 )
		begin
			$display("\ndone");
			$finish;
		end
	end
	
	
	
	always @ ( posedge clk )
	begin
		
		//$display( "%h", `get_cpu_rp_pc );
		
		if (!ready)
		begin
			ready <= 1;
			advance_pc_etc_after_reg_instr_16();
			prepare_to_load_16_no_addr();
			
			//$display(ig1_instr_changes_pc);
		end
		
		else if ( curr_state == pkg_cpu::cpu_st_load_instr_hi )
		begin
			// Back up temp_data_in and init_instr_grp
			instr_in_hi <= temp_data_in;
			final_instr_grp <= init_instr_grp;
			
			if ( init_instr_grp != pkg_instr_dec::instr_grp_5 )
			begin
				//instr_in_hi <= temp_data_in;
				curr_state <= pkg_cpu::cpu_st_start_exec_instr;
			end
			
			// Handle 32-bit instructions
			else if ( init_instr_grp == pkg_instr_dec::instr_grp_5 )
			begin
				//instr_in_hi <= temp_data_in;
				curr_state <= pkg_cpu::cpu_st_load_instr_lo;
				
				advance_dio_addr_for_instr_lo();
				prepare_to_load_16_no_addr();
			end
			
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
		end
		
		
		// Instruction execution states
		else if ( curr_state == pkg_cpu::cpu_st_start_exec_instr )
		begin
			start_exec_instr();
		end
		
		else // if ( curr_state == pkg_cpu::cpu_st_finish_exec_instr )
		begin
			finish_exec_instr();
			
			//curr_state <= pkg_cpu::cpu_st_load_instr_hi;
		end
		
	end
	
	
	
endmodule


