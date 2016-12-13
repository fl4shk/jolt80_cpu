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


`include "src/cpu_extras_defines.svinc"
`include "src/instr_decoder_defines.svinc"


`define make_mem_pair(index_hi) `make_pair( mem, index_hi )
`define make_mem_quad(index_hi) `make_quad( mem, index_hi )


//typedef struct packed
//{
//	//bit [`cpu_addr_msb_pos:0] read_addr_in, write_addr_in;
//	bit [`cpu_addr_msb_pos:0] addr_in;
//	bit [`cpu_data_inout_16_msb_pos:0] write_data_in;
//	
//	// Size (8-bit or 16-bit) of data being read/written
//	//bit read_data_acc_sz, write_data_acc_sz;
//	bit data_acc_sz;
//	
//	// Write enable
//	bit write_data_we;
//	
//} tb_mem_inputs;


// Test ROM/RAM (though mainly RAM with some initial values)
// Synchronous reads and writes
module tb_memory
	
	//( input bit clk, input bit reset,
	//input tb_mem_inputs the_inputs,
	//output bit [`cpu_data_inout_16_msb_pos:0] read_data_out );
	( input bit clk, input bit reset,
	input bit [`cpu_addr_msb_pos:0] addr_in,
	input bit [`cpu_data_inout_16_msb_pos:0] write_data_in,
	
	// Size (8-bit or 16-bit) of data being read/written
	input bit data_acc_sz,
	
	// Write enable
	input bit write_data_we,
	output bit [`cpu_data_inout_16_msb_pos:0] read_data_out );
	
	import pkg_cpu::*;
	import pkg_instr_dec::*;
	
	
	
	parameter num_bytes = 17'h10000;
	
	
	// The memory (DON'T change this to a bit array!)
	logic [`cpu_data_inout_8_msb_pos:0] mem[0:num_bytes];
	
	//bit can_write;
	bit can_rdwr;
	
	//assign read_data_out = ( the_inputs.read_data_acc_sz 
	//	== pkg_cpu::cpu_data_acc_sz_8 ) ? mem[the_inputs.read_addr_in]
	//	: `make_mem_pair(the_inputs.read_addr_in);
	
	
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
	
	
	initial
	begin
		for ( zero_counter=0; zero_counter<num_bytes; ++zero_counter )
		begin
			mem[zero_counter] = 0;
		end
		
		//can_write = 1;
		can_rdwr = 1;
		
		//$readmemh( "readmemh_input.txt.ignore", mem, 0, ( num_bytes >> 1 )
		//	- 1 );
		$readmemh( "readmemh_input.txt.ignore", mem, 0, num_bytes );
		
		$display( "tb_memory:  %h %h %h\t\t%h %h %h\t\t%h", 
			`make_mem_pair(0), `make_mem_pair(2), `make_mem_pair(4),
			`make_mem_pair(6), `make_mem_pair(8), `make_mem_pair(10),
			`make_mem_pair(12) );
	end
	
	
	
	always @ ( posedge clk )
	begin
		can_rdwr <= can_rdwr + 1;
		
		if (can_rdwr )
		begin
			//$display( "mem[4], mem[5]:  %h %h", mem[4], mem[5] );
			//$display( "mem[0x7ffc], mem[0x7ffb], mem[0x7ffa]:  %h %h %h",
			//	mem[16'h7ffc], mem[16'h7ffb], mem[16'h7ffa] );
			
			if ( write_data_we == 1'b0 )
			begin
				//$display("helo");
				// Read 8-bit data
				if ( data_acc_sz == pkg_cpu::cpu_data_acc_sz_8 )
				begin
					$display( "8-bit read:  %h, %h", addr_in, 
						mem[addr_in] );
					read_data_out <= { `cpu_data_inout_8_width'h0,
						mem[addr_in] };
				end
				
				// Read 16-bit data
				else // if ( data_acc_sz == pkg_cpu::cpu_data_acc_sz_16 )
				begin
					//$display( "16-bit read:  %h, %h", addr_in, 
					//	`make_mem_pair(addr_in) );
					read_data_out <= `make_mem_pair(addr_in);
				end
			end
			
			else // if ( write_data_we == 1'b1 )
			begin
				//$display("nice");
				// Write 8-bit data
				if ( data_acc_sz == pkg_cpu::cpu_data_acc_sz_8 )
				begin
					mem[addr_in] 
						<= write_data_in[`cpu_data_inout_8_msb_pos:0];
					$display( "8-bit write:  %h, %h", addr_in,
						write_data_in[`cpu_data_inout_8_msb_pos:0] );
				end
				
				// Write 16-bit data
				else // if ( data_acc_sz == pkg_cpu::cpu_data_acc_sz_16 )
				begin
					`make_mem_pair(addr_in) <= write_data_in;
					$display( "16-bit write:  %h", write_data_in );
				end
			end
		end
		
	end
	
endmodule


// This module is intended for use as a clock generator for things besides
// instances of tb_memory
module tb_half_clk_gen( input bit reset, output bit half_clk );
	
	bit local_half_clk, ready;
	
	assign half_clk = local_half_clk;
	
	always @ (reset)
	begin
		if (reset)
		begin
			local_half_clk = 1'b0;
			
			ready = 1'b0;
			
			#2
			ready = 1'b1;
		end
	end
	
	always
	begin
		#2
		
		if (ready)
		begin
			local_half_clk = !local_half_clk;
		end
	end
	
endmodule


// This module is intended for use as a clock generator for tb_memory in
// test_benches
module tb_memory_clk_gen( input bit reset, output bit mem_clk );
	
	bit local_mem_clk, ready;
	
	assign mem_clk = local_mem_clk;
	
	always @ (reset)
	begin
		if (reset)
		begin
			local_mem_clk = 1'b0;
			
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
			local_mem_clk = !local_mem_clk;
		end
	end
	
endmodule




// Example test_bench module:
module example_test_bench( input bit tb_half_clk, input bit reset );
	
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
	
	
	always @ ( posedge tb_half_clk )
	begin
	
	if (ready)
	begin
		// Main code stuff here
		
	end
	
	end
	
	
endmodule


