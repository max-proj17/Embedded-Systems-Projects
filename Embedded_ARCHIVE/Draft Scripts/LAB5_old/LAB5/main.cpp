/*
 * LAB5.cpp
 *
 * Created: 4/10/2023 12:52:52 PM
 * Author : mfinch1
 */ 

#include <avr/io.h>
#include <stdio.h>
#include <stdlib.h>
#define FOSC 16000000 // Clock Speed
#define BAUD 9600
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
	while ( !(UCSR0A & (1<<RXC0)) )
	;
	/* Get and return received data from buffer */
	return UDR0;
}

int main(void)
{
	
	USART_Init(MYUBRR);
	unsigned char c;
	
	
	while(1)
	{
		c = USART_Receive();
		if(c == 'f')
		{
			USART_Transmit('u');
		}
	}
	
}

