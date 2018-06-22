# From andrewrk #zig on IRC - 16 Jun 18 [20:48] Central Time Zone
# zig build-obj yourfile.zig --target-arch msp430 --target-os freestanding  --emit asm

SUPPORT_FILES=gcc/include/
ELF_PREFIX=gcc/bin/msp430-elf-

CODEFILES=src/main.zig Makefile

all: main

main: $(CODEFILES)
	zig build-obj src/main.zig --target-arch msp430 --target-os freestanding --emit asm --release-small --libc-include-dir gcc/include/
# Note, not working yet.
	gcc/bin/msp430-elf-gcc -nostdlib -mmcu=msp430f5510 -msmall -I$(SUPPORT_FILES) -Lsrc -T msp430f5510.ld -ggdb -Wl,-M=output.map zig-cache/main.s -o main.elf
	echo "----------DISASSEMBLY OF ALL SECTIONS---------" > asm.lst
	$(ELF_PREFIX)objdump -D main.elf >> asm.lst
	echo "---------SECTION SUMMARY/SYMBOL TABLE---------" >> asm.lst
	$(ELF_PREFIX)objdump -x main.elf >> asm.lst
	echo "--------------SECTION SIZES-------------------" >> asm.lst
	$(ELF_PREFIX)size main.elf >> asm.lst

debug:
	LD_LIBRARY_PATH=./gcc/bin/ ./mspdebug tilib gdb 2000 &> ./mspdebug.log &
	LD_LIBRARY_PATH=./gcc/bin/ $(ELF_PREFIX)gdb main.elf -ex "target remote :2000"

ezFetToTILib:
	sudo LD_LIBRARY_PATH=./gcc/bin/ ./mspdebug tilib --allow-fw-update
# taken from https://www.pabigot.com/msp430/exp430fr5969-launchpad-first-experiences/

.PHONY: debug ezFetToTILib
