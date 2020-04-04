#include <stdint.h>
#include <stdio.h>
#include <math.h>
#include "msp432p401r.h"

extern int asm_main(int input);


void main() {
    int input, output;

    // Main Loop
    while(1) {
        printf("Enter input: ");

        // Get input from console
        scanf ("%d",&input);

         output = asm_main(input);

        if(output) {
            printf("Number is odd\n");
        } else {
            printf("Number is even\n");
        }
    }

}
