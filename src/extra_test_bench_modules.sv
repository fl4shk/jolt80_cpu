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


// This module is intended for use as a clock generator in test_benches
module tb_clk_gen( input logic reset, output logic clk );
	
	logic local_clk, ready;
	
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
module example_test_bench( input logic tb_clk, input logic reset );
	
	logic ready;
	
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


