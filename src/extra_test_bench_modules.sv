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


//`include "src/cpu_extras_defines.svinc"
`include "src/instr_decoder_defines.svinc"


`define make_mem_pair(index_hi) `make_pair( mem, index_hi )
`define make_mem_quad(index_hi) `make_quad( mem, index_hi )


typedef struct packed
{
	bit [`cpu_addr_msb_pos:0] read_addr_in, write_addr_in;
	bit [`cpu_data_inout_16_msb_pos:0] write_data_in;
	
	// Size (8-bit or 16-bit) of data being read/written
	bit read_data_acc_sz, write_data_acc_sz;
	
	// Write enable
	bit write_data_we;
	
} tb_mem_inputs;


// Test ROM/RAM (though mainly RAM with some initial values)
// Asynchronous reads, Synchronous writes
module tb_memory
	
	( input bit write_clk, input bit reset,
	input tb_mem_inputs the_inputs,
	output bit [`cpu_data_inout_16_msb_pos:0] read_data_out );
	
	import pkg_cpu::*;
	import pkg_instr_dec::*;
	
	
	
	parameter num_bytes = 17'h10000;
	
	
	// The memory (DON'T change this to a bit array!)
	logic [`cpu_data_inout_8_msb_pos:0] mem[0:num_bytes];
	
	
	assign read_data_out = ( the_inputs.read_data_acc_sz 
		== pkg_cpu::cpu_data_acc_sz_8 ) ? mem[the_inputs.read_addr_in]
		: `make_mem_pair(the_inputs.read_addr_in);
	
	
	integer zero_counter;
	//logic [15:0] init_counter;
	//
	//
	//// 
	//task init_mem_16;
	//	input [`cpu_data_inout_16_msb_pos:0] to_write;
	//	
	//	`make_mem_pair(init_counter) = to_write;
	//	init_counter = init_counter + 2;
	//endtask
	//task init_mem_32;
	//	input [31:0] to_write;
	//	
	//	`make_mem_quad(init_counter) = to_write;
	//	init_counter = init_counter + 4;
	//endtask
	
	
	//initial
	//begin
	//	for ( zero_counter=0; zero_counter<num_bytes; ++zero_counter )
	//	begin
	//		mem[zero_counter] = 0;
	//	end
	//	
	//	init_counter = 16'h0;
	//	
	//	init_mem_16({ `instr_g1_id, pkg_instr_dec::instr_g1_op_cpyi, 4'he, 
	//		8'h10 });
	//	init_mem_16({ `instr_g1_id, pkg_instr_dec::instr_g1_op_cpyi, 4'hf, 
	//		8'h10 });
	//	init_mem_16({ `instr_g1_id, pkg_instr_dec::instr_g1_op_cpyi, 4'hd, 
	//		8'h10 });
	//	init_mem_16({ `instr_g1_id, pkg_instr_dec::instr_g1_op_cpyi, 4'hd, 
	//		8'h10 });
	//	init_mem_16({ `instr_g1_id, pkg_instr_dec::instr_g1_op_cmpi, 4'hd, 
	//		8'h10 });
	//	init_mem_16({ `instr_g1_id, pkg_instr_dec::instr_g1_op_cmpi, 4'hf, 
	//		8'h10 });
	//	init_mem_16({ `instr_g1_id, pkg_instr_dec::instr_g1_op_addi, 4'hf, 
	//		8'h10 });
	//	//init_mem_16({ `instr_g4_id, pkg_instr_dec::instr_g4_op_bra, 
	//	//	-8'h2 });
	//	//init_mem_16({ `instr_g1_id, pkg_instr_dec::instr_g1_op_cmpi, 4'h0, 
	//	//	8'h10 });
	//	//init_mem_16({ `instr_g1_id, pkg_instr_dec::instr_g1_op_cpyi, 4'h3,
	//	//	8'h3f });
	//	//init_mem_32({ `instr_g5_ihi_id, pkg_instr_dec::instr_g5_op_calli,
	//	//	4'h8, 3'h7, 16'hffaa });
	//	//init_mem_32({ `instr_g5_ihi_id, pkg_instr_dec::instr_g5_op_calli,
	//	//	4'h8, 3'h7, -16'hffaa });
	//	//init_mem_16({ `instr_g2_id, pkg_instr_dec::instr_g2_op_str, 4'h3,
	//	//	4'h9 });
	//	
	//	//$display( "tb_memory:  %h %h %h\t\t%h %h %h\t\t%h", 
	//	//	`make_mem_pair(0), `make_mem_pair(2), `make_mem_pair(4),
	//	//	`make_mem_pair(6), `make_mem_pair(8), `make_mem_pair(10),
	//	//	`make_mem_pair(12) );
	//end
	
	initial
	begin
		for ( zero_counter=0; zero_counter<num_bytes; ++zero_counter )
		begin
			mem[zero_counter] = 0;
		end
		
		$readmemh( "readmemh_input.txt.ignore", mem, 0, ( num_bytes >> 1 )
			- 1 );
		
		$display( "tb_memory:  %h %h %h\t\t%h %h %h\t\t%h", 
			`make_mem_pair(0), `make_mem_pair(2), `make_mem_pair(4),
			`make_mem_pair(6), `make_mem_pair(8), `make_mem_pair(10),
			`make_mem_pair(12) );
	end
	
	
	
	always @ ( posedge write_clk )
	begin
		if ( the_inputs.write_data_we == 1'b1 )
		begin
			// Write 8-bit data
			if ( the_inputs.write_data_acc_sz 
				== pkg_cpu::cpu_data_acc_sz_8 )
			begin
				mem[the_inputs.write_addr_in] <= the_inputs.write_data_in
					[`cpu_data_inout_8_msb_pos:0];
			end
			
			else // if ( the_inputs.write_data_acc_sz
				// == pkg_cpu::cpu_data_acc_sz_16 )
			begin
				`make_mem_pair(the_inputs.write_addr_in)
					<= the_inputs.write_data_in;
			end
		end
	end
	
endmodule



// This module is intended for use as a clock generator in test_benches
module tb_clk_gen( input bit reset, output bit clk );
	
	bit local_clk, ready;
	
	assign clk = local_clk;
	
	always @ (reset)
	begin
		if (reset)
		begin
			local_clk = 1'b0;
			
			ready = 1'b0;
			
			#1
			ready = 1'b1;
		end
	end
	
	always
	begin
		#1
		
		if (ready)
		begin
			local_clk = !local_clk;
		end
	end
	
endmodule


// Example test_bench module:
module example_test_bench( input bit tb_clk, input bit reset );
	
	bit ready;
	
	// This is used instead of an initial block
	always @ (reset)
	begin
		if (reset)
		begin
			ready = 1'b0;
			
			// Other initialization stuff goes here
			
		end
		
		if ( ready == 1'b0 )
		begin
			#1
			ready = 1'b1;
		end
	end
	
	
	always @ ( posedge tb_clk )
	begin
	
	if (ready)
	begin
		// Main code stuff here
		
	end
	
	end
	
	
endmodule


