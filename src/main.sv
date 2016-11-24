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
`include "src/proc_flags_defines.svinc"

//typedef enum logic
//{
//	temp_0,
//	temp_1
//} temp_enum;



module alu_test_bench;
	
	import pkg_alu::get_alu_oper_cat;
	
	logic master_clk, ready;
	
	logic dummy;
	
	// ALU inputs and outputs
	pkg_alu::alu_oper the_alu_op;
	pkg_alu::alu_oper_cat the_alu_op_cat;
	logic [`alu_inout_msb_pos:0] alu_a_in_lo, alu_a_in_hi, alu_b_in;
	logic [`proc_flags_msb_pos:0] alu_proc_flags_in;
	logic [`alu_inout_msb_pos:0] alu_out_lo, alu_out_hi;
	logic [`proc_flags_msb_pos:0] alu_proc_flags_out;
	
	alu test_alu( .oper(the_alu_op), 
		.a_in_lo(alu_a_in_lo), .a_in_hi(alu_a_in_hi), .b_in(alu_b_in),
		.proc_flags_in(alu_proc_flags_in), 
		.out_lo(alu_out_lo), .out_hi(alu_out_hi),
		.proc_flags_out(alu_proc_flags_out) );
	
	
	
	
	initial
	begin
		master_clk = 1'b0;
		ready = 1'b0;
		dummy = 1'b0;
		
		//the_alu_op = pkg_alu::alu_op_add + 1;
		//the_alu_op = pkg_alu::alu_op_add + pkg_alu::alu_op_add;
		//the_alu_op = the_alu_op + 1;
		//the_alu_op += 1;
		
		//// Arithmetic operations
		//// Addition operations
		//the_alu_op = alu_op_add;
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
		//// Operations analogous to logic gates (none of these affect carry)
		//the_alu_op = alu_op_and;
		//the_alu_op = alu_op_orr;
		//the_alu_op = alu_op_xor;
		//
		//// Complement operations
		//the_alu_op = alu_op_inv;
		//the_alu_op = alu_op_invp;
		the_alu_op = alu_op_neg;
		//the_alu_op = alu_op_negp;
		//
		//
		//// 8-bit Bitshifting operations (number of bits specified by b_in)
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
		//// 8-bit Bit rotating operations (with carry as bit 8 or bit 0)
		//// that rotate by [b_in % inout_width] bits
		//the_alu_op = alu_op_rolc;
		//the_alu_op = alu_op_rorc;
		//
		//
		//
		//// 16-bit Bitshifting operations that shift { a_in_hi, a_in_lo }
		//// by b_in bits
		//the_alu_op = alu_op_lslp;
		//the_alu_op = alu_op_lsrp;
		//the_alu_op = alu_op_asrp;
		//
		//
		//// 16-bit Bit rotation operations that rotate { a_in_hi, a_in_lo }
		//// by [b_in % inout_width] bits
		//the_alu_op = alu_op_rolp;
		//the_alu_op = alu_op_rorp;
		//
		//
		//// 16-bit Bit rotating operations that rotate { a_in_hi, a_in_lo }
		//// (with carry as bit 16 or bit 0) by [b_in % inout_width] bits
		//the_alu_op = alu_op_rolcp;
		//the_alu_op = alu_op_rorcp;
		
		get_alu_oper_cat( the_alu_op, the_alu_op_cat );
		
		{ alu_a_in_hi, alu_a_in_lo, alu_b_in } = { `alu_inout_width'h0,
			`alu_inout_width'h0, `alu_inout_width'h0 };
		alu_proc_flags_in = `proc_flags_width'h0;
		
		//$display(the_alu_op_cat);
		
		#1
		ready = 1'b1;
	end
	
	// Clock generation
	always
	begin
		#1
		
		if (ready)
		begin
			master_clk = !master_clk;
		end
	end
	
	always @ ( posedge master_clk )
	begin
		
		if ( the_alu_op_cat == alu_op_cat_8_no_ci )
		begin
			//$display( "%d %d\t\t%d %b", alu_a_in_lo, alu_b_in, alu_out_lo, 
			//	alu_proc_flags_out );
			//$display( "%h %h\t\t%h %b", alu_a_in_lo, alu_b_in, alu_out_lo, 
			//	alu_proc_flags_out );
			$display( "%b %b\t\t%b %b", alu_a_in_lo, alu_b_in, alu_out_lo, 
				alu_proc_flags_out );
			
			{ dummy, alu_a_in_lo, alu_b_in } = { dummy, alu_a_in_lo,
				alu_b_in } + 1;
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
				alu_proc_flags_in[pkg_pflags::pf_slot_c],
				alu_b_in[`alu_inout_width/2:0], alu_out_lo, 
				alu_proc_flags_out );
			
			//{ dummy, alu_a_in_lo, alu_b_in,
			//	alu_proc_flags_in[pkg_pflags::pf_slot_c] }
			//	= { dummy, alu_a_in_lo, alu_b_in,
			//	alu_proc_flags_in[pkg_pflags::pf_slot_c] } + 1;
			{ dummy, alu_a_in_lo, 
				alu_proc_flags_in[pkg_pflags::pf_slot_c], 
				alu_b_in[`alu_inout_width/2:0] }
				= { dummy, alu_a_in_lo, 
				alu_proc_flags_in[pkg_pflags::pf_slot_c],
				alu_b_in[`alu_inout_width/2:0] } + 1;
		end
		
		else if ( the_alu_op_cat == alu_op_cat_16_no_ci )
		begin
			//$display( "%d %d\t\t%d %b", { alu_a_in_hi, alu_a_in_lo }, 
			//	alu_b_in, { alu_out_hi, alu_out_lo }, alu_proc_flags_out );
			//$display( "%h %h\t\t%h %b", { alu_a_in_hi, alu_a_in_lo }, 
			//	alu_b_in, { alu_out_hi, alu_out_lo }, alu_proc_flags_out );
			$display( "%b %b\t\t%b %b", { alu_a_in_hi, alu_a_in_lo }, 
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
			$display( "%b %b %d\t\t%b %b", { alu_a_in_hi, alu_a_in_lo },
				alu_proc_flags_in[pkg_pflags::pf_slot_c], alu_b_in[1:0],
				{ alu_out_hi, alu_out_lo }, alu_proc_flags_out );
			
			//{ dummy, { alu_a_in_hi, alu_a_in_lo }, alu_b_in,
			//	alu_proc_flags_in[pkg_pflags::pf_slot_c] }
			//	= { dummy, { alu_a_in_hi, alu_a_in_lo }, alu_b_in,
			//	alu_proc_flags_in[pkg_pflags::pf_slot_c] } + 1;
			{ dummy, { alu_a_in_hi, alu_a_in_lo }, 
				alu_proc_flags_in[pkg_pflags::pf_slot_c], alu_b_in[3:0] }
				= { dummy, { alu_a_in_hi, alu_a_in_lo }, 
				alu_proc_flags_in[pkg_pflags::pf_slot_c], alu_b_in[3:0] } 
				+ 1;
		end
		
		
		if (dummy)
		begin
			$finish;
		end
	end
	
endmodule

