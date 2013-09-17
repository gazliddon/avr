        .include        "ports.i"
        .include        "delays.i"

	.global 	hSyncISR	
	.global 	hSyncInit


	.section 	.bss

hLineW:
	.word 		0

	
	.section 	.text

hSyncInit:
	rcall 	r012
	rcall 	portCMark

	sts 	hLineW, r0 		;; Zero hline counter
	sts 	hLineW+1, r0

	;; Set up timer 0 counter
	out 	TCCR0A, r0 		;; Normal mode, counting up
	ldi 	r16, 0b00000010 	;; 8 prescale
	out 	TCCR0B, 16

	out 	PORTD, r1 		; Pixel data on

	sei
	out 	TCNT0,r0  		;; reset timer 0


	;; Do ten lines
	
1:	lds 	r16,hLineW
	cpi 	r16,10
	brne 	1b

;; exit
	rcall 	portCMark
	rjmp 	sleep

;; Horizontal sync Int service routine

hSyncISR:
	push 	r16
	in 	r16, SREG
	push 	r16

	;; Bump hlIneW
	lds 	r16,hLineW
	add 	r16,r1
	sts 	hLineW, r16
	lds 	r16, hLineW+1
	adc 	r16,r0
	sts 	hLineW+1, r16

	;; Stabilise to a known value
1:	in 	r16, TCNT0
	cpi 	r16,72
	brne 	1b

	ldi 	r16, 14 	; 1
        rcall   delay3xplus8    ; 2  = 3 + 50

	out 	TCNT0, r0 		; 55
	out 	PORTB, r1 		; 56

	ldi 	r16, 14    		; 57
	rcall 	delay3xplus8 	; 58 3 + 71
	nop			; 74

	out 	PORTB, r0 		; 75
	out 	PORTD, r1 		; Pixel data on

	rcall 	lineRoutine
	pop 	r16
	out 	SREG, r16
	pop 	r16
	reti


lineRoutine:
	ret
