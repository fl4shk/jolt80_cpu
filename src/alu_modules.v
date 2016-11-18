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


module alu( input wire [`const_alu_oper_msb_pos:0] oper,
	input wire [`const_alu_inout_msb_pos:0] a_in, b_in,
	input wire [`const_proc_flags_msb_pos:0] proc_flags_in,
	output reg [`const_alu_inout_msb_pos:0] out,
	output reg [`const_proc_flags_msb_pos:0] proc_flags_out );
	
	reg [`const_alu_inout_msb_pos:0] temp_out;
	reg [`const_proc_flags_msb_pos:0] temp_proc_flags_out;
	
	always @ ( a_in, b_in, proc_flags_in )
	begin
		case (oper)
		// Arithmetic operations
			// Addition operations
			`enum_alu_oper_add:
			begin
				{ proc_flags_out[`enum_proc_flag_c], out } = a_in + b_in;
				temp_out = out;
			end
			
			`enum_alu_oper_adc:
			begin
				{ proc_flags_out[`enum_proc_flag_c], out } = a_in + b_in 
					+ proc_flags_in[`enum_proc_flag_c];
				temp_out = out;
			end
			
			// Subtraction operations
			`enum_alu_oper_sub:
			begin
				{ proc_flags_out[`enum_proc_flag_c], out } = a_in 
					+ (~b_in) + 1'b1;
				temp_out = out;
			end
			
			`enum_alu_oper_sbc:
			begin
				{ proc_flags_out[`enum_proc_flag_c], out } = a_in + (~b_in)
					+ proc_flags_in[`enum_proc_flag_c];
				temp_out = out;
			end
			
			`enum_alu_oper_cmp:
			begin
				{ proc_flags_out[`enum_proc_flag_c], temp_out } = a_in 
					+ (~b_in) + 1'b1;
				out = `const_alu_inout_width'hx;
			end
		
		// Bitwise operations
			// Operations analogous to logic gates (none of these affect
			// carry)
			`enum_alu_oper_and:
			begin
				out = a_in & b_in;
				{ temp_out, proc_flags_out[`enum_proc_flag_c] } = { out,
					proc_flags_in[`enum_proc_flag_c] };
			end
			
			`enum_alu_oper_or:
			begin
				out = a_in | b_in;
				{ temp_out, proc_flags_out[`enum_proc_flag_c] } = { out,
					proc_flags_in[`enum_proc_flag_c] };
			end
			
			`enum_alu_oper_xor:
			begin
				out = a_in ^ b_in;
				{ temp_out, proc_flags_out[`enum_proc_flag_c] } = { out,
					proc_flags_in[`enum_proc_flag_c] };
			end
			
			// Bitshifting operations (one bit at a time), starting with
			// 4'h8
			`enum_alu_oper_lsl:
			begin
				{ proc_flags_out[`enum_proc_flag_c], out } = { 1'b0, a_in } 
					<< 1'b1;
				temp_out = out;
			end
			
			`enum_alu_oper_lsr:
			begin
				{ out, proc_flags_out[`enum_proc_flag_c] }
					= { a_in, 1'b0 } >> 1'b1;
				temp_out = out;
			end
		
		endcase
		
		proc_flags_out[`enum_proc_flag_z] 
			= ( temp_out == `const_alu_inout_width'h0 );
	end
	
	
endmodule
