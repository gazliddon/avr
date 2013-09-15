#include "delays.i"

        .include        "ports.i"
        .include        "delays.i"

        .global         hlineTest
        .global         hlineTest2


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

hlineTest2:
	rcall 	r012
	rcall 	portCMark

	;; Set up timer 0 counter
	out 	TCCR0A, r0 		;; Normal mode, counting up
	ldi 	r16, 0b00000010 	;; 8 prescale
	out 	TCCR0B, 16

	;; get Going

	out 	PORTD, r1 		; Pixel data on

	;; Do ten lines

	ldi 	r17, 10
	out 	TCNT0,r0  		;; reset timer 0

1:	rcall 	newHLine
	dec 	r17
	tst 	r17
	brne 	1b

	ldi 	r16, 20
	rcall 	delay3xplus8
	rcall 	portCMark
	rjmp 	sleep

newHLine:
	out 	PORTD, r0

1:	in 	r16, TCNT0
	cpi 	r16,72
	brne 	1b

	ldi 	r16, 14 	; 1
        rcall   delay3xplus8    ; 2  = 3 + 50

	out TCNT0, r0 		; 55
	out PORTB, r1 		; 56

	ldi r16, 14    		; 57
	rcall delay3xplus8 	; 58 3 + 71
	nop			; 74

	out PORTB,r0 		; 75
	out PORTD, r1 		; Pixel data on
	ret



;; Test hline timing in tracer

hlineTest:

        ldi     r16,0
        mov     r0,r16

        ldi     r16,1
        mov     r1,r16

        ldi     r16,2
        mov     r2,r16

        ;; All ports to outputs!
        ldi     r16,0xff
        out     DDRB, r16
        out     DDRC, r16
        out     DDRD, r16

        ;; Signature so we know when we started
        out     PORTC, r1
        out     PORTC, r0
        out     PORTC, r1

        rjmp    hlineStart ; hline492 should start at PORTC = 1 + 4


; 492 cycles inc ret, alternates pixel data between 2 and 1
; 2 pixels 2, 3 pixels 1
; c0 = 2
; c1 = 2
; c2 = 1
; c3 = 1
; c4 = 1

hline496:
        ldi r16, 99          ; 1 = 1
1:
        out PORTD,r2          ; 1 = 1 (first PORTD out at 2 cycles in (hlineStart + 4) 
        dec r16               ; 1 = 2
        out PORTD,r1          ; 1 = 3
        brne 1b               ; 2 = if taken 1 if not (So r16 * 5 +1 cycles) 
        ret                   ; 4

hlineStart:
        rcall   hline496        ; c = 0

        nop                     ; c = 499  (496 + 3 for call)
        nop                     ; c = 500
        nop                     ; c = 501
        nop                     ; c = 502
        nop                     ; c = 503
        nop                     ; c = 504
        nop                     ; c = 505
        nop                     ; c = 506
        nop                     ; c = 507

        out     PORTD, r0       ; c = 508 Front porch zero pixel data

        nop                     ; c = 509 
        nop                     ; c = 510
        nop                     ; c = 511
        nop                     ; c = 512 
        nop                     ; c = 513
        nop                     ; c = 514
        nop                     ; c = 515
        nop                     ; c = 516
        nop                     ; c = 517
        nop                     ; c = 518
        nop                     ; c = 519
        nop                     ; c = 520

        out PORTB, r1           ; 0 c = 521 Hysnc on turn off in 76 cycles

; 3 x r16 + 8 including call
        ldi     r16, 21         ;  1 c = 522
        rcall   delay3xplus8    ;  2 c = 523 = 71

        nop                     ; 73 c = 594
        nop                     ; 74 c = 595
        nop                     ; 75 c = 596

        out PORTB, r0           ; 76 c = 597 Hsync off

        out     PORTC, r1       ; Signature so we know we ended
        out     PORTC, r0
        out     PORTC, r1
        rjmp sleep              ; Goto sleep

        
        .section .data

hlineVec:
        .word 0

