
#include <stdint.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
//
//#ifndef BAUD
//#define BAUD 9600
//#endif
//#include "STDIO_UART.h"

#include "nrf24l01.h"
#include "nrf24l01-mnemonics.h"
#include "spi.h"
//void print_config(void);
#define FOSC 16000000 // Clock Speed
#define BAUD 9600
#define MYUBRR FOSC/16/BAUD-1
volatile bool status = false;
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
void USART_Transmit_Multiple(char*data, int size)
{
	for(int i=0; i<size; i++)
	{
		USART_Transmit(data[i]);
	}
}
unsigned char USART_Receive( void )
{
	/* Wait for data to be received */
	while ( !(UCSR0A & (1<<RXC0)) );
	/* Get and return received data from buffer */
	//Dtostrf
	return UDR0;
}
volatile bool message_received = false;
int main(void) {
	
	char tx_message[32];
	char rx_message[32];				
	//strcpy(tx_message,"Hello World!");
	USART_Init(MYUBRR);
	USART_Transmit('R');
	USART_Transmit('e');
	USART_Transmit('1');
	//uart_init();
	nrf24_init();
	USART_Transmit('2');
	//printf("I'm the Controller\n");
	//print_config();
	
	nrf24_start_listening();
	
	while (1) {
		USART_Transmit('3');
		if(message_received)
		{
			message_received = false;
			strcpy(rx_message,nrf24_read_message());
			USART_Transmit('R');
			//printf("Received message: %s\n",rx_message);
			_delay_ms(500); // Wait for 1 second
			
			status = nrf24_send_message(tx_message);
			if(status == true)
			{
				
				//printf("Message sent successfully\n");
				USART_Transmit('S');
			}
		}
		
		
	}
	
	
	return 0;
}
ISR(INT0_vect)
{
	message_received = true;
}
//void print_config(void)
//{
	//uint8_t data;
	//printf("Startup successful\n\n nRF24L01+ configured as:\n");
	//printf("-------------------------------------------\n");
	//nrf24_read(CONFIG,&data,1);
	//printf("CONFIG		0x%x\n",data);
	//nrf24_read(EN_AA,&data,1);
	//printf("EN_AA			0x%x\n",data);
	//nrf24_read(EN_RXADDR,&data,1);
	//printf("EN_RXADDR		0x%x\n",data);
	//nrf24_read(SETUP_RETR,&data,1);
	//printf("SETUP_RETR		0x%x\n",data);
	//nrf24_read(RF_CH,&data,1);
	//printf("RF_CH			0x%x\n",data);
	//nrf24_read(RF_SETUP,&data,1);
	//printf("RF_SETUP		0x%x\n",data);
	//nrf24_read(STATUS,&data,1);
	//printf("STATUS		0x%x\n",data);
	//nrf24_read(FEATURE,&data,1);
	//printf("FEATURE		0x%x\n",data);
	//printf("-------------------------------------------\n\n");
//}