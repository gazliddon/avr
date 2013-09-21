# Dev Env Todo
How can I remove repetition?

## Vim
- softspaces for .s files
- set tab widths how I like them

## Debugger
- Create a bootup script for GDB
- bp main - continue
- set up window splits for tui the way I like them
- Can I reconnect without restarting gbd?
  - Yes, target remote :1234
  - Turn this into a short cut / macro

# Notes
Assignations

PORTD = pixel data

PORTB 1 = Vsync
PORTB 2 = Hsynce

actual 4600
should be = 3800 76 cycles
out by 950 = 19 cycles

hline

line start = 

pixel data = 0 (d = 510:)
front porch = 25500 ns = c 510 (d = 13)
hysnc  = 26150 ns =  c 523 (d = 97) 
back porch = 31000 = c 620 

## Done
- Get MCU working
- Include the right section
- Initialise with _mmcu
- Make sure AVR_MMCU_TAG_NAME len is corect (String error?)
- Change asciiz to asciz
- Make sure trace file is going to correct place
  - Include set trace file command into avr stuff

# Environment
- Stop auto complete on tab?
- Set tab size and to softtabs


