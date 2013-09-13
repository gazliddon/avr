	.include "avr.i"
	.include "ports.i"

	.section ".vectors"
	rjmp 	main                    ; v01 Vector for start of projects
	rjmp 	__vector_01
	rjmp 	__vector_02
	rjmp 	__vector_03
	rjmp 	__vector_04
	rjmp 	__vector_05
	rjmp 	__vector_06
	rjmp 	__vector_07
	rjmp 	__vector_08
	rjmp 	__vector_09
	rjmp 	__vector_10
	rjmp 	__vector_11

	.section ".text"

__vector_01:
__vector_02:
__vector_03:
__vector_04:
__vector_05:
__vector_06:
__vector_07:
__vector_08:
__vector_09:
__vector_10:
	rjmp exit


; 	Horizontal blank intterupt       
__vector_11:
	push 	r16
	in 	r16, SREG
	push 	r16
	push 	r26
	push 	r27

	ldi 	r26, lo8(myVar)
	ldi 	r27, hi8(myVar)

	;; Increment myVar by 1
	ld 	r1,X 		; Get the val we're writing
	inc 	r1
	st 	X,r1 		; store it to *X (26:27)

	out 	PORTD, r1 	; Output it on port d

	pop 	r27
	pop 	r26
	pop 	r16
	out 	SREG, r16
	pop 	r16
	reti


main:
	cli
	
	ldi 	r30, lo8(gpoke)
	ldi 	r31, hi8(gpoke)
	rcall 	doPokes
	

	sei
1: 	rjmp	1b

	.section ".bss"

	.global myVar
myVar:	.byte 0

	.section ".data"

	COUNT = 0x1000
gpoke:
	.byte mem_DDRB,0x7f

	.byte TCCR1A, 0
	.byte TCCR1B, 0
	.byte TCNT1L, 0
	.byte TCNT1H, 0

	.byte OCR1AL, COUNT & 0xff
	.byte OCR1AH, COUNT >> 8
	.byte TCCR1B, ((1<< WGM12) | (1<<CS12))
	.byte TIMSK1, (1 << OCIE1A)
	.byte 0,0


