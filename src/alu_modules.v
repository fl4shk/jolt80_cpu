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
	
	//reg [`const_alu_inout_msb_pos:0] temp_out;
	reg [`const_proc_flags_msb_pos:0] temp_proc_flags_out;
	
	reg do_not_change_z_flag;
	
	
	wire [`const_alu_inout_width:0] rotate_max_shift_thing;
	wire [`const_alu_inout_msb_pos:0] rotate_mod_thing;
	
	assign rotate_max_shift_thing = 1 << `const_alu_inout_width;
	assign rotate_mod_thing = ( `const_alu_inout_width'h1 
		<< `const_alu_inout_width ) - `const_alu_inout_width'h1;
	
	
	always @ ( oper, a_in, b_in, proc_flags_in )
	begin
		do_not_change_z_flag = 1'b0;
		
		// Arithmetic operations
		// Addition operations
		if ( oper == `enum_alu_oper_add )
		begin
			{ proc_flags_out[`enum_proc_flag_c], out } = a_in + b_in;
		end
		
		else if ( oper == `enum_alu_oper_adc )
		begin
			{ proc_flags_out[`enum_proc_flag_c], out } = a_in + b_in 
				+ proc_flags_in[`enum_proc_flag_c];
		end
		
		// Subtraction operations
		else if ( oper == `enum_alu_oper_sub )
		begin
			{ proc_flags_out[`enum_proc_flag_c], out } = a_in 
				+ (~b_in) + 1'b1;
		end
		
		else if ( oper == `enum_alu_oper_sbc )
		begin
			{ proc_flags_out[`enum_proc_flag_c], out } = a_in + (~b_in)
				+ proc_flags_in[`enum_proc_flag_c];
		end
		
		else if ( oper == `enum_alu_oper_cmp )
		begin
			{ proc_flags_out[`enum_proc_flag_c], out } = a_in + (~b_in)
				+ 1'b1;
		end
		
		// Bitwise operations
		// Operations analogous to logic gates (none of these affect
		// carry)
		else if ( oper == `enum_alu_oper_and )
		begin
			{ out, proc_flags_out[`enum_proc_flag_c] } 
				= { a_in & b_in, proc_flags_in[`enum_proc_flag_c] };
		end
		
		else if ( oper == `enum_alu_oper_orr )
		begin
			{ out, proc_flags_out[`enum_proc_flag_c] }
				= { a_in | b_in, proc_flags_in[`enum_proc_flag_c] };
		end
		
		else if ( oper == `enum_alu_oper_xor )
		begin
			{ out, proc_flags_out[`enum_proc_flag_c] }
				= { a_in ^ b_in, proc_flags_in[`enum_proc_flag_c] };
		end
		
		// Bitshifting operations (number of bits specified by b_in),
		// starting with 4'h8
		else if ( oper == `enum_alu_oper_lsl )
		begin
			if ( b_in == `const_alu_inout_width'h0 )
			begin
				{ proc_flags_out[`enum_proc_flag_c], 
					do_not_change_z_flag }
					= { proc_flags_in[`enum_proc_flag_c], 1'b1 };
			end
			
			else
			begin
				{ proc_flags_out[`enum_proc_flag_c], out } 
					= { 1'b0, a_in } << b_in;
			end
		end
		
		else if ( oper == `enum_alu_oper_lsr )
		begin
			if ( b_in == `const_alu_inout_width'h0 )
			begin
				{ proc_flags_out[`enum_proc_flag_c], 
					do_not_change_z_flag } 
					= { proc_flags_in[`enum_proc_flag_c], 1'b1 };
			end
			
			else
			begin
				{ out, proc_flags_out[`enum_proc_flag_c] } 
					= { a_in, 1'b0 } >> b_in;
			end
		end
		
		else if ( oper == `enum_alu_oper_asr )
		begin
			if ( b_in == `const_alu_inout_width'h0 )
			begin
				{ proc_flags_out[`enum_proc_flag_c],
					do_not_change_z_flag }
					= { proc_flags_in[`enum_proc_flag_c], 1'b1 };
			end
			
			else
			begin
				{ out, proc_flags_out[`enum_proc_flag_c] }
					= $signed({ a_in, 1'b0 }) >>> b_in;
			end
		end
		
		else if ( oper == `enum_alu_oper_rol )
		begin
			if ( b_in == `const_alu_inout_width'h0 )
			begin
				{ proc_flags_out[`enum_proc_flag_c],
					do_not_change_z_flag }
					= { proc_flags_in[`enum_proc_flag_c], 1'b1 };
			end
			
			else
			begin
				//out = a_in;
			end
		end
		
		else if ( oper == `enum_alu_oper_ror )
		begin
			if ( b_in == `const_alu_inout_width'h0 )
			begin
				{ proc_flags_out[`enum_proc_flag_c],
					do_not_change_z_flag }
					= { proc_flags_in[`enum_proc_flag_c], 1'b1 };
			end
			
			else
			begin
				out = a_in;
			end
		end
		
		else
		begin
			out = a_in;
		end
		
		
		if (!do_not_change_z_flag)
		begin
			proc_flags_out[`enum_proc_flag_z] 
				= ( out == `const_alu_inout_width'h0 );
		end
		
		else
		begin
			proc_flags_out[`enum_proc_flag_z] 
				= proc_flags_in[`enum_proc_flag_z];
		end
	end
	
	
endmodule
