TARGET_MCU=msp430f5510
SUPPORT_FILES_DIR=gcc/include

ZZ=zig build-obj
GCC=gcc/bin/
MSPDEBUG=./

PROJECT_FILE=src/main.zig
ZFLAGS=--target-arch msp430 --target-os freestanding --emit asm
ZFLAGS+=--release-small
# LLVM can emit calls to libgcc hardware multiplier routines
ZFLAGS+=-mllvm -mhwmult=32bit
ZFLAGS+=--libc-include-dir gcc/include/ # required to import C Header

CFLAGS=-mmcu=$(TARGET_MCU) -msmall -minrt
CFLAGS+=-I$(SUPPORT_FILES_DIR) -L$(SUPPORT_FILES_DIR)

# Required to link in calls to libgcc hardware multiplier routines
# Change to match width of hardware multiplier for your target
LFLAGS=-lmul_32

OUTPUT=main.elf

CODEFILES=src/main.zig Makefile

all: main

main: $(CODEFILES)
	$(ZZ) $(PROJECT_FILE) $(ZFLAGS)
	$(GCC)msp430-elf-gcc $(CFLAGS) zig-cache/main.s $(LFLAGS) -o $(OUTPUT)
	
	echo "----------DISASSEMBLY OF ALL SECTIONS---------" > asm.lst
	$(GCC)msp430-elf-objdump -D $(OUTPUT) >> asm.lst
	echo "---------SECTION SUMMARY/SYMBOL TABLE---------" >> asm.lst
	$(GCC)msp430-elf-objdump -x $(OUTPUT) >> asm.lst
	echo "--------------SECTION SIZES-------------------" >> asm.lst
	$(GCC)msp430-elf-size $(OUTPUT) >> asm.lst

justGCC: $(CODEFILES)
	$(GCC)msp430-elf-gcc $(CFLAGS) zig-cache/main.s $(LFLAGS) -o $(OUTPUT)
	
	echo "----------DISASSEMBLY OF ALL SECTIONS---------" > asm.lst
	$(GCC)msp430-elf-objdump -D $(OUTPUT) >> asm.lst
	echo "---------SECTION SUMMARY/SYMBOL TABLE---------" >> asm.lst
	$(GCC)msp430-elf-objdump -x $(OUTPUT) >> asm.lst
	echo "--------------SECTION SIZES-------------------" >> asm.lst
	$(GCC)msp430-elf-size $(OUTPUT) >> asm.lst

debug:
	LD_LIBRARY_PATH=$(GCC) $(MSPDEBUG)mspdebug tilib gdb 2000 &> mspdebug.log &
	LD_LIBRARY_PATH=$(GCC) $(GCC)msp430-elf-gdb $(OUTPUT) -ex "target remote :2000" -ex "monitor prog $(OUTPUT)"

attach:
	LD_LIBRARY_PATH=$(GCC) $(MSPDEBUG)mspdebug tilib gdb 2000 &> mspdebug.log &
	LD_LIBRARY_PATH=$(GCC) $(GCC)msp430-elf-gdb $(OUTPUT) -ex "target remote :2000"

ezFetToTILib:
	sudo LD_LIBRARY_PATH=$(GCC) $(MSPDEBUG)mspdebug tilib --allow-fw-update
# taken from https://www.pabigot.com/msp430/exp430fr5969-launchpad-first-experiences/

.PHONY: debug attach ezFetToTILib
