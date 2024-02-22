#include "func_libs.h"

SFE_UBLOX_GNSS myGNSS; // SFE_UBLOX_GNSS uses I2C. For Serial or SPI, see Example2 and Example3

// read GPS values
float latitude = 0;
float longitude = 0;
float gps_altitude = 0;
float gps_speed = 0;
int n_satellites = 0;
int GPSYear, GPSMonth, GPSDay, GPSHour, GPSMinute, GPSSecond;
unsigned long epochTime;
char GPSDate[6], GPSTime[6];

bool init_GNSS(void)
{
  bool GPS_available;
  Serial.println("SparkFun u-blox Example");

  // myGNSS.enableDebugging(); // Uncomment this line to enable helpful debug messages on Serial

  if (myGNSS.begin() == false) // Connect to the u-blox module using Wire port
  {
    Serial.println(F("u-blox GNSS not detected at default I2C address. Retrying..."));
    delay(1000);
    if (myGNSS.begin() == false) // Connect to the u-blox module using Wire port
    {
      errLeds();
      delay(1000);
    }
  }

  myGNSS.setI2COutput(COM_TYPE_UBX); // Set the I2C port to output UBX only (turn off NMEA noise)

  // myGNSS.saveConfigSelective(VAL_CFG_SUBSEC_IOPORT); //Optional: save (only) the communications port settings to flash and BBR
  // Callback: printPVTdata will be called when new NAV PVT data arrives
  long latitude = myGNSS.getLatitude();
  Serial.print(F("Lat: "));
  Serial.print(latitude);

  long longitude = myGNSS.getLongitude();
  Serial.print(F(" Long: "));
  Serial.print(longitude);
  Serial.print(F(" (degrees * 10^-7)"));

  long altitude = myGNSS.getAltitude();
  Serial.print(F(" Alt: "));
  Serial.print(altitude);
  Serial.print(F(" (mm)"));

  byte SIV = myGNSS.getSIV();
  Serial.print(F(" SIV: "));
  Serial.print(SIV);

  GPSYear = (uint8_t)(myGNSS.getYear() - 2000);
  GPSMonth = (uint8_t)(myGNSS.getMonth());
  GPSDay = (uint8_t)(myGNSS.getDay());
  GPSHour = myGNSS.getHour();
  GPSMinute = myGNSS.getMinute();
  GPSSecond = myGNSS.getSecond();

  Serial.print("Date is ");
  if (myGNSS.getDateValid() == false)
  {
    Serial.print("not ");
    GPS_available = 0;
    set_RTC_check = 0;
  }
  else
  {
    sprintf(GPSDate, "%02d%02d%02d",
            GPSYear, GPSMonth, GPSDay);
    rtc.setDate(myGNSS.getDay(), myGNSS.getMonth(), GPSYear); // day, month, year
    //set_RTC_check = 1;
  }

  Serial.print("valid   Time is ");
  if (myGNSS.getTimeValid() == false)
  {
    Serial.print("not ");
    GPS_available = 0;
    set_RTC_check = 0;
  }
  else
  {
    sprintf(GPSTime, "%02d%02d%02d",
            GPSHour, GPSMinute, GPSSecond);
    rtc.setTime(GPSHour, GPSMinute, GPSSecond); // hours, minutes, seconds
    set_RTC_check = 1;
  }
  Serial.print("valid");

  Serial.println();
  return GPS_available;
}

// Callback: printPVTdata will be called when new NAV PVT data arrives
// See u-blox_structs.h for the full definition of UBX_NAV_PVT_data_t
//         _____  You can use any name you like for the callback. Use the same name when you call setAutoPVTcallback
//        /                  _____  This _must_ be UBX_NAV_PVT_data_t
//        |                 /               _____ You can use any name you like for the struct
//        |                 |              /
//        |                 |              |
void printPVTdata(UBX_NAV_PVT_data_t *ubxDataStruct)
{
  Serial.println();

  Serial.print(F("Time: "));         // Print the time
  uint8_t hms = ubxDataStruct->hour; // Print the hours
  if (hms < 10)
    Serial.print(F("0")); // Print a leading zero if required
  Serial.print(hms);
  Serial.print(F(":"));
  hms = ubxDataStruct->min; // Print the minutes
  if (hms < 10)
    Serial.print(F("0")); // Print a leading zero if required
  Serial.print(hms);
  Serial.print(F(":"));
  hms = ubxDataStruct->sec; // Print the seconds
  if (hms < 10)
    Serial.print(F("0")); // Print a leading zero if required
  Serial.print(hms);
  Serial.print(F("."));
  uint32_t millisecs = ubxDataStruct->iTOW % 1000; // Print the milliseconds
  if (millisecs < 100)
    Serial.print(F("0")); // Print the trailing zeros correctly
  if (millisecs < 10)
    Serial.print(F("0"));
  Serial.print(millisecs);

  int32_t latitude = ubxDataStruct->lat; // Print the latitude
  Serial.print(F(" Lat: "));
  Serial.print(latitude);

  int32_t longitude = ubxDataStruct->lon; // Print the longitude
  Serial.print(F(" Long: "));
  Serial.print(longitude);
  Serial.print(F(" (degrees * 10^-7)"));

  int32_t altitude = ubxDataStruct->hMSL; // Print the height above mean sea level
  Serial.print(F(" Height above MSL: "));
  Serial.print(altitude);
  Serial.println(F(" (mm)"));
}
// String GPSYear, GPSMonth, GPSDay, GPSHour, GPSMinute, GPSSecond; // Device/GPS date/time

bool readout_GPS(void)
{
  bool GPS_available = 1;
  latitude = myGNSS.getLatitude();
  longitude = myGNSS.getLongitude();
  gps_altitude = myGNSS.getAltitude();
  n_satellites = myGNSS.getSIV();

  GPSYear = (uint8_t)(myGNSS.getYear() - 2000); // myGNSS.getYear();
  GPSMonth = myGNSS.getMonth();
  GPSDay = myGNSS.getDay();
  GPSHour = myGNSS.getHour();
  GPSMinute = myGNSS.getMinute();
  GPSSecond = myGNSS.getSecond();
  sprintf(GPSDate, "%02d%02d%02d",
          GPSYear, GPSMonth, GPSDay);
  sprintf(GPSTime, "%02d%02d%02d",
          GPSHour, GPSMinute, GPSSecond);
  if (set_RTC_check == 0)
  {
    rtc.setDate(myGNSS.getDay(), myGNSS.getMonth(), GPSYear); // rtc.setDate(GPSDay, GPSMonth, GPSYear); // day, month, year
    rtc.setTime(GPSHour, GPSMinute, GPSSecond);               // hours, minutes, seconds
    if (rtc.getDay() == myGNSS.getDay()){
        Serial.print(F("Success set Day! "));
        set_RTC_check = 1;
    }      
    else
      set_RTC_check = 0;
  }
#ifdef main_SERIAL_DEBUG

  Serial.print("Date is ");
  if (myGNSS.getDateValid() == false)
  {
    Serial.print("not ");
    GPS_available = 0;
  }
  else
  {
    sprintf(GPSDate, "%02d%02d%02d ",
            GPSYear, GPSMonth, GPSDay);
    Serial.print(GPSDate);
    rtc.setDate(GPSDay, GPSMonth, GPSYear); // day, month, year
    GPS_available = 1;
  }

  Serial.print("valid   Time is ");
  if (myGNSS.getTimeValid() == false)
  {
    Serial.print("not ");
    GPS_available = 0;
  }
  else
  {
    sprintf(GPSTime, "%02d%02d%02d",
            GPSHour, GPSMinute, GPSSecond);
    rtc.setTime(GPSHour, GPSMinute, GPSSecond); // hours, minutes, seconds
    Serial.print(GPSTime);
    GPS_available = 1;
  }
  Serial.print("valid");

  if (GPS_available == 1)
  {
    Serial.print(F("Lat: "));
    Serial.print(latitude);

    Serial.print(F(" Long: "));
    Serial.print(longitude);
    Serial.print(F(" (degrees * 10^-7)"));

    Serial.print(F(" Alt: "));
    Serial.print(gps_altitude);
    Serial.print(F(" (mm)"));

    Serial.print(F(" SIV: "));
    Serial.print(n_satellites);
  }
// myGNSS.powerOff(20000); // Shutdown the GPS module and add 10 minutes to make sure the GPS doesn't wake up before it is time to exit deep sleep
#endif
  return GPS_available;
}

// Print for RTC
void print2digits(int number)
{
  if (number < 10)
  {
    Serial.print("0");
  }
  Serial.print(number);
}

void errLeds(void)
{
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, HIGH);
  delay(100);
  digitalWrite(LED_BUILTIN, LOW);
  delay(100);
}

// tasks functions
void task_led_alive()
{
  digitalWrite(LED_BUILTIN, !digitalRead(LED_BUILTIN));
}

// A sample NMEA stream.
const char *gpsStream =
    "$GPRMC,045103.000,A,3014.1984,N,09749.2872,W,0.67,161.46,030913,,,A*7C\r\n"
    "$GPGGA,045104.000,3014.1985,N,09749.2873,W,1,09,1.2,211.6,M,-22.5,M,,0000*62\r\n"
    "$GPRMC,045200.000,A,3014.3820,N,09748.9514,W,36.88,65.02,030913,,,A*77\r\n"
    "$GPGGA,045201.000,3014.3864,N,09748.9411,W,1,10,1.2,200.8,M,-22.5,M,,0000*6C\r\n"
    "$GPRMC,045251.000,A,3014.4275,N,09749.0626,W,0.51,217.94,030913,,,A*7D\r\n"
    "$GPGGA,045252.000,3014.4273,N,09749.0628,W,1,09,1.3,206.9,M,-22.5,M,,0000*6F\r\n";

// The TinyGPSPlus object
TinyGPSPlus tinygps;

void init_TinyGPS(void)
{

  Serial.println(F("BasicExample.ino"));
  Serial.println(F("Basic demonstration of TinyGPSPlus (no device needed)"));
  Serial.print(F("Testing TinyGPSPlus library v. "));
  Serial.println(TinyGPSPlus::libraryVersion());
  Serial.println(F("by Mikal Hart"));
  Serial.println();

  while (*gpsStream)
    if (tinygps.encode(*gpsStream++))
      readout_TinyGPS();

  Serial.println();
  Serial.println(F("Done."));
}
int tinyGPSYear = 2023;
int tinyGPSMonth = 01;
int tinyGPSDay = 01;
int tinyGPSHour = 0;
int tinyGPSMinute = 0;
int tinyGPSSecond = 0;
char tinyGPSDateTime[20], tinyGPSTime[10];
float tinyGPSlat = 0;
float tinyGPSlong = 0;
// This custom version of delay() ensures that the gps object
// is being "fed".
static void smartDelay(unsigned long ms)
{
  unsigned long start = millis();
  do
  {
    while (Serial1.available())
      tinygps.encode(Serial1.read());
  } while (millis() - start < ms);
}

