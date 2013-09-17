	.include "avr.i"
	.include "ports.i"
	.include "delays.i"

	.section .vectors
	rjmp 	main            ; v01 Vector for start of projects
	rjmp    sleep	        ; v02
	rjmp    sleep	
	rjmp    sleep
	rjmp    sleep
	rjmp    sleep
	rjmp    sleep
	rjmp    sleep
	rjmp    sleep
	rjmp    sleep
	rjmp    sleep
	rjmp    hSyncISR	; v11

	.section .text
; 	Horizontal blank intterupt       
main:
	cli
	ldi 	r30, lo8(gpoke)
	ldi 	r31, hi8(gpoke)
	rcall 	doPokes

        rjmp    hSyncInit


CYCLES_PER_LINE = 634

gpoke:
	.byte mem_DDRB,0xff
	.byte mem_DDRC,0xff
	.byte mem_DDRD,0xff

	.byte TCCR1A, 0
	.byte TCCR1B, 0
	.byte TCNT1L, 0
	.byte TCNT1H, 0

	.byte OCR1AL, CYCLES_PER_LINE & 0xff
	.byte OCR1AH, CYCLES_PER_LINE >> 8

	.byte TCCR1B, ((1<< WGM12) | (1<<CS12))
	.byte TIMSK1, (1 << OCIE1A)
	.byte 0,0


