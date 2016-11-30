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
	import pkg_instr_dec::*;
	
	( input bit [`instr_main_msb_pos:0] instr_hi,
	output instr_group group_out ); 
	
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
	import pkg_instr_dec::*;
	
	//( input bit [`instr_main_msb_pos:0] instr_hi,
	//output bit [`instr_op_max_msb_pos:0] opcode_out,
	//output bit [`instr_g1_ra_index_msb_pos:0] ra_index_out,
	//output bit [`instr_g1_imm_value_msb_pos:0] imm_value_8_out );
	
	( input bit [`instr_main_msb_pos:0] instr_hi,
	output ig1_dec_outputs ig1d_outputs );
	
	assign { ig1d_outputs.opcode, ig1d_outputs.ra_index, 
		ig1d_outputs.imm_value_8 } = instr_hi[ `instr_g1_op_range_hi
		: `instr_g1_imm_value_range_lo ];
	//assign ig1d_outputs = instr_hi[ `instr_g1_op_range_hi
	//	: `instr_g1_imm_value_range_lo ];

endmodule


// Instruction Group 2 decoder
// Encoding:  10oo oooo aaaa bbbb
module instr_grp_2_decoder
	import pkg_instr_dec::*;
	
	//( input bit [`instr_main_msb_pos:0] instr_hi,
	//output bit [`instr_op_max_msb_pos:0] opcode_out,
	//output bit [`instr_g2_ra_index_msb_pos:0] ra_index_out, rb_index_out,
	//output bit ra_index_is_for_pair, rb_index_is_for_pair );
	
	( input bit [`instr_main_msb_pos:0] instr_hi,
	output ig2_dec_outputs ig2d_outputs );
	
	
	assign ig2d_outputs.opcode = instr_hi[ `instr_g2_op_range_hi
		: `instr_g2_op_range_lo ];
	
	
	// ra_index_is_for_pair and rb_index_is_for_pair are created in this
	// module so that other modules do not have to obtain that information
	// themselves.
	assign ig2d_outputs.ra_index_is_for_pair 
		= ( ( ig2d_outputs.opcode == pkg_instr_dec::instr_g2_op_invp )
		|| ( ig2d_outputs.opcode == pkg_instr_dec::instr_g2_op_negp )
		
		|| ( ig2d_outputs.opcode == pkg_instr_dec::instr_g2_op_lslp )
		|| ( ig2d_outputs.opcode == pkg_instr_dec::instr_g2_op_lsrp )
		|| ( ig2d_outputs.opcode == pkg_instr_dec::instr_g2_op_asrp )
		|| ( ig2d_outputs.opcode == pkg_instr_dec::instr_g2_op_rolp )
		|| ( ig2d_outputs.opcode == pkg_instr_dec::instr_g2_op_rorp )
		
		|| ( ig2d_outputs.opcode == pkg_instr_dec::instr_g2_op_rolcp )
		|| ( ig2d_outputs.opcode == pkg_instr_dec::instr_g2_op_rorcp )
		
		|| ( ig2d_outputs.opcode == pkg_instr_dec::instr_g2_op_cpyp )
		|| ( ig2d_outputs.opcode == pkg_instr_dec::instr_g2_op_swp )
		
		|| ( ig2d_outputs.opcode == pkg_instr_dec::instr_g2_op_call ) );
	
	assign ig2d_outputs.rb_index_is_for_pair 
		= ( ( ig2d_outputs.opcode == pkg_instr_dec::instr_g2_op_cpyp )
		|| ( ig2d_outputs.opcode == pkg_instr_dec::instr_g2_op_swp )
		|| ( ig2d_outputs.opcode == pkg_instr_dec::instr_g2_op_ldr )
		|| ( ig2d_outputs.opcode == pkg_instr_dec::instr_g2_op_str ) );
	
	
	// Bitshift to ignore the lower bit if necessary
	assign ig2d_outputs.ra_index = instr_hi[ `instr_g2_ra_index_range_hi
		: `instr_g2_ra_index_range_lo ] 
		>> ig2d_outputs.ra_index_is_for_pair;
	assign ig2d_outputs.rb_index = instr_hi[ `instr_g2_rb_index_range_hi
		: `instr_g2_rb_index_range_lo ] 
		>> ig2d_outputs.rb_index_is_for_pair;
	
endmodule


// Instruction Group 3 decoder
// Encoding:  1100 ooaa aabb bccc
module instr_grp_3_decoder
	import pkg_instr_dec::*;
	
	//( input bit [`instr_main_msb_pos:0] instr_hi,
	//output bit [`instr_op_max_msb_pos:0] opcode_out,
	//output bit [`instr_g3_ra_index_msb_pos:0] ra_index_out,
	//output bit [`instr_g3_rbp_index_msb_pos:0] rbp_index_out,
	//	rcp_index_out );
	
	( input bit [`instr_main_msb_pos:0] instr_hi,
	output ig3_dec_outputs ig3d_outputs );
	
	//assign { opcode_out, ra_index_out, rbp_index_out, rcp_index_out }
	//assign ig3d_outputs = instr_hi[ `instr_g3_op_range_hi 
	//	: `instr_g3_rcp_index_range_lo ];
	assign { ig3d_outputs.opcode, ig3d_outputs.ra_index,
		ig3d_outputs.rbp_index, ig3d_outputs.rcp_index } 
		= instr_hi[`instr_g3_op_range_hi:`instr_g3_rcp_index_range_lo];
	
endmodule


// Instruction Group 4 decoder
// Encoding:  1101 oooo iiii iiii
module instr_grp_4_decoder
	import pkg_instr_dec::*;
	
	//( input bit [`instr_main_msb_pos:0] instr_hi,
	//output bit [`instr_op_max_msb_pos:0] opcode_out,
	//output bit [`instr_g4_imm_value_msb_pos:0] imm_value_8_out );
	
	( input bit [`instr_main_msb_pos:0] instr_hi,
	output ig4_dec_outputs ig4d_outputs );
	
	//assign { opcode_out, imm_value_8_out }
	//	= instr_hi[`instr_g4_op_range_hi:`instr_g4_imm_value_range_lo];
	
	//assign ig4d_outputs = instr_hi[ `instr_g4_op_range_hi
	//	: `instr_g4_imm_value_range_lo ];
	assign { ig4d_outputs.opcode, ig4d_outputs.imm_value_8 } 
		= instr_hi[`instr_g4_op_range_hi:`instr_g4_imm_value_range_lo];
	
endmodule


// Instruction Group 5 decoder
// Encoding:  1110 00oo oaaa abbb   iiii iiii jjjj jjjj
module instr_grp_5_decoder
	import pkg_instr_dec::*;
	
	//( input bit [`instr_main_msb_pos:0] instr_hi, instr_lo,
	//output bit [`instr_op_max_msb_pos:0] opcode_out,
	//output bit [`instr_g5_ihi_ra_index_msb_pos:0] ra_index_out,
	//output bit [`instr_g5_ihi_rbp_index_msb_pos:0] rbp_index_out,
	//output bit [`instr_g5_ilo_imm_value_msb_pos:0] imm_value_16_out );
	
	( input bit [`instr_main_msb_pos:0] instr_hi, instr_lo,
	output ig5_dec_outputs ig5d_outputs );
	
	
	//assign { opcode_out, ra_index_out, rbp_index_out, imm_value_16_out }
	//	= { instr_hi[ `instr_g5_ihi_op_range_hi 
	//	: `instr_g5_ihi_rbp_index_range_lo ], instr_lo };
	
	//assign ig5d_outputs = { instr_hi[ `instr_g5_ihi_op_range_hi 
	//	: `instr_g5_ihi_rbp_index_range_lo ], instr_lo };
	assign { ig5d_outputs.opcode, ig5d_outputs.ra_index,
		ig5d_outputs.rbp_index, ig5d_outputs.imm_value_16 } 
		= { instr_hi[ `instr_g5_ihi_op_range_hi 
		: `instr_g5_ihi_rbp_index_range_lo ], instr_lo };
	
endmodule