static void printInt(unsigned long val, bool valid, int len)
{
  char sz[32] = "*****************";
  if (valid)
    sprintf(sz, "%ld", val);
  sz[len] = 0;
  for (int i = strlen(sz); i < len; ++i)
    sz[i] = ' ';
  if (len > 0)
    sz[len - 1] = ' ';
  Serial.print(sz);
  smartDelay(0);
}

static void printDateTime(TinyGPSDate &d, TinyGPSTime &t)
{
  if (!d.isValid())
  {
    Serial.print(F("********** "));
  }
  else
  {
    // char sz[32];
    sprintf(tinyGPSDateTime, "%02d/%02d/%02d ", d.year(), d.month(), d.day());
    Serial.print(tinyGPSDateTime);
  }

  if (!t.isValid())
  {
    Serial.print(F("******** "));
  }
  else
  {
    // char sz[32];
    sprintf(tinyGPSTime, "%02d:%02d:%02d ", t.hour(), t.minute(), t.second());
    Serial.println(tinyGPSTime);
  }

  printInt(d.age(), d.isValid(), 5);
  smartDelay(0);
}

bool readout_TinyGPS(void)
{
  Serial.print(F("TinyGPS Location: "));
  if (tinygps.location.isValid())
  {
    tinyGPSlat = tinygps.location.lat();
    tinyGPSlong = tinygps.location.lng();
    Serial.print(tinyGPSlat, 6);
    Serial.print(F(","));
    Serial.print(tinyGPSlong, 6);
  }
  else
  {
    Serial.print(F("INVALID"));
  }

  Serial.print(F("Tiny GPS Date/Time: "));
  printDateTime(tinygps.date, tinygps.time);
  // if (tinygps.date.isValid())
  // {
  //   tinyGPSYear = tinygps.date.year();
  //   tinyGPSMonth = tinygps.date.month();
  //   tinyGPSDay = tinygps.date.day();

  //   Serial.print(tinyGPSYear);
  //   Serial.print(F("/"));
  //   Serial.print(tinyGPSMonth);
  //   Serial.print(F("/"));
  //   Serial.print(tinyGPSDay);

  //   sprintf(tinyGPSDate, "%02d%02d%02d ",
  //           tinyGPSYear, tinyGPSMonth, tinyGPSDay);
  // }
  // else
  // {
  //   Serial.print(F("INVALID"));
  //   return 0;
  // }

  // Serial.print(F(" "));
  // if (tinygps.time.isValid())
  // {
  //   tinyGPSHour = tinygps.time.hour();
  //   tinyGPSMinute = tinygps.time.minute();
  //   tinyGPSSecond = tinygps.time.second();
  //   if (tinygps.time.hour() < 10)
  //     Serial.print(F("0"));
  //   Serial.print(tinygps.time.hour());
  //   Serial.print(F(":"));
  //   if (tinygps.time.minute() < 10)
  //     Serial.print(F("0"));
  //   Serial.print(tinygps.time.minute());
  //   Serial.print(F(":"));
  //   if (tinygps.time.second() < 10)
  //     Serial.print(F("0"));
  //   Serial.print(tinygps.time.second());
  //   Serial.print(F("."));
  //   if (tinygps.time.centisecond() < 10)
  //     Serial.print(F("0"));
  //   Serial.print(tinygps.time.centisecond());
  //   sprintf(tinyGPSTime, "%02d%02d%02d",
  //           tinyGPSHour, tinyGPSMinute, tinyGPSSecond);
  // }
  // else
  // {
  //   Serial.print(F("INVALID"));
  //   return 0;
  // }

  Serial.println();
  return 1;
}

// ADS1115 adc0(ADS1115_DEFAULT_ADDRESS);
// Adafruit_ADS1115 ads; /* Use this for the 16-bit version */
Adafruit_ADS1115 ads1; // First ADS1115 for the (0x48) address object
Adafruit_ADS1115 ads2; // Second ADS1115 for the (0x49) address object
Adafruit_ADS1115 ads3; // Second ADS1115 for the (0x50) address object
// Average<float> readingadc0(11);
// Average<float> readingadc1(11);
// Average<float> readingadc2(11);
// Average<float> readingadc3(11);

// int countadc = 0;
// float ADS1115_multiplier;
// volatile bool continuousConversionReady = false;
//  ADS1115 adc0(ADS1115_DEFAULT_ADDRESS);
//   Wire ADS1115 ALERT/RDY pin to Arduino pin 2
const int alertReadyPin = 6;
bool check_ads1 = 1;
bool check_ads2 = 1;
bool check_ads3 = 1;

void init_ads1115s()
{

  // ads.begin();
  pinMode(alertReadyPin, INPUT);
  // The ADC input range (or gain) can be changed via the following
  // functions, but be careful never to exceed VDD +0.3V max, or to
  // exceed the upper and lower limits if you adjust the input range!
  // Setting these values incorrectly may destroy your ADC!
  //                                                                ADS1015  ADS1115
  //                                                                -------  -------
  // ads.setGain(GAIN_TWOTHIRDS);  // 2/3x gain +/- 6.144V  1 bit = 3mV      0.1875mV (default)
  // ads.setGain(GAIN_ONE);        // 1x gain   +/- 4.096V  1 bit = 2mV      0.125mV
  ads1.setGain(GAIN_TWO); // 2x gain   +/- 2.048V  1 bit = 1mV      0.0625mV
  ads2.setGain(GAIN_TWO); // 2x gain   +/- 2.048V  1 bit = 1mV      0.0625mV
  ads3.setGain(GAIN_TWO); // 2x gain   +/- 2.048V  1 bit = 1mV      0.0625mV
                          // ads.setGain(GAIN_FOUR);       // 4x gain   +/- 1.024V  1 bit = 0.5mV    0.03125mV
                          // ads.setGain(GAIN_EIGHT);      // 8x gain   +/- 0.512V  1 bit = 0.25mV   0.015625mV
                          // ads.setGain(GAIN_SIXTEEN);    // 16x gain  +/- 0.256V  1 bit = 0.125mV  0.0078125mV
  //  ADS1115_multiplier = ads.voltsPerBit() * 1000.0F; // Gets the millivolts per bit
  /* Use this to set data rate for the 16-bit version (optional)*/
  // ads.setSPS(ADS1115_DR_8SPS);                      // for ADS1115 fastest samples per second is 860 (default is 128)

  // ads.readADC_Differential_0_1();                   // in case chip was previously in contuous mode, take out of continuous
  // ads.waitForConversion(); // delay to ensure any last remaining conversion completes
  // needed becasue if formerly was in continuous, 2 conversions need to complete
  // Initializing both ADS1115 modules
  // Starting ads1 at 0x48 I²C position
  if (!ads1.begin(0x48))
  {
    Serial.println("Failed to initialize ADS1.");
    check_ads1 = 0;
  }
  // Starting ads1 at 0x49 I²C position
  if (!ads2.begin(0x49))
  {
    Serial.println("Failed to initialize ADS2.");
    check_ads2 = 0;
  }
  // Starting ads1 at 0x50 I²C position
  if (!ads3.begin(0x4A))
  {
    Serial.println("Failed to initialize ADS3.");
    check_ads3 = 0;
  }
}

int16_t current_adc;
int16_t last_adc = 0;

// Statistics
//  define statistic object for each variable

// Statistic Pt1000negStats; // Pt1000- (mV) to adc12, 230707: remove this Pt1000- recording, because it connect to GND.
Statistic Pt1000posStats; // Pt1000+ (mV) to adc11
Statistic WE1Stats;       // OP1 Working Electrode 1 (mV) to adc13; 230707 change to adc12
Statistic AE1Stats;       // OP2 Auxillary Electrode 1 (mV) to adc10
Statistic WE2Stats;       // OP3 Working Electrode 2 (mV) to adc20
Statistic AE2Stats;       // OP4 Auxillary Electrode 2 (mV) to adc23
Statistic WE3Stats;       // OP5 Working Electrode 3 (mV) to adc21
Statistic AE3Stats;       // OP6 Auxillary Electrode 3 (mV) to adc22
Statistic PIDOPWE4Stats;  // PIDOP or Working Electrode 4 (mV) to adc31; 230707 change to adc13
Statistic AE4Stats;       // OP8 Auxillary Electrode 4 (mV) to adc30
Statistic TGS3Stats;      // 230707: TGS3 sensor (mV) to adc33
Statistic NGMStats;       // NGM sensor (mV) to adc32
Statistic TGS1Stats;      // 230707 TGS1 sensor (mV) to adc31

void read_singleallADS()
{
  int16_t adc10, adc11, adc12, adc13;
  float volts10, volts11, volts12, volts13;
  int16_t adc20, adc21, adc22, adc23;
  int16_t adc30, adc31, adc32, adc33;
  if (check_ads1)
  {
    adc10 = ads1.readADC_SingleEnded(0); // OP2
    adc11 = ads1.readADC_SingleEnded(1); // Pt1000+
    adc12 = ads1.readADC_SingleEnded(2); // Pt1000-; 230707 change to OP1
    adc13 = ads1.readADC_SingleEnded(3); // OP1; 230707 change to PIDOP

    volts10 = ads1.computeVolts(adc10);
    volts11 = ads1.computeVolts(adc11);
    volts12 = ads1.computeVolts(adc12);
    volts13 = ads1.computeVolts(adc13);
#ifdef main_SERIAL_DEBUG
    Serial.println("-----------------------------------------------------------");
    Serial.print("AIN10: ");
    Serial.print(adc10);
    Serial.print("  ");
    Serial.print(volts10);
    Serial.println("V");
    Serial.print("AIN11: ");
    Serial.print(adc11);
    Serial.print("  ");
    Serial.print(volts11);
    Serial.println("V");
    Serial.print("AIN12: ");
    Serial.print(adc12);
    Serial.print("  ");
    Serial.print(volts12);
    Serial.println("V");
    Serial.print("AIN13: ");
    Serial.print(adc13);
    Serial.print("  ");
    Serial.print(volts13);
    Serial.println("V");
#endif
    // add to statistic vector
    AE1Stats.add(volts10);
    Pt1000posStats.add(volts11);
    WE1Stats.add(volts12);      // 230707: Pt1000negStats.add(volts12);
    PIDOPWE4Stats.add(volts13); // 230707: WE1Stats.add(volts13);
  }
  if (check_ads2)
  {
    adc20 = ads2.readADC_SingleEnded(0); // OP3
    adc21 = ads2.readADC_SingleEnded(1); // OP5
    adc22 = ads2.readADC_SingleEnded(2); // OP6
    adc23 = ads2.readADC_SingleEnded(3); // OP4
#ifdef main_SERIAL_DEBUG
    Serial.print("AIN20: ");
    Serial.print(adc20);
    Serial.print("  ");
    Serial.print(ads2.computeVolts(adc20));
    Serial.println("V");
    Serial.print("AIN21: ");
    Serial.print(adc21);
    Serial.print("  ");
    Serial.print(ads2.computeVolts(adc21));
    Serial.println("V");
    Serial.print("AIN22: ");
    Serial.print(adc22);
    Serial.print("  ");
    Serial.print(ads2.computeVolts(adc22));
    Serial.println("V");
    Serial.print("AIN23: ");
    Serial.print(adc23);
    Serial.print("  ");
    Serial.print(ads2.computeVolts(adc23));
    Serial.println("V");
#endif
    // add to statistic vector
    WE2Stats.add(ads2.computeVolts(adc20));
    WE3Stats.add(ads2.computeVolts(adc21));
    AE3Stats.add(ads2.computeVolts(adc22));
    AE2Stats.add(ads2.computeVolts(adc23));
  }
  if (check_ads3)
  {
    adc30 = ads3.readADC_SingleEnded(0); // OP8
    adc31 = ads3.readADC_SingleEnded(1); // PIDOPWE4
    adc32 = ads3.readADC_SingleEnded(2); // NGM
    adc33 = ads3.readADC_SingleEnded(3); // TGS
    // add to statistic vector
    AE4Stats.add(ads3.computeVolts(adc30));
    TGS1Stats.add(ads3.computeVolts(adc31)); // 230707 PIDOPWE4Stats.add(ads3.computeVolts(adc31));
    NGMStats.add(ads3.computeVolts(adc32));
    TGS3Stats.add(ads3.computeVolts(adc33));
#ifdef main_SERIAL_DEBUG
    Serial.print("AIN30: ");
    Serial.print(adc30);
    Serial.print("  ");
    Serial.print(ads3.computeVolts(adc30));
    Serial.println("V");
    Serial.print("AIN31: ");
    Serial.print(adc31);
    Serial.print("  ");
    Serial.print(ads3.computeVolts(adc31));
    Serial.println("V");
    Serial.print("AIN32: ");
    Serial.print(adc32);
    Serial.print("  ");
    Serial.print(ads3.computeVolts(adc32));
    Serial.println("V");
    Serial.print("AIN33: ");
    Serial.print(adc33);
    Serial.print("  ");
    Serial.print(ads3.computeVolts(adc33));
    Serial.println("V");
#endif
  }
}

