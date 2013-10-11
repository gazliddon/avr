
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
SCR_LINE_L =  20
SCR_LINE_H =  21

SRAM_CHARS =   22
SRAM_CHARS_L = 22
SRAM_CHARS_H = 23

FLASH_CHARS =   24
FLASH_CHARS_L = 24
FLASH_CHARS_H = 25

;; Transient / trashed
T_64 =        12
LT_0 =        10
T_CHAR_ADD =  11

;; Reg >= 16 temp
T_CHAR_WIDTH = 16
T_1 = 17
T_2 = 18
T_3 = 19

printScreenKernelInit:
	clr Y_PIXEL

	ldi SCR_LINE_L,   lo8(ramScreen)
	ldi SCR_LINE_H, hi8(ramScreen)

	ldi SRAM_CHARS_L, lo8(characters)
	ldi SRAM_CHARS_H, hi8(characters)

	ldi FLASH_CHARS_L, lo8(characters)
	ldi FLASH_CHARS_H, hi8(characters)

	ret

; Needed to generate on entry to printer
; Z -> char
; X -> scr

printScreenLineKernel:
	;; Calc first char address
	movw 	X, SCR_LINE 			; 0  (1)
	ldi 	T_1,64 				; 1  (1)
	mov 	T_64, T_1 			; 2  (1)
	ld 	T_1, X+ 			; 3  (3)
	mul 	T_1,T_64 			; 6  (2)
	movw 	Z,FLASH_CHARS 			; 8  (1)
	cpi 	T_1,MAX_CHARS 			; 9  (1)
	brsh    .+2 				; 10 (2/1)
	movw 	Z,SRAM_CHARS 			; 10 (1)

	add 	ZL, r0 				; 12 (1)
	adc 	ZH, r1 				; 13 (1)
	ldi 	T_CHAR_WIDTH,7 		; 14 (1)

	mov 	T_1, Y_PIXEL
	andi 	T_1, 7
	lsl 	T_1
	lsl 	T_1
	lsl 	T_1
	add 	ZL,T_1
	adc 	ZH,0

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

	inc 	r1
	inc 	Y_PIXEL         ;; Inc yPos

	ret

lineBufferKernelInit:
        ret

lineBufferKernel:
        ret
