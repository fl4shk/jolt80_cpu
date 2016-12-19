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


`include "src/instr_decoder_defines.svinc"
`include "src/alu_defines.svinc"
//`include "src/cpu_extras_defines.svinc"

// This module decodes the instruction group of an instruction's 
module instr_group_decoder
	
	( input bit [`instr_main_msb_pos:0] instr_hi,
	output pkg_instr_dec::instr_group group_out ); 
	
	import pkg_instr_dec::*;
	
	instr_group temp_group;
	
	assign group_out = temp_group;
	
	
	always @ (instr_hi)
	begin
		if ( instr_hi[`instr_g1_id_pos] == `instr_g1_id )
		begin
			temp_group = pkg_instr_dec::instr_grp_1;
		end
		
		else if ( instr_hi[`instr_g2_id_range_hi:`instr_g2_id_range_lo] 
			== `instr_g2_id )
		begin
			temp_group = pkg_instr_dec::instr_grp_2;
		end
		
		else if ( instr_hi[`instr_g3_id_range_hi:`instr_g3_id_range_lo]
			== `instr_g3_id )
		begin
			temp_group = pkg_instr_dec::instr_grp_3;
		end
		
		else if ( instr_hi[`instr_g4_id_range_hi:`instr_g4_id_range_lo]
			== `instr_g4_id )
		begin
			temp_group = pkg_instr_dec::instr_grp_4;
		end
		
		else if ( instr_hi[ `instr_g5_ihi_id_range_hi
			: `instr_g5_ihi_id_range_lo ] == `instr_g5_ihi_id )
		begin
			temp_group = pkg_instr_dec::instr_grp_5;
		end
		
		else
		begin
			temp_group = pkg_instr_dec::instr_grp_unknown;
		end
	end
	
endmodule


// Instruction Group 1 decoder
// Encoding:  0ooo aaaa iiii iiii
module instr_grp_1_decoder
	
	//( input bit [`instr_main_msb_pos:0] instr_hi,
	//output ig1_dec_outputs ig1d_outputs );
	( input bit [`instr_main_msb_pos:0] instr_hi,
		output bit [`instr_g1_op_msb_pos:0] opcode,
		output bit [`cpu_reg_index_ie_msb_pos:0] ra_index,
		output bit [`instr_g1_imm_value_msb_pos:0] imm_value_8,
		output bit ra_index_is_for_pair );
	
	import pkg_instr_dec::*;
	
	//assign { ig1d_outputs.opcode, ig1d_outputs.ra_index, 
	//	ig1d_outputs.imm_value_8 } = instr_hi[ `instr_g1_op_range_hi
	//	: `instr_g1_imm_value_range_lo ];
	//assign { opcode, ra_index, imm_value_8 } 
	//	= instr_hi[ `instr_g1_op_range_hi : `instr_g1_imm_value_range_lo ];
	assign opcode = instr_hi[`instr_g1_op_range_hi:`instr_g1_op_range_lo];
	
	assign ra_index_is_for_pair = ig1_get_ra_index_is_for_pair(opcode);
	
	assign ra_index = instr_hi[ `instr_g1_ra_index_range_hi 
		: `instr_g1_ra_index_range_lo ] >> ra_index_is_for_pair;
	assign imm_value_8 = instr_hi[ `instr_g1_imm_value_range_hi
		: `instr_g1_imm_value_range_lo ];
	
endmodule


// Instruction Group 2 decoder
// Encoding:  10oo oooo aaaa bbbb
module instr_grp_2_decoder
	
	//( input bit [`instr_main_msb_pos:0] instr_hi,
	//output ig2_dec_outputs ig2d_outputs );
	( input bit [`instr_main_msb_pos:0] instr_hi,
		output bit [`instr_g2_op_msb_pos:0] opcode,
		output bit [`cpu_reg_index_ie_msb_pos:0] ra_index,
		output bit [`cpu_reg_index_ie_msb_pos:0] rb_index,
		output bit ra_index_is_for_pair, rb_index_is_for_pair );
	
	import pkg_instr_dec::*;
	
	
	assign opcode = instr_hi[`instr_g2_op_range_hi:`instr_g2_op_range_lo];
	
	// ra_index_is_for_pair and rb_index_is_for_pair are created in this
	// module so that other modules do not have to obtain that information
	// themselves.
	assign ra_index_is_for_pair = ig2_get_ra_index_is_for_pair(opcode);
	assign rb_index_is_for_pair = ig2_get_rb_index_is_for_pair(opcode);
	
	
	// Bitshift to ignore the lower bit if necessary
	assign ra_index = instr_hi[ `instr_g2_ra_index_range_hi
		: `instr_g2_ra_index_range_lo ] >> ra_index_is_for_pair;
	assign rb_index = instr_hi[ `instr_g2_rb_index_range_hi
		: `instr_g2_rb_index_range_lo ] >> rb_index_is_for_pair;
	