float avg_AE1 = 0; // the average ads1
float avg_WE1 = 0;
float avg_Pt1000pos = 0;
// float avg_Pt1000neg = 0;
float std_AE1 = 0; // the stdev ads1
float std_WE1 = 0;
float std_Pt1000pos = 0;
// float std_Pt1000neg = 0;

float avg_WE2 = 0; // the average ads2
float avg_AE2 = 0;
float avg_WE3 = 0;
float avg_AE3 = 0;
float std_WE2 = 0; // the stdev ads2
float std_AE2 = 0;
float std_WE3 = 0;
float std_AE3 = 0;

float avg_AE4 = 0; // the average ads3
float avg_PIDOPWE4 = 0;
float avg_NGM = 0;
float avg_TGS3 = 0;
float avg_TGS1 = 0;
float std_AE4 = 0; // the stdev ads3
float std_PIDOPWE4 = 0;
float std_NGM = 0;
float std_TGS3 = 0;
float std_TGS1 = 0;
void calallsensStat()
{
  // Averages
  if (check_ads1)
  {
    avg_AE1 = AE1Stats.average();
    avg_WE1 = WE1Stats.average();
    avg_Pt1000pos = Pt1000posStats.average();
    avg_PIDOPWE4 = PIDOPWE4Stats.average();

    // Std dev of sens
    std_AE1 = AE1Stats.pop_stdev();
    std_WE1 = WE1Stats.pop_stdev();
    std_Pt1000pos = Pt1000posStats.pop_stdev();
    std_PIDOPWE4 = PIDOPWE4Stats.pop_stdev();

    // clear data arrays

    AE1Stats.clear();
    WE1Stats.clear();
    Pt1000posStats.clear();
    PIDOPWE4Stats.clear();
  }
  if (check_ads2)
  {
    avg_AE2 = AE2Stats.average();
    avg_WE2 = WE2Stats.average();
    avg_AE3 = AE3Stats.average();
    avg_WE3 = WE3Stats.average();

    std_AE2 = AE2Stats.pop_stdev();
    std_WE2 = WE2Stats.pop_stdev();
    std_AE3 = AE3Stats.pop_stdev();
    std_WE3 = WE3Stats.pop_stdev();

    AE2Stats.clear();
    WE2Stats.clear();
    AE3Stats.clear();
    WE3Stats.clear();
  }
  if (check_ads3)
  {
    avg_AE4 = AE4Stats.average();
    avg_TGS1 = TGS1Stats.average();
    avg_NGM = NGMStats.average();
    avg_TGS3 = TGS3Stats.average();

    std_AE4 = AE4Stats.pop_stdev();
    std_TGS1 = TGS1Stats.pop_stdev();
    std_NGM = NGMStats.pop_stdev();
    std_TGS3 = TGS3Stats.pop_stdev();

    AE4Stats.clear();
    TGS1Stats.clear();
    NGMStats.clear();
    TGS3Stats.clear();
  }
#ifdef main_SERIAL_DEBUG
  Serial.print("avg_AE1: ");
  Serial.print(avg_AE1);
  Serial.print(" mV\t");
  Serial.print("avg_WE1: ");
  Serial.print(avg_WE1);
  Serial.print("mV\t");
  Serial.print("avg_Pt1000pos: ");
  Serial.print(avg_Pt1000pos);
  Serial.print("mV\t");
  Serial.print("avg_Pt1000neg: ");
  Serial.print(avg_Pt1000neg);
  Serial.println(" mV");
#endif
}

// create constructor
SPS30 sps30;

/////////////////////////////////////////////////////////////
/*define communication channel to use for SPS30
 valid options:
 *   I2C_COMMS              use I2C communication
 *   SOFTWARE_SERIAL        Arduino variants and ESP8266 (NOTE)
 *   SERIALPORT             ONLY IF there is NO monitor attached
 *   SERIALPORT1            Arduino MEGA2560, Due. Sparkfun ESP32 Thing : MUST define new pins as defaults are used for flash memory)
 *   SERIALPORT2            Arduino MEGA2560, Due and ESP32
 *   SERIALPORT3            Arduino MEGA2560 Due only for now

 * NOTE: Softserial has been left in as an option, but as the SPS30 is only
 * working on 115K the connection will probably NOT work on any device.*/
/////////////////////////////////////////////////////////////
#define SP30_COMMS I2C_COMMS

/////////////////////////////////////////////////////////////
/* define driver debug
 * 0 : no messages
 * 1 : request sending and receiving
 * 2 : request sending and receiving + show protocol errors */
//////////////////////////////////////////////////////////////
#define DEBUG 0

/**
 *  @brief : display error message
 *  @param mess : message to display
 *  @param r : error code
 *
 */

///////////////////////////////////////////////////////////////
/* define new AUTO Clean interval
 * Will be remembered after power off
 *
 * default is 604800 seconds
 * 0 = disable Auto Clean
 * -1 = do not change current setting */
//////////////////////////////////////////////////////////////
#define AUTOCLEANINTERVAL -1

///////////////////////////////////////////////////////////////
/* Perform a clean NOW ?
 *  1 = yes
 *  0 = NO */
//////////////////////////////////////////////////////////////
#define PERFORMCLEANNOW 1

/////////////////////////////////////////////////////////////
/* define the maximum of the last measured values to include
 * as part of an running error margin calculation
 */
//////////////////////////////////////////////////////////////
#define INCLUDE_ERRORCALC 10

// for typical/average error margin
struct comp
{
  float typical;
  float avg;
};

struct comp compta[INCLUDE_ERRORCALC + 1];
/**
 *  @brief : display error message
 *  @param mess : message to display
 *  @param r : error code
 *
 */
void ErrtoMess(char *mess, uint8_t r)
{
  char buf[80];

  Serial.print(mess);

  sps30.GetErrDescription(r, buf, 80);
  Serial.println(buf);
}

/**
 *  @brief : continued loop after fatal error
 *  @param mess : message to display
 *  @param r : error code
 *
 *  if r is zero, it will only display the message
 */
void Errorloop(char *mess, uint8_t r)
{
  if (r)
    ErrtoMess(mess, r);
  else
    Serial.println(mess);
  // Serial.println(F("Program on hold"));
  // for(;;) delay(100000);
}

/**
 * @brief: read and display device info
 */
void GetDeviceInfo()
{
  char buf[32];
  uint8_t ret;
  SPS30_version v;

  // try to read serial number
  ret = sps30.GetSerialNumber(buf, 32);
  if (ret == SPS30_ERR_OK)
  {
    Serial.print(F("Serial number : "));
    if (strlen(buf) > 0)
      Serial.println(buf);
    else
      Serial.println(F("not available"));
  }
  else
    ErrtoMess((char *)"could not get serial number.", ret);

  // try to get product name
  ret = sps30.GetProductName(buf, 32);
  if (ret == SPS30_ERR_OK)
  {
    Serial.print(F("Product name : "));

    if (strlen(buf) > 0)
      Serial.println(buf);
    else
      Serial.println(F("not available"));
  }
  else
    ErrtoMess((char *)"could not get product name.", ret);

  // try to get version info
  ret = sps30.GetVersion(&v);
  if (ret != SPS30_ERR_OK)
  {
    Serial.println(F("Can not read version info"));
    return;
  }

  Serial.print(F("Firmware level: "));
  Serial.print(v.major);
  Serial.print(".");
  Serial.println(v.minor);

  if (SP30_COMMS != I2C_COMMS)
  {
    Serial.print(F("Hardware level: "));
    Serial.println(v.HW_version);

    Serial.print(F("SHDLC protocol: "));
    Serial.print(v.SHDLC_major);
    Serial.print(".");
    Serial.println(v.SHDLC_minor);
  }

  Serial.print(F("Library level : "));
  Serial.print(v.DRV_major);
  Serial.print(".");
  Serial.println(v.DRV_minor);
}

/**
 * @brief: Get & Set new Auto Clean Interval
 *
 */
void SetAutoClean()
{
  uint32_t interval;
  uint8_t ret;

  // try to get interval
  ret = sps30.GetAutoCleanInt(&interval);
  if (ret == SPS30_ERR_OK)
  {
    Serial.print(F("Current Auto Clean interval: "));
    Serial.print(interval);
    Serial.println(F(" seconds"));
  }
  else
    ErrtoMess((char *)"could not get clean interval.", ret);

  // only if requested
  if (AUTOCLEANINTERVAL == -1)
  {
    Serial.println(F("No Auto Clean interval change requested."));
    return;
  }

  // try to set interval
  interval = AUTOCLEANINTERVAL;
  ret = sps30.SetAutoCleanInt(interval);
  if (ret == SPS30_ERR_OK)
  {
    Serial.print(F("Auto Clean interval now set : "));
    Serial.print(interval);
    Serial.println(F(" seconds"));
  }
  else
    ErrtoMess((char *)"could not set clean interval.", ret);

  // try to get interval
  ret = sps30.GetAutoCleanInt(&interval);
  if (ret == SPS30_ERR_OK)
  {
    Serial.print(F("Current Auto Clean interval: "));
    Serial.print(interval);
    Serial.println(F(" seconds"));
  }
  else
    ErrtoMess((char *)"could not get clean interval.", ret);
}

