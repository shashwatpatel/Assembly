#include <stdint.h>
#include <stdio.h>
#include "msp432p401r.h"

extern int asm_main(int cur_val);
extern void port1_init();

void bin_conv(int n, int bits) {
    int c, k;
    for (c = bits-1; c >= 0; c--) {
        k = n >> c;
        if (k & 1) {
            printf("1");
        } else {
            printf("0");
        }
    }

    printf("\n");
}

void main() {
    int cur_val = 0x3C;
    port1_init();

    // Main Loop
    while(1) {
        cur_val = asm_main(cur_val);
        bin_conv(cur_val,8);
    }
}