endmodule


// Instruction Group 3 decoder
// Encoding:  1100 ooaa aabb bccc
module instr_grp_3_decoder
	
	//( input bit [`instr_main_msb_pos:0] instr_hi,
	//output ig3_dec_outputs ig3d_outputs );
	( input bit [`instr_main_msb_pos:0] instr_hi,
		output bit [`instr_g3_op_msb_pos:0] opcode,
		output bit [`cpu_reg_index_ie_msb_pos:0] ra_index,
		output bit [`cpu_reg_index_ie_msb_pos:0] rbp_index,
		output bit [`cpu_reg_index_ie_msb_pos:0] rcp_index );
	
	import pkg_instr_dec::*;
	
	//assign { opcode, ra_index, rbp_index, rcp_index } 
	//	= instr_hi[`instr_g3_op_range_hi:`instr_g3_rcp_index_range_lo];
	assign opcode = instr_hi[`instr_g3_op_range_hi:`instr_g3_op_range_lo];
	assign ra_index = instr_hi[ `instr_g3_ra_index_range_hi 
		: `instr_g3_ra_index_range_lo ];
	assign rbp_index = instr_hi[ `instr_g3_rbp_index_range_hi 
		: `instr_g3_rbp_index_range_lo ];
	assign rcp_index = instr_hi[ `instr_g3_rcp_index_range_hi 
		: `instr_g3_rcp_index_range_lo ];
	
endmodule


// Instruction Group 4 decoder
// Encoding:  1101 oooo iiii iiii
module instr_grp_4_decoder
	
	//( input bit [`instr_main_msb_pos:0] instr_hi,
	//output ig4_dec_outputs ig4d_outputs );
	( input bit [`instr_main_msb_pos:0] instr_hi,
		output bit [`instr_g4_op_msb_pos:0] opcode,
		output bit [`instr_g4_imm_value_msb_pos:0] imm_value_8 );
	
	import pkg_instr_dec::*;
	
	//assign { opcode, imm_value_8 } 
	//	= instr_hi[`instr_g4_op_range_hi:`instr_g4_imm_value_range_lo];
	assign opcode = instr_hi[`instr_g4_op_range_hi:`instr_g4_op_range_lo];
	assign imm_value_8 = instr_hi[ `instr_g4_imm_value_range_hi 
		: `instr_g4_imm_value_range_lo ];
	
endmodule


// Instruction Group 5 decoder
// Encoding:  1110 00oo oaaa abbb   iiii iiii jjjj jjjj
module instr_grp_5_decoder
	
	//( input bit [`instr_main_msb_pos:0] instr_hi,
	//output ig5_dec_outputs ig5d_outputs );
	( input bit [`instr_main_msb_pos:0] instr_hi,
		output bit [`instr_g5_op_msb_pos:0] opcode,
		output bit [`cpu_reg_index_ie_msb_pos:0] ra_index,
		output bit [`cpu_reg_index_ie_msb_pos:0] rbp_index,
		output bit ra_index_is_for_pair );
	
	import pkg_instr_dec::*;
	
	assign opcode = instr_hi[ `instr_g5_ihi_op_range_hi
		: `instr_g5_ihi_op_range_lo ];
	//assign opcode = 3;
	
	
	// ra_index_is_for_pair is created in this module so that other modules
	// do not have to obtain that information themselves.
	assign ra_index_is_for_pair 
		= ig5_get_ra_index_is_for_pair(opcode);
	
	assign ra_index = instr_hi[ `instr_g5_ihi_ra_index_range_hi
		: `instr_g5_ihi_ra_index_range_lo ] >> ra_index_is_for_pair;
	
	assign rbp_index = instr_hi[ `instr_g5_ihi_rbp_index_range_hi
		: `instr_g5_ihi_rbp_index_range_lo ];
	
	
endmodule