// /**
//  * @brief: read and display all values
//  */
// bool read_all()
// {
//   static bool header = true;
//   uint8_t ret, error_cnt = 0;
//   struct sps_values val;

//   // loop to get data
//   do {

//     ret = sps30.GetValues(&val);

//     // data might not have been ready
//     if (ret == SPS30_ERR_DATALENGTH){

//         if (error_cnt++ > 3) {
//           ErrtoMess((char *) "Error during reading values: ",ret);
//           return(false);
//         }
//         delay(1000);
//     }
//     // if other error
//     else if(ret != SPS30_ERR_OK) {
//       ErrtoMess((char *) "Error during reading values: ",ret);
//       return(false);
//     }

//   } while (ret != SPS30_ERR_OK);

//   // only print header first time
//   if (header) {
//     Serial.println(F("-------------Mass -----------    ------------- Number --------------   -Average-"));
//     Serial.println(F("     Concentration [μg/m3]             Concentration [#/cm3]             [μm]"));
//     Serial.println(F("P1.0\tP2.5\tP4.0\tP10\tP0.5\tP1.0\tP2.5\tP4.0\tP10\tPartSize\n"));
//     header = false;
//   }

//   Serial.print(val.MassPM1);
//   Serial.print(F("\t"));
//   Serial.print(val.MassPM2);
//   Serial.print(F("\t"));
//   Serial.print(val.MassPM4);
//   Serial.print(F("\t"));
//   Serial.print(val.MassPM10);
//   Serial.print(F("\t"));
//   Serial.print(val.NumPM0);
//   Serial.print(F("\t"));
//   Serial.print(val.NumPM1);
//   Serial.print(F("\t"));
//   Serial.print(val.NumPM2);
//   Serial.print(F("\t"));
//   Serial.print(val.NumPM4);
//   Serial.print(F("\t"));
//   Serial.print(val.NumPM10);
//   Serial.print(F("\t"));
//   Serial.print(val.PartSize);
//   Serial.print(F("\n"));

//   return(true);
// }

double calc_avg(struct sps_values v)
{
  double a, b;

  a = (double)v.NumPM0 * (double)0.499;
  /*Serial.print(F("\n a: "));
  Serial.print(a);
  Serial.print(F("\t a: "));
*/
  b = (double)(v.NumPM1 - v.NumPM0);
  a += b * (double)0.99;
  /*Serial.print(a);
  Serial.print(F("\t b "));
  Serial.print(b);
  Serial.print(F("\t a "));
*/
  b = (double)(v.NumPM2 - v.NumPM1);
  a += b * (double)2.49;
  /*Serial.print(a);
  Serial.print(F("\t b "));
  Serial.print(b);
  Serial.print(F("\t a "));;
  */
  b = (double)(v.NumPM4 - v.NumPM2);
  a += b * (double)3.99;
  /*Serial.print(a);
  Serial.print(F("\t b "));
  Serial.print(b);
  Serial.print(F("\t a "));
*/
  b = (double)(v.NumPM10 - v.NumPM4);
  a += b * (double)9.99;
  /*Serial.print(a);
  Serial.print(F("\t b "));
  Serial.print(b);
  Serial.print(F("\t a "));
  Serial.print(a);
  Serial.print(F("\t b "));
  Serial.print(b);
  Serial.print(F("\n"));
  */
  return (a / (double)v.NumPM10);
}

/**
 * @brief : calculate error margin based X amount of samples
 * @param v: current read measurement
 * @param avg : current calculated average
 *
 * return : running error margin
 */
double error_margin(struct sps_values v, double avg)
{
  static uint8_t loaded = 0; // number of loaded values
  uint8_t i;
  double error = 0, tot_t = 0;

  // if loaded history is full
  if (loaded == INCLUDE_ERRORCALC)
  {
    // shift out oldest
    for (i = 0; i < loaded; i++)
    {
      compta[i].typical = compta[i + 1].typical;
      compta[i].avg = compta[i + 1].avg;
    }
  }

  // add new values
  compta[loaded].typical = v.PartSize;
  compta[loaded].avg = avg;

  // as long as history not fully loaded
  if (loaded < INCLUDE_ERRORCALC)
    loaded++;

  // get the running values (as far as they are in history)
  for (i = 0; i < loaded; i++)
  {
    error += (double)(compta[i].typical - compta[i].avg);
    tot_t += (double)compta[i].typical;
  }

  // calculate error
  return (error / tot_t);
}
/**
 * @brief will print nice aligned columns
 *
 * @param val : value to print
 * @param width : total width of value including decimal point
 * @param prec : precision after the decimal point
 */
void print_aligned(double val, signed char width, unsigned char prec)
{
  char out[15];

  dtostrf(val, width, prec, out);
  Serial.print(out);
  Serial.print(F("\t  "));
}

/**
 * @brief : read and display all values
 *
 */
float MassPM1 = 0; // the average
float MassPM2_5 = 0;
float MassPM4 = 0;
float MassPM10 = 0;
float NumPM0_5 = 0;
float NumPM1 = 0; // the average
float NumPM2_5 = 0;
float NumPM4 = 0;
float NumPM10 = 0;
float typ_PartSize = 0;
float avg_PartSize = 0;
float actual_Error_Margin = 0;
float running_Error_Margin = 0;
bool read_allSPS30()
{
  static bool header = true;
  uint8_t ret, error_cnt = 0;
  struct sps_values val;

  // loop to get data
  do
  {

    ret = sps30.GetValues(&val);

    // data might not have been ready or value is 0 (can happen at start)
    if (ret == SPS30_ERR_DATALENGTH || val.MassPM1 == 0)
    {

      if (error_cnt++ > 3)
      {
        ErrtoMess((char *)"Error during reading values: ", ret);
        return (false);
      }
      delay(1000);
    }

    // if other error
    else if (ret != SPS30_ERR_OK)
    {
      ErrtoMess((char *)"Error during reading values: ", ret);
      return (false);
    }

  } while (ret != SPS30_ERR_OK);

  // only print header first time
  if (header)
  {
    Serial.println(F("----------------------------Mass -----------------------------    -------------------------------- Number ---------------------------------      -------Partsize --------         ----- Error Margin -----"));
    Serial.println(F("                     Concentration [μg/m3]                                                 Concentration [#/cm3]                                           [μm]                          % "));
    Serial.print(F(" PM1.0             PM2.5           PM4.0           PM10             PM0.5           PM1.0           PM2.5           PM4.0           PM10          Typical         Average         Actual    last "));
    Serial.print(INCLUDE_ERRORCALC);
    Serial.println(F(" samples\n"));
    header = false;

    // often seen the first reading to be "out of bounds". so we skip it
    return (true);
  }

  MassPM1 = val.MassPM1;
  MassPM2_5 = val.MassPM2;
  MassPM4 = val.MassPM4;
  MassPM10 = val.MassPM10;
  NumPM0_5 = val.NumPM0;
  NumPM1 = val.NumPM1;
  NumPM2_5 = val.NumPM2;
  NumPM4 = val.NumPM4;
  NumPM10 = val.NumPM10;
  typ_PartSize = val.PartSize;

  avg_PartSize = calc_avg(val);

  // calculated actual Error Margin
  actual_Error_Margin = (((double)val.PartSize - avg_PartSize) / (double)val.PartSize) * 100;

  running_Error_Margin = error_margin(val, avg_PartSize) * 100;
#ifdef main_SERIAL_DEBUG
  print_aligned((double)val.MassPM1, 8, 5);
  print_aligned((double)val.MassPM2, 8, 5);
  print_aligned((double)val.MassPM4, 8, 5);
  print_aligned((double)val.MassPM10, 8, 5);
  print_aligned((double)val.NumPM0, 9, 5);
  print_aligned((double)val.NumPM1, 9, 5);
  print_aligned((double)val.NumPM2, 9, 5);
  print_aligned((double)val.NumPM4, 9, 5);
  print_aligned((double)val.NumPM10, 9, 5);
  print_aligned((double)val.PartSize, 7, 5);
  print_aligned(avg_PartSize, 7, 5);
  print_aligned(actual_Error_Margin, 6, 2);
  print_aligned(running_Error_Margin, 6, 2);

  Serial.print(F("\n"));
#endif
  return (true);
}

/**
 * According to the datasheet: PMx defines particles with a size smaller than “x” micrometers (e.g., PM2.5 = particles smaller than 2.5 μm).
 *
 *assume :  PM0.5   PM1    PM2.5  PM4    PM10       Typical size
 *          30.75 / 35.2 / 35.4 / 35.4 / 35.4 #/cm³ -> 0.54μm
 *
 * That means (taking the samples mentioned above):
 * 30.75 have a size up to 0.5 um               >> avg. size impact = 30.75 * 0.499
 * 35.2 - 30.75 have a size between 0.5 and 1   >> avg. size impact = (35.2 - 30.75) * 0.99
 * 35.4 - 35.2 have a size between 1 and 2.5um >> etc
 *
 * Add the avg. size impact values ( 20.325) and divide by total = PM10 = 35.4) gives a calculated avg size of 0.57.
 *
 * PM0.5  PM1   PM2.5   PM4   PM10  avg size
 * 30.75   35.2  35.4  35.4  35.4  0.54
 * 0.499   0.99  2.49  3.99  9.99
 * 15.345  4.40  0.498    0    0   20.247
 *
 *                   Calculated average : 0.5719
 *
 * It is not a 100% fit. Maybe they apply different multiplier for size impact, maybe have more information in the sensor than exposed,
 * maybe include a number of the previous measurements in the calculations to prevent the number jump up and down too much
 * between the snap-shots.
 * I had a sketch running for 175 samples, sample every 3 seconds
 * The average for the 175 typical size was : 0,575451860465117 um
 * The average for 175 calculated avg was : 0,583083779069767 um,
 * Thus a delta of 0,007631918604651 over 175 samples. The error margin of 1.33%. I can live with that.
 *
 * One suprising aspect is when float's were used to calculate often 0.57620 is the outcome... When checking the values and calculations
 * with a spreadsheet, there was a mismatch in the result . (error with float measurement ?)
 *
 * Hence the double values are applied.
 *
 */

