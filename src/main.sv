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


module alu_test_bench;
	
	logic master_clk, ready;
	
	logic dummy;
	
	// ALU inputs and outputs
	pkg_alu::alu_op the_alu_op;
	logic [`alu_inout_msb_pos:0] alu_a_in, alu_b_in;
	logic [`proc_flags_msb_pos:0] alu_proc_flags_in;
	logic [`alu_inout_msb_pos:0] alu_out;
	logic [`proc_flags_msb_pos:0] alu_proc_flags_out;
	
	alu test_alu( .oper(the_alu_op), .a_in(alu_a_in), .b_in(alu_b_in),
		.proc_flags_in(alu_proc_flags_in), .out(alu_out),
		.proc_flags_out(alu_proc_flags_out) );
	
	logic alu_op_type;
	assign alu_op_type = ( ( the_alu_op == pkg_alu::alu_op_adc )
		|| ( the_alu_op == pkg_alu::alu_op_sbc )
		|| ( the_alu_op == pkg_alu::alu_op_rolc )
		|| ( the_alu_op == pkg_alu::alu_op_rorc ) );
	
	initial
	begin
		the_alu_op = `alu_op_width'h0;
		
		master_clk = 1'b0;
		ready = 1'b0;
		dummy = 1'b0;
		
		//the_alu_op = pkg_alu::alu_op_add;
		//the_alu_op = pkg_alu::alu_op_adc;
		//the_alu_op = pkg_alu::alu_op_sub;
		//the_alu_op = pkg_alu::alu_op_sbc;
		//the_alu_op = pkg_alu::alu_op_cmp;
		
		//the_alu_op = pkg_alu::alu_op_and;
		//the_alu_op = pkg_alu::alu_op_orr;
		//the_alu_op = pkg_alu::alu_op_xor;
		//the_alu_op = pkg_alu::alu_op_lsl;
		//the_alu_op = pkg_alu::alu_op_lsr;
		//the_alu_op = pkg_alu::alu_op_asr;
		//the_alu_op = pkg_alu::alu_op_rol;
		//the_alu_op = pkg_alu::alu_op_ror;
		the_alu_op = pkg_alu::alu_op_rolc;
		//the_alu_op = pkg_alu::alu_op_rorc;
		
		
		{ alu_a_in, alu_b_in } = { `alu_inout_width'h0,
			`alu_inout_width'h0 };
		alu_proc_flags_in = `proc_flags_width'h0;
		
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
		if (!alu_op_type)
		begin
			//$display( "%d %d\t\t%d %b", alu_a_in, alu_b_in, alu_out,
			//	alu_proc_flags_out );
			//$display( "%h %h\t\t%h %b", alu_a_in, alu_b_in, alu_out,
			//	alu_proc_flags_out );
			//$display( "%b %b\t\t%b %b", alu_a_in, alu_b_in, alu_out,
			//	alu_proc_flags_out );
			$display( "%b %d\t\t%b %b", alu_a_in, alu_b_in[1:0], alu_out,
				alu_proc_flags_out );
			//{ dummy, alu_a_in, alu_b_in } = { dummy, alu_a_in, alu_b_in } 
			//	+ 1;
			{ dummy, alu_a_in, alu_b_in[1:0] } 
				= { dummy, alu_a_in, alu_b_in[1:0] } + 1;
		end
		
		else // if (alu_op_type)
		begin
			//$display( "%d %b %d\t\t%d %b", alu_a_in, 
			//	alu_proc_flags_in[pkg_pflags::pf_slot_c], alu_b_in,
			//	alu_out, alu_proc_flags_out );
			//$display( "%h %b %d\t\t%h %b", alu_a_in, 
			//	alu_proc_flags_in[pkg_pflags::pf_slot_c], alu_b_in,
			//	alu_out, alu_proc_flags_out );
			//$display( "%b %b %d\t\t%b %b", alu_a_in, 
			//	alu_proc_flags_in[pkg_pflags::pf_slot_c], alu_b_in,
			//	alu_out, alu_proc_flags_out );
			$display( "%b %b %d\t\t%b %b", alu_a_in, 
				alu_proc_flags_in[pkg_pflags::pf_slot_c], alu_b_in[1:0],
				alu_out, alu_proc_flags_out );
			
			//{ dummy, alu_a_in, alu_b_in, 
			//	alu_proc_flags_in[pkg_pflags::pf_slot_c] } 
			//	= { dummy, alu_a_in, 
			//	alu_proc_flags_in[pkg_pflags::pf_slot_c], alu_b_in } + 1;
			{ dummy, alu_a_in, alu_proc_flags_in[pkg_pflags::pf_slot_c], 
				alu_b_in[1:0] }
				= { dummy, alu_a_in, 
				alu_proc_flags_in[pkg_pflags::pf_slot_c], alu_b_in[1:0] } 
				+ 1;
		end
		
		if (dummy)
		begin
			$finish;
		end
	end
	
endmodule

