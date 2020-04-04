
		.thumb

			.data

			.text			; Puts code in ROM
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

NVIC_IPR2	.word	0xE000E408		; NVIC interrupt priority 2
NVIC_IPR8	.word	0xE000E420		; NVIC interrupt priority 8
NVIC_ISER0	.word	0xE000E100		; NVIC enable register 0
NVIC_ISER1	.word	0xE000E104		; NVIC enable register 1

STCSR		.word	0xE000E010		;basic control of SysTick e.g. enable, clock source, interrupt or poll
STRVR		.word	0xE000E014		;value to load Current Value register when 0 is reached
STCVR		.word	0xE000E018		;the current value of the count down.
STCALIB		.word	0xE000E01C		;might contain the number of ticks to generate a 10ms interval and other information, depending on the implementation




			.global asm_main
			.thumbfunc asm_main

			.global Port2_Init
			.thumbfunc Port2_Init

			.global SysTick_Init
			.thumbfunc SysTick_Init

			.global NVIC_Init
			.thumbfunc NVIC_Init

			.global Port1_Init
			.thumbfunc Port1_Init

			.global Port1_ISR
			.thumbfunc Port1_ISR

asm_main:	.asmfunc		; main

reset:
	mov r5, #0 ;Reset counter

SysTick_Polling:
	;Increment and compare values if equal then check else re run
	ADD R5, #1
	CMP R5, #0x1000
	BEQ check
	b SysTick_Polling
	bx		lr

check:
	;Load in control of systick
	LDR R1, STCSR
	LDR R5, [R1]
	;Checking conditions to set up toggle LED
	AND R5, #0x10000
	CMP R5, #0x10000
	BEQ toggle
	b SysTick_Polling
	;bx 	lr

toggle:
	;Load in P1OUT and use EOR to toggle
	LDR R1, P2OUT
	LDRB R10, [R1]
	EOR R10, #1
	STRB R10, [R1]
	b reset
	.endasmfunc

NVIC_Init:	.asmfunc				; NVIC_Init


	LDR R4, NVIC_IPR8
	LDR R1, [R4]
	ORR R1, #0X40000000
	STR R1, [R4];IPR8

	LDR R4, NVIC_ISER1
	LDR R1, [R4]
	ORR R1, #8
	STR R1, [R4]; ISER1

	cpsie i
	bx		lr
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

	LDR R1, P1OUT
	LDRB R2, [R1]
	ORR R2, #0x12
	STRB R2, [R1]

	LDR R1, P1DIR
	LDRB R2, [R1]
	BIC R2, R2, #0x12
	STRB R2, [R1]

	LDR R1, P1IES
	LDRB R2, [R1]
	ORR R2, #0x12
	STRB R2, [R1]

	LDR R1, P1IE
	LDRH R2, [R1]
	ORR R2, #0x12
	STRH R2, [R1]

	LDR R1, P1REN
	LDRB R2, [R1]
	ORR R2, #0x12
	STRB R2, [R1]
	bx		lr
	        .endasmfunc

Port2_Init:		.asmfunc

	LDR R1, P2SEL0
	LDRB R2, [R1]
	BIC R2, #0x01
	STRB R2, [R1]

	LDR R1, P2SEL1
	LDRB R2, [R1]
	BIC R2, #0x01
	STRB R2, [R1]

	LDR R1, P2DIR
	LDRB R2, [R1]
	ORR R2, #0x01
	STRB R2, [R1]

	bx lr

			.endasmfunc

SysTick_Init:	.asmfunc
	LDR R1, STCSR ;Load in clk source
	LDR R9, [R1]
	BIC R9, #1 ;clear last bit to 0
	STR R9, [R1]


	LDR R1, STRVR ;load value of register
	MOV R9, #0xFFFF
	;Add and store the value 1111111111111111
	ADD R9, R9
	ADD R9, R9
	ADD R9, R9
	ADD R9, R9
	STR R9, [R1]

	MOV R9, #77

	LDR R1, STCVR
	STR R9, [R1]

	LDR R1, STCSR
	ORR R9, #0x05
	BIC R9, #2
	STR R9, [R1]




			bx		lr
			 .endasmfunc

Port1_ISR:	.asmfunc
	;Load and acknowledge p1ifg

	LDR R1, P1IFG
	LDRB R2, [R1]
	BIC R2, #0x12
	STRB R2, [R1]

	LDR R7, P1IN
	LDRB R4, [R7]
	AND R4, R4, #0x12
	AND R5, R4, #2
	AND R6, R4, #0x10
	CMP R6, #0x10
	BEQ right_button ;Jump to right button operations
	CMP R5, #0x02
	BEQ left_button ;Jump to left button operations


right_button:

	MOV R4, #0xFFFF
	LDR R3, STRVR
	LDR R6, [R3]
	ADD R6, R4 ;Changes the speed of timer 300 is faster can slow it by increasing number
	STR R6, [R3]
	bx	lr

left_button:

	MOV R4, #0xFFFF
	LDR R3, STRVR
	LDR R6, [R3]
	SUB R6, R4 ;Changes the speed of timer 300 is faster can slow it by increasing number

	STR R6, [R3]


	bx		lr				; return to C program
;l:
	;bx	lr
.endasmfunc


	        .endasmfunc
	        .end