bool init_I2CSPS30(void)
{
  char SPS30_available;
  SPS30_available = 1;
  // set driver debug level
  sps30.EnableDebugging(DEBUG);

  // Begin communication channel

  //   if (! sps30.begin(SP30_COMMS))
  //     Errorloop((char *) "could not initialize communication channel.", 0);

  if (sps30.begin(SP30_COMMS) == false)
  {
    Errorloop((char *)"Could not set I2C communication channel.", 0);
    SPS30_available = 0;
  }

  // check for SPS30 connection
  if (!sps30.probe())
    // Errorloop((char *)"could not probe / connect with SPS30.", 0);
    Serial.println(F("could not probe / connect with SPS30."));
  else
    Serial.println(F("Detected SPS30."));

  // reset SPS30 connection
  if (!sps30.reset())
    Errorloop((char *)"could not reset.", 0);

  // read device info
  // GetDeviceInfo();

  // do Auto Clean interval, Current Auto Clean interval: 345600 seconds
  // SetAutoClean();
  // start measurement
  if (sps30.start())
  {
    // Serial.println(F("SPS30 Measurement started"));
  }
  else
    Errorloop((char *)"Could NOT start measurement", 0);

  // clean now requested
  if (PERFORMCLEANNOW)
  {
    // clean now
    if (sps30.clean() == true)
      Serial.println(F("fan-cleaning manually started"));
    else
      Serial.println(F("Could NOT manually start fan-cleaning"));
  }

  if (sps30.I2C_expect() == 4)
    Serial.println(F(" !!! Due to I2C buffersize only the SPS30 MASS concentration is available !!! \n"));
  return SPS30_available;
}

// SensirionI2CSgp40 sgp40;
SensirionI2CSgp41 sgp41;
// Sampling interval in seconds
// This code uses a fixed heating pulse of ca. 200 ms for the measurement and
// thus, the sampling interval defines the duty cycle
float sampling_interval = 1.f;
int SGP41_conditioning_sec = 0;
// time in seconds needed for NOx conditioning
uint16_t SGP41_conditioning_s = 10;
// VOCGasIndexAlgorithm voc_algorithm(sampling_interval);
VOCGasIndexAlgorithm voc_algorithm;
NOxGasIndexAlgorithm nox_algorithm;
uint16_t defaultCompenstaionRh = 0x8000; // in ticks as defined by SGP41
uint16_t defaultCompenstaionT = 0x6666;  // in ticks as defined by SGP41
uint16_t compensationRh = 0;             // in ticks as defined by SGP41
uint16_t compensationT = 0;              // in ticks as defined by SGP41
uint16_t SGP4x_srawVoc = 0;
int32_t SGP4x_voc_index = 0;
uint16_t SGP4x_srawNox = 0;
int32_t SGP4x_nox_index = 0;
uint16_t SGP41_error;
char errorMessage[64];

void init_SGP4x(void)
{
  uint16_t error;
  char errorMessage[256];

  sgp41.begin(Wire);

  uint16_t serialNumber[3];
  uint8_t serialNumberSize = 3;

  error = sgp41.getSerialNumber(serialNumber, serialNumberSize);

  if (error)
  {
    Serial.print("Error trying to execute getSerialNumber(): ");
    errorToString(error, errorMessage, 256);
    Serial.println(errorMessage);
  }
  else
  {
    Serial.print("SerialNumber:");
    Serial.print("0x");
    for (size_t i = 0; i < serialNumberSize; i++)
    {
      uint16_t value = serialNumber[i];
      Serial.print(value < 4096 ? "0" : "");
      Serial.print(value < 256 ? "0" : "");
      Serial.print(value < 16 ? "0" : "");
      Serial.print(value, HEX);
    }
    Serial.println();
  }

  uint16_t testResult;
  error = sgp41.executeSelfTest(testResult);
  if (error)
  {
    Serial.print("Error trying to execute executeSelfTest(): ");
    errorToString(error, errorMessage, 256);
    Serial.println(errorMessage);
  }
  else if (testResult != 0xD400)
  {
    Serial.print("executeSelfTest failed with error: ");
    Serial.println(testResult);
  }

  Serial.print("Sampling interval (sec):\t");
  Serial.println(voc_algorithm.get_sampling_interval());
  Serial.println("");
}

// void sgp40MeasureRawSignalLowPower(uint16_t compensationRh,
//                                    uint16_t compensationT, uint16_t* error) {
//    // uint16_t SGP4x_srawVoc = 0;
//    // int32_t SGP4x_voc_index = 0;
//     // Request a first measurement to heat up the plate (ignoring the result)
//     *error = sgp40.measureRawSignal(compensationRh, compensationT, SGP4x_srawVoc);
//     if (*error) {
//         return;
//     }

//     // Delaying 170 msec to let the plate heat up.
//     // Keeping in mind that the measure command already include a 30ms delay
//     delay(140);

//     // Request the measurement values
//     *error = sgp40.measureRawSignal(compensationRh, compensationT, SGP4x_srawVoc);
//     if (*error) {
//         return;
//     }
//     #ifdef main_SERIAL_DEBUG
//     Serial.print("\t");
//     Serial.print("RH: ");
//      Serial.print(compensationRh);
//     Serial.print("  Temp: ");
//     Serial.print(compensationT);

//     Serial.print("  SGP4x_srawVoc: ");
//     Serial.println(SGP4x_srawVoc);
//     #endif
//     // Turn heater off
//     *error = sgp40.turnHeaterOff();
//     if (*error) {
//         return;
//     }

//     // Process raw signals by Gas Index Algorithm to get the VOC index values
//     SGP4x_voc_index = voc_algorithm.process(SGP4x_srawVoc);
//     #ifdef main_SERIAL_DEBUG
//     Serial.print("\t");
//     Serial.print("SGP4xVOC Index: ");
//     Serial.println(SGP4x_voc_index);
//     #endif
// }

// void readout_SGP40(void){
//    uint16_t error;
//     char errorMessage[256];
//     uint16_t defaultRh = 0x8000;
//     uint16_t defaultT = 0x6666;
//    // uint16_t srawVoc = 0;

//     //delay(1000);
//     defaultRh = uint16_t(BME0x77_RH);
//     defaultT =  uint16_t(BME0x77_temp);
//     // 3. Measure SGP40 signals using low power mode
//     sgp40MeasureRawSignalLowPower(defaultRh, defaultT, &error);
//     if (error) {
//         Serial.print(
//             "SGP40 - Error trying to acquire data in low power mode: ");
//         errorToString(error, errorMessage, sizeof(errorMessage));
//         Serial.println(errorMessage);
//     }

//     // error = sgp40.measureRawSignal(defaultRh, defaultT, srawVoc);
//     // if (error) {
//     //     Serial.print("Error trying to execute measureRawSignal(): ");
//     //     errorToString(error, errorMessage, 256);
//     //     Serial.println(errorMessage);
//     // } else {
//     //     Serial.print("SRAW_VOC:");
//     //     Serial.println(srawVoc);
//     // }
// }

bool condiandreadout_SGP41(void)
{

  // float humidity = 0;     // %RH
  // float temperature = 0;  // degreeC
  //  uint16_t srawVoc = 0;
  //  uint16_t srawNox = 0;
  //  uint16_t defaultCompenstaionRh = 0x8000;  // in ticks as defined by SGP41
  //  uint16_t defaultCompenstaionT = 0x6666;   // in ticks as defined by SGP41
  //  uint16_t compensationRh = 0;              // in ticks as defined by SGP41
  //  uint16_t compensationT = 0;               // in ticks as defined by SGP41

  // 1. Sleep: Measure every second (1Hz), as defined by the Gas Index
  // Algorithm
  //    prerequisite
  // delay(1000);

  // 2. Measure temperature and humidity for SGP internal compensation
  // error = sht4x.measureHighPrecision(temperature, humidity);
  // if (error) {
  //     Serial.print(
  //         "SHT4x - Error trying to execute measureHighPrecision(): ");
  //     errorToString(error, errorMessage, 256);
  //     Serial.println(errorMessage);
  //     Serial.println("Fallback to use default values for humidity and "
  //                    "temperature compensation for SGP41");
  compensationRh = defaultCompenstaionRh;
  compensationT = defaultCompenstaionT;
  // } else {
  //     Serial.print("T:");
  //     Serial.print(temperature);
  //     Serial.print("\t");
  //     Serial.print("RH:");
  //     Serial.println(humidity);

  // convert temperature and humidity to ticks as defined by BME6880x76
  // interface
  // NOTE: in case you read RH and T raw signals check out the
  // ticks specification in the datasheet, as they can be different for
  // different sensors
  compensationT = static_cast<uint16_t>((BME0x76_temp + 45) * 65535 / 175);
  compensationRh = static_cast<uint16_t>(BME0x76_RH * 65535 / 100);
  //}

  // 3. Measure SGP4x signals
  if (SGP41_conditioning_s > 0)
  {
    // During NOx conditioning (10s) SRAW NOx will remain 0
    SGP41_error =
        sgp41.executeConditioning(compensationRh, compensationT, SGP4x_srawVoc);

    SGP41_conditioning_s--;

    // Serial.print("SGP 41 conditioning: ");
    // Serial.println(SGP41_conditioning_s);
    return 0;
  }
  else
  {
    Serial.println("SGP 41 conditioning: complete ");
    Serial.print("Temp: ");
    Serial.print(BME0x76_temp);
    Serial.print("   compensationT: ");
    Serial.print(compensationT);
    Serial.print("\t");
    Serial.print("RH:");
    Serial.print(BME0x76_RH);
    Serial.print("   compensationRH: ");
    Serial.println(compensationRh);

    SGP41_error = sgp41.measureRawSignals(compensationRh, compensationT, SGP4x_srawVoc,
                                          SGP4x_srawNox);
  }

  // 4. Process raw signals by Gas Index Algorithm to get the VOC and NOx
  // index
  //    values
  if (SGP41_error)
  {
    Serial.print("SGP41 - Error trying to execute measureRawSignals(): ");
    errorToString(SGP41_error, errorMessage, 256);
    Serial.println(errorMessage);
    return 0;
  }
  else
  {
    SGP4x_voc_index = voc_algorithm.process(SGP4x_srawVoc);
    SGP4x_nox_index = nox_algorithm.process(SGP4x_srawNox);
    Serial.print("SGP4x_srawVoc: ");
    Serial.print(SGP4x_srawVoc);
    Serial.print("\t");
    Serial.print("SGP4x_srawNox: ");
    Serial.print(SGP4x_srawNox);
    Serial.print("\t");
    Serial.print("VOC Index: ");
    Serial.print(SGP4x_voc_index);
    Serial.print("\t");
    Serial.print("NOx Index: ");
    Serial.println(SGP4x_nox_index);
    check_SGP41_readout = 1;
    return 1;
  }
}

/* Create an object of the class Bsec2 */
// Bsec2 envSensor;

// #define PANIC_LED LED_BUILTIN
// #define PANIC_DUR 100

/*!
 * @brief Configuring the sensor with digital pin 13 as
 * an output and toggles it at one second pace
 */
