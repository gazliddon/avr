#include "delays.i"

        .include        "ports.i"
        .include        "delays.i"

        .global         hlineTest

;; Test pattern;; Alternates between r1 and r0
;; loop cycles = (r16 * 6) + 1 
;; overhead = 5
;; r16 = 82 = 492 cycles


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

        out PORTB, r1           ; c = 521 Hysnc on

        ldi     r16, 28         ; c = 522
        rcall   delay3xplus8    ; c = 523 92 cycles

        out PORTB, r0           ; c = 614 Hsync off

        out     PORTC, r1       ; Signature so we know we ended
        out     PORTC, r0
        out     PORTC, r1

        rjmp sleep              ; Goto sleep

        

