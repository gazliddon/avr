        .include        "ports.i"
        .include        "delays.i"
	.include "avr.i"

	.global 	hLineTest
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

; 50 =  1250
; 70  = 1450
; 130 = 5250


start = 50
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
	lds 	r16, hLineW
	cpi 	r16, 10
	brne 	1b

	cli

;; exit
	rcall 	portCMark
	rjmp 	sleep

;; Horizontal sync Int service routine
hSyncISR:
	out PORTC,r1
	push 	r16
	in 	r16, SREG
	push 	r16
	push 	r27
	push 	r26

	ldi 	r27, 0 				; Remove interrupt latency jitter (align to 20mhz clock & 7) 
	ldi 	r26, TCNT1L
11:	ld 	r16, X
	andi 	r16, 7
	brne 	11b

	;; -------->
	;; Don't mess with this :D
	lds 	r27,hLineW 	; 1 = 6
	;; Stabilise to a known value
1:	in 	r16, TCNT0
	cpi 	r16,78 		; 625
	brlt 	1b 		; 626

	;; Bump hlIneW - brings us up to 634 cycles

	add 	r27,r1 		; 627 (1)
	sts 	hLineW, r27     ; 628 (2)
	lds 	r16, hLineW+1   ; 630 (2)
	adc 	r16,r0 		; 632 (1)
	out TCNT0,r0 		; 633 (tcnt will be set on 634)
	out PORTC,r0 		; 0 (happens on 1)
	sts 	hLineW+1, r16 	; 1 (2)
	;; -------->
	
	out PORTD, r0 		; 3 (happens on 4) Black out pixel data 

	nop 	; 4
	nop 	; 5
	nop 	; 6
	nop 	; 7
	nop 	; 8
	nop 	; 9
	nop 	; 10
	nop 	; 11
	
	out 	PORTB, r1 		; 12  (1 (happens on 13))
	
	ldi 	r16, 22    		; 3  (74)
	rcall 	delay3xplus8 		;    (74) 

	out 	PORTB, r0 		; 86 (1) (happens on 87, hsync duration == 74)

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
	out 	PORTD, r2
	ret


;; base of table
;; we need something to point to the entry in the line routine table
;; count


bmap_init:
	ret
bmap:
	ret

front_porch:
vsync_start:
vsync_end:
blank:
	ret
jmp:
	ret


.macro 	line routine, repeats
	.word \routine, \repeats
.endm

.macro jump dest
	.word 	jmp, . - \dest
.endm

;; Y (28:29) -> table
set_line_table:
	sts line_table_pc, r28
	sts line_table_pc+1,r29
	ldd r16, Y+2
	sts line_count, r16
	ldd r16, Y+3
	sts line_count+1, r16
	ret



;; 39 cycles + call overhead - can call this in back porch
;; 42 = w call means 5 cycle lead in to pushing pixles :)
;; reduce cycles by assign line_table_pc + count to regs
jmp_next:
	;; this block 14 cycles

	lds 	r26,line_table_pc       ; 2 x -> entry in table
	lds 	r27,line_table_pc+1     ; 2

	ld 	r30,X+ 		  	; 2 get the routtine in Y
	ld 	r31,X+ 			; 2

	lds 	r16,line_count 	    	; 2 bump the count
	sub 	r16,r1                  ; 1
	lds 	r17,line_count+1        ; 2
	sbc 	r17,r0                  ; 1

	;; Both paths 15 cycles
	brcc 	normal  		; (1/2) No need to get next command

	
	   ld 	 r16, X+ 	        ; 2 (3) Skip count record
	   ld 	 r17, X+                ; 2 (5)
	   ld 	 r30, X+ 	        ; 2 (7) Get new routine
	   ld 	 r31, X+                ; 2 (9)
	   ld 	 r16, X+ 	        ; 2 (11) get new count
	   ld 	 r17, X+                ; 2 (13)
	   rjmp  exit 			; 2 (15)

normal:
	   nop                          ; 1 (3)
	   nop                          ; 1 (4)
	   nop                          ; 1 (5)
	   nop                          ; 1 (6)
	   nop                          ; 1 (7)
	   nop                          ; 1 (8)
	   nop                          ; 1 (9)
	   nop                          ; 1 (10)
	   nop                          ; 1 (11)
	   nop                          ; 1 (12)
	   nop                          ; 1 (13)
	   nop                          ; 1 (14)
	   nop                          ; 1 (15)
	
exit:
	;; 8 cycles
	sts 	line_table_pc, r30      ; 2
	sts 	line_table_pc+1, r31    ; 2
	sts 	line_count, r16              ; 2
	sts 	line_count+1, r17              ; 2

jump_routine:
	ret

	ijmp                            ; 2





test_line_table:
	line 	bmap_init,1
	line 	bmap,250
	line 	bmap,229
	line 	front_porch,10
	line 	vsync_start,1
	line 	vsync_end,1
	line 	blank,32
	jump 	test_line_table

test_line_table_size = . - test_line_table


hLineTest:
	;; Copy line table from pgm rom -> memory
	ldi 	r30, lo8(test_line_table)
	ldi 	r31, hi8(test_line_table)
	ldi 	r28, lo8(line_table_buffer)
	ldi 	r29, hi8(line_table_buffer)
	ldi 	r16, test_line_table_size
	rcall 	cp_pmem_to_mem

	ldi 	r28, lo8(line_table_buffer)
	ldi 	r29, hi8(line_table_buffer)
	rcall 	set_line_table

	out PORTC, r0
	out PORTC, r1
	rcall jmp_next
	
	out PORTC, r0
	out PORTC, r1
	rcall jmp_next
	
	out PORTC, r0
	out PORTC, r1
	
	rjmp sleep



	.section .bss
line_table_pc: 		.long 	0
line_count: 		.word 	0
.comm line_table_buffer, test_line_table_size