// static void panicLeds(void)
// {
//   int n = 0;
//   while (n < 10)
//   {
//     digitalWrite(PANIC_LED, HIGH);
//     delay(PANIC_DUR);
//     digitalWrite(PANIC_LED, LOW);
//     delay(PANIC_DUR);
//     n++;
//   }
// }
Bme68x bme; // Create an instance of the BME688 sensor 0x77
float BME0x77_temp, BME0x77_pressure, BME0x77_RH, BME0x77_gasresistance, BME0x77_status;
/* Heater temperature in degree Celsius */
// uint16_t tempProf[10] = {400, 200, 225, 250, 275, 300, 325, 350, 375, 400};
uint16_t tempProf[85] = {400, 400, 400, 400, 400,
                         200, 200, 200, 200, 200,
                         400, 400, 400, 400, 400,
                         225, 225, 225, 225, 225,
                         400, 400, 400, 400, 400,
                         250, 250, 250, 250, 250,
                         400, 400, 400, 400, 400,
                         275, 275, 275, 275, 275,
                         400, 400, 400, 400, 400,
                         300, 300, 300, 300, 300,
                         400, 400, 400, 400, 400,
                         325, 325, 325, 325, 325,
                         400, 400, 400, 400, 400,
                         350, 350, 350, 350, 350,
                         400, 400, 400, 400, 400,
                         375, 375, 375, 375, 375,
                         400, 400, 400, 400, 400};
float Rgas[85] = {0, 0, 0, 0, 0,
                  0, 0, 0, 0, 0,
                  0, 0, 0, 0, 0,
                  0, 0, 0, 0, 0,
                  0, 0, 0, 0, 0,
                  0, 0, 0, 0, 0,
                  0, 0, 0, 0, 0,
                  0, 0, 0, 0, 0,
                  0, 0, 0, 0, 0,
                  0, 0, 0, 0, 0,
                  0, 0, 0, 0, 0,
                  0, 0, 0, 0, 0,
                  0, 0, 0, 0, 0,
                  0, 0, 0, 0, 0,
                  0, 0, 0, 0, 0,
                  0, 0, 0, 0, 0,
                  0, 0, 0, 0, 0};
unsigned long startBME0x77Millis, endBME0x77Millis;
bool BME0x77settemp = 0;
//#define BMEx77_SERIAL_DEBUG 1
bool readout_BME0x77(void)
{

  bme68xData data;
  // int temp;
  if (BME0x77settemp == 0)
  {
#ifdef BMEx77_SERIAL_DEBUG
    Serial.print(RTC_sec);
    Serial.print(" Set temperature ");
    Serial.print(tempProf[tempProf_idx]);
    Serial.print("C: ");
    startBME0x77Millis = millis();
#endif
    /* Set the heater configuration to 400 deg C for 900ms for Forced mode */
    bme.setHeaterProf(tempProf[tempProf_idx], 700);//230830: change back to 700ms from 1700mm with 10k pull resisterB24,
    //230825 add4.7k pullup I2C, keep 1700ms
    // 230823 change from 700 to 1700 hope to prevent MKR frozen, 
    // 230817:change temperature profile to 85 steps, change from 3900 to 900
    bme.setOpMode(BME68X_FORCED_MODE);
    delayMicroseconds(bme.getMeasDur());
    BME0x77settemp = 1;
  }

  if ((BME0x77settemp == 1) && (bme.fetchData()))
  {
    bme.getData(data);
    BME0x77_temp = data.temperature;
    BME0x77_pressure = data.pressure;
    BME0x77_RH = data.humidity;
    Rgas[tempProf_idx] = data.gas_resistance;
    Rgas0x76[tempProf_idx] = BME0x76_gasresistance;
  //  BME0x77_status = data.status;
#ifdef BMEx77_SERIAL_DEBUG
    endBME0x77Millis = millis();
    Serial.print("Time to Fetch data: ");
    Serial.print(endBME0x77Millis - startBME0x77Millis);
    Serial.print(" ms ");
    Serial.print(" Gas resistance: ");
    Serial.println(Rgas[tempProf_idx]);
#endif
   

//#ifdef BMEx77_SERIAL_DEBUG
    //Serial.println(Rgas[tempProf_idx]);
    // Serial.print(String(data.temperature) + ", ");
    // Serial.print(String(data.pressure) + ", ");
    // Serial.print(String(data.humidity) + ", ");
    // Serial.print(data.status, HEX);
    // Serial.print(" 400C: ");
    // Serial.print(String(data.gas_resistance) + ", ");
//#endif
    tempProf_idx++;
    BME0x77settemp = 0;
  }
  if (tempProf_idx == 85)
    return 1;
  else
    return 0;

  // BME68X_FORCED_MODE
  // for (int i = 0; i < 10; i++ )
  // { // Temperature range from 100 to 400°C with 50°C steps
  // 	// Serial.println();
  // 	// Serial.print("Gas resistance at ");
  // 	//startMillis = millis();
  //   temp = tempProf[i];
  // 	bme.setHeaterProf(tempProf[i], 1000); // Set the gas heater temperature and duration
  // 								   // startMillis = millis();
  // 	bme.setOpMode(BME68X_FORCED_MODE);
  // 	// while (millis() - startMillis < 1000) {
  // 	//   bme.getData(data);
  // 	//   Serial.print(data.gas_resistance / 1000.0, 3);  // Convert gas resistance to kOhm
  // 	//   Serial.print(" kOhm, ");
  // 	if (bme.fetchData())
  // 	{
  // 		//endMillis = millis();
  // 		// Serial.print("Time to Fetch data:: ");
  // 		//Serial.print(endMillis - startMillis);
  // 		//Serial.print(" ms ");
  // 		Serial.print(tempProf[i]);
  // 		Serial.print("C: ");
  // 		// Serial.print("Gas resistance: ");
  // 		bme.getData(data);
  //     Rgas[i+1] = data.gas_resistance;
  // 		Serial.print(Rgas[i+1]); // Convert gas resistance to kOhm
  // 		Serial.print(", ");
  // 	}
  // 	//}
  // }
  // Serial.println();
}

Bsec iaqSensor; // at Ì2C 0x76
// uint8_t bsecState[BSEC_MAX_STATE_BLOB_SIZE] = {0};
// uint16_t stateUpdateCounter = 0;

// Bme68x bme2; // Create an instance of the BME688 sensor
// #define NEW_GAS_MEAS (BME68X_GASM_VALID_MSK | BME68X_HEAT_STAB_MSK | BME68X_NEW_DATA_MSK)
/* Macros used in BME68x_datalogger module */

/* Configure the BSEC library with information about the sensor
    18v/33v = Voltage at Vdd. 1.8V or 3.3V
    3s/300s = BSEC operating mode, BSEC_SAMPLE_RATE_LP or BSEC_SAMPLE_RATE_ULP
    4d/28d = Operating age of the sensor in days
    generic_18v_3s_4d
    generic_18v_3s_28d
    generic_18v_300s_4d
    generic_18v_300s_28d
    generic_33v_3s_4d
    generic_33v_3s_28d
    generic_33v_300s_4d
    generic_33v_300s_28d
*/
const uint8_t bsec_config_iaq[] = {
#include "config/generic_33v_3s_4d/bsec_iaq.txt"
};

/**
 * @brief Initializes the sensor and hardware settings
 */
void init_BME0x76(void){
  iaqSensor.begin(BME68X_I2C_ADDR_LOW, Wire); //_LOW 0x76
  output = "\n0x76 LP BSEC library version " + String(iaqSensor.version.major) + "." + String(iaqSensor.version.minor) + "." + String(iaqSensor.version.major_bugfix) + "." + String(iaqSensor.version.minor_bugfix);
  Serial.println(output);
  //checkIaqSensorStatus();

  iaqSensor.setConfig(bsec_config_iaq); //"config/generic_33v_3s_4d/bsec_iaq.txt"
  //checkIaqSensorStatus();

  loadState();

  bsec_virtual_sensor_t sensorList[12] = {
      BSEC_OUTPUT_IAQ,
      BSEC_OUTPUT_STATIC_IAQ,
      BSEC_OUTPUT_CO2_EQUIVALENT,
      BSEC_OUTPUT_BREATH_VOC_EQUIVALENT,
      BSEC_OUTPUT_RAW_TEMPERATURE,
      BSEC_OUTPUT_RAW_PRESSURE,
      BSEC_OUTPUT_RAW_HUMIDITY,
      BSEC_OUTPUT_RAW_GAS,
      BSEC_OUTPUT_STABILIZATION_STATUS,
      BSEC_OUTPUT_RUN_IN_STATUS,
      BSEC_OUTPUT_SENSOR_HEAT_COMPENSATED_TEMPERATURE,
      BSEC_OUTPUT_SENSOR_HEAT_COMPENSATED_HUMIDITY
      // BSEC_OUTPUT_GAS_PERCENTAGE
  };

  iaqSensor.updateSubscription(sensorList, 12, BSEC_SAMPLE_RATE_LP); //_ULP _300s data update every 5 minutes

  //checkIaqSensorStatus();
   Serial.println("Complete init_BME0x76_LP");
}


void init_BME0x76_ULP_LP(void){
  iaqSensor.begin(BME68X_I2C_ADDR_LOW, Wire); //_LOW 0x76
  output = "\n0x76 ULP LP BSEC library version " + String(iaqSensor.version.major) + "." + String(iaqSensor.version.minor) + "." + String(iaqSensor.version.major_bugfix) + "." + String(iaqSensor.version.minor_bugfix);
  Serial.println(output);
  //checkIaqSensorStatus();

  iaqSensor.setConfig(bsec_config_iaq); //"config/generic_33v_3s_4d/bsec_iaq.txt"
  //checkIaqSensorStatus();

  loadState();

   //basic_config_state_ULP_LP.ino
   bsec_virtual_sensor_t sensorList1[7] = {
     BSEC_OUTPUT_IAQ,
     BSEC_OUTPUT_STATIC_IAQ,
     BSEC_OUTPUT_CO2_EQUIVALENT,
     BSEC_OUTPUT_BREATH_VOC_EQUIVALENT,
     BSEC_OUTPUT_RAW_GAS,
     BSEC_OUTPUT_STABILIZATION_STATUS,
     BSEC_OUTPUT_RUN_IN_STATUS
   };

  iaqSensor.updateSubscription(sensorList1, 7, BSEC_SAMPLE_RATE_ULP); //somehow, this list doet not update.

  bsec_virtual_sensor_t sensorList2[5] = {
    BSEC_OUTPUT_RAW_TEMPERATURE,
    BSEC_OUTPUT_RAW_PRESSURE,
    BSEC_OUTPUT_RAW_HUMIDITY,
    BSEC_OUTPUT_SENSOR_HEAT_COMPENSATED_TEMPERATURE,
    BSEC_OUTPUT_SENSOR_HEAT_COMPENSATED_HUMIDITY
  };

  iaqSensor.updateSubscription(sensorList2, 5, BSEC_SAMPLE_RATE_LP);
  //checkIaqSensorStatus();
   Serial.println("Complete init_BME0x76_ULP_LP");
}

