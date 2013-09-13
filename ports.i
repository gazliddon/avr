
;; Ports on avr, uss with out

SREG = 0x3F
SPH = 0x3E
SPL = 0x3D
SMCR = 0x33
ACSR = 0x30
SPI = 0x31
SPDR = 0x2E
SPCR = 0x2C
GPIOR2 = 0x2B
TCCR0B = 0x25
EEARL = 0x21
EEDR = 0x20
DDRB = 0x04

PIND =  0x09
DDRD =  0x0a  
PORTD = 0x0b

mem_SREG = SREG + 0x20 
mem_SPH = SPH + 0x20 
mem_SPL = SPL + 0x20 
mem_SMCR = SMCR + 0x20 
mem_ACSR = ACSR + 0x20 
mem_SPI = SPI + 0x20 
mem_SPDR = SPDR + 0x20 
mem_SPCR = SPCR + 0x20 
mem_GPIOR2 = GPIOR2 + 0x20 
mem_TCCR = TCCR+ 0x20
mem_EEARL = EEARL + 0x20 
mem_EEDR = EEDR + 0x20 
mem_DDRB = DDRB + 0x20 

mem_PIND =  0x09 + 0x20
mem_DDRD =  0x0a + 0x20
mem_PORTD = 0x0b + 0x20

