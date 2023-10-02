#include <avr/io.h>
#include <util/delay.h>
#include <stdint.h>
#include "nrf24l01.h"
#ifndef F_CPU
#define F_CPU 16000000UL
#endif
#include <stdio.h>
#include <avr/interrupt.h>

#define BIT(x) (1 << (x))
#define SETBITS(x,y) ((x) |= (y))
#define CLEARBITS(x,y) ((x) &= (~(y)))
#define SETBIT(x,y) SETBITS((x), (BIT((y))))
#define CLEARBIT(x,y) CLEARBITS((x), (BIT((y))))

#define W 1
#define R 0

#define CE_PIN PORTD7 // Use pin PD7 as the SS (CS) pin
#define CSN_PIN PORTB0

#define CE_PORT PORTD
#define CSN_PORT PORTB

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
	while ( !( UCSR0A & (1<<UDRE0)) );
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
//PORTD7 is CE
//PORTB0 is CSN
void spi_init(void) {
	DDRB |= (1<<DDB3) | (1<<DDB5) | (1 << DDB0); // Set MOSI, SCK and CSN as  outputs
	DDRB &= ~(1<<DDB4); //Set MISO as input
	DDRD |= (1<<DDD7); //set CE as output
	
	//Enable arduino SPI in Master mode with no prescaler
	SPCR |= (1<<SPE) | (1<<MSTR); 
	
	SETBIT(CSN_PORT, CSN_PIN);
	CLEARBIT(CE_PORT, CE_PIN);
}

char WriteByteSPI(unsigned char data)
{
	//load byte
	SPDR = data;
	//wait for transmission to finish
	while(!(SPSR & (1 << SPIF)));
	//return whats recieved from the nrf
	return SPDR;
}
//The nrf starts listening for commands when CSN goes low
//and closes the connection when CSN goes back high
uint8_t GetReg(uint8_t reg)
{
	_delay_us(10);
	CLEARBIT(CSN_PORT, CSN_PIN);
	_delay_us(10);
	WriteByteSPI(R_REGISTER + reg);
	_delay_us(10);
	reg = WriteByteSPI(NOP); //send a dummy byte to receive first byte in "reg" register
	_delay_us(10);
	SETBIT(CSN_PORT, CSN_PIN);
	return reg;
}
//This function is for single bytes of data
void WriteToNRF(uint8_t reg, uint8_t Package)
{
	_delay_us(10);
	CLEARBIT(CSN_PORT, CSN_PIN);
	_delay_us(10);
	WriteByteSPI(W_REGISTER + reg);
	_delay_us(10);
	WriteByteSPI(Package);
	_delay_us(10);
	SETBIT(CSN_PORT, CSN_PIN);
} 
uint8_t *WriteToNrf(uint8_t ReadWrite, uint8_t reg, uint8_t *val, uint8_t antVal )
{
	if(ReadWrite == W)
	{
		reg = W_REGISTER + reg;
	}
	static uint8_t ret[32];
	
	_delay_us(10);
	CLEARBIT(CSN_PORT, CSN_PIN);
	_delay_us(10);
	WriteByteSPI(W_REGISTER + reg);
	_delay_us(10);
	for(int i=0; i<antVal; i++)
	{
		if(ReadWrite == R && reg != W_TX_PAYLOAD)
		{
			ret[i]=WriteByteSPI(NOP);
			_delay_us(10);
		}
		else
		{
			WriteByteSPI(val[i]);
			_delay_us(10);
		}
	}
	SETBIT(CSN_PORT, CSN_PIN);
	return ret;
}
void nrf24l01_init(void)
{
	
	_delay_ms(100);
	uint8_t val[5];
	
	//This enables auto acknowledge to the transmitter knows that the receiver got its message
	val[0]=0x01;
	
	WriteToNrf(W, EN_AA, val, 1);
	//Configure delay between every retry, highly dependent on data rate and payload size
	val[0] = 0x2F;
	WriteToNrf(W, SETUP_RETR, val, 1);
	
	//Choose number of enabled data pipes
	val[0] = 0x01;
	WriteToNrf(W, EN_RXADDR, val, 1); //enable data pipe 0
	
	//This sets up the RF address width (how many bytes is the receiver address)
	val[0] = 0x03; //5 bytes
	WriteToNrf(W, SETUP_AW, val, 1);
	
	//Set up channel frequency, 2.4GHz - 2.527GHz, w/1MHz step
	val[0] = 0x01;
	WriteToNrf(W, RF_SETUP, val, 1);
	
	//RX Address setup, five bytes makes it unique and secure
	for(int i=0; i<5; i++)
	{
		val[i] = 0x12;
	}
	//we chose pipe0 so we will send the address to that channel
	//You can give different addresses to different channels 
	///to listen to multiple transmitters
		
	WriteToNrf(W, RX_ADDR_P0, val, 5); 
	
	//TX Address setup, (same as RX for AA)
	for(int i=0; i<5; i++)
	{
		val[i] = 0x12;
	}
	
	WriteToNrf(W, TX_ADDR, val, 5);
	
	//payload width setup size (1-32 bytes)
	val[0]=5; //send five bytes per package
	WriteToNrf(W, RX_PW_P0, val, 1);
	
	//boot up nrf and choose whether its going to be a transmitter or receiver
	val[0] = 0x1E;
	//0001 1110 - bit 0 = '0' - TRANSM, '1' - RECEI, bit 1 = power up
	WriteToNrf(W, CONFIG, val, 1);
	
	_delay_ms(100);
	
	// **********
	// To change to a receiver mid program, delay by 50ms(to make sure RF is sleeping),
	//  then send 0x1F to CONFIG register, then wait 50ms before the first receive command. 

	
	
}

