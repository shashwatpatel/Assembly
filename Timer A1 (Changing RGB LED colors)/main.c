#include <stdint.h>
#include <stdio.h>
#include "msp432p401r.h"

extern void asm_main();
extern void TimerA1_ISR();
extern void Port1_ISR();

// Port 1 ISR
void PORT1_IRQHandler() {
    Port1_ISR();        // Call assembly Port 1 ISR
}

// Timer A1 ISR
void TA1_0_IRQHandler() {
    TimerA1_ISR();      // Call assembly ISR
}

void main() {
    asm_main();

    // Main Loop
    while(1);
}
