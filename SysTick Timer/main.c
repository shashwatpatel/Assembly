#include <stdint.h>
#include <stdio.h>
#include "msp432p401r.h"

extern void asm_main();
extern void Port2_Init();
extern void SysTick_Init();
extern void Port1_Init();
extern void NVIC_Init();

void PORT1_IRQHandler() {
    Port1_ISR(); // Call assembly Port 1 ISR
    }
void main(){

    Port2_Init();
    SysTick_Init();
    NVIC_Init();
    Port1_Init();

   while(1)
   {
       asm_main();
   }

}
