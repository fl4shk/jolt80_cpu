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


`include "src/alu_defines.vinc"
`include "src/proc_flags_defines.vinc"

////initial
////begin
////	//$display(`__LINE__);
////end

module alu_test_bench;
	reg master_clk;
	
	reg dummy;
	// ALU inputs and outputs
	reg [`const_alu_oper_msb_pos:0] alu_oper;
	reg [`const_alu_inout_msb_pos:0] alu_a_in, alu_b_in;
	reg [`const_proc_flags_msb_pos:0] alu_proc_flags_in;
	wire [`const_alu_inout_msb_pos:0] alu_out;
	wire [`const_proc_flags_msb_pos:0] alu_proc_flags_out;
	
	alu test_alu( .oper(alu_oper), .a_in(alu_a_in), .b_in(alu_b_in),
		.proc_flags_in(alu_proc_flags_in), .out(alu_out),
		.proc_flags_out(alu_proc_flags_out) );
	
	
	initial
	begin
		master_clk = 1'b0;
		dummy = 1'b0;
		
		//alu_oper = `enum_alu_oper_add;
		//alu_oper = `enum_alu_oper_adc;
		//alu_oper = `enum_alu_oper_sub;
		//alu_oper = `enum_alu_oper_sbc;
		//alu_oper = `enum_alu_oper_cmp;
		
		//alu_oper = `enum_alu_oper_and;
		//alu_oper = `enum_alu_oper_or;
		//alu_oper = `enum_alu_oper_xor;
		//alu_oper = `enum_alu_oper_lsl;
		//alu_oper = `enum_alu_oper_lsr;
		
		{ alu_a_in, alu_b_in } = { `const_alu_inout_width'h0,
			`const_alu_inout_width'h0 };
		alu_proc_flags_in = `const_proc_flags_width'h0;
	end
	
	// Clock generation
	always
	begin
		#1
		master_clk <= !master_clk;
	end
	
	always @ ( posedge master_clk )
	begin
		//{ dummy, alu_a_in, alu_b_in } <= { dummy, alu_a_in, alu_b_in } + 1;
		//$display( "%h %h\t\t%h %b", alu_a_in, alu_b_in, alu_out,
		//	alu_proc_flags_out );
		
		
		//{ dummy, alu_a_in, alu_b_in, alu_proc_flags_in[`enum_proc_flag_c] } 
		//	<= { dummy, alu_a_in, alu_b_in, 
		//	alu_proc_flags_in[`enum_proc_flag_c] } + 1;
		//$display( "%d %d %b\t\t%d %b", alu_a_in, alu_b_in,
		//	alu_proc_flags_in[`enum_proc_flag_c], alu_out, 
		//	alu_proc_flags_out );
		
		
		{ dummy, alu_a_in } <= { dummy, alu_a_in } + 1;
		$display( "%h\t\t%h %b", alu_a_in, alu_out, alu_proc_flags_out );
		
		
		if (dummy)
		begin
			$finish;
		end
	end
	
endmodule

