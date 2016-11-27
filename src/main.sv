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
`include "src/cpu_extras_defines.svinc"

`include "src/instr_decoder_defines.svinc"


module spcpu_test_bench;
	
	logic clk_gen_reset, tb_clk;
	
	// Various test bench reset signals
	logic alu_tb_reset, 
		instr_grp_dec_tb_reset,
		instr_dec_tb_reset;
	
	
	tb_clk_gen clk_gen( .reset(clk_gen_reset), .clk(tb_clk) );
	
	alu_test_bench alu_tb( .tb_clk(tb_clk), .reset(alu_tb_reset) );
	instr_group_decoder_test_bench instr_grp_dec_tb( .tb_clk(tb_clk), 
		.reset(instr_grp_dec_tb_reset) );
	
	instr_decoder_test_bench instr_dec_tb( .tb_clk(tb_clk),
		.reset(instr_dec_tb_reset) );
	
	initial
	begin
		clk_gen_reset = 1'b1;
		
		//alu_tb_reset = 1'b1;
		//instr_grp_dec_tb_reset = 1'b1;
		instr_dec_tb_reset = 1'b1;
	end
	
	
	//initial
	//begin
	//	$finish;
	//end
	
	
endmodule



module instr_decoder_test_bench( input logic tb_clk, input logic reset );
	
	logic ready;
	
	import pkg_instr_dec::*;
	
	logic [`instr_main_msb_pos:0] test_instr_hi, test_instr_lo;
	instr_group test_instr_group;
	
	// instr_grp_1_decoder outputs
	logic [`instr_op_max_msb_pos:0] test_ig1_opcode;
	logic [instr_g1_ra_index_msb_pos:0] test_ig1_ra_index;
	logic [instr_g1_imm_value_msb_pos:0] test_ig1_imm_value_8;
	
	// instr_grp_2_decoder outputs
	logic [`instr_op_max_msb_pos:0] test_ig2_opcode;
	logic [instr_g2_ra_index_msb_pos:0] test_ig2_ra_index;
	logic [instr_g2_rb_index_msb_pos:0] test_ig2_rb_index;
	logic test_ig2_ra_index_is_for_pair, test_ig2_rb_index_is_for_pair;
	
	// instr_grp_3_decoder outputs
	logic [`instr_op_max_msb_pos:0] test_ig3_opcode;
	logic [instr_g3_ra_index_msb_pos:0] test_ig3_ra_index;
	logic [instr_g3_rbp_index_msb_pos:0] test_ig3_rbp_index;
	logic [instr_g3_rcp_index_msb_pos:0] test_ig3_rcp_index;
	
	
	// Instruction decoder modules
	instr_group_decoder instr_grp_dec( .instr_hi(test_instr_hi),
		.group_out(test_instr_group) );
	instr_grp_1_decoder instr_grp_1_dec( .instr_hi(test_instr_hi),
		.opcode_out(test_ig1_opcode), .ra_index_out(test_ig1_ra_index),
		.imm_value_8_out(test_ig1_imm_value_8) );
	instr_grp_2_decoder instr_grp_2_dec( .instr_hi(test_instr_hi),
		.opcode_out(test_ig2_opcode), .ra_index_out(test_ig2_ra_index),
		.rb_index_out(test_ig2_rb_index),
		.ra_index_is_for_pair(test_ig2_ra_index_is_for_pair),
		.rb_index_is_for_pair(test_ig2_rb_index_is_for_pair) );
	instr_grp_3_decoder instr_grp_3_dec( .instr_hi(test_instr_hi),
		.opcode_out(test_ig3_opcode), .ra_index_out(test_ig3_ra_index),
		.rbp_index_out(test_ig3_rbp_index),
		.rcp_index_out(test_ig3_rcp_index) );
	
	
	// This is used instead of an initial block
	always @ (reset)
	begin
		if (reset)
		begin
			ready = 1'b0;
			
			// Other initialization stuff goes here
			test_instr_hi = 0;
			
			//$display( instr_g1_reg_a_index_range_hi,
			//	instr_g1_reg_a_index_range_lo, 
			//	instr_g1_imm_value_range_hi,
			//	instr_g1_imm_value_range_lo );
		end
		
		if ( ready == 1'b0 )
		begin
			#1
			ready = 1'b1;
			
			#2
			test_instr_hi = { instr_g1_id, pkg_instr_dec::instr_g1_op_adci,
				4'b0111, 8'h33 };
			
			#2
			test_instr_hi = { instr_g1_id, pkg_instr_dec::instr_g1_op_cmpi,
				4'h1, 8'h99 };
			
			#2
			test_instr_hi = { instr_g1_id, pkg_instr_dec::instr_g1_op_cpyi, 
				12'b0 };
			
			#2
			test_instr_hi = { instr_g2_id, pkg_instr_dec::instr_g2_op_call, 
				4'd3, 4'd9 };
			
			#2
			test_instr_hi = { instr_g2_id, pkg_instr_dec::instr_g2_op_invp, 
				4'd3, 4'd9 };
			
			#2
			test_instr_hi = { instr_g2_id, pkg_instr_dec::instr_g2_op_cpyp, 
				4'd3, 4'd9 };
			
			#2
			test_instr_hi = { instr_g2_id, pkg_instr_dec::instr_g2_op_swp, 
				4'd4, 4'd9 };
			
			#2
			test_instr_hi = { instr_g2_id, pkg_instr_dec::instr_g2_op_ldr, 
				4'd4, 4'd9 };
			
			#2
			test_instr_hi = { instr_g2_id, pkg_instr_dec::instr_g2_op_str, 
				4'd4, 4'd9 };
			
			#2
			test_instr_hi = { instr_g3_id, pkg_instr_dec::instr_g3_op_strx,
				4'd3, 3'd2, 3'd7 };
			
			#2
			$finish;
		end
	end
	
	
	always @ ( posedge tb_clk )
	begin
	
	if (ready)
	begin
		// Main code stuff here
		
		case (test_instr_group)
			pkg_instr_dec::instr_grp_1:
			begin
				$display( "Group 1\t\t%b %b %b", test_ig1_opcode,
					test_ig1_ra_index, test_ig1_imm_value_8 );
			end
			
			pkg_instr_dec::instr_grp_2:
			begin
				$display( "Group 2\t\t%b %b %b\t\t%b %b", test_ig2_opcode,
					test_ig2_ra_index, test_ig2_rb_index,
					test_ig2_ra_index_is_for_pair,
					test_ig2_rb_index_is_for_pair );
				
				if ( test_ig2_opcode == pkg_instr_dec::instr_g2_op_invp )
				begin
					$display("invp instruction encountered");
				end
			end
			
			pkg_instr_dec::instr_grp_3:
			begin
				$display( "Group 3\t\t%b %b %b %b", test_ig3_opcode,
					test_ig3_ra_index, test_ig3_rbp_index,
					test_ig3_rcp_index );
			end
			
			default:
			begin
				$display("Unknown instruction encoding");
			end
			
		endcase
	end
	
	end
	
	
endmodule




module instr_group_decoder_test_bench( input logic tb_clk, 
	input logic reset );
	
	logic ready;
	
	import pkg_instr_dec::*;
	
	logic [`instr_main_msb_pos:0] test_instr_hi, test_instr_lo;
	instr_group test_instr_group;
	
	instr_group_decoder instr_grp_dec( .instr_hi(test_instr_hi),
		.group_out(test_instr_group) );
	
	// This is used instead of an initial block
	always @ (reset)
	begin
		if (reset)
		begin
			ready = 1'b0;
			test_instr_hi = `instr_main_width'h0000;
			
		end
		
		if ( ready == 1'b0 )
		begin
			#1
			ready = 1'b1;
			
			
			#2
			test_instr_hi = { instr_g1_id, pkg_instr_dec::instr_g1_op_addi, 
				4'b0111, 8'h33 };
			
			
			#2
			test_instr_hi = { instr_g2_id, pkg_instr_dec::instr_g2_op_call,
				4'd1, 4'd2 };
			
			
			//#2
			//test_instr_hi = { instr_g3_id, pkg_instr_dec::instr_g3_op_
			
			#2
			$finish;
			
		end
	end
	
	
	always @ ( posedge tb_clk )
	begin
	
	if (ready)
	begin
		
		$display( "%b %b %b %b\t\t%d", test_instr_hi[15:12], 
			test_instr_hi[11:8], test_instr_hi[7:4], test_instr_hi[3:0], 
			test_instr_group );
		
	end
	
	end
	
	
endmodule



module alu_test_bench( input logic tb_clk, input logic reset );
	
	logic ready;
	
	import pkg_alu::get_alu_oper_cat_tb;
	
	logic dummy;
	
	// ALU inputs and outputs
	pkg_alu::alu_oper the_alu_op;
	pkg_alu::alu_oper_cat the_alu_op_cat;
	logic [`alu_inout_msb_pos:0] alu_a_in_lo, alu_a_in_hi, alu_b_in;
	logic [`proc_flags_msb_pos:0] alu_proc_flags_in;
	logic [`alu_inout_msb_pos:0] alu_out_lo, alu_out_hi;
	logic [`proc_flags_msb_pos:0] alu_proc_flags_out;
	
	alu test_alu( .oper(the_alu_op), 
		.a_in_hi(alu_a_in_hi), .a_in_lo(alu_a_in_lo), .b_in(alu_b_in),
		.proc_flags_in(alu_proc_flags_in), 
		.out_lo(alu_out_lo), .out_hi(alu_out_hi),
		.proc_flags_out(alu_proc_flags_out) );
	
	
	// This is used instead of an initial block
	always @ (reset)
	begin
		if (reset)
		begin
			ready = 1'b0;
			
			dummy = 1'b0;
			
			//the_alu_op = pkg_alu::alu_op_add + 1;
			//the_alu_op = pkg_alu::alu_op_add + pkg_alu::alu_op_add;
			//the_alu_op = the_alu_op + 1;
			//the_alu_op += 1;
			
			//// Arithmetic operations
			//// Addition operations
			the_alu_op = alu_op_add;
			//the_alu_op = alu_op_adc;
			//
			//
			//// Subtraction operations
			//the_alu_op = alu_op_sub;
			//the_alu_op = alu_op_sbc;
			//the_alu_op = alu_op_cmp;
			//
			//// Bitwise operations
			//
			//// Operations analogous to logic gates (none of these affect
			//// carry)
			//the_alu_op = alu_op_and;
			//the_alu_op = alu_op_orr;
			//the_alu_op = alu_op_xor;
			//
			//// Complement operations
			//the_alu_op = alu_op_inv;
			//the_alu_op = alu_op_invp;
			//the_alu_op = alu_op_neg;
			//the_alu_op = alu_op_negp;
			//
			//
			//// 8-bit Bitshifting operations (number of bits specified by
			//// b_in)
			//the_alu_op = alu_op_lsl;
			//the_alu_op = alu_op_lsr;
			//the_alu_op = alu_op_asr;
			//
			//// 8-bit Bit rotation operations (number of bits specified by
			//// [b_in % inout_width])
			//the_alu_op = alu_op_rol;
			//the_alu_op = alu_op_ror;
			//
			//
			//// Bit rotating instructions that use carry as bit 8 for a
			//// 9-bit rotate of { carry, a_in_lo } by one bit:
			//the_alu_op = alu_op_rolc;
			//the_alu_op = alu_op_rorc;
			//
			//
			//
			//// 16-bit Bitshifting operations that shift 
			//// { a_in_hi, a_in_lo } by b_in bits
			//the_alu_op = alu_op_lslp;
			//the_alu_op = alu_op_lsrp;
			//the_alu_op = alu_op_asrp;
			//
			//
			//// 16-bit Bit rotation operations that rotate 
			//// { a_in_hi, a_in_lo } by [b_in % inout_width] bits
			//the_alu_op = alu_op_rolp;
			//the_alu_op = alu_op_rorp;
			//
			//
			//// Bit rotating instructions that use carry as bit 16 for a
			//// 17-bit rotate of { carry, a_in_hi, a_in_lo } by one bit:
			//the_alu_op = alu_op_rolcp;
			//the_alu_op = alu_op_rorcp;
			
			get_alu_oper_cat_tb( the_alu_op, the_alu_op_cat );
			
			{ alu_a_in_hi, alu_a_in_lo, alu_b_in } = { `alu_inout_width'h0,
				`alu_inout_width'h0, `alu_inout_width'h0 };
			alu_proc_flags_in = `proc_flags_width'h0;
			
			//$display(the_alu_op_cat);
		end
		
		if ( ready == 1'b0 )
		begin
			#1
			ready = 1'b1;
		end
	end
	
	
	always @ ( posedge tb_clk )
	begin
	
	if (ready)
	begin
		
		if ( the_alu_op_cat == alu_op_cat_8_no_ci )
		begin
			//$display( "%d %d\t\t%d %b", alu_a_in_lo, alu_b_in, 
			//	alu_out_lo, alu_proc_flags_out );
			//$display( "%h %h\t\t%h %b", alu_a_in_lo, alu_b_in, 
			//	alu_out_lo, alu_proc_flags_out );
			//$display( "%b %b\t\t%b %b", alu_a_in_lo, alu_b_in, 
			//	alu_out_lo, alu_proc_flags_out );
			$display( "%b %d\t\t%b %b", alu_a_in_lo, alu_b_in, 
				alu_out_lo, alu_proc_flags_out );
			//$display( "%b %d\t\t%b %b", alu_a_in_lo,
			//	alu_b_in[ `alu_inout_width >> 2:0 ], alu_out_lo, 
			//	alu_proc_flags_out );
			
			{ dummy, alu_a_in_lo, alu_b_in } = { dummy, alu_a_in_lo,
				alu_b_in } + 1;
			
			//{ dummy, alu_a_in_lo, alu_b_in[ `alu_inout_width >> 2:0 ] }
			//	= { dummy, alu_a_in_lo, 
			//	alu_b_in[ `alu_inout_width >> 2:0 ] } + 1;
		end
		
		else if ( the_alu_op_cat == alu_op_cat_8_ci )
		begin
			//$display( "%d %b %d\t\t%d %b", alu_a_in_lo,
			//	alu_proc_flags_in[pkg_pflags::pf_slot_c], alu_b_in,
			//	alu_out_lo, alu_proc_flags_out );
			//$display( "%h %b %h\t\t%h %b", alu_a_in_lo,
			//	alu_proc_flags_in[pkg_pflags::pf_slot_c], alu_b_in,
			//	alu_out_lo, alu_proc_flags_out );
			//$display( "%b %b %b\t\t%b %b", alu_a_in_lo,
			//	alu_proc_flags_in[pkg_pflags::pf_slot_c], alu_b_in,
			//	alu_out_lo, alu_proc_flags_out );
			$display( "%b %b %d\t\t%b %b", alu_a_in_lo,
				alu_proc_flags_in[pkg_pflags::pf_slot_c], alu_b_in,
				alu_out_lo, alu_proc_flags_out );
			//$display( "%b %b %d\t\t%b %b", alu_a_in_lo,
			//	alu_proc_flags_in[pkg_pflags::pf_slot_c],
			//	alu_b_in[ `alu_inout_and_carry_width >> 2:0 ], alu_out_lo, 
			//	alu_proc_flags_out );
			
			{ dummy, alu_a_in_lo, alu_proc_flags_in[pkg_pflags::pf_slot_c],
				alu_b_in }
				= { dummy, alu_a_in_lo, 
				alu_proc_flags_in[pkg_pflags::pf_slot_c], alu_b_in } + 1;
			//{ dummy, alu_a_in_lo, 
			//	alu_proc_flags_in[pkg_pflags::pf_slot_c], 
			//	alu_b_in[ `alu_inout_and_carry_width >> 2:0 ] }
			//	= { dummy, alu_a_in_lo, 
			//	alu_proc_flags_in[pkg_pflags::pf_slot_c],
			//	alu_b_in[ `alu_inout_and_carry_width >> 2:0 ] } + 1;
		end
		
		else if ( the_alu_op_cat == alu_op_cat_16_no_ci )
		begin
			//$display( "%d %d\t\t%d %b", { alu_a_in_hi, alu_a_in_lo }, 
			//	alu_b_in, { alu_out_hi, alu_out_lo }, alu_proc_flags_out );
			//$display( "%h %h\t\t%h %b", { alu_a_in_hi, alu_a_in_lo }, 
			//	alu_b_in, { alu_out_hi, alu_out_lo }, alu_proc_flags_out );
			//$display( "%b %b\t\t%b %b", { alu_a_in_hi, alu_a_in_lo }, 
			//	alu_b_in, { alu_out_hi, alu_out_lo }, alu_proc_flags_out );
			$display( "%b %d\t\t%b %b", { alu_a_in_hi, alu_a_in_lo }, 
				alu_b_in, { alu_out_hi, alu_out_lo }, alu_proc_flags_out );
			
			{ dummy, { alu_a_in_hi, alu_a_in_lo }, alu_b_in } = { dummy, 
				{ alu_a_in_hi, alu_a_in_lo }, alu_b_in } + 1;
		end
		
		else // if ( the_alu_op_cat == alu_op_cat_16_ci )
		begin
			//$display( "%d %b %d\t\t%d %b", { alu_a_in_hi, alu_a_in_lo },
			//	alu_proc_flags_in[pkg_pflags::pf_slot_c], alu_b_in,
			//	{ alu_out_hi, alu_out_lo }, alu_proc_flags_out );
			//$display( "%h %b %h\t\t%h %b", { alu_a_in_hi, alu_a_in_lo },
			//	alu_proc_flags_in[pkg_pflags::pf_slot_c], alu_b_in,
			//	{ alu_out_hi, alu_out_lo }, alu_proc_flags_out );
			//$display( "%b %b %b\t\t%b %b", { alu_a_in_hi, alu_a_in_lo },
			//	alu_proc_flags_in[pkg_pflags::pf_slot_c], alu_b_in,
			//	{ alu_out_hi, alu_out_lo }, alu_proc_flags_out );
			//$display( "%b %b %d\t\t%b %b", { alu_a_in_hi, alu_a_in_lo },
			//	alu_proc_flags_in[pkg_pflags::pf_slot_c], alu_b_in,
			//	{ alu_out_hi, alu_out_lo }, alu_proc_flags_out );
			$display( "%b %b\t\t%b %b", { alu_a_in_hi, alu_a_in_lo },
				alu_proc_flags_in[pkg_pflags::pf_slot_c], 
				{ alu_out_hi, alu_out_lo }, alu_proc_flags_out );
			//$display( "%b %b %d\t\t%b %b", { alu_a_in_hi, alu_a_in_lo },
			//	alu_proc_flags_in[pkg_pflags::pf_slot_c], 
			//	alu_b_in[ `alu_inout_pair_and_carry_width >> 2:0 ],
			//	{ alu_out_hi, alu_out_lo }, alu_proc_flags_out );
			
			//{ dummy, { alu_a_in_hi, alu_a_in_lo }, 
			//	alu_proc_flags_in[pkg_pflags::pf_slot_c], alu_b_in }
			//	= { dummy, { alu_a_in_hi, alu_a_in_lo }, 
			//	alu_proc_flags_in[pkg_pflags::pf_slot_c], alu_b_in } + 1;
			{ dummy, { alu_a_in_hi, alu_a_in_lo }, 
				alu_proc_flags_in[pkg_pflags::pf_slot_c] }
				= { dummy, { alu_a_in_hi, alu_a_in_lo }, 
				alu_proc_flags_in[pkg_pflags::pf_slot_c] } + 1;
			//{ dummy, { alu_a_in_hi, alu_a_in_lo }, 
			//	alu_proc_flags_in[pkg_pflags::pf_slot_c], 
			//	alu_b_in[ `alu_inout_pair_and_carry_width >> 2:0 ] }
			//	= { dummy, { alu_a_in_hi, alu_a_in_lo }, 
			//	alu_proc_flags_in[pkg_pflags::pf_slot_c], 
			//	alu_b_in[ `alu_inout_pair_and_carry_width >> 2:0 ] } + 1;
		end
		
		
		if (dummy)
		begin
			$finish;
		end
		
	end
	
	end
	
	
endmodule



