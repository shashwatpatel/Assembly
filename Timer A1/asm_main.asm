			.thumb

			.data
OUT			.byte	0				; LED Output
;CYC			.half	0000000111000000			; Cycles

			.text
;CYC_ptr		.word	CYC				; Pointer to cycles
OUT_ptr		.word	OUT				; Pointer to LED Output

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

NVIC_IPR2	.word	0xE000E408		; NVIC interrupt priority 2
NVIC_ISER0	.word	0xE000E100		; NVIC enable register 0

			.global asm_main
			.thumbfunc asm_main

			.global TimerA1_ISR
			.thumbfunc TimerA1_ISR

asm_main:	.asmfunc		; main
	;Call the functions
	push {lr}
	bl Port2_Init
	bl NVIC_Init
	bl TimerA1_Init
	pop {lr}
    bx      lr
    		.endasmfunc

Port2_Init:	.asmfunc				; Port 2 Init
	; TODO: Complete this SR
	;Initialization of I/O ports
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

NVIC_Init:	.asmfunc				; NVIC_Init
	; TODO: Complete this SR

	LDR R0, NVIC_IPR2
	LDR R1, NVIC_ISER0
	ORR R2, #0x00400000
	STR R2, [R0] ;Updates the value of IPR 2
	;enable interrupt in NVIC
	ORR R2, #0x0000400
	STR R2, [R1] ;Updates the value of NVIC interrupt and enables it
	bx		lr
	        .endasmfunc


TimerA1_Init:	.asmfunc			; TimerA1_Init
	; TODO: Complete this SR
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
	MOV R6, #300 ;Changes the speed of timer 300 is faster can slow it by increasing number
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



TimerA1_ISR:	.asmfunc			; TimerA1_ISR
	; TODO: Complete this ISR
	;Triggers acknowledge
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


	        .end
