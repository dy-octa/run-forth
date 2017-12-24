# run-forth
A tiny Forth compiler, assembler and processor written in verilog.

# Features
A basic portion of Forth is supported. The Forth program can be compiled to run-forth assembly, then the binary code. As for the assembly and binary code, an ISA is designed to support the Forth language to run on the stack machine implemented in verilog. Since the Forth language is so close to the architecture of a stack machine, the compiler and assembler don't utilize so many typical compiling techniques, but use a simple scan instead. Further details can be seen in the [document](architecture.pdf).

# Run
```
Make
./compiler something.fs something.asm
./assembler something.asm code.txt dict.txt
```
For simulation, please copy code.txt and dict.txt (please do not change the names) to forth-processor/.
A couple of tests are provided in /samples.