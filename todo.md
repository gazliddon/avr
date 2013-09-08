# Environment

- Stop auto complete on tab?
- Set tab size and to softtabs


# Sleep to return control to the simulator

Enable slpeep mode
set sleep mode in SMCR
b0 SE   Sleep enable
b1 SM0  Mode
b2 SM1
b3 SM2

1011 = power down = 11
1101 = standby  = 13

;; Set Sleep mode
  out SMCR, 0b00001011
  sleep

