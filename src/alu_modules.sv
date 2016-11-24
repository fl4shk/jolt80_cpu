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
module alu( input pkg_alu::alu_oper oper,
	input logic [`alu_inout_msb_pos:0] a_in_lo, a_in_hi, b_in,
	input logic [`proc_flags_msb_pos:0] proc_flags_in,
	output logic [`alu_inout_msb_pos:0] out_lo, out_hi,
	output logic [`proc_flags_msb_pos:0] proc_flags_out );
	
	
	import pkg_alu::alu_oper_cat;
	alu_oper_cat oper_cat;
	
	logic do_not_change_z_flag;
	
	import pkg_alu::get_alu_oper_cat;
	
	
	// 8-bit bit rotation stuff
	logic [`alu_inout_msb_pos:0] rot_mod_thing;
	logic [`alu_inout_width:0] rot_c_mod_thing;
	logic [ `alu_inout_width + `alu_inout_width - 1:0 ] rot_temp;
	logic [ `alu_inout_width + `alu_inout_width + 1:0 ] rot_c_temp;
	
	
	assign rot_mod_thing = ( 1 << `alu_inout_width ) - 1;
	assign rot_c_mod_thing = ( 1 << `alu_inout_and_carry_width ) - 1;
	
	assign rot_temp = { a_in_lo, a_in_lo };
	assign rot_c_temp = { proc_flags_in[pkg_pflags::pf_slot_c], a_in_lo,
		proc_flags_in[pkg_pflags::pf_slot_c], a_in_lo };
	
	
	// 16-bit bit rotation stuff
	logic [`alu_inout_pair_msb_pos:0] rot_p_mod_thing;
	logic [`alu_inout_pair_width:0] rot_p_c_mod_thing;
	logic [ `alu_inout_pair_width + `alu_inout_pair_width - 1:0 ]
		rot_p_temp;
	logic [ `alu_inout_pair_width + `alu_inout_pair_width + 1:0 ]
		rot_p_c_temp;
	
	assign rot_p_mod_thing = ( 1 << `alu_inout_pair_width ) - 1;
	assign rot_p_c_mod_thing = ( 1 << `alu_inout_pair_and_carry_width ) 
		- 1;
	
	assign rot_p_temp = { { a_in_hi, a_in_lo }, { a_in_hi, a_in_lo } };
	assign rot_p_c_temp = { proc_flags_in[pkg_pflags::pf_slot_c], 
		{ a_in_hi, a_in_lo }, proc_flags_in[pkg_pflags::pf_slot_c], 
		{ a_in_hi, a_in_lo } };
	
	
	
	always @ ( oper, a_in_lo, b_in, proc_flags_in )
	begin
		get_alu_oper_cat( oper, oper_cat );
		
		do_not_change_z_flag = 1'b0;
		
		case (oper)
		// Arithmetic operations
			// Addition operations
			pkg_alu::alu_op_add:
			begin
				{ proc_flags_out[pkg_pflags::pf_slot_c], out_lo } = a_in_lo 
					+ b_in;
			end
			
			pkg_alu::alu_op_adc:
			begin
				{ proc_flags_out[pkg_pflags::pf_slot_c], out_lo } = a_in_lo 
					+ b_in + proc_flags_in[pkg_pflags::pf_slot_c];
			end
			
			// Subtraction operations
			pkg_alu::alu_op_sub:
			begin
				{ proc_flags_out[pkg_pflags::pf_slot_c], out_lo } = a_in_lo 
					+ (~b_in) + 1'b1;
			end
			
			pkg_alu::alu_op_sbc:
			begin
				{ proc_flags_out[pkg_pflags::pf_slot_c], out_lo } = a_in_lo 
					+ (~b_in) + proc_flags_in[pkg_pflags::pf_slot_c];
			end
			
			pkg_alu::alu_op_cmp:
			begin
				{ proc_flags_out[pkg_pflags::pf_slot_c], out_lo } = a_in_lo 
					+ (~b_in) + 1'b1;
			end
			
		// Bitwise operations
			// Operations analogous to logic gates (none of these affect
			// carry)
			pkg_alu::alu_op_and:
			begin
				{ out_lo, proc_flags_out[pkg_pflags::pf_slot_c] } 
					= { a_in_lo & b_in, 
					proc_flags_in[pkg_pflags::pf_slot_c] };
			end
			
			pkg_alu::alu_op_orr:
			begin
				{ out_lo, proc_flags_out[pkg_pflags::pf_slot_c] } 
					= { a_in_lo | b_in, 
					proc_flags_in[pkg_pflags::pf_slot_c] };
			end
			
			pkg_alu::alu_op_xor:
			begin
				{ out_lo, proc_flags_out[pkg_pflags::pf_slot_c] } 
					= { a_in_lo ^ b_in, 
					proc_flags_in[pkg_pflags::pf_slot_c] };
			end
			
			// Complement operations
			pkg_alu::alu_op_inv:
			begin
				{ out_lo, proc_flags_out[pkg_pflags::pf_slot_c] }
					= { ~a_in_lo, proc_flags_in[pkg_pflags::pf_slot_c] };
			end
			
			pkg_alu::alu_op_invp:
			begin
				{ { out_hi, out_lo }, 
					proc_flags_out[pkg_pflags::pf_slot_c] }
					= { ~{ a_in_hi, a_in_lo }, 
					proc_flags_in[pkg_pflags::pf_slot_c] };
			end
			
			pkg_alu::alu_op_neg:
			begin
				{ out_lo, proc_flags_out[pkg_pflags::pf_slot_c] }
					= { -a_in_lo, proc_flags_in[pkg_pflags::pf_slot_c] };
			end
			
			pkg_alu::alu_op_negp:
			begin
				{ { out_hi, out_lo }, 
					proc_flags_out[pkg_pflags::pf_slot_c] }
					= { -{ a_in_hi, a_in_lo }, 
					proc_flags_in[pkg_pflags::pf_slot_c] };
			end
			
			// 8-bit Bitshifting operations (number of bits specified by
			// b_in)
			pkg_alu::alu_op_lsl:
			begin
				if ( b_in == `alu_inout_width'h0 )
				begin
					// Don't change ANYTHING
					{ proc_flags_out[pkg_pflags::pf_slot_c], 
						do_not_change_z_flag, out_lo } 
						= { proc_flags_in[pkg_pflags::pf_slot_c], 1'b1, 
						a_in_lo };
				end
				
				else
				begin
					{ proc_flags_out[pkg_pflags::pf_slot_c], out_lo } 
						= { 1'b0, a_in_lo } << b_in;
				end
			end
			
			pkg_alu::alu_op_lsr:
			begin
				if ( b_in == `alu_inout_width'h0 )
				begin
					// Don't change ANYTHING
					{ proc_flags_out[pkg_pflags::pf_slot_c], 
						do_not_change_z_flag, out_lo } 
						= { proc_flags_in[pkg_pflags::pf_slot_c], 1'b1, 
						a_in_lo };
				end
				
				else
				begin
					{ out_lo, proc_flags_out[pkg_pflags::pf_slot_c] } 
						= { a_in_lo, 1'b0 } >> b_in;
				end
			end
			
			pkg_alu::alu_op_asr:
			begin
				if ( b_in == `alu_inout_width'h0 )
				begin
					// Don't change ANYTHING
					{ proc_flags_out[pkg_pflags::pf_slot_c], 
						do_not_change_z_flag, out_lo } 
						= { proc_flags_in[pkg_pflags::pf_slot_c], 1'b1, 
						a_in_lo };
				end
				
				else
				begin
					{ out_lo, proc_flags_out[pkg_pflags::pf_slot_c] } 
						= $signed({ a_in_lo, 1'b0 }) >>> b_in;
				end
			end
			
			// 8-bit Bit rotation operations (number of bits specified by
			// [b_in % inout_width])
			pkg_alu::alu_op_rol:
			begin
				if ( b_in == `alu_inout_width'h0 )
				begin
					// Don't change ANYTHING
					{ proc_flags_out[pkg_pflags::pf_slot_c], 
						do_not_change_z_flag, out_lo } 
						= { proc_flags_in[pkg_pflags::pf_slot_c], 1'b1, 
						a_in_lo };
				end
				
				else
				begin
					// Don't change carry
					{ out_lo, proc_flags_out[pkg_pflags::pf_slot_c] } 
						= { rot_temp[ ( `alu_inout_width 
						- ( b_in & rot_mod_thing ) ) 
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
						do_not_change_z_flag, out_lo } 
						= { proc_flags_in[pkg_pflags::pf_slot_c], 1'b1, 
						a_in_lo };
				end
				
				else
				begin
					// Don't change carry
					{ out_lo, proc_flags_out[pkg_pflags::pf_slot_c] }
						= { rot_temp[ ( b_in & rot_mod_thing ) 
						+: `alu_inout_width ],
						proc_flags_in[pkg_pflags::pf_slot_c] };
				end
			end
			
			
			// 8-bit Bit rotating operations (with carry as bit 8)
			// that rotate by [b_in % [inout_width + 1]] bits
			pkg_alu::alu_op_rolc:
			begin
				if ( b_in == `alu_inout_width'h0 )
				begin
					// Don't change ANYTHING
					{ proc_flags_out[pkg_pflags::pf_slot_c], 
						do_not_change_z_flag, out_lo } 
						= { proc_flags_in[pkg_pflags::pf_slot_c], 1'b1, 
						a_in_lo };
				end
				
				else
				begin
					{ proc_flags_out[pkg_pflags::pf_slot_c], out_lo }
						= rot_c_temp[ ( `alu_inout_and_carry_width 
						- ( b_in & rot_c_mod_thing ) )
						+: `alu_inout_and_carry_width ];
				end
			end
			
			pkg_alu::alu_op_rorc:
			begin
				if ( b_in == `alu_inout_width'h0 )
				begin
					// Don't change ANYTHING
					{ proc_flags_out[pkg_pflags::pf_slot_c], 
						do_not_change_z_flag, out_lo } 
						= { proc_flags_in[pkg_pflags::pf_slot_c], 1'b1, 
						a_in_lo };
				end
				
				else
				begin
					{ proc_flags_out[pkg_pflags::pf_slot_c], out_lo }
						= rot_c_temp[ ( b_in & rot_c_mod_thing )
						+: `alu_inout_and_carry_width + 1 ];
				end
			end
			
			// 16-bit Bitshifting operations that shift { a_in_hi, 
			// a_in_lo } by b_in bits
			pkg_alu::alu_op_lslp:
			begin
				if ( b_in == `alu_inout_width'h0 )
				begin
					// Don't change ANYTHING
					{ proc_flags_out[pkg_pflags::pf_slot_c], 
						do_not_change_z_flag, { out_hi, out_lo } } 
						= { proc_flags_in[pkg_pflags::pf_slot_c], 1'b1, 
						{ a_in_hi, a_in_lo } };
				end
				
				else
				begin
					{ proc_flags_out[pkg_pflags::pf_slot_c], { out_hi, 
						out_lo } } = { 1'b0, { a_in_hi, a_in_lo } } 
						<< b_in;
				end
			end
			
			pkg_alu::alu_op_lsrp:
			begin
				if ( b_in == `alu_inout_width'h0 )
				begin
					// Don't change ANYTHING
					{ proc_flags_out[pkg_pflags::pf_slot_c], 
						do_not_change_z_flag, { out_hi, out_lo } } 
						= { proc_flags_in[pkg_pflags::pf_slot_c], 1'b1, 
						{ a_in_hi, a_in_lo } };
				end
				
				else
				begin
					{ { out_hi, out_lo }, 
						proc_flags_out[pkg_pflags::pf_slot_c] } 
						= { { a_in_hi, a_in_lo }, 1'b0 } >> b_in;
				end
			end
			
			pkg_alu::alu_op_asrp:
			begin
				if ( b_in == `alu_inout_width'h0 )
				begin
					// Don't change ANYTHING
					{ proc_flags_out[pkg_pflags::pf_slot_c], 
						do_not_change_z_flag, { out_hi, out_lo } } 
						= { proc_flags_in[pkg_pflags::pf_slot_c], 1'b1, 
						{ a_in_hi, a_in_lo } };
				end
				
				else
				begin
					{ { out_hi, out_lo }, 
						proc_flags_out[pkg_pflags::pf_slot_c] } 
						= $signed({ { a_in_hi, a_in_lo }, 1'b0 }) >>> b_in;
				end
			end
			
			
			// 16-bit Bit rotation operations that rotate { a_in_hi,
			// a_in_lo } by [b_in % inout_width] bits
			pkg_alu::alu_op_rolp:
			begin
				if ( b_in == `alu_inout_width'h0 )
				begin
					// Don't change ANYTHING
					{ proc_flags_out[pkg_pflags::pf_slot_c], 
						do_not_change_z_flag, { out_hi, out_lo } } 
						= { proc_flags_in[pkg_pflags::pf_slot_c], 1'b1, 
						{ a_in_hi, a_in_lo } };
				end
				
				else
				begin
					// Don't change carry
					{ { out_hi, out_lo }, 
						proc_flags_out[pkg_pflags::pf_slot_c] } 
						= { rot_p_temp[ ( `alu_inout_pair_width 
						- ( b_in & rot_p_mod_thing ) ) 
						+: `alu_inout_pair_width ],
						proc_flags_in[pkg_pflags::pf_slot_c] };
				end
			end
			
			pkg_alu::alu_op_rorp:
			begin
				if ( b_in == `alu_inout_width'h0 )
				begin
					// Don't change ANYTHING
					{ proc_flags_out[pkg_pflags::pf_slot_c], 
						do_not_change_z_flag, { out_hi, out_lo } } 
						= { proc_flags_in[pkg_pflags::pf_slot_c], 1'b1, 
						{ a_in_hi, a_in_lo } };
				end
				
				else
				begin
					// Don't change carry
					{ { out_hi, out_lo }, 
						proc_flags_out[pkg_pflags::pf_slot_c] }
						= { rot_p_temp[ ( b_in & rot_p_mod_thing ) 
						+: `alu_inout_pair_width ],
						proc_flags_in[pkg_pflags::pf_slot_c] };
				end
			end
			
			
			// 16-bit Bit rotating operations that rotate { a_in_hi,
			// a_in_lo } (with carry as bit 16) by [b_in 
			// % [inout_width + 1]] bits
			pkg_alu::alu_op_rolcp:
			begin
				if ( b_in == `alu_inout_width'h0 )
				begin
					// Don't change ANYTHING
					{ proc_flags_out[pkg_pflags::pf_slot_c], 
						do_not_change_z_flag, { out_hi, out_lo } } 
						= { proc_flags_in[pkg_pflags::pf_slot_c], 1'b1, 
						{ a_in_hi, a_in_lo } };
				end
				
				else
				begin
					{ proc_flags_out[pkg_pflags::pf_slot_c], 
						{ out_hi, out_lo } }
						= rot_p_c_temp[ ( `alu_inout_pair_and_carry_width 
						- ( b_in & rot_p_c_mod_thing ) )
						+: `alu_inout_pair_and_carry_width ];
				end
			end
			pkg_alu::alu_op_rorcp:
			begin
				if ( b_in == `alu_inout_width'h0 )
				begin
					// Don't change ANYTHING
					{ proc_flags_out[pkg_pflags::pf_slot_c], 
						do_not_change_z_flag, { out_hi, out_lo } } 
						= { proc_flags_in[pkg_pflags::pf_slot_c], 1'b1, 
						{ a_in_hi, a_in_lo } };
				end
				
				else
				begin
					{ proc_flags_out[pkg_pflags::pf_slot_c], 
						{ out_hi, out_lo } }
						= rot_p_c_temp[ ( b_in & rot_p_c_mod_thing )
						+: `alu_inout_pair_and_carry_width + 1 ];
				end
			end
			
			default:
			begin
				// Don't change ANYTHING
				{ proc_flags_out[pkg_pflags::pf_slot_c], 
					do_not_change_z_flag, out_lo } 
					= { proc_flags_in[pkg_pflags::pf_slot_c], 1'b1, 
					a_in_lo };
			end
			
		endcase
		
		
		if (!do_not_change_z_flag)
		begin
			if ( ( oper_cat == alu_op_cat_8_no_ci )
				|| ( oper_cat == alu_op_cat_8_ci ) )
			begin
				proc_flags_out[pkg_pflags::pf_slot_z] = ( out_lo == 0 );
			end
			
			else
			begin
				proc_flags_out[pkg_pflags::pf_slot_z] 
					= ( { out_hi, out_lo } == 0 );
			end
		end
		
		else // if (do_not_change_z_flag)
		begin
			proc_flags_out[pkg_pflags::pf_slot_z] 
				= proc_flags_in[pkg_pflags::pf_slot_z];
		end
	end
	
	
endmodule


