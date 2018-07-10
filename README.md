# Introduction

This is a starter repository for msp430 development using the Zig programming
language.

Development was done on the MSP430F5510-STK board from Olimex because it has
some built in peripherals to make testing easy and portable.

I could never get the MSPDebug stack that comes with MSPGCC to program the MCU
and so the excellent and free mspdebug is used as a gdb stub.

The msp430 llvm backend is incapable of producing object code currently, and so
Zig instructs llvm to produce assembly which is then assembled and linked using
the free MSPGCC toolset from TI.

The msp430 device header in Zig is produced by modifying a TI provided device
specific header using a series of sed commands. The produced header is not
committed in the repository in order to avoid any licensing issues, but it will
be automatically created for you when you compile the project using make.

Modify the `TARGET_MCU` Makefile variable to target the exact msp430 device for
your project.

# Setup

  1. Download the latest stable MSPGCC for MSP430 from TI and copy
      the folder 'gcc' to the top level of the repository.
  2. Download mspdebug and copy the executable to the top level of the repository.
  3. Upgrade Launchpad firmware to tilib firmware with `make ezFetToTILib`.
      Must be root as device ID will change during firmware update.
  4. Copy udev rules to `/etc/udev/rules.d/` so that root privileges are not
      needed for subsequent uses of mspdebug.

# Building

```
make
```

1. Creates header (if it doesn't already exist)
2. Builds the elf file and creates listing `asm.lst`

```
make debug
```

1. Starts gdb session.
2. Erases memory and programs device.

```
make attach
```

1. Starts gdb session without programming device.

```
make justZig
```

1. Only invokes Zig compiler. Emits assembly file.

```
make justGCC
```

1. Invokes GCC to assemble file produced by justZig target.
2. Creating elf file in two steps allows editing of assembly file.

```
make deviceHeaderToZig
```

1. Based on `TARGET_MCU` variable in Makefile, modifies TI header and stores in
   include directory as `$(TARGET_MCU).zig`

```
make ezFetToTILib
```

1. Invokes mspdebug and upgrades Launchpad firmware to tilib (FET430UIF)
   firmware.
2. Invoked with sudo automatically.

# Notes

## Hardware multiplication

One of the flags passed to Zig is the msp430 llvm backend option
`-mhwmult=f5series`. This allows llvm to generate calls to the MSPGCC provided
hardware multiplier routines. This library needs to be linked in. See the
variable `LFLAGS` in the Makefile as well.  The options for hardware
multiplication and corresponding library are:

| HW OPTION | LIBRARY |
| ---------|--------- |
| "none" | -lmul_none |
| "16bit" | -lmul_16 |
| "32bit" | -lmul_32 |
| "f5series" | -lmul_f5 |

Note: the selection happens automatically when we use gcc's runtime (ie. don't
pass in the options `-nostartfiles` or `-nostdlib` to gcc). You must still
select the correct hardware multiplier for your target to llvm. gcc might be
unable to link, thus warning you if you pass the incorrect option to llvm.

I was never able to link when the hardware multiplier was needed and
`-nostdlib` was used. The symbol `__mspabi_mpyll` was always missing.

## Code and Data Models

llvm emits assembly code that uses the mnemonic "call" and "ret" to enter
subroutines. These instructions can only reach into the lower 64K of memory.
However, the assembler will automatically translate the mnemonics to the correct
"calla" and "reta" instructions if applicable based on the command line
parameters "-msmall" or "-mlarge".
