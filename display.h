#ifndef display_h
#define display_h

#include "WProgram.h"

class Display {
  public:
    Display(byte data, byte latch, byte clock);
    bool write(int number);
    void blank();
    void decimals(bool l, bool r);
    bool left_dec, right_dec;
  private:
    byte data, latch, clock, current_number;
    void shiftData(byte lowdata, byte highdata);
};
#endif
