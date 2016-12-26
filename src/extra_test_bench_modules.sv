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



// Test ROM/RAM (though mainly RAM with some initial values)
// Synchronous reads and writes
module tb_memory
	
	//( input bit clk, input bit reset,
	//input tb_mem_inputs the_inputs,
	//output bit [`cpu_data_inout_16_msb_pos:0] read_data_out );
	( input bit clk, input bit reset, input bit req_rdwr,
	input bit [`cpu_addr_msb_pos:0] addr_in,
	input bit [`cpu_data_inout_8_msb_pos:0] write_data_in_8,
	input bit [`cpu_data_inout_16_msb_pos:0] write_data_in_16,
	
	
	// Size (8-bit or 16-bit) of data being read/written
	input bit data_acc_sz,
	
	// Write enable
	input bit write_data_we_8, write_data_we_16,
	output bit [`cpu_data_inout_8_msb_pos:0] read_data_out_8,
	output bit [`cpu_data_inout_16_msb_pos:0] read_data_out_16,
	output bit data_ready );
	
	import pkg_cpu::*;
	import pkg_instr_dec::*;
	
	
	
	parameter num_bytes = 17'h10000;
	
	
	// The memory (DON'T change this to a bit array!)
	logic [`cpu_data_inout_8_msb_pos:0] mem[ 0 : ( num_bytes - 1 ) ];
	
	////bit can_write;
	bit can_rdwr;
	
	//assign read_data_out = ( the_inputs.read_data_acc_sz 
	//	== pkg_cpu::cpu_data_acc_sz_8 ) ? mem[the_inputs.read_addr_in]
	//	: `make_mem_pair(the_inputs.read_addr_in);
	
	
	initial $readmemh( "readmemh_input.txt.ignore", mem, 0, 
		( num_bytes - 1 ) ); 
	initial data_ready = 0;
	
	initial can_rdwr = 1;
	
	
	
	//always @ ( posedge clk )
	//begin
	//	if (!req_rdwr)
	//	begin
	//		data_ready <= 0;
	//		can_rdwr <= 1;
	//	end
	//	
	//	else // if (req_rdwr)
	//	begin
	//		data_ready <= can_rdwr;
	//		can_rdwr <= !can_rdwr;
	//	end
	//end
	
	// Use this with wrappers around real FPGA block RAM (though it also
	// works for test benches, apparently)
	always @ ( posedge clk )
	begin
		can_rdwr <= !can_rdwr;
		
		if (!req_rdwr)
		begin
			data_ready <= 0;
		end
		
		else // if (req_rdwr)
		begin
			data_ready <= can_rdwr;
		end
	end
	
	
	
	always @ ( posedge clk )
	begin
		if ( req_rdwr && can_rdwr )
		begin
			if ( data_acc_sz == pkg_cpu::cpu_data_acc_sz_8 )
			begin
				if ( write_data_we_8 == 1'b0 )
				begin
					// Read 8-bit data
					$display( "8-bit read:  %h, %h", addr_in, 
						mem[addr_in] );
					read_data_out_8 <= { `cpu_data_inout_8_width'h0,
						mem[addr_in] };
				end
				
				else // if ( write_data_we_8 == 1'b1 )
				begin
					// Write 8-bit data
					mem[addr_in] 
						<= write_data_in_8[`cpu_data_inout_8_msb_pos:0];
					$display( "8-bit write:  %h, %h", addr_in,
						write_data_in_8[`cpu_data_inout_8_msb_pos:0] );
				end
			end
		end
	end
	
	always @ ( posedge clk )
	begin
		if ( req_rdwr && can_rdwr )
		begin
			if ( data_acc_sz == pkg_cpu::cpu_data_acc_sz_16 )
			begin
				if ( write_data_we_16 == 1'b0 )
				begin
					// Read 16-bit data
					//$display( "16-bit read:  %h, %h", addr_in, 
					//	`make_mem_pair(addr_in) );
					read_data_out_16 <= `make_mem_pair(addr_in);
				end
				
				else // if ( write_data_we_16 == 1'b1 )
				begin
					// Write 16-bit data
					`make_mem_pair(addr_in) <= write_data_in_16;
					$display( "16-bit write:  %h", write_data_in_16 );
				end
			end
		end
	end
	
endmodule



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




//// Example test_bench module:
//module example_test_bench( input bit tb_clk, input bit reset );
//	
//	bit ready;
//	
//	// This is used instead of an initial block
//	always @ (reset)
//	begin
//		if (reset)
//		begin
//			ready = 1'b0;
//			
//			// Other initialization stuff goes here
//			
//		end
//		
//		if ( ready == 1'b0 )
//		begin
//			#1
//			ready = 1'b1;
//		end
//	end
//	
//	
//	always @ ( posedge tb_clk )
//	begin
//	
//	if (ready)
//	begin
//		// Main code stuff here
//		
//	end
//	
//	end
//	
//	
//endmodule


