;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Assembly Language file for Lab 3 in ECE:3360
; Spring 2023, The University of Iowa
; Author : Max Finch, Tiger Slowinski
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.include "m328Pdef.inc"

.cseg
.org 0

setup:
	; Configure I/O lines.
	sbi   DDRB,0      ; PB0 is now output (SER)
	sbi   DDRB,1      ; PB1 is now output (SRCLK)
	sbi   DDRB,2      ; PB2 is now output (RCLK)
	cbi   DDRB,3	  ; PB3 is now input (button)
	cbi   DDRB,4	  ; PB4 is now input (Rotary A)
	cbi   DDRD,5      ; PD5 is now input (Rotary B)
	sbi   DDRB,5	  ; PB5 is led L
	cbi   PORTB,5     ; turn off led L

	ldi R16, 0x40     ; "-" is first character to be displayed
	ldi R20, 0        ; R20 holds state of display, 0 to 15 coorresponds to 0 to F
	jmp main



stay_put:
	rcall delay_10ms     ;R22 is sample register
	inc  R22
	cpi R22, 50		     ;inner loop of 50
	breq inc_R27_reset_R22
	here:
	cpi R27, 4           ;outer loop of 4: 50 x 4 = 200 loops of 10ms = 2s
	breq set_led_to_dash ;reset
	sbic PINB, 3		 ;if button released
	rjmp check_digit     ;Check the digit
	rjmp stay_put

inc_R27_reset_R22:
	inc R27
	ldi R22, 0
	rjmp here

set_led_to_dash:
	ldi R22, 0    ;reset R22 (200->0)
	ldi R27, 0    ;reset R27 (4->0)
	ldi R23, 0    ;reset register that counts correct passcode entry
	ldi R24, 0
	ldi R16, 0x40 ;set leds to dash
	rjmp main

validate:
	cpse R24, R23					;If equal passcode is correct.
	rjmp incorrect_code			   ;If not correct go to to underscore and 9s delay
	rjmp led_code

incorrect_code:
	ldi R23, 0    ;reset register that counts correct passcode entry
	ldi R24, 0
	ldi R16, 0x08 ;set to underscore for 9 seconds
	rcall display
	rcall delay_9s
	rjmp set_led_to_dash

led_code:
	;activate led for 5 seconds
	ldi R16, 0x80 ;set to decimal point
	rcall display
	sbi PORTB,5
	rcall delay_5s
	cbi PORTB,5
	rjmp set_led_to_dash
	
check_E_code:
		cpi R16, 0x79  ;if the right number
		breq tally  ;tally for a correct number 
		inc R24
		rjmp main
check_8_code:
		cpi R16, 0x7F
		breq tally
		inc R24
		rjmp main
check_5_code:
		cpi R16, 0x6D
		breq tally
		inc R24
		rjmp main
check_9_code:
		cpi R16, 0x6F
		breq tally
		inc R24
		rjmp main
check_A_code:
		cpi R16, 0x77
		breq tally
		inc R24
		rjmp validate


main:
	rcall display
	sbis PINB, 4
	rjmp CW_1	    ;if A is pulled low first, likely CW turn
	sbis PIND, 5 
	rjmp CCW_1		;if B is pulled low first, likely CCW turn
	sbis PINB, 3    ;button press
	rjmp stay_put
	rjmp main

tally:          ;final check
	inc R23
	inc R24
	cpi R24, 5  ;if max nums for code reached
	breq validate ;check if correct or not
	rjmp main

check_digit:    
	ldi R22, 0    ;reset R22 (200->0)
	ldi R27, 0    ;reset R27 (4->0)
	;Check for E859A

	cpi R24, 0
	breq check_E_code
	
	cpi R24, 1
	breq check_8_code

	cpi R24, 2
	breq check_5_code

	cpi R24, 3
	breq check_9_code

	cpi R24, 4
	breq check_A_code

CW_1:
	sbic PIND, 5
	rjmp CW_1   ;loop if B is still set
	rjmp CW_2   ;once B is low, go to CW_2

CCW_1:
	sbic PINB, 4
	rjmp CCW_1   ;loop if A is still set
	rjmp CCW_2   ;once A is low, go to CCW_2

CW_2:
	sbic PINB, 4 ;if A goes high, go to next phase
	rjmp CW_3
	rjmp CW_2

CCW_2:
	sbic PIND, 5 ;if B goes high, go to next phase
	rjmp CCW_3
	rjmp CCW_2

CW_3:
	sbic PIND, 5 ;if B goes high, CW turn is complete
	rjmp increment
	rjmp CW_3

CCW_3:
	sbic PINB, 4 ;if A goes high, CCW turn is complete
	rjmp decrement
	rjmp CCW_3
	
increment:
	cpi R16, 0x40        ;Checks for "-" state and increments R20 if R20 < 15
	breq dash_to_zero
	cpi R20, 15
	breq main
	inc R20
	rjmp switch_number

