			.thumb

			.data

			.text			; Puts code in ROM


			.global asm_main
			.thumbfunc asm_main

asm_main:	.asmfunc		; main

	mov r0, #1
	mov r1, #6

	push {lr} ;address of next line of cide stored into lr
	bl factorial

	bx		lr

factorial:

	;check if R0 is 1 then move
	cmp r1, #1 ;compares values after checking
	BEQ shift

	;else statement execution
	push {r1}
	sub r1, r1, #1
	push {LR}
	bl factorial ;jumps back and executes the loop again

	;perform the calculations
	pop {r1}
	mul r0, r1, r0
	pop {PC}

shift:
	pop {PC}
	        .endasmfunc
	        .end

