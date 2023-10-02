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