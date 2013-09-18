        .include        "ports.i"
        .include        "delays.i"
	.include "avr.i"

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

start = 100
t0start = 0
	ldi 	r16,lo8(start)
	ldi 	r17,hi8(start)
	ldi 	r18,t0start 
	sts 	TCNT1L, r16
	sts 	TCNT1H, r17
	out 	TCNT0,r18  		;; reset timer 0

	sei

	ldi r17,0xff
	ldi r18,0x80
	;; Do ten lines
1: 	out PORTC, r17
	out PORTC, r18
	nop
	lds 	r16, hLineW
	cpi 	r16, 255
	brne 	1b

	cli

;; exit
	rcall 	portCMark
	rjmp 	sleep

;; Horizontal sync Int service routine
hSyncISR:
	push 	r16
	in 	r16, SREG
	push 	r16
	push 	r27
	push 	r26

	ldi 	r27, 0 				; Remove any jitter (align to 
	ldi 	r26, TCNT1L
11:	ld 	r16, X
	andi 	r16, 3
	brne 	11b

	lds 	r27,hLineW 	; 1 = 6
	;; Stabilise to a known value
1:	in 	r16, TCNT0
	cpi 	r16,78 		; 624
	brlt 	1b 		; 625

	;; Bump hlIneW
	add 	r27,r1 		; 1
	sts 	hLineW, r27     ; 1
	lds 	r16, hLineW+1   ; 1
	adc 	r16,r0 		; 1
	out TCNT0,r0 		; 633 (tcnt will be set on 634)
	sts 	hLineW+1, r16 	; 1


	out 	PORTB, r1 		; 0 (1)
	ldi 	r16, 22    		; 1 (1)
	rcall 	delay3xplus8 		; 2 (74) 
	out 	PORTB, r0 		; 76 (1)

	rcall 	lineRoutine
	
	pop 	r26
	pop 	r27
	pop 	r16
	out 	SREG, r16
	pop 	r16
	reti


lineRoutine:
	out 	PORTD, r1 		; 77 (1) (hsync now low)
	ldi 	r16,10
	rcall 	delay3xplus8
	out 	PORTD, r0
	ret
