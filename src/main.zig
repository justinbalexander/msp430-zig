const hw = @cImport({
                      @cInclude("msp430f5510.h");
                    });
const mem = @import("std").mem;
 
extern var __bssstart: u8;
extern var __bsssize: u8;

var silly: u32 = 76;
var inBSS: u32=0;

//export var aoeu: i32 section(".text2") = 1234;


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
  while (true) {
      silly+=1;
      if (silly > 0x7FFF){
        inBSS+=1;
      }
  }
}
