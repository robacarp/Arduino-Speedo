// shiftOut(dataPin, clockPin, data);
int data = 10;
int latch = 11;
int clock = 12;
// ser - data input, 
// rclk - register clock - make it happen,
// srclk - clock - pulse with each pin

void setup(){
    pinMode(data, OUTPUT);
    pinMode(latch, OUTPUT);
    pinMode(clock, OUTPUT);
    pinMode(13, OUTPUT);
    
    shiftData(0xf, 0xf4);
    digitalWrite(13, 1);
}
int at = 0;
void loop(){
    write_number(at);
    at ++;
    if (at > 99) at = 0;
    delay(500);
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
    shiftOut(data, clock, MSBFIRST, 0xff);
    shiftOut(data, clock, MSBFIRST, 0xff);
    digitalWrite(latch,1);
    delay(1);
    digitalWrite(latch,0);
    delay(1);
    shiftOut(data, clock, MSBFIRST, highdata);
    shiftOut(data, clock, MSBFIRST, lowdata);
    digitalWrite(latch,1);
}
