# From andrewrk #zig on IRC - 16 Jun 18 [20:48] Central Time Zone
# zig build-obj yourfile.zig --target-arch msp430 --target-os freestanding  --emit asm

CODEFILES=src/main.zig Makefile

all: main

main: $(CODEFILES)
	zig build-obj src/main.zig --target-arch msp430 --target-os freestanding --target-environ code16 --emit asm --libc-include-dir gcc/include/
# Note, not working yet.
	gcc/bin/msp430-elf-gcc -o main.elf zig-cache/main.s
