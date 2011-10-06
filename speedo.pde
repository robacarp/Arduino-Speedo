#include <NewSoftSerial.h>
#include <TinyGPS.h>

// shiftOut(dataPin, clockPin, data);
int data = 10;
int latch = 11;
int clock = 12;
int tx_pin = 7;
int rx_pin = 8;
int last_speed = 0;
int decimal_pts = 0;

TinyGPS gps;
NewSoftSerial nss(rx_pin, tx_pin);

void setup(){
    pinMode(data, OUTPUT);
    pinMode(latch, OUTPUT);
    pinMode(clock, OUTPUT);
    pinMode(13, OUTPUT);
    shiftData(0xff, 0xff);
    nss.begin(9600);
    Serial.begin(115200);
}

bool state = false;

float lat,lon;
unsigned long age;

int last_millis = 0;

void loop(){
  int speed;
  int year;
  byte month, day, hour, minute, second, hundredths;

  while (nss.available()){
    digitalWrite(13,1);
    int c = nss.read();
    //Serial.print(c);

    if (gps.encode(c)){
      gps.f_get_position(&lat, &lon, &age);
      speed = gps.f_speed_mph();
      //Serial.print();
      //Serial.print("  ");
      //Serial.print(lat);
      //Serial.print("  ");
      //Serial.println(lon);
    }
  }

   if (speed <= 2) {
     gps.crack_datetime(&year,&month,&day,&hour,&minute,&second,&hundredths,&age);
     if (hour > 6)
       hour = hour - 6;
     else
       hour = 24 + hour - 6;

     if (millis() - last_millis > 1000){
       last_millis = millis();
       decimal_pts = (decimal_pts == 1) ? 3 : 1;
     }

     if (decimal_pts == 1)
       write_number(hour);
     else
       write_number(minute);

   } else {
     decimal_pts = 0;
     buff_write( speed );
   }
}

boolean buff_write( int speed ){
  if (speed == last_speed)
    return false;
  last_speed = speed;
  return write_number( speed );
}


boolean write_number(int number){
    if (number > 99)
      number = number - ((number / 100) * 100);
    if (number < 0)
      return write_number( number * -1 );
    byte codes[] = { B10001000, B11101011, B01001100, 
                     B01001001, B00101011, B00011001,
                     B00011000, B11001011, B00001000, 
                     B00001011 };
    byte left = codes[number / 10];
    byte right = codes[ number - ( number / 10 ) * 10 ];

    if (decimal_pts == 1 || decimal_pts == 2)
      left = left & B11110111;
    if (decimal_pts == 2 || decimal_pts == 3)
      right = right & B11110111;

    shiftData( left, right );
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