void init_BME68xsSGP4x(void)
{
  // BSEC 0x76 center

  // pinMode(LED_BUILTIN, OUTPUT);
  iaqSensor.begin(BME68X_I2C_ADDR_LOW, Wire); //_LOW 0x76
  output = "\n0x76 BSEC library version " + String(iaqSensor.version.major) + "." + String(iaqSensor.version.minor) + "." + String(iaqSensor.version.major_bugfix) + "." + String(iaqSensor.version.minor_bugfix);
  Serial.println(output);
  checkIaqSensorStatus();

  iaqSensor.setConfig(bsec_config_iaq); //"config/generic_33v_3s_4d/bsec_iaq.txt"
  checkIaqSensorStatus();

  loadState();

  bsec_virtual_sensor_t sensorList[12] = {
      BSEC_OUTPUT_IAQ,
      BSEC_OUTPUT_STATIC_IAQ,
      BSEC_OUTPUT_CO2_EQUIVALENT,
      BSEC_OUTPUT_BREATH_VOC_EQUIVALENT,
      BSEC_OUTPUT_RAW_TEMPERATURE,
      BSEC_OUTPUT_RAW_PRESSURE,
      BSEC_OUTPUT_RAW_HUMIDITY,
      BSEC_OUTPUT_RAW_GAS,
      BSEC_OUTPUT_STABILIZATION_STATUS,
      BSEC_OUTPUT_RUN_IN_STATUS,
      BSEC_OUTPUT_SENSOR_HEAT_COMPENSATED_TEMPERATURE,
      BSEC_OUTPUT_SENSOR_HEAT_COMPENSATED_HUMIDITY
      // BSEC_OUTPUT_GAS_PERCENTAGE
  };

  iaqSensor.updateSubscription(sensorList, 12, BSEC_SAMPLE_RATE_LP); //_ULP _300s data update every 5 minutes

  // basic_config_state_ULP_LP.ino
  //  bsec_virtual_sensor_t sensorList1[7] = {
  //    BSEC_OUTPUT_IAQ,
  //    BSEC_OUTPUT_STATIC_IAQ,
  //    BSEC_OUTPUT_CO2_EQUIVALENT,
  //    BSEC_OUTPUT_BREATH_VOC_EQUIVALENT,
  //    BSEC_OUTPUT_RAW_GAS,
  //    BSEC_OUTPUT_STABILIZATION_STATUS,
  //    BSEC_OUTPUT_RUN_IN_STATUS
  //  };

  // iaqSensor.updateSubscription(sensorList1, 7, BSEC_SAMPLE_RATE_ULP); //somehow, this list doet not update.

  // bsec_virtual_sensor_t sensorList2[5] = {
  //   BSEC_OUTPUT_RAW_TEMPERATURE,
  //   BSEC_OUTPUT_RAW_PRESSURE,
  //   BSEC_OUTPUT_RAW_HUMIDITY,
  //   BSEC_OUTPUT_SENSOR_HEAT_COMPENSATED_TEMPERATURE,
  //   BSEC_OUTPUT_SENSOR_HEAT_COMPENSATED_HUMIDITY
  // };

  // iaqSensor.updateSubscription(sensorList2, 5, BSEC_SAMPLE_RATE_LP);

  checkIaqSensorStatus();
  // Print the header
  // output = "Timestamp [ms], IAQ, IAQ accuracy, Static IAQ, CO2 equivalent, breath VOC equivalent, raw temp[°C], pressure [hPa], raw relative humidity [%], gas [Ohm], Stab Status, run in status, comp temp[°C], comp humidity [%], gas percentage";
  Serial.println("Complete setup BSEC on BME0x76");

  // Gas scanner 0x77
  /* Initializes the sensor based on ÌC library */
  bme.begin(BME68X_I2C_ADDR_HIGH, Wire); // 0x77

  Serial.println("BME68x I2C 0x77 begin");
  /* Set the default configuration for temperature, pressure and humidity */
  bme.setTPH();

  /* Set the heater configuration to 300 deg C for 100ms for Forced mode */
  bme.setHeaterProf(300, 100);

  if (bme.checkStatus())
  {
    if (bme.checkStatus() == BME68X_ERROR)
    {
      Serial.println("Gas scanner BME 0x77 error:" + bme.statusString());
      return;
    }
    else if (bme.checkStatus() == BME68X_WARNING)
    {
      Serial.println("Gas scanner BME 0x77 Warning:" + bme.statusString());
    }
  }
  // Serial.println("TimeStamp(ms), nFieldsLeft, Temperature(deg C), Pressure(Pa), Humidity(%), Gas resistance(ohm), Status, Gas index");

  // SGP41
  uint16_t error;
  char errorMessage[256];

  sgp41.begin(Wire);

  uint16_t serialNumber[3];
  uint8_t serialNumberSize = 3;

  error = sgp41.getSerialNumber(serialNumber, serialNumberSize);

  if (error)
  {
    Serial.print("SGP41 Error trying to execute getSerialNumber(): ");
    errorToString(error, errorMessage, 256);
    Serial.println(errorMessage);
  }
  else
  {
    Serial.print("SerialNumber:");
    Serial.print("0x");
    for (size_t i = 0; i < serialNumberSize; i++)
    {
      uint16_t value = serialNumber[i];
      Serial.print(value < 4096 ? "0" : "");
      Serial.print(value < 256 ? "0" : "");
      Serial.print(value < 16 ? "0" : "");
      Serial.print(value, HEX);
    }
    Serial.println();
  }

  uint16_t testResult;
  error = sgp41.executeSelfTest(testResult);
  if (error)
  {
    Serial.print("SGP 41 Error trying to execute executeSelfTest(): ");
    errorToString(error, errorMessage, 256);
    Serial.println(errorMessage);
  }
  else if (testResult != 0xD400)
  {
    Serial.print("SGP41 executeSelfTest failed with error: ");
    Serial.println(testResult);
  }

  delay(1000); // needed on some Arduino boards in order to have Serial ready

  int32_t index_offset;
  int32_t learning_time_offset_hours;
  int32_t learning_time_gain_hours;
  int32_t gating_max_duration_minutes;
  int32_t std_initial;
  int32_t gain_factor;
  voc_algorithm.get_tuning_parameters(
      index_offset, learning_time_offset_hours, learning_time_gain_hours,
      gating_max_duration_minutes, std_initial, gain_factor);

  Serial.println("\nVOC Gas Index Algorithm parameters");
  Serial.print("Index offset:\t");
  Serial.println(index_offset);
  Serial.print("Learing time offset hours:\t");
  Serial.println(learning_time_offset_hours);
  Serial.print("Learing time gain hours:\t");
  Serial.println(learning_time_gain_hours);
  Serial.print("Gating max duration minutes:\t");
  Serial.println(gating_max_duration_minutes);
  Serial.print("Std inital:\t");
  Serial.println(std_initial);
  Serial.print("Gain factor:\t");
  Serial.println(gain_factor);

  nox_algorithm.get_tuning_parameters(
      index_offset, learning_time_offset_hours, learning_time_gain_hours,
      gating_max_duration_minutes, std_initial, gain_factor);

  Serial.println("\nNOx Gas Index Algorithm parameters");
  Serial.print("Index offset:\t");
  Serial.println(index_offset);
  Serial.print("Learing time offset hours:\t");
  Serial.println(learning_time_offset_hours);
  Serial.print("Gating max duration minutes:\t");
  Serial.println(gating_max_duration_minutes);
  Serial.print("Gain factor:\t");
  Serial.println(gain_factor);
  Serial.println("");
}
float BME0x76_iaq, BME0x76_iaqAccuracy, BME0x76_staticiaq, BME0x76_CO2Equi,
    BME0x76_breathVocEqui, BME0x76_rawTemp, BME0x76_rawRH, BME0x76_gasPercentage,
    BME0x76_temp, BME0x76_pressure, BME0x76_RH, BME0x76_gasresistance,
    BME0x76_Stabstatus, BME0x76_runstatus;

int n_BME0x76_readout = 0;
float Rgas0x76[85] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0};
void readout_BME0x76(void)
{

  String outputBME0x76;
  // if (iaqSensor.run())
  //{ // If new data is available
  //  digitalWrite(LED_BUILTIN, LOW);
  //  Basic config state
  BME0x76_iaq = iaqSensor.iaq;
  BME0x76_iaqAccuracy = iaqSensor.iaqAccuracy;
  BME0x76_staticiaq = iaqSensor.staticIaq;
  BME0x76_CO2Equi = iaqSensor.co2Equivalent;
  BME0x76_breathVocEqui = iaqSensor.breathVocEquivalent;
  BME0x76_rawTemp = iaqSensor.rawTemperature;
  BME0x76_pressure = iaqSensor.pressure;
  BME0x76_rawRH = iaqSensor.rawHumidity;
  BME0x76_gasresistance = iaqSensor.gasResistance;
  BME0x76_Stabstatus = iaqSensor.stabStatus;
  BME0x76_runstatus = iaqSensor.runInStatus;
  BME0x76_temp = iaqSensor.temperature;
  BME0x76_RH = iaqSensor.humidity;
  // BME0x76_gasPercentage = iaqSensor.gasPercentage;
  // Basic config state ULP LP
  //   output += ", " + String(iaqSensor.iaq);
  //  output += ", " + String(iaqSensor.iaqAccuracy);
  //  output += ", " + String(iaqSensor.rawTemperature);
  //  output += ", " + String(iaqSensor.pressure);
  //  output += ", " + String(iaqSensor.rawHumidity);
  //  output += ", " + String(iaqSensor.gasResistance);
  //  output += ", " + String(iaqSensor.temperature);
  //  output += ", " + String(iaqSensor.humidity);
  outputBME0x76 += String(RTC_sec);
  outputBME0x76 += ", " + String(BME0x76_iaq);
  outputBME0x76 += ", " + String(BME0x76_iaqAccuracy);
  outputBME0x76 += ", " + String(BME0x76_staticiaq);
  outputBME0x76 += ", " + String(BME0x76_CO2Equi);
  outputBME0x76 += ", " + String(BME0x76_breathVocEqui);
  outputBME0x76 += ", " + String(BME0x76_rawTemp);
  outputBME0x76 += ", " + String(BME0x76_pressure);
  outputBME0x76 += ", " + String(BME0x76_rawRH);
  outputBME0x76 += ", " + String(BME0x76_gasresistance);
  outputBME0x76 += ", " + String(BME0x76_Stabstatus);
  outputBME0x76 += ", " + String(BME0x76_runstatus);
  outputBME0x76 += ", " + String(BME0x76_temp);
  outputBME0x76 += ", " + String(BME0x76_RH);
  // outputBME0x76 += ", " + String(iaqSensor.gasPercentage);
  Serial.println(outputBME0x76);
  // n_BME0x76_readout++;
  //  Serial.println(output);
  //  digitalWrite(LED_BUILTIN, HIGH);
  updateState();
  // }
}

// Thermocouple K type for stove oven
MCP9600 sensor;

