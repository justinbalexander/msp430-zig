const hw = @cImport({
                      @cInclude("msp430f5510.h");
                    });
const mem = @import("std").mem;
const builtin = @import("builtin");
 
extern var __bssstart: u8;
extern var __bsssize: u8;
extern var PBOUT_H: u8;
extern var PBDIR_H: u8;

var silly: u32 = 76;
var inBSS: u32=0;


export const reset_vector: nakedcc fn() void section(".isr.system_reset") = _start;
export nakedcc fn _start() section(".text.boot") noreturn {
  // Setup stack pointer
  asm volatile (
        \\ mov #0x3400, sp
        \\ mov sp, r4
        );

  // Initialize bss
  if (@ptrToInt(&__bsssize) > 0)
  {
    const len = @ptrToInt(&__bsssize);
    var bss_ptr = @ptrCast([*]u8, &__bssstart);
    var bss_slice = bss_ptr[0..len];
    @inlineCall(mem.set, u8, bss_slice, 0);
  }
  
  // TODO: Initialized data


  @noInlineCall(main);
}

export fn main() noreturn {
  hw.WDTCTL = hw.WDTPW + hw.WDTHOLD;
  @noInlineCall(initPorts);
  @noInlineCall(initTimerISR);
  asm volatile ("NOP");
  asm volatile ("EINT");
  while (true) {
      silly+=1;
      if (silly > 0x7FFF){
        inBSS+=1;
      }
  }
}

fn initTimerISR() void {
  const ta0ctl_ptr = @ptrCast(*volatile u16, &hw.TA0CTL);
  ta0ctl_ptr.* = hw.MC__STOP;
  hw.TA0CCTL0 = hw.OUTMOD_4 + hw.CCIE;
  hw.TA0CCR0 = 0x1000;
  hw.TA0CTL = hw.TASSEL__SMCLK + hw.MC__UP + hw.ID_3 + hw.TACLR;
}

fn initPorts() void {
  PBOUT_H &= ~u8(0x80);
  PBDIR_H |= u8(1<<7);
}

export const ta0_vector: nakedcc fn() void section(".isr.ta0") = ta0;
export nakedcc fn ta0() void {
  PBOUT_H ^= 1<<7;
  asm volatile ("reti");
}
