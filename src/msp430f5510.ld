ENTRY(_start)

/* Set stacksize here */
/*STACKSIZE = 512*/

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
  RAM : ORIGIN = 0x2400, LENGTH = 4K - 512
  STACK : ORIGIN = 0x2400 + 4K - 512, LENGTH = 512

  ROM : ORIGIN = 0x8000, LENGTH = 0xFFD2 - 0x8000

  ISR41 : ORIGIN = 0xFFD2, LENGTH = 2
  ISR42 : ORIGIN = 0xFFD4, LENGTH = 2
  ISR43 : ORIGIN = 0xFFD6, LENGTH = 2
  ISR44 : ORIGIN = 0xFFD8, LENGTH = 2
  ISR45 : ORIGIN = 0xFFDA, LENGTH = 2
  ISR46 : ORIGIN = 0xFFDC, LENGTH = 2
  ISR47 : ORIGIN = 0xFFDE, LENGTH = 2
  ISR48 : ORIGIN = 0xFFE0, LENGTH = 2
  ISR49 : ORIGIN = 0xFFE2, LENGTH = 2
  ISR50 : ORIGIN = 0xFFE4, LENGTH = 2
  ISR51 : ORIGIN = 0xFFE6, LENGTH = 2
  ISR52 : ORIGIN = 0xFFE8, LENGTH = 2
  ISR53 : ORIGIN = 0xFFEA, LENGTH = 2
  ISR54 : ORIGIN = 0xFFEC, LENGTH = 2
  ISR55 : ORIGIN = 0xFFEE, LENGTH = 2
  ISR56 : ORIGIN = 0xFFF0, LENGTH = 2
  ISR57 : ORIGIN = 0xFFF2, LENGTH = 2
  ISR58 : ORIGIN = 0xFFF4, LENGTH = 2
  ISR59 : ORIGIN = 0xFFF6, LENGTH = 2
  ISR60 : ORIGIN = 0xFFF8, LENGTH = 2
  ISR61 : ORIGIN = 0xFFFA, LENGTH = 2
  ISR62 : ORIGIN = 0xFFFC, LENGTH = 2
  ISR63 : ORIGIN = 0xFFFE, LENGTH = 2
}

SECTIONS {
  .rodata :
  {
    . = ALIGN(2);
    *(.rodata .rodata.*)
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
    *(.text .text.*)
  } > ROM

  .data :
  {
    . = ALIGN(2);
    *(.data .data.*)
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
    *(.bss .bss.*)
    . = ALIGN(2);
    *(COMMON)
    PROVIDE (__bssend = .);
  } > RAM
  PROVIDE (__bsssize = SIZEOF(.bss));

  .isr.rtc_a :
  {
    KEEP(*(.isr.rtc_a))
  } > ISR41

  .isr.p2 :
  {
    KEEP(*(.isr.p2))
  } > ISR41

  .isr.ta2iv :
  {
    KEEP(*(.isr.ta2iv))
  } > ISR43

  .isr.ta2 :
  {
    KEEP(*(.isr.ta2))
  } > ISR44

  .isr.usci_b1 :
  {
    KEEP(*(.isr.usci_b1))
  } > ISR45

  .isr.usci_a1 :
  {
    KEEP(*(.isr.usci_a1))
  } > ISR46

  .isr.p1 :
  {
    KEEP(*(.isr.p1))
  } > ISR47

  .isr.ta1iv :
  {
    KEEP(*(.isr.ta1iv))
  } > ISR48

  .isr.ta1 :
  {
    KEEP(*(.isr.ta1))
  } > ISR49

  .isr.dma :
  {
    KEEP(*(.isr.dma))
  } > ISR50

  .isr.usb_ubm :
  {
    KEEP(*(.isr.usb_ubm))
  } > ISR51

  .isr.ta0iv :
  {
    KEEP(*(.isr.ta0iv))
  } > ISR52

  .isr.ta0 :
  {
    KEEP(*(.isr.ta0))
  } > ISR53

  .isr.ta0iv :
  {
    KEEP(*(.isr.ta0iv))
  } > ISR54

  .isr.usci_b0 :
  {
    KEEP(*(.isr.usci_b0))
  } > ISR55

  .isr.usci_a0 :
  {
    KEEP(*(.isr.usci_a0))
  } > ISR56

  .isr.wdt :
  {
    KEEP(*(.isr.wdt))
  } > ISR57

  .isr.tb0iv :
  {
    KEEP(*(.isr.tb0iv))
  } > ISR58

  .isr.tb0 :
  {
    KEEP(*(.isr.tb0))
  } > ISR59

  .isr.comp_b :
  {
    KEEP(*(.isr.comp_b))
  } > ISR60

  .isr.user_nmi :
  {
    KEEP(*(.isr.user_nmi))
  } > ISR61

  .isr.system_nmi :
  {
    KEEP(*(.isr.system_nmi))
  } > ISR62

  .isr.system_reset :
  {
    KEEP(*(.isr.system_reset))
  } > ISR63


}

INCLUDE msp430f5510_symbols.ld
