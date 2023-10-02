;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Assembly Language file (2/2) for Lab 2 in ECE:3360
; Spring 2023, The University of Iowa
; Created: 2/4/2023 10:56:48 AM
; Author : Max Finch, Tiger Slowinski
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


.equ count1 = 60000				; assign a 16-bit value to symbol "count"
delay_extra_long:
	ldi r30, low(count)	  	; r31:r30  <-- load a 16-bit value into counter register for outer loop
	ldi r31, high(count);
d11:
	ldi   r29, 255		    	; r29 <-- load a 8-bit value into counter register for inner loop
	d22:
		nop											; no operation
		dec   r29            		; r29 <-- r29 - 1
		brne  d22								; branch to d2 if result is not "0"
	sbiw r31:r30, 1					; r31:r30 <-- r31:r30 - 1
	brne d11									; branch to d1 if result is not "0"
ret											; return

flashing:
	
	ldi R16,0x00
	ldi R19,0x00
	call display_nums
	rcall delay_extra_long

	ldi R16,0x40
	ldi R19,0x40
	call display_nums
	rcall delay_extra_long

	ret

.equ count = 8502				; assign a 16-bit value to symbol "count"

delay_long:
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


delay_extra_long_2:
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

pulse_clock:
	sbi   PORTB,1
	cbi   PORTB,1
ret

pulse_latch:
	sbi   PORTB,2
	cbi   PORTB,2
ret