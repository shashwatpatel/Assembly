	.thumb

			.text					; Puts code in ROM

P1IN		.word 0x40004C00
P1SEL0		.word 0x40004C0A
P1SEL1		.word 0x40004C0C
P1OUT		.word 0x40004C02
P1DIR		.word 0x40004C04
P1REN		.word 0x40004C06

			.global asm_main
			.thumbfunc asm_main

			.global port1_init
			.thumbfunc port1_init

; R0 = Input
asm_main:	.asmfunc				; Main
	
  	;Load the value of P1IN
	LDR R5, P1IN
	LDRB R7, [R5]
	;AND with 12 and compare with 10000
	AND R7, R7, #18 ;AND the byte with 10010
	CMP R7, #0x10
	beq right_button ;Jump to right button operations
	CMP R7, #0x02
	beq left_button ;Jump to left button operations
	b exit

; Shift bits to right
right_button:
	;AND R4, R0, #0x80	 ;AND it with 000010000000
	ROR R0, #1	 ;Rotate right 000000000001
	MOV R4, R0
	LSR R4, #24	 ;Logical shift right 11000
	ORR R0, R4, R0 ; ORR both and store in R0
	b exit

; Do the opposite of right button (shift bits to left)
left_button:
	;AND R9, R0, #0x07	 ;AND with 00000111
	LSL R0, #1	 ;Rotate right 000000000001
	MOV R4, R0
	LSR R4, #8   ;Logical shift right 1000

	ORR R0, R4, R0		 ; ORR both and store in R0
	b exit

	        .endasmfunc

port1_init:	.asmfunc				; Port 1 Init
;Initialization of I/O ports
	LDR R1, P1SEL0
	LDRB R2, [R1]
	BIC R2, #0x12
	STRB R2, [R1]

	LDR R1, P1SEL1
	LDRB R2, [R1]
	BIC R2, #0x12
	STRB R2, [R1]

	LDR R1, P1DIR
	LDRB R2, [R1]
	BIC R2, R2, #0x12
	STRB R2, [R1]

	LDR R1, P1REN
	LDRB R2, [R1]
	ORR R2, #0x12
	STRB R2, [R1]

	LDR R1, P1OUT
	LDRB R2, [R1]
	ORR R2, #0x12
	STRB R2, [R1]


	
exit:
	bx		lr						; Return to C program
	        .endasmfunc
	        .end