dash_to_zero:
	ldi R16, 0x3F       ;For going from initial "-" to "0" on CW turn 
	ldi R20, 0
	rjmp main

decrement:
	cpi R16, 0x40       ;Checks for "-" state and decrements R20 if R20 > 0
	breq dash_to_F
	cpi R20, 0
	breq main 
	dec R20
	rjmp switch_number

dash_to_F:
	ldi R16, 0x71       ;For going from initial "-" to "F" on CCW turn, sets state to 15
	ldi R20, 15
	rjmp main

switch_number:
	ldi R19, 0      ;Checks if device is in 0 state, if not checks all other numbers
	cpse R20, R19
	rjmp check_1
	ldi R16, 0x3F
	rjmp main

check_1:
	ldi R19, 1      ;R20 is compared with decimal values 0-15, and when a match is found R16 is updated with cooresponding bit pattern
	cpse R20, R19
	rjmp check_2
	ldi R16, 0x06
	jmp main

check_2:
	ldi R19, 2
	cpse R20, R19
	rjmp check_3
	ldi R16, 0x5B
	jmp main

check_3:
	ldi R19, 3
	cpse R20, R19
	rjmp check_4
	ldi R16, 0x4F
	jmp main

check_4:
	ldi R19, 4
	cpse R20, R19
	rjmp check_5
	ldi R16, 0x66
	jmp main

check_5:
	ldi R19, 5
	cpse R20, R19
	rjmp check_6
	ldi R16, 0x6D
	jmp main

check_6:
	ldi R19, 6
	cpse R20, R19
	rjmp check_7
	ldi R16, 0x7D
	jmp main

check_7:
	ldi R19, 7
	cpse R20, R19
	rjmp check_8
	ldi R16, 0x07
	jmp main

check_8:
	ldi R19, 8
	cpse R20, R19
	rjmp check_9
	ldi R16, 0x7F
	jmp main

check_9:
	ldi R19, 9
	cpse R20, R19
	rjmp check_A
	ldi R16, 0x6F
	jmp main

check_A:
	ldi R19, 10
	cpse R20, R19
	rjmp check_B
	ldi R16, 0x77
	jmp main

check_B:
	ldi R19, 11
	cpse R20, R19
	rjmp check_C
	ldi R16, 0x7C
	jmp main

check_C:
	ldi R19, 12
	cpse R20, R19
	rjmp check_D
	ldi R16, 0x39
	jmp main

check_D:
	ldi R19, 13
	cpse R20, R19
	rjmp check_E
	ldi R16, 0x5E
	jmp main

check_E:
	ldi R19, 14
	cpse R20, R19
	rjmp check_F
	ldi R16, 0x79
	jmp main

check_F:
	ldi R16, 0x71
	jmp main
	
display: ; backup used registers on stack

	push R16
	push R17
	in R17, SREG
	push R17
	ldi R17, 8 ; loop --> test all 8 bits
loop:
	rol R16 ; rotate left trough Carry
	BRCS set_ser_in_1 ; branch if Carry is set
	; put code here to set SER to 0
	cbi PORTB,0
	rjmp end
set_ser_in_1:
    ; put code here to set SER to 1...
	sbi PORTB,0
end:
	; put code here to generate SRCLK pulse...
	rcall pulse_clock
	dec R17
	brne loop
	; put code here to generate RCLK pulse
	rcall pulse_latch
	; restore registers from stack
	pop R17
	out SREG, R17
	pop R17
	pop R16
	ret  

delay_1s:
	rcall delay_10ms
	inc R22           ;loop 10ms 100 times = 1s delay
	cpi R22, 100
	brne delay_1s
	ldi R22, 0x00
	ret

delay_5s:
	rcall delay_1s
	rcall delay_1s
	rcall delay_1s
	rcall delay_1s
	rcall delay_1s
	ret

delay_9s:
	rcall delay_1s
	rcall delay_1s
	rcall delay_1s
	rcall delay_1s
	rcall delay_1s
	rcall delay_1s
	rcall delay_1s
	rcall delay_1s
	rcall delay_1s
	ret

pulse_clock:
	sbi   PORTB,1
	cbi   PORTB,1
ret

pulse_latch:
	sbi   PORTB,2
	cbi   PORTB,2
ret

delay_10ms:
	ldi R21, 0x64        ;100 (base 10) is loaded to counter register
	out TCNT0, R21       
	ldi R21, 0b00000101  ;starts clock in normal mode, prescaler 1024
	out TCCR0B, R21
again:
	in R21, TIFR0       
	sbrs R21, TOV0       ;skip if overflow flag is set
	rjmp again
	ldi R21, 0x00       
	out TCCR0B, R21      ;stops timer
	ldi R21, (1<<TOV0)   
	out TIFR0, R21       ;reset flag bit
	ret

.exit