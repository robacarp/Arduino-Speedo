#include <NewSoftSerial.h>
#include <TinyGPS.h>
#include "display.h"

TinyGPS gps;
NewSoftSerial nss(8, 7);
Display display(10, 11, 12);
unsigned int gps_data_count = 0;
unsigned int gps_dead_count = 0;
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
  pinMode(13, OUTPUT);
}

void loop(){
  millisCounter();

  if (maintainGps()) {

    //reset dead state counter
    gps_dead_count = 0;
    digitalWrite(13,0);

    //and increment good data counter
    gps_data_count ++;

  } else {

    //if the gps has been dead for a short while
    //  turn on green LED to indicated possible
    //  signal loss
    if (gps_data_count > 0 && gps_dead_count > 250) {
      digitalWrite(13,1);
    }

    //if the gps has been dead for a long while
    //  send the unit back to blinkenlights mode
    //  until we get reliable data again
    if (gps_dead_count > 2000) {
      gps_data_count = 0;
    }

    gps_dead_count ++;
  }

  //before any valid gps data comes in, just blinkenlights
  if (gps_data_count == 0){

    if (millis_state){
      display.decimals(true, false);
    } else {
      display.decimals(false, true);
    }
    display.blank();

  //some real data do display
  } else {

    pullGpsData();

    //if we're more or less stopped, show the time
    if (speed <= 2) {
      if (millis_state){
        display.decimals(true, false);
        display.write(hour);
      } else {
        display.decimals(false, true);
        display.write(minute);
      }

    //its time for SPEED!
    } else {
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

