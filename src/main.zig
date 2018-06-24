const hw = @cImport({
                      @cInclude("msp430f5510.h");
                    });
 
// Needed for now as @cInclude not importing definition correctly
extern var PBOUT_H: u8;
extern var PBDIR_H: u8;

var inData: u16 = 76;
var inBSS: u16 = 0;

export fn main() noreturn {
  hw.WDTCTL = hw.WDTPW + hw.WDTHOLD;
  @noInlineCall(initPorts);
  @noInlineCall(initTimerISR);
  asm volatile ("NOP");
  asm volatile ("EINT");
  while (true) {
    @noInlineCall(aFunction);
  }
}

fn aFunction() void {
  inData+=1;
  if (inData > 0x7FFF){
    inBSS+=inData;
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
  PBDIR_H |= 1<<7;
}

export const ta0_vector section("__interrupt_vector_timer0_a0") = ta0;
export nakedcc fn ta0() void {
  PBOUT_H ^= 1<<7;
  asm volatile ("reti");
}
