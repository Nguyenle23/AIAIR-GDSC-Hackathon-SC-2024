#ifndef FUNC_LIBS_H
#define FUNC_LIBS_H
#include <Arduino.h>
#include <avr/dtostrf.h>
#include <RTCZero.h>

//Global object
extern RTCZero rtc;
extern bool set_RTC_check;
#include <SPI.h>
#include <SD.h>
#include <SparkFun_u-blox_GNSS_v3.h>
#include <Wire.h> //Needed for I2C to GNSS
extern SFE_UBLOX_GNSS myGNSS;
extern bool init_GNSS(void);
extern bool readout_GPS(void);
extern void print2digits(int number);
extern void errLeds();
extern float latitude, longitude, gps_altitude, gps_speed;
extern int n_satellites;
extern int GPSYear, GPSMonth, GPSDay, GPSHour, GPSMinute, GPSSecond; // Device/GPS date/time
extern uint8_t RTC_year, RTC_month, RTC_day, RTC_hour, RTC_min, RTC_sec;//RTC system date time
extern char GPSDate[6], GPSTime[6];
#include <TinyGPSPlus.h>
// The TinyGPSPlus object
extern TinyGPSPlus tinygps;
extern String output;
extern void init_TinyGPS(void);
extern bool readout_TinyGPS(void);
extern char tinyGPSDateTime[20], tinyGPSTime[10];
extern float tinyGPSlat;
extern float tinyGPSlong;

//#include "Adafruit_ADS1015.h"
#include "Adafruit_ADS1X15.h"
#include "Statistic.h"
extern float avg_AE1; // the average ads1
extern float avg_WE1;
extern float avg_Pt1000pos;
//extern float avg_Pt1000neg;
extern float std_AE1; // the stdev ads1
extern float std_WE1;
extern float std_Pt1000pos;
//extern float std_Pt1000neg;

extern float avg_WE2; // the average ads2
extern float avg_AE2;
extern float avg_WE3;
extern float avg_AE3;
extern float std_WE2; // the stdev ads2
extern float std_AE2;
extern float std_WE3;
extern float std_AE3;

extern float avg_AE4; // the average ads3
extern float avg_PIDOPWE4;
extern float avg_NGM;
extern float avg_TGS3;
extern float avg_TGS1;
extern float std_AE4; // the stdev ads3
extern float std_PIDOPWE4;
extern float std_NGM;
extern float std_TGS3;
extern float std_TGS1;
extern void init_ads1115s();
extern void read_singleallADS();
extern void calallsensStat();
#include "sps30.h"
extern bool init_I2CSPS30(void);
extern bool read_allSPS30();
// create SPS30 constructor
extern SPS30 sps30;
extern float MassPM1; // the average
extern float MassPM2_5;
extern float MassPM4;
extern float MassPM10;
extern float NumPM0_5; 
extern float NumPM1; // the average
extern float NumPM2_5;
extern float NumPM4;
extern float NumPM10;
extern float typ_PartSize;
extern float avg_PartSize;
extern float actual_Error_Margin;
extern float running_Error_Margin;
#include <SRI2C.h>

#include <bme68xLibrary.h>
//#include <bsec2.h>


extern float BME0x77_temp,BME0x77_pressure, BME0x77_RH, BME0x77_gasresistance, BME0x77_status;
extern int tempProf_idx;
extern bool readout_BME0x77(void);
//extern void init_BME6880x77(void);
//extern void readout_BME6880x77(void);
/* Create an object of the class Bsec2 */
//extern Bsec2 envSensor;

/* Configuration for two class classification used here
 * For four class classification please use configuration under config/FieldAir_HandSanitizer_Onion_Cinnamon
 */
//#include "config/FieldAir_HandSanitizer/FieldAir_HandSanitizer.h"
//#include "config/Default_H2S_NonH2S/Default_H2S_NonH2S.h"

extern void init_BME0x76(void);
extern void init_BME0x76_ULP_LP(void);
extern float Rgas[85];
extern Bme68x bme; // Create an instance of the BME688 sensor
extern float BME0x76_iaq, BME0x76_iaqAccuracy, BME0x76_staticiaq,BME0x76_CO2Equi,
BME0x76_breathVocEqui,BME0x76_rawTemp,BME0x76_rawRH,BME0x76_gasPercentage,
BME0x76_temp,BME0x76_pressure, BME0x76_RH, BME0x76_gasresistance, 
BME0x76_Stabstatus, BME0x76_runstatus;
#include "bsec.h"

extern Bsec iaqSensor;

extern void loadState(void);
extern void updateState(void);
extern void checkIaqSensorStatus(void);
extern void readout_BME0x76(void);
extern int n_BME0x76_readout;
extern float Rgas0x76[85];
#include <SensirionI2CSgp41.h>
//#include <SensirionI2CSgp40.h>
#include <VOCGasIndexAlgorithm.h>
#include <NOxGasIndexAlgorithm.h>
extern void init_SGP4x(void);
extern void readout_SGP40(void);
extern uint16_t SGP41_conditioning_s;
extern int SGP41_conditioning_sec;
extern bool condiandreadout_SGP41(void);
extern SensirionI2CSgp41 sgp41;
extern uint16_t SGP4x_srawVoc;
extern int32_t SGP4x_voc_index;
extern uint16_t SGP4x_srawNox;
extern int32_t SGP4x_nox_index;
extern uint16_t SGP41_error;
extern int check_SGP41_readout;

extern void init_BME68xsSGP4x(void);
//extern void readout_BME68xsSGP4x(void);

#include "Seeed_MCP9600.h"
extern float Stove_temp;
extern void init_MCP9600(void);
extern void readout_Ktypetemp(void);

#endif