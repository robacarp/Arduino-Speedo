#ifndef display_c
#define display_c

#include "display.h"
#include "WProgram.h"


Display::Display(byte data, byte latch, byte clock){
  this->data = data;
  this->latch = latch;
  this->clock = clock;
  this->left_dec = false;
  this->right_dec = false;

  pinMode(data, OUTPUT);
  pinMode(latch, OUTPUT);
  pinMode(clock, OUTPUT);
}

bool Display::write(int number){
    if (number > 99)
      number = number - ((number / 100) * 100);

    byte codes[] = { B10001000, B11101011, B01001100,
                     B01001001, B00101011, B00011001,
                     B00011000, B11001011, B00001000,
                     B00001011 };

    byte left  = codes[ number / 10 ];
    byte right = codes[ number - ( number / 10 ) * 10 ];

    if (number < 0) {
      left = B11111111;
      right = B11111111;
    }

    if (this->left_dec)
      left = left & B11110111;
    if (this->right_dec)
      right = right & B11110111;

    shiftData( left, right );
}

void Display::blank(){
  write(-1);
}


void Display::shiftData(byte lowdata, byte highdata){
    digitalWrite(this->data,0);
    digitalWrite(this->latch,0);
    digitalWrite(this->clock,0);
    delay(1);
    shiftOut(this->data, clock, MSBFIRST, highdata);
    shiftOut(this->data, clock, MSBFIRST, lowdata);
    digitalWrite(latch,1);
}

void Display::decimals(bool left, bool right){
  this->left_dec = left;
  this->right_dec = right;
}

#endif
