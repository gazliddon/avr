
	.global	main
	.global	__vectors
	.global	delayxplus16

	.section ".vectors"

__vectors:
	rjmp 	main                    ; Vector for start of projects

	; Thus routine is exactly 10 words :)
delayxplus16:
	; 3 + 13 + xoff                 ; Some code to fill in the space :D

1:		
	subi	r16, 3			;				1   \_ 3 * (x / 3) + 2
	brsh	1b			;				1/2 /
	neg	r16			; [1,2,3], inverse of time left	1
	sbrs	r16, 0			;				1/2 \_ 2 if set, 3 if clear
	rjmp	.			;				2   /
	sbrs	r16, 1			;				1/2 \_ 2 if set, 3 if clear
	rjmp .				;				2   /
	sbrs	r16, 1			;				1/2 \_ 2 if set, 3 if clear
	rjmp .				;				2   /
	ret				;				4

	rjmp	__vector_11             ;  Vector for Hblank routine


main:   
	; Poke values from a table into registers
	eor	r1, r1

	ldi	r30, lo8(pokelist)
	ldi	r31, hi8(pokelist)
	ldi	r27, 0
1:
	lpm	r26, Z+         ; Load from Z and post inc into R26
	tst	r26             ; If it's zero we're done
	breq	2f
	lpm	r16, Z+         ; Get the value we're going to store
	st	X, r16          ; Store it in the register
	rjmp	1b              ; Loop!

;; Really not sure what this does
2:
	ldi     27, 0x01

3:	st	X+, r1
	cpi	r27, 0x05
	brne	3b
	cli


asminit:
	rjmp	mainloop

; 	Horizontal blank intterupt       
__vector_11:

	reti

mainloop:
                rjmp mainloop

pokelist:
	.byte	0x5e,	0x02	;; SPH
	.byte	0x5d,	0xff	;; SPL

	.byte	0x24,	0x0e	;; DDRB
	.byte	0x25,	0x02	;; PORTB
	.byte	0x27,	0x3f	;; DDRC
	.byte	0x2a,	0xff	;; DDRD

	.byte	0x4c,	0x50	;; SPCR
	.byte	0x4d,	0x01	;; SPSR

	.byte	0x6f,	0x02	;; TIMSK1       Enable timer A
	.byte	0x80,	0x33	;; TCCR1A       Is this right? Toggle OC1 on timer match + 10bit PWN
	.byte	0x81,	0x19	;; TCCR1B       No prescaler, clear counter on match, mysterious 0x10
	.byte	0x89,	0x02	;; OCR1AH
	.byte	0x88,	0x7b	;; OCR1AL 	Timer compare every 635 cycles (adjust from Craft 634)

	.byte	0x8b,	0x00	;; OCR2BH
	.byte	0x8a,	0x4b	;; OCR2BL
	.byte	0xb0,	0x33	;; TCCR2A

	.byte	0xb1,	0x0a	;; CCR2B

	.byte	0, 0



