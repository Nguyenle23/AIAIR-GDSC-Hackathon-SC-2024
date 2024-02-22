#ifndef __SRI2C_H__
#define __SRI2C_H__
#include <Wire.h>
#include <Arduino.h>

extern bool readout_SRI2Csingle(void);
extern void init_SRI2C_single(void);
extern uint16_t SRco2Val;
#endif // __SRI2C_H__