;
; Embedded_Lab_4.asm
;
; Created: 3/25/2023 4:46:16 PM
; Author : Max Finch
;

.include "m328Pdef.inc"

.cseg
.org 0x0000

rjmp skip

msg: .DB "Hello "
	 

msgg: .DB "World "
	  .DW 0

skip:
nop

; Grounded pins: PIN_5: R/W (Read/Write), PIN_1: GND (Ground), Vee (1K resistor)
; Powered pins: PIN_2: Vcc (Supply), Vee (10K resistor)

ldi R16, 0xFF    ; Load 0xFF (binary 11111111) into R16
out DDRC, R16    ; Set all PORTC pins as outputs
			     ; PC0 is D4, PC1 is D5, PC2 is D6, PC3 is D7
sbi   DDRB,5     ; PB5 is R/S
sbi   DDRB,3     ; PB3 is Enable 

.def numClocks = R21   ; sets the clock value for delay
.def setup_hex = R22   ; numClock values: 0x64 -> 10ms, 0xB2 -> 5ms, 0xFD -> 200us, for 100ms, do 10ms 10 times

PWM_init:
	ldi r17, (1<<COM2B1)|(1<<WGM21)|(1<<WGM20);
	sts TCCR2A,r17 ; 8 bit PWM non-inverted
	ldi r17,(1<<CS20)
	sts TCCR2B,r17 ; Timer clock = I/O clock
	ldi r17,0x3F ;50% duty cycle
	sts OCR2B,r17 ; Set compare value/duty cycle ratio
	sbi DDRD, PORTD3 ; Set OC2B pin as output
	

start_seq:

	rcall _8bit_initialization

	rcall _4bit_initialization
	cbi PORTB, 3   ;enable
	
	rjmp bruh

; Print Hello
bruh:
    
	ldi R30, LOW(2*msg)
	ldi R31, HIGH(2*msg)
	ldi R24, 6   ; Length of the string
	rcall displayCString
	



	rcall delay_10ms
	rcall shift_cursor
	rcall delay_10ms

	ldi R30, LOW(2*msgg)
	ldi R31, HIGH(2*msgg)
	ldi R24, 6   ; Length of the string
	rcall displayCString
	rjmp literallynothingtbh

shift_cursor:
    cbi PORTB, 5        ; making RS -> 0 for commands
	cbi PORTB, 3        ; Enable low
	; Set interface to 4-bit, 2-line mode
	ldi R16, 0b1100   
	out PORTC, R16        ; Send command to LCD (RS = 0)
	rcall strobe_enable
	rcall delay_200us       ; Wait for instruction to complete
	; Send command again to configure the high nibble
	ldi R16, 0b0000
	out PORTC, R16        ; Send command to LCD (RS = 0)
	rcall strobe_enable
	sbi PORTB, 5        ; making RS -> 0 for commands
	
	
	ret
	

literallynothingtbh:
	nop
	nop
	nop
	rjmp literallynothingtbh


displayCString:
sbi PORTB, 5
L20:
		lpm
		swap R0
		out PORTC, R0
		rcall strobe_enable
		rcall delay_200us
		swap R0
		out PORTC, R0
		rcall strobe_enable
		rcall delay_200us
		adiw ZH:ZL,1
		dec R24
		brne L20
		ret

_8bit_initialization:

	cbi PORTB, 5        ; making RS -> 0 for commands
	cbi PORTB, 3        ; Enable low

	rcall delay_100ms     ; 1

	ldi R16, 0x03         ; 2 and 3
	out PORTC, R16       
	rcall strobe_enable
	rcall delay_5ms 

	ldi R16, 0x03         ; 4 and 5
	out PORTC, R16       
	rcall strobe_enable
	rcall delay_200us

	ldi R16, 0x03         ; 6 and 7
	out PORTC, R16       
	rcall strobe_enable
	rcall delay_200us

	ldi R16, 0x02         ; 8 and 9
	out PORTC, R16       
	rcall strobe_enable
	rcall delay_5ms

	ret

_4bit_initialization:

	cbi PORTB, 5        ; making RS -> 0 for commands
	cbi PORTB, 3        ; Enable low

	; Write command "Set interface" (Write 28 hex (4-Bits, 2-lines)
	ldi R16, 0b0010   
	out PORTC, R16        
	rcall strobe_enable
	rcall delay_200us       
	ldi R16, 0b1000
	out PORTC, R16        
	rcall strobe_enable

	;rcall delay_5ms       

	; Write command "Enable Display/Cursor"(Write 08 hex (don't shift display, hide cursor))
	ldi R16, 0b0000      
	out PORTC, R16        
	rcall strobe_enable
	rcall delay_200us     
	ldi R16, 0b1001		
	out PORTC, R16        
	rcall strobe_enable

	;rcall delay_5ms       

	; Write command "Clear and Home"(Write 01 hex (clear and home display))
	ldi R16, 0b0000  
	out PORTC, R16        
	rcall strobe_enable
	rcall delay_200us       
	ldi R16, 0b0001   
	out PORTC, R16       
	rcall strobe_enable

	;rcall delay_5ms       

	; Write command "Set Cursor Move Direction" (Write 06 hex (move cursor right))
	ldi R16, 0b0000   
	out PORTC, R16        
	rcall strobe_enable
	rcall delay_200us       
	ldi R16, 0b0110   
	out PORTC, R16        
	rcall strobe_enable

	;rcall delay_5ms       

	; After this the display is ready to accept data (Write 0C hex (turn on display))
	ldi R16, 0b0000   
	out PORTC, R16       
	rcall strobe_enable
	rcall delay_200us      
	ldi R16, 0b1100   
	out PORTC, R16        
	rcall strobe_enable
ret
	
strobe_enable:
    sbi PORTB, 3          ; Enable high
	nop
	nop
	nop
	nop
	nop
    cbi PORTB, 3          ; Enable low
	rcall delay_2ms
	ret




	
delay_100ms:
	rcall delay_10ms
	rcall delay_10ms
	rcall delay_10ms
	rcall delay_10ms
	rcall delay_10ms
	rcall delay_10ms
	rcall delay_10ms
	rcall delay_10ms
	rcall delay_10ms
	rcall delay_10ms
	ret

delay_10ms:
	ldi numClocks, 0x64        ;100 (base 10) is loaded to counter register
	rcall delay
	ret
delay_5ms:
	ldi numClocks, 0xB2
	rcall delay
	ret
delay_200us:
	ldi numClocks, 0xFD
	rcall delay
	ret
delay_2ms:
	ldi numClocks, 0xE0
	rcall delay
	ret

delay:        
	out TCNT0, numClocks       
	ldi numClocks, 0b00000101  ;starts clock in normal mode, prescaler 1024
	out TCCR0B, numClocks
again:
	in numClocks, TIFR0       
	sbrs numClocks, TOV0       ;skip if overflow flag is set
	rjmp again
	ldi numClocks, 0x00       
	out TCCR0B, numClocks      ;stops timer
	ldi numClocks, (1<<TOV0)   
	out TIFR0, numClocks       ;reset flag bit
	ret


	.exit
