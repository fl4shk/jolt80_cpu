# Jolt80 CPU
This is a small CPU I'm developing to practice my SystemVerilog skills and
CPU implementation skills.


Note that since Icarus Verilog's support for SystemVerilog enums is not
complete (at least as of this writing), _when using something with better
SystemVerilog support (such as Altera Quartus II)_, it is **NECESSARY to
change the task set\_more\_alu\_config in src/alu\_control\_tasks.svinc to
use a cast**!
