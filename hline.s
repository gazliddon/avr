        .include        "ports.i"
        .include        "delays.i"
	.include 	"avr.i"
	.include 	"copper.i"

	.global 	hLineTest
	.global 	hSyncISR	
	.global 	hSyncInit


	.global 	frameEnd
	.section 	.bss

hLineW:
	.word 	0
syncVals:
	.word 	0

frameEnd:
	.word 	0
	.section 	.text

hSyncInit:
	rcall 	r012
	rcall 	portCMark

	rcall 	hLineTest

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
framesToRun = 2

charsToCopy = 10*10

        ldi     ZL,lo8(screen)
        ldi     ZH,hi8(screen)
        
        ldi     YL,lo8(ramScreen)
        ldi     YH,hi8(ramScreen)
        
        ldi     r16,lo8(charsToCopy)
        ldi     r17,hi8(charsToCopy)
        rcall   cp_flash_to_sram

	ldi 	r16,lo8(start)
	ldi 	r17,hi8(start)
	ldi 	r18,t0start 
	sts 	TCNT1L, r16
	sts 	TCNT1H, r17
	out 	TCNT0,r18  		;; reset timer 0

	sei

	;; Do two frames
	ldi r17, framesToRun
1: 	;; out PORTC, r1
	;; out PORTC, r0
	lds 	r16, frameEnd
	cp 	r16,r17
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
	push 	r26
	push 	r27
        push    r28
        push    r29
        push    r30
        push    r31


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
	nop                     ; 633 (1)
	out TCNT0,r0 		; 634 (tcnt will be set on 0)
	out PORTD,r0 		; 0 (happens on 1)
	sts 	hLineW+1, r16 	; 1 (2)
	;; -------->
	
	push r17 ; 2
	nop 	; 5
	nop 	; 6
	nop 	; 7
	nop 	; 8
	lds 	r17,syncVals ; 9
	or 	r17,r1       ; 11
	out 	PORTB, r17    ; 12 (happens on 13)
	
	;; We're in Hysnc
	ldi 	r16, 22    		; 3  (74)
	rcall 	delay3xplus8 		;    (74) 

	cbi 	PORTB, 0 		; 86 (1) (happens on 87, hsync duration == 74)

	rcall  	copper_next

	icall
	
	pop 	r17

	pop 	r31
	pop 	r30
	pop 	r29
	pop 	r28
	pop 	r27
	pop 	r26
	pop 	r16
	out 	SREG, r16
	pop 	r16
	reti

;; base of table
;; we need something to point to the entry in the line routine table
;; count


bmap_init:
	ldi 	r16,0xff
	out 	PORTD,r16
	ldi  	r20,1
	ret

bmap:	
	ldi 	r16,0xff
	out 	PORTD,r20
	add    r20,r1
	ret

front_porch:
	ret

vsync_start:
	sts 	syncVals, r2
	ret

vsync_end:
	sts 	syncVals, r0
	ret

blank:
	ret

inky:
	ldi 	r16,90
1:	out 	PORTD, r16
	dec 	r16
	brne 	1b
	out PORTD, r0
	ret

test_copper_list:
	line    inky,1
        line    printScreenKernelInit,1
        line    printScreenLineKernel,50
        line    printScreenLineKernel,149
        line    printScreenLineKernel,152
        line    printScreenLineKernel,129

	line 	front_porch,10
	line 	vsync_start,1
	line 	blank,1
	line 	vsync_end,1
	line 	blank,31
	loop

test_copper_list_size = . - test_copper_list


hLineTest:
	;; Copy line table from pgm rom -> memory
	ldi 	r30, lo8(test_copper_list)
	ldi 	r31, hi8(test_copper_list)
	ldi 	r28, lo8(copper_list_buffer)
	ldi 	r29, hi8(copper_list_buffer)
	ldi 	r16, test_copper_list_size
	rcall 	cp_pmem_to_mem

	ldi 	r28, lo8(copper_list_buffer)
	ldi 	r29, hi8(copper_list_buffer)
	rjmp 	set_copper_list

	.section .bss
	.comm 	copper_list_pc, 2
	.comm 	line_count, 2
	.comm 	copper_list_buffer, test_copper_list_size



