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


package pkg_alu;
	// ALU operation enum values
	typedef enum logic [`alu_op_msb_pos:0]
	{
		// Arithmetic operations
		// Addition operations
		alu_op_add,
		alu_op_adc,
		
		
		// Subtraction operations
		alu_op_sub,
		alu_op_sbc,
		alu_op_cmp,
		
		// Bitwise operations
		
		// Operations analogous to logic gates (none of these affect carry),
		// starting with 4'h5
		alu_op_and,
		alu_op_orr,
		alu_op_xor,
		
		//alu_op_inv,
		
		// Bitshifting operations (number of bits specified by b_in)
		alu_op_lsl,
		alu_op_lsr,
		
		// Bit rotation operations (number of bits specified by [b_in %
		// inout_width])
		alu_op_asr,
		alu_op_rol,
		alu_op_ror,
		
		
		// Bit rotating operations that use carry as bit 8 or bit 0 (number
		// of bits to rotate by specified by [b_in % inout_width])
		alu_op_rolc,
		alu_op_rorc
	} alu_op;
	
endpackage
