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


//module alu( input logic [`alu_op_msb_pos:0] oper,
module alu( input pkg_alu::alu_op oper,
	input logic [`alu_inout_msb_pos:0] a_in, b_in,
	input logic [`proc_flags_msb_pos:0] proc_flags_in,
	output logic [`alu_inout_msb_pos:0] out,
	output logic [`proc_flags_msb_pos:0] proc_flags_out );
	
	
	logic do_not_change_z_flag;
	
	
	logic [`alu_inout_msb_pos:0] rotate_no_carry_mod_thing;
	logic [`alu_inout_width:0] rotate_with_carry_mod_thing;
	logic [`alu_inout_width + `alu_inout_width - 1:0]
		rotate_no_carry_temp;
	logic [`alu_inout_width + `alu_inout_width + 1:0]
		rolc_temp, rorc_temp;
	
	
	assign rotate_no_carry_mod_thing = ( `alu_inout_width'h1 
		<< `alu_inout_width ) - `alu_inout_width'h1;
	assign rotate_with_carry_mod_thing = ( 1 
		<< `alu_inout_and_carry_width ) - 1;
	
	assign rotate_no_carry_temp = { a_in, a_in };
	
	//assign rolc_temp = { a_in, proc_flags_in[pkg_pflags::pf_slot_c], 
	//	a_in, proc_flags_in[pkg_pflags::pf_slot_c] };
	assign rolc_temp = { a_in, proc_flags_in[pkg_pflags::pf_slot_c], a_in,
		proc_flags_in[pkg_pflags::pf_slot_c] };
	assign rorc_temp = { proc_flags_in[pkg_pflags::pf_slot_c], a_in,
		proc_flags_in[pkg_pflags::pf_slot_c], a_in };
	
	always @ ( oper, a_in, b_in, proc_flags_in )
	begin
		do_not_change_z_flag = 1'b0;
		
		case (oper)
		// Arithmetic operations
			// Addition operations, starting with 4'h0
			pkg_alu::alu_op_add:
			begin
				{ proc_flags_out[pkg_pflags::pf_slot_c], out } = a_in 
					+ b_in;
			end
			
			pkg_alu::alu_op_adc:
			begin
				{ proc_flags_out[pkg_pflags::pf_slot_c], out } = a_in 
					+ b_in + proc_flags_in[pkg_pflags::pf_slot_c];
			end
			
			// Subtraction operations, starting with 4'h2
			pkg_alu::alu_op_sub:
			begin
				{ proc_flags_out[pkg_pflags::pf_slot_c], out } = a_in 
					+ (~b_in) + 1'b1;
			end
			
			pkg_alu::alu_op_sbc:
			begin
				{ proc_flags_out[pkg_pflags::pf_slot_c], out } = a_in 
					+ (~b_in) + proc_flags_in[pkg_pflags::pf_slot_c];
			end
			
			pkg_alu::alu_op_cmp:
			begin
				{ proc_flags_out[pkg_pflags::pf_slot_c], out } = a_in 
					+ (~b_in) + 1'b1;
			end
			
		// Bitwise operations
			// Operations analogous to logic gates (none of these affect
			// carry), starting with 4'h5
			pkg_alu::alu_op_and:
			begin
				{ out, proc_flags_out[pkg_pflags::pf_slot_c] } 
					= { a_in & b_in, 
					proc_flags_in[pkg_pflags::pf_slot_c] };
			end
			
			pkg_alu::alu_op_orr:
			begin
				{ out, proc_flags_out[pkg_pflags::pf_slot_c] } 
					= { a_in | b_in, proc_flags_in[pkg_pflags::pf_slot_c] };
			end
			
			pkg_alu::alu_op_xor:
			begin
				{ out, proc_flags_out[pkg_pflags::pf_slot_c] } 
					= { a_in ^ b_in, 
					proc_flags_in[pkg_pflags::pf_slot_c] };
			end
			
			// Bitshifting operations (number of bits specified by b_in),
			// starting with 4'h8
			pkg_alu::alu_op_lsl:
			begin
				if ( b_in == `alu_inout_width'h0 )
				begin
					// Don't change ANYTHING
					{ proc_flags_out[pkg_pflags::pf_slot_c], 
						do_not_change_z_flag, out } 
						= { proc_flags_in[pkg_pflags::pf_slot_c], 1'b1, 
						a_in };
				end
				
				else
				begin
					{ proc_flags_out[pkg_pflags::pf_slot_c], out } 
						= { 1'b0, a_in } << b_in;
				end
			end
			
			pkg_alu::alu_op_lsr:
			begin
				if ( b_in == `alu_inout_width'h0 )
				begin
					// Don't change ANYTHING
					{ proc_flags_out[pkg_pflags::pf_slot_c], 
						do_not_change_z_flag, out } 
						= { proc_flags_in[pkg_pflags::pf_slot_c], 1'b1, 
						a_in };
				end
				
				else
				begin
					{ out, proc_flags_out[pkg_pflags::pf_slot_c] } 
						= { a_in, 1'b0 } >> b_in;
				end
			end
			
			pkg_alu::alu_op_asr:
			begin
				if ( b_in == `alu_inout_width'h0 )
				begin
					// Don't change ANYTHING
					{ proc_flags_out[pkg_pflags::pf_slot_c], 
						do_not_change_z_flag, out } 
						= { proc_flags_in[pkg_pflags::pf_slot_c], 1'b1, 
						a_in };
				end
				
				else
				begin
					{ out, proc_flags_out[pkg_pflags::pf_slot_c] } 
						= $signed({ a_in, 1'b0 }) >>> b_in;
				end
			end
			
			// Bit rotation operations (number of bits specified by [b_in %
			// inout_width]), starting with 4'ha
			pkg_alu::alu_op_rol:
			begin
				if ( b_in == `alu_inout_width'h0 )
				begin
					// Don't change ANYTHING
					{ proc_flags_out[pkg_pflags::pf_slot_c], 
						do_not_change_z_flag, out } 
						= { proc_flags_in[pkg_pflags::pf_slot_c], 1'b1, 
						a_in };
				end
				
				else
				begin
					// Don't change carry
					{ out, proc_flags_out[pkg_pflags::pf_slot_c] } 
						= { rotate_no_carry_temp[ ( `alu_inout_width 
						- ( b_in & rotate_no_carry_mod_thing ) ) 
						+: `alu_inout_width ],
						proc_flags_in[pkg_pflags::pf_slot_c] };
				end
			end
			
			pkg_alu::alu_op_ror:
			begin
				if ( b_in == `alu_inout_width'h0 )
				begin
					// Don't change ANYTHING
					{ proc_flags_out[pkg_pflags::pf_slot_c], 
						do_not_change_z_flag, out } 
						= { proc_flags_in[pkg_pflags::pf_slot_c], 1'b1, 
						a_in };
				end
				
				else
				begin
					// Don't change carry
					{ out, proc_flags_out[pkg_pflags::pf_slot_c] }
						= { rotate_no_carry_temp[ ( b_in 
						& rotate_no_carry_mod_thing ) 
						+: `alu_inout_width ],
						proc_flags_in[pkg_pflags::pf_slot_c] };
				end
			end
			
			pkg_alu::alu_op_rolc:
			begin
				if ( b_in == `alu_inout_width'h0 )
				begin
					// Don't change ANYTHING
					{ proc_flags_out[pkg_pflags::pf_slot_c], 
						do_not_change_z_flag, out } 
						= { proc_flags_in[pkg_pflags::pf_slot_c], 1'b1, 
						a_in };
				end
				
				else
				begin
					//{ out } 
					//	= { rotate_no_carry_temp[ ( `alu_inout_width 
					//	- ( b_in & rotate_no_carry_mod_thing ) ) 
					//	+: `alu_inout_width ] };
					{ proc_flags_out[pkg_pflags::pf_slot_c], out }
						= rolc_temp[ ( `alu_inout_and_carry_width 
						- ( b_in & rotate_with_carry_mod_thing ) )
						+: `alu_inout_and_carry_width ];
				end
			end
			
			pkg_alu::alu_op_rorc:
			begin
				if ( b_in == `alu_inout_width'h0 )
				begin
					// Don't change ANYTHING
					{ proc_flags_out[pkg_pflags::pf_slot_c], 
						do_not_change_z_flag, out } 
						= { proc_flags_in[pkg_pflags::pf_slot_c], 1'b1, 
						a_in };
				end
				
				else
				begin
					//{ out }
					//	= { rotate_no_carry_temp[ ( b_in 
					//	& rotate_no_carry_mod_thing ) 
					//	+: `alu_inout_width + 1 ] };
					{ proc_flags_out[pkg_pflags::pf_slot_c], out }
						= rorc_temp[ ( b_in & rotate_with_carry_mod_thing )
						+: `alu_inout_and_carry_width + 1 ];
				end
			end
			
			default:
			begin
				// Don't change ANYTHING
				{ proc_flags_out[pkg_pflags::pf_slot_c], 
					do_not_change_z_flag, out } 
					= { proc_flags_in[pkg_pflags::pf_slot_c], 1'b1, a_in };
			end
		
		endcase
		
		
		if (!do_not_change_z_flag)
		begin
			proc_flags_out[pkg_pflags::pf_slot_z] = ( out 
				== `alu_inout_width'h0 );
		end
		
		else // if (do_not_change_z_flag)
		begin
			proc_flags_out[pkg_pflags::pf_slot_z] 
				= proc_flags_in[pkg_pflags::pf_slot_z];
		end
	end
	
	
endmodule


