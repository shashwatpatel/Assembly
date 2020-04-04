			.thumb

			.data


			.text


P1IN		.word	0x40004C00		; Port 1 Input
P1OUT		.word	0x40004C02		; Port 1 Output
P1DIR		.word	0x40004C04		; Port 1 Direction
P1REN		.word	0x40004C06		; Port 1 Resistor Enable
P1SEL0		.word	0x40004C0A		; Port 1 Select 0
P1SEL1		.word	0x40004C0C		; Port 1 Select 1
P1IV		.word	0x40004C0E		; Port 1 interrupt vector register
P1IES		.word	0x40004C18		; Port 1 interrupt edge select
P1IE		.word	0x40004C1A		; Port 1 interrupt enable
P1IFG		.word	0x40004C1C		; Port 1 interrupt flag

P2IN		.word	0x40004C01		; Port 2 Input
P2OUT		.word	0x40004C03		; Port 2 Output
P2DIR		.word	0x40004C05		; Port 2 Direction
P2REN		.word	0x40004C07		; Port 2 Resistor Enable
P2DS		.word	0x40004C09		; Port 2 Drive Strength
P2SEL0		.word	0x40004C0B		; Port 2 Select 0
P2SEL1		.word	0x40004C0D		; Port 2 Select 1

TA1CTL		.word	0x40000400		; TimerAx Control Register
TA1CCTL0	.word	0x40000402		; Timer_A Capture/Compare Control Register
TA1CCR0		.word	0x40000412		; Timer_A Capture/Compare Register
TA1EX0		.word	0x40000420		; Timer_A Expansion Register
TA1R		.word	0x40000410		; TimerA register

NVIC_IPR2	.word	0xE000E408		; NVIC interrupt priority 2
NVIC_IPR8	.word	0xE000E420		; NVIC interrupt priority 8
NVIC_ISER0	.word	0xE000E100		; NVIC enable register 0
NVIC_ISER1	.word	0xE000E104		; NVIC enable register 1

			.global asm_main
			.thumbfunc asm_main

			.global TimerA1_ISR
			.thumbfunc TimerA1_ISR

			.global Port1_ISR
			.thumbfunc Port1_ISR

asm_main:	.asmfunc		; main
	;Call asm functions
	push {lr}
	bl Port2_Init
	bl NVIC_Init
	bl TimerA1_Init
	bl Port1_Init
	pop {lr}
	
    bx      lr
    		.endasmfunc

Port1_Init:	.asmfunc				; Port 1 Init
	
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
	BIC R2, #0x12
	STRB R2, [R1]

	LDR R1, P1REN
	LDRB R2, [R1]
	ORR R2, #0x12
	STRB R2, [R1]

	LDR R1, P1OUT
	LDRB R2, [R1]
	ORR R2, #0x12
	STRB R2, [R1]

	LDR R1, P1IES
	LDRB R2, [R1]
	ORR R2, #0x12
	STRB R2, [R1]

	LDR R1, P1IE
	LDRB R2, [R1]
	ORR R2, #0x12
	STRB R2, [R1]


	bx		lr						; Return to C program
	        .endasmfunc


Port2_Init:	.asmfunc				; Port 2 Init
	;Initialize Pins of Port 2
	LDR R1, P2SEL0
	LDRB R3, [R1]
	BIC R0, #0x01
	STRB R0, [R1]

	LDR R1, P2SEL1
	LDRB R3, [R1]
	BIC R3, #0x01
	STRB R0, [R1]

	LDR R1, P2DIR
	LDRB R3, [R1]
	ORR R0, #7
	STRB R0, [R1]


	bx		lr
	        .endasmfunc

TimerA1_Init:	.asmfunc			; TimerA1_Init

		CPSID I ;Disable IRQ

	LDR R1, TA1CTL
	LDRH R5, [R1]
	MVN R6, #0x0030 ;Movenot 0000000000110000 (inv)
	AND R6, R5 ;Bits 4 and 5 and stop at 00
	STRH R6, [R1]

	;Arm the TAIE and define A clk
	MOV R5, #0x0182
	STRH R5, [R1]

	;Enables Interrupt by CCIFG flag and sets to compare mode
	LDR R4, TA1CCTL0
	MOV R5, #0x0010
	STRH R5, [R4] ;Enable interrupt

	;Compare values and store in TA1CCR0
	LDR R3, TA1CCR0
	MOV R6, #450 ;Changes the speed of timer 300 is faster can slow it by increasing number
	SUBH R6, #1
	STRH R6, [R3]

	;Load up a 3 bit prescale
	LDR R8, TA1EX0
	MOV R5, #0x0005
	STRH R5, [R8]

	;Reset the timer to 0 and start using in Up mode
	LDRH R5, [R1]
	ORR R5, #0x0014
	STRH R5, [R1]


	CPSIE I ;Enable IRQ
					

	bx		lr
	        .endasmfunc

NVIC_Init:	.asmfunc				; NVIC_Init

	LDR R0, NVIC_IPR2
	LDR R4, NVIC_IPR8
	LDR R1, NVIC_ISER0
	LDR R3, NVIC_ISER1


	ORR R2, #0X500000
	STR R2, [R0] ;ipr2

	ORR R2, #0X400
	STR R2, [R1]; ISER0


	ORR R2, #0X40000000
	STR R2, [R4];IPR8

	ORR R2, #0x8
	STR R2, [R3]; ISER1
	bx		lr
	        .endasmfunc

TimerA1_ISR:	.asmfunc			; TimerA1_ISR
	
	LDR R1, TA1CTL
	LDRH R2, [R1]
	MVN R4, #0X01
	AND R4, R2
	STRH R4, [R1]
	b LED_Out ;call the output function

	bx		lr

		.endasmfunc


LED_Out:	.asmfunc				; LED_Out
	; TODO: Complete this SR
	;Set P2In as input and P2OUT as output
	LDR R0, TA1CCTL0
	LDR R5, P2IN
	LDR R1, P2OUT
	LDRB R9, [R5]
	;Increment output and compare
	ADDB R9, #1
	CMP R9, #0X04
	IT EQ ;If then equal to check
	moveq R9, #1
	STRB R9, [R1]
	LDRH R8, [R0]
	BIC R8, #1
	STRH R8, [R0]

	MOV R1, #0x00  ;Reset the LED
	bx		lr
	        .endasmfunc




Port1_ISR:	.asmfunc

	;Load in interrupt flag and acknowledge
	LDR R1, P1IFG
	LDRB R2, [R1]
	BIC R2, #0x12
	STRB R2, [R1]

	LDR R7, P1IN
	LDRB R4, [R7]
	;AND bits and compare values to declare operation
	AND R4, R4, #0x12
	CMP R4, #0x02
	BEQ right_button ;Jump to right button operations
	CMP R4, #0x10
	BEQ left_button ;Jump to left button operations

	b exit

right_button:

	LDR R3, TA1CCR0
	LDRH R6, [R3]
	ADD R6, #100 ;speed up
	STRH R6, [R3]
	b exit

left_button:

	LDR R3, TA1CCR0
	LDRH R6, [R3]
	SUB R6, #50 ;speed down
	STRH R6, [R3]
	b exit

exit:
	bx		lr

	        .endasmfunc
		.end


