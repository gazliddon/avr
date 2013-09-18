;; Some miscellaneous utility routines
        .include        "avr.i"

        .global         sleep
        .global         doPokes
	.global 	r012
	.global 	portCMark

;; Test pattern;; Alternates between r1 and r0
;; loop cycles = (r16 * 6) + 1 
;; overhead = 5
;; r16 = 82 = 492 cycles

portCMark:
	;; Mark for the start of test so trace will get it
	out 	PORTC, r0
	out 	PORTC, r1
	out 	PORTC, r2
	out 	PORTC, r0
	ret

;; 	r0 = 0
;; 	r1 = 1
;; 	r2 = 2
r012:	eor 	r0,r0
	ldi 	r16, 1
	mov 	r1, r16
	ldi 	r16, 2
	mov 	r2, r16
	ret

;; Puts the machine to sleep
sleep: 	cli
	out SMCR, 1
	sleep

;; Pokes stuff from a table into zero page addresses from
;; 1 -> ff inclusive
;; address 0 marks end of table
;; r30:31 (Z) -> poke table
;; trashes 1,26,27

doPokes:
	ldi r27, 0 		; X hi = 0
pokesLoop:
	lpm 	r26, Z+ 	; X lo = write address
	tst 	r26 		; Finished poke list if 0
	breq 	pokesDone
	lpm 	r1, Z+ 		; Get the val we're writing
	st 	X,r1 		; store it to *X (26:27)
	rjmp pokesLoop  	; Loop!
pokesDone:
	ret


