const msp = @import("../include/msp430f5510.zig");
 
var inData: u16 = 76;
var inBSS: u16 = 0;

export fn main() noreturn {
  msp.WDTCTL.* = msp.WDTPW + msp.WDTHOLD;
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
  msp.TA0CTL.* = msp.MC__STOP;
  msp.TA0CCTL0.* = msp.OUTMOD_4 + msp.CCIE;
  msp.TA0CCR0.* = 0x1000;
  msp.TA0CTL.* = msp.TASSEL__SMCLK + msp.MC__UP + msp.ID_3 + msp.TACLR;
}

fn initPorts() void {
const BIT7t = 0x80;
  msp.P4OUT.* = msp.P4OUT.* & 0x7f;
  msp.P4DIR.* = msp.P4DIR.* | msp.BIT7;
}

export const ta0_vector section("__interrupt_vector_timer0_a0") = ta0;
export nakedcc fn ta0() void {
  msp.P4OUT.* = msp.P4OUT.* ^ 0x80;
  asm volatile ("reti");
}
