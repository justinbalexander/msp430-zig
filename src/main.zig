const hw = @cImport({
                      @cInclude("msp430f5510.h");
                    });
 
extern var __bssstart: u8;
extern var __bssend: u8;

export nakedcc fn _start() section(".text.boot") noreturn
{
  // Setup stack pointer
  asm volatile ("mov #0x3400, sp");

  // Initialize bss
  if (@ptrToInt(&__bssend) > @ptrToInt(&__bssstart))
  {
    @memset((*volatile [1]u8)(&__bssstart), 0, @ptrToInt(&__bssend) - @ptrToInt(&__bssstart));
  }
  
  // TODO: Initialized data


  main();
}

export fn main() noreturn {
  hw.WDTCTL = hw.WDTPW + hw.WDTHOLD;
  while (true) {}
}
