# Spark80 CPU
This is a small CPU I'm developing to practice my SystemVerilog skills and
CPU implementation skills.


Note that since Icarus Verilog's support for enums is not complete (at
least as of this writing), _when using something with better SystemVerilog
support (such as Altera Quartus II)_, it is **NECESSARY to change the task
set\_more\_alu\_config to use a cast**!

