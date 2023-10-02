/*
 * Thermicar.c
 *
 * Created: 4/22/2023 5:39:58 PM
 * Author : maxfi
 */ 

#include <avr/io.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdbool.h>
#include <util/delay.h>
#define FOSC 16000000 // Clock Speed
#define BAUD 9600
#define F_CPU 16000000
#define MYUBRR FOSC/16/BAUD-1



void USART_Init( unsigned int ubrr)
{
	///*Set baud rate */
	UBRR0H = (unsigned char)(ubrr>>8);
	UBRR0L = (unsigned char)ubrr;
	/*Enable receiver and transmitter */
	UCSR0B = (1<<RXEN0)|(1<<TXEN0);
	/* Set frame format: 8data, 2stop bit */
	UCSR0C = (1<<USBS0)|(3<<UCSZ00);
}
void USART_Transmit( unsigned char data )
{
	/* Wait for empty transmit buffer */
	while ( !( UCSR0A & (1<<UDRE0)) )
	;
	/* Put data into buffer, sends the data */
	UDR0 = data;
}
unsigned char USART_Receive( void )
{
	/* Wait for data to be received */
	while ( !(UCSR0A & (1<<RXC0)) );
	/* Get and return received data from buffer */
	//Dtostrf
	return UDR0;
}

int ADC_To_PWM(int x) {
	float result = 249.0 * (1.0 - exp(-4.0 * pow(x-506.0, 2.0) / pow(506.0, 2.0)));
	return (int)round(result);
}
int num = 1;
void get_ADC(void)
{
	ADCSRA = ADCSRA | (1<<ADSC);
	//while(ADSC == 1){};

	while (!(ADCSRA & (1 << ADIF)));
	ADCSRA |= 1 << ADIF;
	
	//float ADC_val = (ADC*5.0/1024.0);
	//Convert position into PWM value
	//We made the function go from 0-1012
	//Might implement the max value of 1024 later
	//this is just how I started it
	int ADC_val;
	if(ADC > 1012)
	{
		ADC_val = ADC_To_PWM(1012);
	}else{
		ADC_val = ADC_To_PWM(ADC);
	}
	
	char buffer[3];
	char act[4];
	itoa(ADC_val, buffer, 10);
	itoa(ADC, act, 10);
	USART_Transmit(num +'0');
	USART_Transmit('.');
	USART_Transmit(' ');
	USART_Transmit('P');
	USART_Transmit('W');
	USART_Transmit('M');
	USART_Transmit(':');
	USART_Transmit(' ');  
	for(int i=0; i<sizeof(buffer); i++)
	{
		USART_Transmit(buffer[i]);
		
	}
	USART_Transmit(' ');
	USART_Transmit('P');
	USART_Transmit('O');
	USART_Transmit('S');
	USART_Transmit('Y');
	USART_Transmit(':');
	USART_Transmit(' ');
	for(int i=0; i<sizeof(act); i++)
	{
		USART_Transmit(act[i]);
		
	}
	USART_Transmit(' ');
	num++;
	
}


void ADC_Init(void)
{
	ADMUX = (1<<REFS0); //set to VCC and to A0
	ADCSRA = (1<<ADEN) | (1<<ADPS2) | (1<<ADPS1) | (1<<ADPS0);
	
	
}

void PWM_Setup(void)
{
	// Set pin 9 as output
	DDRB |= (1 << PORTB1);

	// Set Timer1 for Fast PWM mode
	TCCR1A |= (1 << WGM11) | (1 << WGM10);
	TCCR1B |= (1 << WGM12) | (1 << WGM13);

	// Set the prescaler to 8
	TCCR1B |= (1 << CS11);

	// Set the TOP value to 249
	ICR1 = 249;

	// Set the duty cycle to 0% (50% is 124)
	OCR1A = 0;


}

int main(void)
{
	ADC_Init();
	USART_Init(MYUBRR);
	
	while(1)
	{
	   unsigned char c = USART_Receive();
	   
	   if ( c == 'A')
	   {
		   get_ADC();
	   }
	
	}
	
	
}