err_t sensor_basic_config()
{
  err_t ret = NO_ERROR;
  CHECK_RESULT(ret, sensor.set_filt_coefficients(FILT_MID));
  CHECK_RESULT(ret, sensor.set_cold_junc_resolution(COLD_JUNC_RESOLUTION_0_25));
  CHECK_RESULT(ret, sensor.set_ADC_meas_resolution(ADC_14BIT_RESOLUTION));
  CHECK_RESULT(ret, sensor.set_burst_mode_samp(BURST_32_SAMPLE));
  CHECK_RESULT(ret, sensor.set_sensor_mode(NORMAL_OPERATION));
  return ret;
}

err_t get_temperature(float *value)
{
  err_t ret = NO_ERROR;
  float hot_junc = 0;
  float junc_delta = 0;
  float cold_junc = 0;
  CHECK_RESULT(ret, sensor.read_hot_junc(&hot_junc));
  CHECK_RESULT(ret, sensor.read_junc_temp_delta(&junc_delta));

  CHECK_RESULT(ret, sensor.read_cold_junc(&cold_junc));

  // SERIAL.print("hot junc=");
  // SERIAL.println(hot_junc);
  // SERIAL.print("junc_delta=");
  // SERIAL.println(junc_delta);
  // SERIAL.print("cold_junc=");
  // SERIAL.println(cold_junc);

  *value = hot_junc;

  return ret;
}

void init_MCP9600(void)
{

  if (sensor.init(THER_TYPE_K))
  {
    Serial.println("MCP 9600 thermocouple sensor init failed!!");
  }
  sensor_basic_config();
  Serial.println("MCP 9600  start!!");
}

float Stove_temp = 0;
void readout_Ktypetemp(void)
{

  get_temperature(&Stove_temp);
}



// // Append data to the SD card (DON'T MODIFY THIS FUNCTION)
// void appendFile(fs::FS &fs, const char * path, const char * message) {
//  // Serial.printf("Appending to file: %s\n", path);

//   File file = fs.open(path, FILE_APPEND);
//   if(!file) {
//     Serial.println("Failed to open file for appending");
//     return;
//   }
//   if(file.print(message)) {
//     Serial.println("Message appended");
//   } else {
//     Serial.println("Append failed");
//   }
//   file.close();
// }



// void init_BME68x(void)
// {
//   bme.begin(0x77, Wire);
//   // if (!) {
//   //   Serial.println("Could not find BME688 sensor!");

//   // }
//   if (bme.checkStatus())
//   {
//     if (bme.checkStatus() == BME68X_ERROR)
//     {
//       Serial.println("Sensor error:" + bme.statusString());
//       return;
//     }
//     else if (bme.checkStatus() == BME68X_WARNING)
//     {
//       Serial.println("Sensor Warning:" + bme.statusString());
//     }
//   }
//   /* Set the default configuration for temperature, pressure and humidity */
//   bme.setTPH();

//   /* Set the heater configuration to 300 deg C for 100ms for Forced mode */
//   bme.setHeaterProf(300, 100);

//   // Serial.println("TimeStamp(ms), Temperature(deg C), Pressure(Pa), Humidity(%), Gas resistance(ohm), Status");
//   bme.setOpMode(BME68X_FORCED_MODE);
//   /* Setting SD Card */
//   // sprintf(LOGBME68x_FILE_NAME, "%02d%02d%02d.csv", rtc.getYear(), rtc.getMonth(), rtc.getDay());
//   // logBME68xData = SD.open(LOGBME68x_FILE_NAME, FILE_WRITE);
//   // /* Parameters for logging in the file */
//   // logHeader = "TimeStamp(ms),Sensor Index,Temperature(deg "
//   //             "C),Pressure(Pa),Humidity(%),Gas Resistance(ohm),Gas "
//   //             "Index,Meas Index,idac,Status,Gas Valid,Heater Stable";

//   // if (logBME68xData.println(logHeader)) {
//   //   Serial.println(logHeader);
//   //   logBME68xData.close();
//   // } else {
//   //   panicLeds();
//   // }
//   // logHeader = "";

//   /* Setting the default heater profile configuration */

//   // bme.setTPH();

//   /* Heater temperature in degree Celsius as per the suggested heater profile
//    */
//   // uint16_t tempProf[10] = {320, 100, 100, 100, 200, 200, 200, 320, 320, 320};
//   /* Multiplier to the shared heater duration */
//   // uint16_t mulProf[10] = {5, 2, 10, 30, 5, 5, 5, 5, 5, 5};
//   /* Shared heating duration in milliseconds */
//   // uint16_t sharedHeatrDur =
//   //     MEAS_DUR - bme[i].getMeasDur(BME68X_PARALLEL_MODE);

//   // bme.setSeqSleep(BME68X_ODR_250_MS);
//   // bme.setHeaterProf(tempProf, durProf, 3);
//   // bme.setOpMode(BME68X_SEQUENTIAL_MODE);

//   // /* Set the default configuration for temperature, pressure and humidity */
//   // bme.setTPH();

//   // /* Heater temperature in degree Celsius */
//   // uint16_t tempProf[10] = { 100, 200, 320 };
//   // /* Heating duration in milliseconds */
//   // uint16_t durProf[10] = { 150, 150, 150 };

//   // bme.setSeqSleep(BME68X_ODR_250_MS);
//   // bme.setHeaterProf(tempProf, durProf, 3);
//   // bme.setOpMode(BME68X_SEQUENTIAL_MODE);

//   // bme.setTemperatureOversampling(BME688_OS_8X);
//   // bme.setHumidityOversampling(BME688_OS_2X);
//   // bme.setPressureOversampling(BME688_OS_4X);
//   // bme.setIIRFilterSize(BME688_FILTER_SIZE_3);

//   // bme.setGasHeater(320, 150); // Set gas heater temperature and duration
// }

// void readout_BME68xsSGP4x(void)
// {
//   bme68xData data;
//   // uint8_t nFieldsLeft = 0;

//   if (iaqSensor.run())
//   { // If new data is available
//     // digitalWrite(LED_BUILTIN, LOW);

//     BME0x76_iaq = iaqSensor.iaq;
//     BME0x76_iaqAccuracy = iaqSensor.iaqAccuracy;
//     BME0x76_staticiaq = iaqSensor.staticIaq;
//     BME0x76_CO2Equi = iaqSensor.co2Equivalent;
//     BME0x76_breathVocEqui = iaqSensor.breathVocEquivalent;
//     BME0x76_rawTemp = iaqSensor.rawTemperature;
//     BME0x76_pressure = iaqSensor.pressure;
//     BME0x76_rawRH = iaqSensor.rawHumidity;
//     BME0x76_gasresistance = iaqSensor.gasResistance;
//     BME0x76_Stabstatus = iaqSensor.stabStatus;
//     BME0x76_runstatus = iaqSensor.runInStatus;
//     BME0x76_temp = iaqSensor.temperature;
//     BME0x76_RH = iaqSensor.humidity;
//     BME0x76_gasPercentage = iaqSensor.gasPercentage;
//     // Serial.println(output);
//     // digitalWrite(LED_BUILTIN, HIGH);
//     updateState();
//   }
//   else
//   {
//     checkIaqSensorStatus();
//   }

//   // 230613 BME68X_SEQUENTIAL_MODE
//   // delay(150);
//   //  if (bme.fetchData())
//   //  {
//   //  	do
//   //  	{
//   //  		nFieldsLeft = bme.getData(data);
//   //     //Serial.println(nFieldsLeft);
//   // 		//if (data.status == NEW_GAS_MEAS)
//   // 		{
//   //       Serial.print(String(millis()) + ", ");
//   // 			Serial.print(String(nFieldsLeft) + ", ");
//   // 			Serial.print(String(data.temperature) + ", ");
//   // 			Serial.print(String(data.pressure) + ", ");
//   // 			Serial.print(String(data.humidity) + ", ");
//   // 			Serial.print(String(data.gas_resistance) + ", ");
//   // 			Serial.print(String(data.status, HEX) + ", ");
//   // 			Serial.println(data.gas_index);
//   // 			if(data.gas_index == 2) /* Sequential mode sleeps after this measurement */
//   // 				delay(250);
//   // 		}
//   // 	} while (nFieldsLeft);
//   // }

//   /*
//   To log the raw gas resistance under different temperature conditions, you can use the following steps:

//   Set the gas heater temperature and duration using the setGasHeater function. You can choose a range of temperatures from 200 to 400 degrees Celsius.

//   Wait for the gas heater to warm up and stabilize the temperature using the waitForHeater function.

//   Read the gas resistance by calling the readGas function with the desired gas parameter. For example, if you want to measure VOCx, you can use the BME688_GAS_RESISTANCE parameter.

//   Repeat the above steps for different gas heater temperatures to log the raw gas resistance under different temperature conditions.
//   */

//   /* Set the heater configuration to 300 deg C for 100ms for Forced mode */
//   bme.setHeaterProf(400, 1000);
//   bme.setOpMode(BME68X_FORCED_MODE);
//   delayMicroseconds(bme.getMeasDur());
//   if (bme.fetchData())
//   {
//     bme.getData(data);
//     Serial.print(String(millis()) + ", ");
//     Serial.print(String(data.temperature) + ", ");
//     Serial.print(String(data.pressure) + ", ");
//     Serial.print(String(data.humidity) + ", ");
//     Serial.print(data.status, HEX);
//     Serial.print(" 400C: ");
//     Serial.print(String(data.gas_resistance) + ", ");
//   }
//   // BME68X_FORCED_MODE
//   for (int temp = 175; temp <= 400; temp += 25)
//   { // Temperature range from 100 to 400°C with 50°C steps
//     // Serial.println();
//     // Serial.print("Gas resistance at ");
//     // startMillis = millis();

//     bme.setHeaterProf(temp, 1000); // Set the gas heater temperature and duration
//                                    // startMillis = millis();
//     bme.setOpMode(BME68X_FORCED_MODE);
//     // while (millis() - startMillis < 1000) {
//     //   bme.getData(data);
//     //   Serial.print(data.gas_resistance / 1000.0, 3);  // Convert gas resistance to kOhm
//     //   Serial.print(" kOhm, ");
//     if (bme.fetchData())
//     {
//       // endMillis = millis();
//       //  Serial.print("Time to Fetch data:: ");
//       // Serial.print(endMillis - startMillis);
//       // Serial.print(" ms ");
//       Serial.print(temp);
//       Serial.print("C: ");
//       // Serial.print("Gas resistance: ");
//       bme.getData(data);
//       Serial.print(data.gas_resistance); // Convert gas resistance to kOhm
//       Serial.print(", ");
//     }
//     //}
//   }
//   Serial.println();

//   // delayMicroseconds(bme.getMeasDur());
//   // bme.waitForHeater(); // Wait for the gas heater to warm up and stabilize the temperature
//   //  delayMicroseconds(bme.getMeasDur());
//   //  Serial.print("Delay: ");
//   //  delay(1000);
//   //  while (!bme.fetchData()){
//   //    bme.getData(data);
//   //  float gas_resistance = data.gas_resistance; // Read the raw gas resistance
//   //  };
//   // Serial.print("Fetch data: ");
//   // Serial.println(bme.fetchData());

//   delay(15000);
// }