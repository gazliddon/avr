
	.include 	"ports.i"
	.include 	"avr.i"
;; ----------------------------------------------------------------------------
;; Globals
	.global 	printScreenKernelInit
	.global 	printScreenLineKernel

;; ----------------------------------------------------------------------------
;; Equates
WIDTH_CHARS =     16
WIDTH_PIXELS =    WIDTH_CHARS * 8

;; ----------------------------------------------------------------------------
;; Vars
        .section        .bss

;; Line bufffers
        .comm ramScreen, WIDTH_CHARS * WIDTH_CHARS

;; ----------------------------------------------------------------------------
;; Code
        .section 	.text

MAX_CHARS = 128

;; Register Allocations

;; Presistent
Y_PIXEL =     15
SCR_LINE =    20
SRAM_CHARS =  22
FLASH_CHARS = 24

;; Transient / trashed
T_64 =        12
LT_0 =        10

;; Reg >= 16 temp
T_CHAR_WIDTH = 16
T_1 = 17
T_2 = 18
T_3 = 19

printScreenKernelInit:
	clr Y_PIXEL

	ldi T_2, lo8(ramScreen)
	ldi T_3, hi8(ramScreen)
	movw SCR_LINE, T_2

	ldi SRAM_CHARS, lo8(characters)
	ldi SRAM_CHARS, hi8(characters)

	ldi FLASH_CHARS, lo8(characters)
	ldi FLASH_CHARS, hi8(characters)
	ret

; Needed to generate on entry to printer
; Z -> char
; X -> scr

printScreenLineKernel:
	;; Calc first char address
	movw 	Z, SCR_LINE 			; 0  (1)
	ldi 	T_1,64 				; 1  (1)
	mov 	T_64, T_1 			; 2  (1)
	lpm 	T_1, Z+ 			; 3  (3)
	mul 	T_1,T_64 			; 6  (2)
	movw 	Z,FLASH_CHARS 			; 8  (1)
	cpi 	T_1,MAX_CHARS 			; 9  (1)
	brsh    .+2 				; 10 (2/1)
	movw 	Z,SRAM_CHARS 			; 10 (1)

	add 	ZL, r0 				; 12 (1)
	adc 	ZH, r1 				; 13 (1)
	ldi 	T_CHAR_WIDTH,5 		; 14 (1)
	;; ->  

renderFromFlash:
        ;; p0
        lpm LT_0,Z+
        out PORTD, LT_0
                ld T_1, X+
        ;; p1
        lpm LT_0,Z+
        out PORTD, LT_0
                cpi     T_1, MAX_CHARS
                movw    T_2, FLASH_CHARS
        ;; p2
        lpm LT_0,Z+
        out PORTD, LT_0
                mul T_1,T_64
        ;; p3
        lpm LT_0,Z+
        out PORTD, LT_0
		brsh .+2
                movw    T_2,SRAM_CHARS
        ;; p4
        lpm LT_0,Z+
        out PORTD, LT_0
                add T_2,r0
                adc T_3,r1
        ;; p5
        lpm LT_0,Z+
        out PORTD, LT_0
		clr r0
		clr r1
 
        ;; p6
        lpm LT_0,Z+
        out PORTD, LT_0
                dec T_CHAR_WIDTH
        ;; p7
        lpm LT_0,Z+
		movw Z, T_2
        out PORTD, LT_0
                brne renderFromFlash  ;; 2 if take 

	inc 	Y_PIXEL         ;; Inc yPos
	mov 	T_1,Y_PIXEL  	;; if we went to next line bump screen address (r20) up
	andi 	T_1, 0x7
	brne 	1f
	movw 	SCR_LINE, X
	inc 	r1
	ret

1:      nop
	inc r1
	ret

lineBufferKernelInit:
        ret

lineBufferKernel:
        ret
