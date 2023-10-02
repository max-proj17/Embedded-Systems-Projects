
#include <SPI.h>
#include "RF24.h"
#include "nRF24L01.h"
#include "RF24_config.h"

RF24 radio(7, 8);
const byte address[10] = "ADDRESS01";

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  radio.begin();
  radio.openWritingPipe(address);
  radio.setPALevel(RF24_PA_MIN);
  radio.stopListening();

}

void loop() {
  // put your main code here, to run repeatedly:
  const char txt[] = "Hello World";
  radio.write(&txt, sizeof(txt));
  delay(1000);
}