// When in Transmit mode, this will send a payload
void transmit_payload(uint8_t * W_buff)
{
	
	WriteToNrf(R, FLUSH_TX, W_buff, 0);  //Flush old data
	WriteToNrf(R, W_TX_PAYLOAD, W_buff, 5); //prepare data for transmission
	
	//sei();
	
	_delay_ms(10);
	SETBIT(CE_PORT, CE_PIN); //Transmit data
	_delay_us(20);
	CLEARBIT(CE_PORT, CE_PIN);  //Stop transmitting the data
	_delay_ms(10);	
} 

//When in receive mode this listens and receives your data
void recieve_payload(void)
{
		//sei();
		SETBIT(CE_PORT, CE_PIN); 
		_delay_ms(1000);
		CLEARBIT(CE_PORT, CE_PIN);
		//cli();  
}
//After every received/transmitted payload you have to rest IRQ in the nRF

void reset(void)
{
	_delay_us(10);
	CLEARBIT(CSN_PORT, CSN_PIN);
	_delay_us(10);
	WriteByteSPI(W_REGISTER + STATUS);
	_delay_us(10);
	WriteByteSPI(0x70);
	_delay_us(10);
	SETBIT(CSN_PORT, CSN_PIN);
}

void INT0_interrupt_init(void)
{
	DDRD &= ~(1<<DDD2);
	
	EICRA |= (1<<ISC01);
	EICRA &= ~(1<<ISC01);
	
	EIMSK |= (1<<INT0);
	sei();
}

/*
Main Code...

*/
int main(void)
{
	uint8_t buf [] = {'1','2','3','4','5'};
	USART_Init(MYUBRR);
	spi_init();
	//INT0_interrupt_init();
	nrf24l01_init();
	uint8_t *data;
	USART_Transmit('S');
	/*
	while(1)
	{
		reset();
		//transmit_payload(buf);
		recieve_payload();
		USART_Transmit('N');
		if((GetReg(STATUS) & (1<<6)) != 0)
		{
			data = WriteToNrf(R, R_RX_PAYLOAD, data, 1);
			USART_Transmit(data[0]);
		}
		
	}
	*/
	///*
	while(1)
	{
		USART_Transmit(GetReg(RX_ADDR_P0));
		reset();
		transmit_payload(buf);
		//USART_Transmit('N');
		while((GetReg(STATUS) & (1<<4)) != 0);
		USART_Transmit('S');
	}
	//*/
	return 0;
}

//uint8_t *data;
//ISR(INT0_vect)
//{
	//cli();
	//CLEARBIT(CE_PORT, CE_PIN);
	//data = WriteToNrf(R, R_RX_PAYLOAD, data, 5);
	//reset();
	//
	////print received data with USART
	//for(int i=0; i<5; i++)
	//{
		//
		//USART_Transmit(data[i]);
	//}
	//sei();
//}