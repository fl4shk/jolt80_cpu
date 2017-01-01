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

`include "src/instr_decoder_defines.svinc"
//`include "src/cpu_extras_defines.svinc"

module true_dual_port_ram
	( input bit clk, 
	input bit [`cpu_addr_msb_pos:0] addr_in_a, addr_in_b,
	input bit [`cpu_data_inout_8_msb_pos:0] write_data_in_a,
		write_data_in_b,
	
	// Write enable
	input bit write_data_we_a, write_data_we_b,
	
	output bit [`cpu_data_inout_8_msb_pos:0] read_data_out_a, 
		read_data_out_b );
	
	
	reg [`cpu_data_inout_8_msb_pos:0] mem[ 0 
		: ( ( 1 << `cpu_addr_width ) - 1 ) ];
	
	initial $readmemh( "readmemh_input.txt.ignore", mem );
	
	// Port A
	always @ ( posedge clk )
	begin
		if (write_data_we_a)
		begin
			mem[addr_in_a] <= write_data_in_a;
		end
		
		read_data_out_a <= mem[addr_in_a];
	end
	
	// Port B
	always @ ( posedge clk )
	begin
		if (write_data_we_b)
		begin
			mem[addr_in_b] <= write_data_in_b;
		end
		
		read_data_out_b <= mem[addr_in_b];
	end
	
endmodule


// Test ROM/RAM (though mainly RAM with some initial values)
// Synchronous reads and writes
module quartus_ii_test_memory
	( input bit clk, input bit req_rdwr,
	input bit [`cpu_addr_msb_pos:0] addr_in,
	input bit [`cpu_data_inout_8_msb_pos:0] write_data_in_8,
	input bit [`cpu_data_inout_16_msb_pos:0] write_data_in_16,
	
	
	// Size (8-bit or 16-bit) of data being read/written
	input bit data_acc_sz,
	
	// Write enable
	input bit write_data_we_8, write_data_we_16,
	output wire [`cpu_data_inout_8_msb_pos:0] read_data_out_8,
	output wire [`cpu_data_inout_16_msb_pos:0] read_data_out_16,
	output bit data_ready );
	
	
	import pkg_cpu::*;
	
	
	wire [`cpu_addr_msb_pos:0] addr_in_2;
	bit can_rdwr;
	
	wire [`cpu_data_inout_8_msb_pos:0] internal_write_data_in_a,
		internal_write_data_in_b;
	wire internal_write_data_we_a, internal_write_data_we_b;
	wire [`cpu_data_inout_8_msb_pos:0] internal_read_data_out_a,
		internal_read_data_out_b;
	
	assign addr_in_2 = ( addr_in + 1 );
	
	assign internal_write_data_in_a 
		= ( ( data_acc_sz == pkg_cpu::cpu_data_acc_sz_8 )
		? write_data_in_8 
		: write_data_in_16[ `cpu_data_inout_16_msb_pos 
		: `cpu_data_inout_8_width ] );
	
	assign internal_write_data_in_b
		= write_data_in_16[`cpu_data_inout_8_msb_pos:0];
	
	assign internal_write_data_we_a
		= ( ( data_acc_sz == pkg_cpu::cpu_data_acc_sz_8 )
		? write_data_we_8 : write_data_we_16 );
	assign internal_write_data_we_b
		= ( ( data_acc_sz == pkg_cpu::cpu_data_acc_sz_16 )
		? write_data_we_16 : 0 );
	
	
	assign read_data_out_8
		= ( ( data_acc_sz == pkg_cpu::cpu_data_acc_sz_8 )
		? internal_read_data_out_a : 0 );
	
	assign read_data_out_16
		= ( ( data_acc_sz == pkg_cpu::cpu_data_acc_sz_16 )
		? { internal_read_data_out_a, internal_read_data_out_b } : 0 );
	
	
	initial data_ready = 0;
	initial can_rdwr = 1;
	
	
	true_dual_port_ram internal_ram( .clk(clk), 
		.addr_in_a(addr_in), .addr_in_b(addr_in_2),
		.write_data_in_a(internal_write_data_in_a),
		.write_data_in_b(internal_write_data_in_b),
		.write_data_we_a(internal_write_data_we_a),
		.write_data_we_b(internal_write_data_we_b),
		.read_data_out_a(internal_read_data_out_a),
		.read_data_out_b(internal_read_data_out_b) );
	
	//always_ff @ ( posedge clk )
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
	
	
endmodule
