ENTRY(_start)

/* Set stacksize here */
STACKSIZE = 512

MEMORY {
  PERIPHERALS : ORIGIN = 0x0000, LENGTH = 4K
  BSL : ORIGIN = 0x1000, LENGTH = 2K
  INFOMEM : ORIGIN = 0x1800, LENGTH = 512
  INFOD : ORIGIN = 0x1800, LENGTH = 128
  INFOC : ORIGIN = 0x1880, LENGTH = 128
  INFOB : ORIGIN = 0x1900, LENGTH = 128
  INFOA : ORIGIN = 0x1980, LENGTH = 128
  USBRAM : ORIGIN = 0x1C00, LENGTH = 2K

  /* Ensures RAM data doesn't spill into stack */
  RAM : ORIGIN = 0x2400, LENGTH = 4K - STACKSIZE
  STACK : ORIGIN = 0x2400 + 4K - STACKSIZE, LENGTH = STACKSIZE

  ROM : ORIGIN = 0x8000, LENGTH = 32K - (23*2)
  ISR : ORIGIN = 0xFFD2, LENGTH = 23*2
}

SECTIONS {
  .isrvectors :
  {
    . = ALIGN(2);
    KEEP (*(.isrvectors))
  } > ISR

  .rodata :
  {
    . = ALIGN(2);
    *(.rodata)
  } > ROM

  .info      : {*(.info)}  > INFOMEM
  .infoA     : {*(.infoA)} > INFOA
  .infoB     : {*(.infoB)} > INFOB
  .infoC     : {*(.infoC)} > INFOC
  .infoD     : {*(.infoD)} > INFOD

  .text :
  {
    . = ALIGN(2);
    KEEP(*(.text.boot))
    *(.text)
  } > ROM

  .data :
  {
    . = ALIGN(2);
    *(.data)
  } > RAM

  .stack :
  {
    PROVIDE (__stack = ORIGIN(RAM) + LENGTH(RAM));
    *(.stack)
  } > STACK
  
  .bss :
  {
    . = ALIGN(2);
    PROVIDE (__bssstart = .);
    *(.bss)
    . = ALIGN(2);
    *(COMMON)
    PROVIDE (__bssend = .);
  } > RAM
  PROVIDE (__bsssize = SIZEOF(.bss));
