




delay_long:
    .equ count = 8502				; assign a 16-bit value to symbol "count"
	ldi r30, low(count)	  	; r31:r30  <-- load a 16-bit value into counter register for outer loop
	ldi r31, high(count);
d1:
	ldi   r29, 31		    	; r29 <-- load a 8-bit value into counter register for inner loop
	d2:
		nop											; no operation
		dec   r29            		; r29 <-- r29 - 1
		brne  d2								; branch to d2 if result is not "0"
	sbiw r31:r30, 1					; r31:r30 <-- r31:r30 - 1
	brne d1									; branch to d1 if result is not "0"
ret											; return

display_nums:
	ldi R18, 0
	rcall display ; call display subroutine
	ldi R18, 1
	rcall display
	ret


delay_shorter:
	rcall delay_long
	rcall delay_long
	rcall delay_long
	rcall delay_long
	rcall delay_long
	rcall delay_long
	rcall delay_long
	rcall delay_long
	ret

delay_extra_long:
	rcall delay_long
	rcall delay_long
	rcall delay_long
	rcall delay_long
	rcall delay_long
	rcall delay_long
	rcall delay_long
	rcall delay_long
	rcall delay_long
	rcall delay_long
	rcall delay_long
	rcall delay_long
	rcall delay_long
	rcall delay_long
	rcall delay_long
	ret


decrement_call:
	cpi R24, 1
	breq decrement
	ret
decrement:
	ldi R25, 5			 ;Blink var
	cpi R20, 0			 ;if 0
	breq flashing_dashes ;go to flashing -- and 00's
	rjmp reverse_switch  ;reverse_switch
	rcall delay_shorter  ;delay
	rcall display_nums	 ;display numbers	
	dec R20				 ;decrement
	rjmp decrement		 ;rjmp decrement

flashing_dashes:
	dec R25
	cpi R25, 0
	brne flash_
	ldi R24, 0  ;turn dec off
	rcall decrement_call   ;since its gonna be rcall dont do this  
	

flash_:
	ldi R16, 0x40
	ldi R19, 0x40
	rcall display_nums
	rcall delay_shorter
	ldi R16, 0x00
	ldi R19, 0x00
	rcall display_nums
	rcall delay_shorter
	rjmp flashing_dashes

reverse_switch:
	;If 0 make 9
	cpi R19, 0x3F
	breq become_9_dec  ;If 9 make 8
	cpi R19, 0x67
	breq become_8_dec  ;If 8 make 7
	cpi R19, 0x7F
	breq become_7_dec  ;If 7 make 6
	cpi R19, 0x07
	breq become_6_dec  ;If 6 make 5
	cpi R19, 0x7D
	breq become_5_dec  ;If 5 make 4
	cpi R19, 0x6D
	breq become_4_dec  ;If 4 make 3
	cpi R19, 0x66
	breq become_3_dec  ;If 3 make 2
	cpi R19, 0x4F
	breq become_2_dec  ;If 2 make 1
	cpi R19, 0x5B
	breq become_1_dec  ;If 1 make 0 (CHANGE MODE?)
	cpi R19, 0x06
	breq become_0_dec

become_0_dec:
	ldi R19, 0x3F
	rjmp decrement
	;rjmp main
become_1_dec:
	ldi R19, 0x06
	rjmp decrement
become_2_dec:
	ldi R19, 0x5B
	rjmp decrement
become_3_dec:
	ldi R19, 0x4F
	rjmp decrement
become_4_dec:
	ldi R19, 0x66
	rjmp decrement

become_5_dec:
	ldi R19, 0x6D
	rjmp decrement

become_6_dec:
	ldi R19, 0x7D
	rjmp decrement

become_7_dec:
	ldi R19, 0x07
	rjmp decrement

become_8_dec:
	ldi R19, 0x7F
	rjmp decrement

become_9_dec:
	ldi R19, 0x67
	rjmp switch_left_dec

switch_left_dec:
	;If 2 make 1
	cpi R16, 0x5B
	breq become_left_1_dec
	;If 1 make 0
	cpi R16, 0x06
	breq become_left_0_dec

become_left_0_dec:
	ldi R16, 0x3F
	rjmp decrement
become_left_1_dec:
	ldi R16, 0x06
	rjmp decrement

pulse_clock:
	sbi   PORTB,1
	cbi   PORTB,1
ret

pulse_latch:
	sbi   PORTB,2
	cbi   PORTB,2
ret

display: ; backup used registers on stack
	sbrs R18, 0
	mov R13, R19 
	sbrc R18, 0
	mov R13, R16
	;Change all R16 below to R13

	push R13
	push R17
	in R17, SREG
	push R17
	ldi R17, 8 ; loop --> test all 8 bits
loop:
	rol R13 ; rotate left trough Carry
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
	pop R13
	ret  


.include "functions.asm"