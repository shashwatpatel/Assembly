			.thumb

			.data

			.text

; Initialize I/O ports with addresses.
P1IN		.word 0x40004C00
P1SEL0		.word 0x40004C0A
P1SEL1		.word 0x40004C0C
P1OUT		.word 0x40004C02
P1DIR		.word 0x40004C04


			.global asm_main
			.thumbfunc asm_main

; Input: R0
; Output: R0
asm_main:	.asmfunc		; main loop

	PUSH {lr}
	b Port1_init

leave:
	LDR R1, P1OUT ;Load the val of P1In in R1

	BFC R0, #1, #31 ;Bit field clears to 0
	CMP R0, #1
	ITE EQ ; If then equal
	BEQ even
	BNE odd


Port1_init:
;Initialization of I/O ports
	LDR R1, P1SEL0
	LDRB R2, [R1]
	BIC R2, #0x00
	STRB R2, [R1]

	LDR R1, P1SEL1
	LDRB R2, [R1]
	BIC R2, #0x00
	STRB R2, [R1]

	LDR R1, P1DIR
	LDRB R2, [R1]
	ORR R2, #0x01
	STRB R2, [R1]
	b leave

; After checking if even then turn LED on
even:

	LDRB R2, [R1]
	BIC R2, #0x01
	STRB R2, [R1]
	b label

; After checking if odd then turn LED on
odd:
	BIC R2, #0x00
	STRB R2, [R1]

label:
	POP {lr} ; After operation pop value of lr
	bx 	lr
	        .endasmfunc
	        .end
