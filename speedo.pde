#include <NewSoftSerial.h>
#include <TinyGPS.h>

// shiftOut(dataPin, clockPin, data);
int data = 10;
int latch = 11;
int clock = 12;
int tx_pin = 7;
int rx_pin = 8;

TinyGPS gps;
NewSoftSerial nss(rx_pin, tx_pin);

void setup(){
    pinMode(data, OUTPUT);
    pinMode(latch, OUTPUT);
    pinMode(clock, OUTPUT);
    shiftData(0xf, 0xf4);
    Serial.begin(9600);
    shiftData(0xff, 0xff);
}

bool state = false;
int last_millis = 0;
void loop(){
    //write_number(speed);
    while (nss.available()){
      int c = nss.read();
      if (gps.encode(c)){
        Serial.println(gps.speed());
      }

      if (millis() - last_millis > 500) {
        last_millis = millis();
        state = ! state;
        digitalWrite(13,state);
      }
    }
}

boolean write_number(int number){
    if (number > 99 || number < 0) return false;
    byte codes[] = { B10001000, B11101011, B01001100, 
                     B01001001, B00101011, B00011001,
                     B00011000, B11001011, B00001000, 
                     B00001011 };
    shiftData( codes[ number / 10 ], codes[ number - ( number / 10 ) * 10 ] ); 
}

void shiftData(byte lowdata, byte highdata){
    digitalWrite(data,0);
    digitalWrite(latch,0);
    digitalWrite(clock,0);
    delay(1);
    shiftOut(data, clock, MSBFIRST, highdata);
    shiftOut(data, clock, MSBFIRST, lowdata);
    digitalWrite(latch,1);
}
