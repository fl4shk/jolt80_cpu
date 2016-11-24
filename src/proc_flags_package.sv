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

`include "src/proc_flags_defines.svinc"

package pkg_pflags;
	
	// Two processor flags (for simplicity):  carry (c) and zero (z)
	typedef enum logic [`proc_flags_msb_pos:0] 
	{
		pf_slot_z,
		pf_slot_c
	} proc_flag_slot;
	
endpackage

