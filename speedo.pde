#include <NewSoftSerial.h>
#include <TinyGPS.h>
#include "display.h"

TinyGPS gps;
NewSoftSerial nss(8, 7);
Display display(10, 11, 12);
unsigned int gps_data_count = 0;
bool millis_state = false;
unsigned long last_millis = 0;

//gps data holders
int year, speed;
byte month, day, hour, minute, second, hundredths;
unsigned long age;

void setup(){
  display.blank();
  nss.begin(9600);
  Serial.begin(115200);
}

void loop(){
  millisCounter();

  if (maintainGps())
    gps_data_count ++;

  //before any valid gps data comes in, just blinkenlights
  if (gps_data_count == 0){
    Serial.println("waiting...");
    if (millis_state){
      display.left_dec = true;
      display.right_dec = false;
    } else {
      display.left_dec = false;
      display.right_dec = true;
    }
    display.blank();
  } else {
    pullGpsData();
    Serial.println("has data...");

    if (speed <= 2) {
      Serial.println("no speed");
      if (millis_state){
        display.left_dec = true;
        display.right_dec = false;
        display.write(hour);
      } else {
        display.left_dec = false;
        display.right_dec = true;
        display.write(minute);
      }
    } else {
      Serial.println("SPEED");
      display.left_dec = false;
      display.right_dec = false;
      display.write(speed);
    }
  }
}

//a sort of global flip-flop...
void millisCounter(){
  if (millis() - last_millis > 500){
    millis_state = ! millis_state;
    last_millis = millis();
  }
}

//from the tinygps example code
bool maintainGps(){
  while (nss.available())
    if (gps.encode( nss.read() ))
      return true;
  return false;
}

void pullGpsData(){
   gps.crack_datetime(&year,&month,&day,&hour,&minute,&second,&hundredths,&age);
   speed = gps.f_speed_mph();
   if (hour > 6)
     hour = hour - 6;
   else
     hour = 24 + hour - 6;
}

