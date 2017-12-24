all: compiler assembler
compiler: compiler.c
	gcc compiler.c -o compiler
assembler: assembler.c
	gcc assembler.c -o assembler