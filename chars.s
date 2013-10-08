
;; ----------------------------------------------------------------------------
;; Globals
        .global fillLineBuffer

;; ----------------------------------------------------------------------------
;; Equates
WIDTH_CHARS =     16
WIDTH_PIXELS =    WIDTH_CHARS * 8

;; ----------------------------------------------------------------------------
;; Code
        .section 	.text

fillLineBuffer00:
fillLineBuffer1:
fillLineBuffer2:
fillLineBuffer3:

fillLineBuffer:
        ;; -> to scr
        ;; -> line buffer

        ;; fetch character
        ;; work out char address
                ;; char number * 64 + 8 * yOff
        ;; scan out pixel data
        ;; dec counter and loop

        ret
lineBufferKernelInit:
        ;; -> line buffer
        ret
lineBufferKernel:
        ;; scan out line buffer
        ;; macroise WIDTH_PIXELS
        ret

;; ----------------------------------------------------------------------------
;; Vars
        .section        .bss

;; Line bufffers
        .comm lineBuffer0, WIDTH_CHARS * 8
        .comm lineBuffer1, WIDTH_CHARS * 8


