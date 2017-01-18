// This file is part of Jolt80 CPU.
// 
// Copyright 2016-2017 by Andrew Clark (FL4SHK).
// 
// Jolt80 CPU is free software: you can redistribute it and/or
// modify it under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
// 
// Jolt80 CPU is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
// 
// You should have received a copy of the GNU General Public License along
// with Jolt80 CPU.  If not, see <http://www.gnu.org/licenses/>.


`include "src/alu_defines.svinc"

`include "src/instr_decoder_defines.svinc"
//`include "src/cpu_extras_defines.svinc"



// use_half_clock is intended to be used for simulation only
`define use_half_clock

module jolt80_test_bench;
	
	`ifdef use_half_clock
	bit clk_gen_reset, tb_half_clk, tb_mem_clk;
	`else
	bit clk_gen_reset, tb_clk;
	`endif
	
	
	bit test_mem_reset;
	
	
	// reset and interrupt signals for test_cpu
	bit test_cpu_reset, test_cpu_interrupt;
	
	
	`ifdef use_half_clock
	tb_half_clk_gen half_clk_gen( .reset(clk_gen_reset), 
		.half_clk(tb_half_clk) );
	tb_memory_clk_gen mem_clk_gen( .reset(clk_gen_reset), 
		.mem_clk(tb_mem_clk) );
	`else
	tb_clk_gen clk_gen( .reset(clk_gen_reset), .clk(tb_clk) );
	`endif
	
	
	
	
	
	wire test_cpu_data_ready;
	//bit test_cpu_reset;
	//wire [`cpu_data_inout_16_msb_pos:0] test_cpu_data_inout_direct;
	wire [`cpu_addr_msb_pos:0] test_cpu_data_inout_addr;
	wire test_cpu_data_acc_sz, test_cpu_data_inout_we;
	//logic [`cpu_data_inout_16_msb_pos:0] test_cpu_data_out;
	bit [`cpu_data_inout_16_msb_pos:0] test_cpu_temp_data_in;
	wire [`cpu_data_inout_16_msb_pos:0] test_cpu_temp_data_out;
	wire test_cpu_req_rdwr;
	
	wire [`cpu_reg_msb_pos:0] test_cpu_debug_vec;
	
	
	
	wire test_mem_data_ready;
	wire [ `cpu_addr_msb_pos - 1 : 0 ] test_mem_addr_2;
	wire [`cpu_data_inout_8_msb_pos:0] test_mem_read_data_out_8;
	wire [`cpu_data_inout_16_msb_pos:0] test_mem_read_data_out_16;
	
	wire [`cpu_data_inout_8_msb_pos:0] test_mem_write_data_in_8;
	wire [`cpu_data_inout_16_msb_pos:0] test_mem_write_data_in_16;
	wire test_mem_write_data_we_8, test_mem_write_data_we_16;
	
	
	
	//initial test_cpu_reset = 1;
	
	//assign test_cpu_data_ready = 1;
	assign test_cpu_data_ready = test_mem_data_ready;
	assign test_mem_addr_2 = ( test_cpu_data_inout_addr >> 1 );
	
	assign test_mem_write_data_we_8
		= ( ( test_cpu_data_acc_sz == pkg_cpu::cpu_data_acc_sz_8 )
		? test_cpu_data_inout_we : 0 );
	assign test_mem_write_data_we_16
		= ( ( test_cpu_data_acc_sz == pkg_cpu::cpu_data_acc_sz_16 )
		? test_cpu_data_inout_we : 0 );
	
	//assign test_cpu_data_inout_direct = ( (!test_cpu_data_inout_we) 
	//	? ( ( test_cpu_data_acc_sz == pkg_cpu::cpu_data_acc_sz_8 )
	//	? test_mem_read_data_out_8 : test_mem_read_data_out_16 )
	//	: `cpu_data_inout_16_width'hz );
	
	
	
	assign test_cpu_temp_data_in
		= ( ( test_cpu_data_acc_sz == pkg_cpu::cpu_data_acc_sz_8 )
		? test_mem_read_data_out_8 : test_mem_read_data_out_16 );
	
	//assign test_cpu_data_out = (test_cpu_data_inout_we)
	//	? test_cpu_data_inout_direct : `cpu_data_inout_16_width'hz;
	//
	//assign test_mem_write_data_in_8
	//	= test_cpu_data_out[`cpu_data_inout_8_msb_pos:0];
	//assign test_mem_write_data_in_16 = test_cpu_data_out;
	assign test_mem_write_data_in_8
		= test_cpu_temp_data_out[`cpu_data_inout_8_msb_pos:0];
	assign test_mem_write_data_in_16 = test_cpu_temp_data_out;
	
	
	
	
	//test_memory test_mem( .clk(clk), .req_rdwr(test_cpu_req_rdwr),
	//	.addr_in(test_cpu_data_inout_addr),
	//	.write_data_in_8(test_mem_write_data_in_8),
	//	.write_data_in_16(test_mem_write_data_in_16),
	//	.write_data_we_8(test_mem_write_data_we_8),
	//	.write_data_we_16(test_mem_write_data_we_16),
	//	.read_data_out_8(test_mem_read_data_out_8),
	//	.read_data_out_16(test_mem_read_data_out_16),
	//	.data_ready(test_cpu_data_ready) );
	
	
	
	
	
	//// This needs to have a wrapper put around it when I actually use 
	//// Jolt80 in my FPGA board
	//mixed_width_true_dual_port_ram #(8,16,15) dedotated_wam
	//	( .addr1(test_cpu_data_inout_addr),
	//	.addr2(test_mem_addr_2),
	//	.data_in1(test_mem_write_data_in_8),
	//	.data_in2(test_mem_write_data_in_16),
	//	.we1(test_mem_write_data_we_8),
	//	.we2(test_mem_write_data_we_16),
	//	.clk(clk),
	//	.data_out1(test_mem_read_data_out_8),
	//	.data_out2(test_mem_read_data_out_16) );
	
	
	//`ifdef use_half_clock
	//tb_memory test_mem( .clk(tb_mem_clk), .reset(test_mem_reset), 
	//`else
	//tb_memory test_mem( .clk(tb_clk), .reset(test_mem_reset), 
	//`endif
	//	.req_rdwr(test_cpu_req_rdwr),
	//	.addr_in(test_cpu_data_inout_addr),
	//	.write_data_in_8(test_mem_write_data_in_8),
	//	.write_data_in_16(test_mem_write_data_in_16),
	//	.data_acc_sz(test_cpu_data_acc_sz),
	//	.write_data_we_8(test_mem_write_data_we_8),
	//	.write_data_we_16(test_mem_write_data_we_16),
	//	.read_data_out_8(test_mem_read_data_out_8),
	//	.read_data_out_16(test_mem_read_data_out_16),
	//	.data_ready(test_mem_data_ready) );
	
	`ifdef use_half_clock
	quartus_ii_test_memory test_mem( .clk(tb_mem_clk), 
	`else
	quartus_ii_test_memory test_mem( .clk(tb_clk),
	`endif
		.req_rdwr(test_cpu_req_rdwr),
		.addr_in(test_cpu_data_inout_addr),
		.write_data_in_8(test_mem_write_data_in_8),
		.write_data_in_16(test_mem_write_data_in_16),
		.data_acc_sz(test_cpu_data_acc_sz),
		.write_data_we_8(test_mem_write_data_we_8),
		.write_data_we_16(test_mem_write_data_we_16),
		.read_data_out_8(test_mem_read_data_out_8),
		.read_data_out_16(test_mem_read_data_out_16),
		.data_ready(test_mem_data_ready) );
	
	
	`ifdef use_half_clock
	jolt80 test_cpu( .clk(tb_half_clk), 
	`else
	jolt80 test_cpu( .clk(tb_clk),
	`endif
		.reset(test_cpu_reset), .interrupt(test_cpu_interrupt),
		.data_ready(test_cpu_data_ready),
		.temp_data_in(test_cpu_temp_data_in),
		.temp_data_out(test_cpu_temp_data_out),
		.data_inout_addr(test_cpu_data_inout_addr),
		.data_acc_sz(test_cpu_data_acc_sz),
		.data_inout_we(test_cpu_data_inout_we),
		.req_rdwr(test_cpu_req_rdwr),
		.debug_vec(test_cpu_debug_vec) );
	
	
	
	initial
	begin
		clk_gen_reset = 1'b1;
		test_cpu_reset = 1'b0;
		test_cpu_interrupt = 1'b0;
		
		#4
		test_cpu_reset = 1'b1;
		
		#4
		test_cpu_reset = 1'b0;
		
		
		//#80
		//test_cpu_interrupt = 1'b1;
		
		//#90
		//test_cpu_interrupt = 1'b0;
	end
	
	////always @ ( posedge tb_half_clk )
	//always @ ( posedge tb_clk )
	//begin
	//	////$display( "%h %h %h %h", test_cpu_data_inout_direct,
	//	////	test_cpu_data_inout_addr, test_cpu_data_acc_sz, 
	//	////	test_cpu_data_inout_we );
	//	//$display( "In Test bench:  %h %h\t\t%h %h %h", 
	//	//	test_cpu_temp_data_in, test_cpu_temp_data_out, 
	//	//	test_cpu_data_inout_addr, test_cpu_data_acc_sz, 
	//	//	test_cpu_data_inout_we );
	//end
	
	
endmodule

