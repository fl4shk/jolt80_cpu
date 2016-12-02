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

//module instr_decoder_test_bench( input bit tb_clk, input bit reset );
//	
//	bit ready;
//	
//	import pkg_instr_dec::*;
//	
//	bit [`instr_main_msb_pos:0] test_instr_hi, test_instr_lo;
//	instr_group test_instr_group;
//	
//	
//	ig1_dec_outputs ig1d_outputs;
//	ig2_dec_outputs ig2d_outputs;
//	ig3_dec_outputs ig3d_outputs;
//	ig4_dec_outputs ig4d_outputs;
//	ig5_dec_outputs ig5d_outputs;
//	
//	
//	// Instruction decoder modules
//	instr_group_decoder instr_grp_dec( .instr_hi(test_instr_hi),
//		.group_out(test_instr_group) );
//	instr_grp_1_decoder instr_grp_1_dec( .instr_hi(test_instr_hi),
//		.ig1d_outputs(ig1d_outputs) );
//	instr_grp_2_decoder instr_grp_2_dec( .instr_hi(test_instr_hi),
//		.ig2d_outputs(ig2d_outputs) );
//	instr_grp_3_decoder instr_grp_3_dec( .instr_hi(test_instr_hi),
//		.ig3d_outputs(ig3d_outputs) );
//	instr_grp_4_decoder instr_grp_4_dec( .instr_hi(test_instr_hi),
//		.ig4d_outputs(ig4d_outputs) );
//	instr_grp_5_decoder instr_grp_5_dec( .instr_hi(test_instr_hi),
//		.ig5d_outputs(ig5d_outputs) );
//	
//	
//	// This is used instead of an initial block
//	always @ (reset)
//	begin
//		if (reset)
//		begin
//			ready = 1'b0;
//			
//			// Other initialization stuff goes here
//			test_instr_hi = 0;
//			
//			//$display( instr_g1_reg_a_index_range_hi,
//			//	instr_g1_reg_a_index_range_lo, 
//			//	instr_g1_imm_value_range_hi,
//			//	instr_g1_imm_value_range_lo );
//		end
//		
//		if ( ready == 1'b0 )
//		begin
//			#1
//			ready = 1'b1;
//			
//			#2
//			test_instr_hi = { `instr_g1_id, 
//				pkg_instr_dec::instr_g1_op_adci, 4'b0111, 8'h33 };
//			
//			#2
//			test_instr_hi = { `instr_g1_id, 
//				pkg_instr_dec::instr_g1_op_cmpi, 4'h1, 8'h99 };
//			
//			#2
//			test_instr_hi = { `instr_g1_id, 
//				pkg_instr_dec::instr_g1_op_cpyi, 12'b0 };
//			
//			#2
//			test_instr_hi = { `instr_g2_id, 
//				pkg_instr_dec::instr_g2_op_call, 4'd3, 4'd9 };
//			
//			#2
//			test_instr_hi = { `instr_g2_id, 
//				pkg_instr_dec::instr_g2_op_invp, 4'd3, 4'd9 };
//			
//			#2
//			test_instr_hi = { `instr_g2_id, 
//				pkg_instr_dec::instr_g2_op_cpyp, 4'd3, 4'd9 };
//			
//			#2
//			test_instr_hi = { `instr_g2_id, 
//				pkg_instr_dec::instr_g2_op_swp, 4'd4, 4'd9 };
//			
//			#2
//			test_instr_hi = { `instr_g2_id, 
//				pkg_instr_dec::instr_g2_op_ldr, 4'd4, 4'd9 };
//			
//			#2
//			test_instr_hi = { `instr_g2_id, pkg_instr_dec::instr_g2_op_str, 
//				4'd4, 4'd9 };
//			
//			#2
//			test_instr_hi = { `instr_g3_id, 
//				pkg_instr_dec::instr_g3_op_strx, 4'd3, 3'd2, 3'd7 };
//			
//			#2
//			test_instr_hi = { `instr_g4_id, pkg_instr_dec::instr_g4_op_bnv,
//				-8'd1 };
//			
//			#2
//			test_instr_hi = { `instr_g4_id, pkg_instr_dec::instr_g4_op_bhi,
//				8'd8 };
//			
//			#2
//			{ test_instr_hi, test_instr_lo } = { `instr_g5_ihi_id, 
//				pkg_instr_dec::instr_g5_op_calli, 4'd3, 3'd2,
//				-16'h1faa };
//			
//			#2
//			{ test_instr_hi, test_instr_lo } = { `instr_g5_ihi_id, 
//				pkg_instr_dec::instr_g5_op_ldrxi, 4'd3, 3'd2,
//				~16'h1faa + 1'b1 };
//			
//			#2
//			$finish;
//		end
//	end
//	
//	
//	always @ ( posedge tb_clk )
//	begin
//	
//	if (ready)
//	begin
//		// Main code stuff here
//		
//		case (test_instr_group)
//			pkg_instr_dec::instr_grp_1:
//			begin
//				$display( "Group 1\t\t%b %b %b", ig1d_outputs.opcode,
//					ig1d_outputs.ra_index, ig1d_outputs.imm_value_8 );
//			end
//			
//			pkg_instr_dec::instr_grp_2:
//			begin
//				$display( "Group 2\t\t%b %b %b\t\t%b %b", 
//					ig2d_outputs.opcode, ig2d_outputs.ra_index,
//					ig2d_outputs.rb_index,
//					ig2d_outputs.ra_index_is_for_pair,
//					ig2d_outputs.rb_index_is_for_pair );
//				
//				//if ( ig2d_outputs.opcode 
//				//	== pkg_instr_dec::instr_g2_op_invp )
//				//begin
//				//	$display("invp instruction encountered");
//				//end
//			end
//			
//			pkg_instr_dec::instr_grp_3:
//			begin
//				$display( "Group 3\t\t%b %b %b %b", ig3d_outputs.opcode,
//					ig3d_outputs.ra_index, ig3d_outputs.rbp_index,
//					ig3d_outputs.rcp_index );
//			end
//			
//			pkg_instr_dec::instr_grp_4:
//			begin
//				$display( "Group 4\t\t%b %b", ig4d_outputs.opcode,
//					ig4d_outputs.imm_value_8 );
//			end
//			
//			pkg_instr_dec::instr_grp_5:
//			begin
//				$display( "Group 5\t\t%b %h %h", ig5d_outputs.opcode,
//					ig5d_outputs.ra_index, ig5d_outputs.rbp_index );
//			end
//			
//			default:
//			begin
//				$display("Unknown instruction encoding");
//			end
//			
//		endcase
//	end
//	
//	end
//	
//	
//endmodule
//
//
//
//
//module instr_group_decoder_test_bench( input bit tb_clk, 
//	input bit reset );
//	
//	bit ready;
//	
//	import pkg_instr_dec::*;
//	
//	bit [`instr_main_msb_pos:0] test_instr_hi, test_instr_lo;
//	instr_group test_instr_group;
//	
//	instr_group_decoder instr_grp_dec( .instr_hi(test_instr_hi),
//		.group_out(test_instr_group) );
//	
//	// This is used instead of an initial block
//	always @ (reset)
//	begin
//		if (reset)
//		begin
//			ready = 1'b0;
//			test_instr_hi = `instr_main_width'h0000;
//			
//		end
//		
//		if ( ready == 1'b0 )
//		begin
//			#1
//			ready = 1'b1;
//			
//			
//			#2
//			test_instr_hi = { `instr_g1_id, 
//				pkg_instr_dec::instr_g1_op_addi, 4'b0111, 8'h33 };
//			
//			
//			#2
//			test_instr_hi = { `instr_g2_id, 
//				pkg_instr_dec::instr_g2_op_call, 4'd1, 4'd2 };
//			
//			
//			//#2
//			//test_instr_hi = { `instr_g3_id, pkg_instr_dec::instr_g3_op_
//			
//			#2
//			$finish;
//			
//		end
//	end
//	
//	
//	always @ ( posedge tb_clk )
//	begin
//	
//	if (ready)
//	begin
//		
//		$display( "%b %b %b %b\t\t%d", test_instr_hi[15:12], 
//			test_instr_hi[11:8], test_instr_hi[7:4], test_instr_hi[3:0], 
//			test_instr_group );
//		
//	end
//	
//	end
//	
//	
//endmodule
//
//
//
//module alu_test_bench( input bit tb_clk, input bit reset );
//	
//	bit ready;
//	
//	import pkg_alu::get_alu_oper_cat_tb;
//	import pkg_alu::*;
//	
//	bit dummy;
//	
//	// ALU inputs and outputs
//	alu_oper the_alu_op;
//	alu_oper_cat the_alu_op_cat;
//	bit [`alu_inout_msb_pos:0] alu_a_in_lo, alu_a_in_hi, alu_b_in;
//	bit [`proc_flags_msb_pos:0] alu_proc_flags_in;
//	bit [`alu_inout_msb_pos:0] alu_out_lo, alu_out_hi;
//	bit [`proc_flags_msb_pos:0] alu_proc_flags_out;
//	
//	alu test_alu( .oper(the_alu_op), 
//		.a_in_hi(alu_a_in_hi), .a_in_lo(alu_a_in_lo), .b_in(alu_b_in),
//		.proc_flags_in(alu_proc_flags_in), 
//		.out_lo(alu_out_lo), .out_hi(alu_out_hi),
//		.proc_flags_out(alu_proc_flags_out) );
//	
//	
//	// This is used instead of an initial block
//	always @ (reset)
//	begin
//	
//	if (reset)
//	begin
//		ready = 1'b0;
//		
//		dummy = 1'b0;
//		
//		//the_alu_op = pkg_alu::alu_op_add + 1;
//		//the_alu_op = pkg_alu::alu_op_add + pkg_alu::alu_op_add;
//		//the_alu_op = the_alu_op + 1;
//		//the_alu_op += 1;
//		
//		//// Arithmetic operations
//		//// Addition operations
//		the_alu_op = alu_op_add;
//		//the_alu_op = alu_op_adc;
//		//
//		//
//		//// Subtraction operations
//		//the_alu_op = alu_op_sub;
//		//the_alu_op = alu_op_sbc;
//		//the_alu_op = alu_op_cmp;
//		//
//		//// Bitwise operations
//		//
//		//// Operations analogous to logic gates (none of these affect
//		//// carry)
//		//the_alu_op = alu_op_and;
//		//the_alu_op = alu_op_orr;
//		//the_alu_op = alu_op_xor;
//		//
//		//// Complement operations
//		//the_alu_op = alu_op_inv;
//		//the_alu_op = alu_op_invp;
//		//the_alu_op = alu_op_neg;
//		//the_alu_op = alu_op_negp;
//		//
//		//
//		//// 8-bit Bitshifting operations (number of bits specified by
//		//// b_in)
//		//the_alu_op = alu_op_lsl;
//		//the_alu_op = alu_op_lsr;
//		//the_alu_op = alu_op_asr;
//		//
//		//// 8-bit Bit rotation operations (number of bits specified by
//		//// [b_in % inout_width])
//		//the_alu_op = alu_op_rol;
//		//the_alu_op = alu_op_ror;
//		//
//		//
//		//// Bit rotating instructions that use carry as bit 8 for a
//		//// 9-bit rotate of { carry, a_in_lo } by one bit:
//		//the_alu_op = alu_op_rolc;
//		//the_alu_op = alu_op_rorc;
//		//
//		//
//		//
//		//// 16-bit Bitshifting operations that shift 
//		//// { a_in_hi, a_in_lo } by b_in bits
//		//the_alu_op = alu_op_lslp;
//		//the_alu_op = alu_op_lsrp;
//		//the_alu_op = alu_op_asrp;
//		//
//		//
//		//// 16-bit Bit rotation operations that rotate 
//		//// { a_in_hi, a_in_lo } by [b_in % inout_width] bits
//		//the_alu_op = alu_op_rolp;
//		//the_alu_op = alu_op_rorp;
//		//
//		//
//		//// Bit rotating instructions that use carry as bit 16 for a
//		//// 17-bit rotate of { carry, a_in_hi, a_in_lo } by one bit:
//		//the_alu_op = alu_op_rolcp;
//		//the_alu_op = alu_op_rorcp;
//		
//		get_alu_oper_cat_tb( the_alu_op, the_alu_op_cat );
//		
//		{ alu_a_in_hi, alu_a_in_lo, alu_b_in } = { `alu_inout_width'h0,
//			`alu_inout_width'h0, `alu_inout_width'h0 };
//		alu_proc_flags_in = `proc_flags_width'h0;
//		
//		//$display(the_alu_op_cat);
//	end
//	
//	if ( ready == 1'b0 )
//	begin
//		#1
//		ready = 1'b1;
//	end
//	
//	end
//	
//	
//	always @ ( posedge tb_clk )
//	begin
//	
//	if (ready)
//	begin
//		
//		if ( the_alu_op_cat == alu_op_cat_8_no_ci )
//		begin
//			//$display( "%d %d\t\t%d %b", alu_a_in_lo, alu_b_in, 
//			//	alu_out_lo, alu_proc_flags_out );
//			//$display( "%h %h\t\t%h %b", alu_a_in_lo, alu_b_in, 
//			//	alu_out_lo, alu_proc_flags_out );
//			//$display( "%b %b\t\t%b %b", alu_a_in_lo, alu_b_in, 
//			//	alu_out_lo, alu_proc_flags_out );
//			$display( "%b %d\t\t%b %b", alu_a_in_lo, alu_b_in, 
//				alu_out_lo, alu_proc_flags_out );
//			//$display( "%b %d\t\t%b %b", alu_a_in_lo,
//			//	alu_b_in[ `alu_inout_width >> 2:0 ], alu_out_lo, 
//			//	alu_proc_flags_out );
//			
//			{ dummy, alu_a_in_lo, alu_b_in } = { dummy, alu_a_in_lo,
//				alu_b_in } + 1;
//			
//			//{ dummy, alu_a_in_lo, alu_b_in[ `alu_inout_width >> 2:0 ] }
//			//	= { dummy, alu_a_in_lo, 
//			//	alu_b_in[ `alu_inout_width >> 2:0 ] } + 1;
//		end
//		
//		else if ( the_alu_op_cat == alu_op_cat_8_ci )
//		begin
//			//$display( "%d %b %d\t\t%d %b", alu_a_in_lo,
//			//	alu_proc_flags_in[pkg_pflags::pf_slot_c], alu_b_in,
//			//	alu_out_lo, alu_proc_flags_out );
//			//$display( "%h %b %h\t\t%h %b", alu_a_in_lo,
//			//	alu_proc_flags_in[pkg_pflags::pf_slot_c], alu_b_in,
//			//	alu_out_lo, alu_proc_flags_out );
//			//$display( "%b %b %b\t\t%b %b", alu_a_in_lo,
//			//	alu_proc_flags_in[pkg_pflags::pf_slot_c], alu_b_in,
//			//	alu_out_lo, alu_proc_flags_out );
//			$display( "%b %b %d\t\t%b %b", alu_a_in_lo,
//				alu_proc_flags_in[pkg_pflags::pf_slot_c], alu_b_in,
//				alu_out_lo, alu_proc_flags_out );
//			//$display( "%b %b %d\t\t%b %b", alu_a_in_lo,
//			//	alu_proc_flags_in[pkg_pflags::pf_slot_c],
//			//	alu_b_in[ `alu_inout_and_carry_width >> 2:0 ], alu_out_lo, 
//			//	alu_proc_flags_out );
//			
//			{ dummy, alu_a_in_lo, alu_proc_flags_in[pkg_pflags::pf_slot_c],
//				alu_b_in }
//				= { dummy, alu_a_in_lo, 
//				alu_proc_flags_in[pkg_pflags::pf_slot_c], alu_b_in } + 1;
//			//{ dummy, alu_a_in_lo, 
//			//	alu_proc_flags_in[pkg_pflags::pf_slot_c], 
//			//	alu_b_in[ `alu_inout_and_carry_width >> 2:0 ] }
//			//	= { dummy, alu_a_in_lo, 
//			//	alu_proc_flags_in[pkg_pflags::pf_slot_c],
//			//	alu_b_in[ `alu_inout_and_carry_width >> 2:0 ] } + 1;
//		end
//		
//		else if ( the_alu_op_cat == alu_op_cat_16_no_ci )
//		begin
//			//$display( "%d %d\t\t%d %b", { alu_a_in_hi, alu_a_in_lo }, 
//			//	alu_b_in, { alu_out_hi, alu_out_lo }, alu_proc_flags_out );
//			//$display( "%h %h\t\t%h %b", { alu_a_in_hi, alu_a_in_lo }, 
//			//	alu_b_in, { alu_out_hi, alu_out_lo }, alu_proc_flags_out );
//			//$display( "%b %b\t\t%b %b", { alu_a_in_hi, alu_a_in_lo }, 
//			//	alu_b_in, { alu_out_hi, alu_out_lo }, alu_proc_flags_out );
//			$display( "%b %d\t\t%b %b", { alu_a_in_hi, alu_a_in_lo }, 
//				alu_b_in, { alu_out_hi, alu_out_lo }, alu_proc_flags_out );
//			
//			{ dummy, { alu_a_in_hi, alu_a_in_lo }, alu_b_in } = { dummy, 
//				{ alu_a_in_hi, alu_a_in_lo }, alu_b_in } + 1;
//		end
//		
//		else // if ( the_alu_op_cat == alu_op_cat_16_ci )
//		begin
//			//$display( "%d %b %d\t\t%d %b", { alu_a_in_hi, alu_a_in_lo },
//			//	alu_proc_flags_in[pkg_pflags::pf_slot_c], alu_b_in,
//			//	{ alu_out_hi, alu_out_lo }, alu_proc_flags_out );
//			//$display( "%h %b %h\t\t%h %b", { alu_a_in_hi, alu_a_in_lo },
//			//	alu_proc_flags_in[pkg_pflags::pf_slot_c], alu_b_in,
//			//	{ alu_out_hi, alu_out_lo }, alu_proc_flags_out );
//			//$display( "%b %b %b\t\t%b %b", { alu_a_in_hi, alu_a_in_lo },
//			//	alu_proc_flags_in[pkg_pflags::pf_slot_c], alu_b_in,
//			//	{ alu_out_hi, alu_out_lo }, alu_proc_flags_out );
//			//$display( "%b %b %d\t\t%b %b", { alu_a_in_hi, alu_a_in_lo },
//			//	alu_proc_flags_in[pkg_pflags::pf_slot_c], alu_b_in,
//			//	{ alu_out_hi, alu_out_lo }, alu_proc_flags_out );
//			$display( "%b %b\t\t%b %b", { alu_a_in_hi, alu_a_in_lo },
//				alu_proc_flags_in[pkg_pflags::pf_slot_c], 
//				{ alu_out_hi, alu_out_lo }, alu_proc_flags_out );
//			//$display( "%b %b %d\t\t%b %b", { alu_a_in_hi, alu_a_in_lo },
//			//	alu_proc_flags_in[pkg_pflags::pf_slot_c], 
//			//	alu_b_in[ `alu_inout_pair_and_carry_width >> 2:0 ],
//			//	{ alu_out_hi, alu_out_lo }, alu_proc_flags_out );
//			
//			//{ dummy, { alu_a_in_hi, alu_a_in_lo }, 
//			//	alu_proc_flags_in[pkg_pflags::pf_slot_c], alu_b_in }
//			//	= { dummy, { alu_a_in_hi, alu_a_in_lo }, 
//			//	alu_proc_flags_in[pkg_pflags::pf_slot_c], alu_b_in } + 1;
//			{ dummy, { alu_a_in_hi, alu_a_in_lo }, 
//				alu_proc_flags_in[pkg_pflags::pf_slot_c] }
//				= { dummy, { alu_a_in_hi, alu_a_in_lo }, 
//				alu_proc_flags_in[pkg_pflags::pf_slot_c] } + 1;
//			//{ dummy, { alu_a_in_hi, alu_a_in_lo }, 
//			//	alu_proc_flags_in[pkg_pflags::pf_slot_c], 
//			//	alu_b_in[ `alu_inout_pair_and_carry_width >> 2:0 ] }
//			//	= { dummy, { alu_a_in_hi, alu_a_in_lo }, 
//			//	alu_proc_flags_in[pkg_pflags::pf_slot_c], 
//			//	alu_b_in[ `alu_inout_pair_and_carry_width >> 2:0 ] } + 1;
//		end
//		
//		
//		if (dummy)
//		begin
//			$finish;
//		end
//		
//	end
//	
//	end
//	
//	
//endmodule
