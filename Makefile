# Set targeted mcu. Use lowercase letters to match filenames in gcc/include
TARGET_MCU=msp430f5510
SUPPORT_FILES_DIR=gcc/include

ZZ=zig
GCC=gcc/bin/
MSPDEBUG=./

PROJECT_FILE=src/main.zig
ASSEMBLY_FILE=zig-cache/main.s
ZFLAGS=build-obj --target-arch msp430 --target-os freestanding --emit asm
ZFLAGS+=--release-small
# LLVM can emit calls to libgcc hardware multiplier routines
ZFLAGS+=-mllvm -mhwmult=f5series

CFLAGS=-mmcu=$(TARGET_MCU) -msmall -minrt
CFLAGS+=-I$(SUPPORT_FILES_DIR) -L$(SUPPORT_FILES_DIR)

# Required to link in calls to libgcc hardware multiplier routines
# if the options -nostartfiles or -nostdlib are selected
# Change to match width of hardware multiplier for your target
# LFLAGS=-lmul_f5

OUTPUT=main.elf

CODEFILES=src/main.zig Makefile

all: main

main: deviceHeaderToZig justZig justGCC

justZig: $(CODEFILES)
	$(ZZ) $(ZFLAGS) $(PROJECT_FILE)

justGCC: $(CODEFILES) $(ASSEMBLY_FILE)
	$(GCC)msp430-elf-gcc $(CFLAGS) $(ASSEMBLY_FILE) $(LFLAGS) -o $(OUTPUT)
	echo "----------DISASSEMBLY OF ALL SECTIONS---------" > asm.lst
	$(GCC)msp430-elf-objdump -D $(OUTPUT) >> asm.lst
	echo "---------SECTION SUMMARY/SYMBOL TABLE---------" >> asm.lst
	$(GCC)msp430-elf-objdump -x $(OUTPUT) >> asm.lst
	echo "--------------SECTION SIZES-------------------" >> asm.lst
	$(GCC)msp430-elf-size $(OUTPUT) >> asm.lst

# Based on TARGET_MCU definition above, converts ld symbols and header
# to zig compatible definitions. Places converted file into include/
deviceHeaderToZig:
ifeq (,$(wildcard include/$(TARGET_MCU).zig)) # only remake if necessary
	cat $(SUPPORT_FILES_DIR)/$(TARGET_MCU)_symbols.ld $(SUPPORT_FILES_DIR)/$(TARGET_MCU).h | sed 's/#/san1/g' | $(GCC)msp430-elf-gcc -P -E - | sed 's/san1/#/g' |	sed -r -f util/mspheaderconvert.sed	| awk '!seen[$$0]++' > include/$(TARGET_MCU).zig
endif

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
