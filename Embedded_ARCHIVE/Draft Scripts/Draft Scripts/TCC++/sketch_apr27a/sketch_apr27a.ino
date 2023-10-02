#include <SPI.h>
#include "RF24.h"
#include "nRF24L01.h"

RF24 radio(5, 4);
const byte address[10] = "ADDRESS01";

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  radio.begin();
  radio.openReadingPipe(0, address);
  radio.setPALevel(RF24_PA_MIN);
  radio.startListening();

}

void loop() {
  // put your main code here, to run repeatedly:
  if(radio.available()){
    char txt[32] = "";
    radio.read(&txt, sizeof(txt));
    Serial.println(txt);
  }
  
}
