
AVR_MMCU_TAG =                  0 
AVR_MMCU_TAG_NAME =             1
AVR_MMCU_TAG_FREQUENCY =        2
AVR_MMCU_TAG_VCC =              3
AVR_MMCU_TAG_AVCC =             4
AVR_MMCU_TAG_AREF =             5
AVR_MMCU_TAG_LFUSE =            6
AVR_MMCU_TAG_HFUSE =            7
AVR_MMCU_TAG_EFUSE =            8
AVR_MMCU_TAG_SIGNATURE =        9
AVR_MMCU_TAG_SIMAVR_COMMAND =   10
AVR_MMCU_TAG_SIMAVR_CONSOLE =   11
AVR_MMCU_TAG_VCD_FILENAME =     12
AVR_MMCU_TAG_VCD_PERIOD =       13
AVR_MMCU_TAG_VCD_TRACE =        14

SIMAVR_CMD_NONE = 0 
SIMAVR_CMD_VCD_START_TRACE = 1 
SIMAVR_CMD_VCD_STOP_TRACE = 2
SIMAVR_CMD_UART_LOOPBACK = 3

        .include "ports.i"

TIMSK1 = 0x6f


TCCR1A = 0x80
TCCR1B = 0x81

OCR1AL = 0x88
OCR1AH = 0x89
OCR1BL = 0x8a
OCR1BH = 0x8b

TCCR2A = 0xb0
CCR2B =  0xb1

TCNT1L = 0x84
TCNT1H = 0x85

;; Bit definitions
WGM12 = 3
CS12 = 2
OCIE1A = 1



X = 26
XL = X
XH = 27

Y = 28
YL = Y
YH = 29

Z = 30
ZL = Z
ZH = 31

;; Bit positions of flags in SREG
I_FLAG = 7
T_FLAG = 6
H_FLAG = 5
S_FLAG = 4
V_FLAG = 3
N_FLAG = 2
Z_FLAG = 1
C_FLAG = 0


