;; Some miscellaneous utility routines
        .include        "avr.i"

        .global         sleep
        .global         doPokes
	.global 	r012
	.global 	portCMark
	.global 	cp_pmem_to_mem
        .global         cp_flash_to_sram

;; -------------------------------------------------------------------------------
;; Copy a chunk for FLASH to SRAM
;; Z -> src
;; Y -> dst
;; r16:r17 length

cp_flash_to_sram:
        push r3
        cp      r16,r0          ;; Not copying zero bytes
        cpc     r17,r0
        breq    2f

        add     r16,ZL
        adc     r17,ZH

1:
        lpm     r3, Z+
        st      Y+,r3
        cp      ZL, r16
        cpc     ZH, r17
        brne    1b

2:      pop r3
        ret

;; -------------------------------------------------------------------------------
;; Copy from PM to ram
;; Z -> src
;; Y -> dst
;; r16 = lengthi
;; r17 = trashed
cp_pmem_to_mem:
1:
	lpm r17,Z+
	st Y+, r17	
	dec r16
	brne 1b
	ret

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


