/*

//#define WindSensorPin 0 // The digital pin location of the anemometer sensor for windspeed to count the number of times the switch is activated per period of time
//#define WindVanePin A1  // The pin the wind vane sensor is connected to
//#define Sunrise_PIN_EN 1
// chip select for SD card
//const int SD_CS_PIN = 4;
//#define RDY_PIN 5    // Connect LP8    RDY pin to Arduino pin  5 (opt.)
//#define EN_VBB_PIN 3 // Connect LP8 EN_VBB pin to Arduino pin  3
//const int alertReadyPin = 6;// Wire ADS1115 ALERT/RDY pin to Arduino pin 6
//#define GPSWAKEUP_PIN 7// define a digital pin capable of driving HIGH and LOW
// See the readme.md for details on connecting the sensor and setting up Azure IoT Central to recieve the data.

I2C scanner. Scanning ...
Found address: 66 (0x42)
Found address: 72 (0x48) ADS1115_1
Found address: 73 (0x49) ADS1115_2
Found address: 74 (0x4A) ADS1115_3
Found address: 89 (0x59) SGP40/41
Found address: 105 (0x69) SPS30
Found address: 119 (0x77) BME688
Found address: 128 (0x80)
Found address: 194 (0xC2)
Found address: 200 (0xC8)
Found address: 201 (0xC9)
Found address: 202 (0xCA)
Found address: 217 (0xD9)
Found address: 233 (0xE9)
Found address: 247 (0xF7)
Done.
Found 15 device(s).

*/
#define DEVICE_NAME "Arduino MKR1010" //"ARDUINO_SAMD_MKRGSM1400"//"ARDUINO_MKRZero"//"ARDUINO_SAMD_MKRGSM1400"
#include <Arduino.h>
#include "func_libs.h"
#include <FlashStorage_SAMD.h>
#include "ThingSpeak.h"
#include <WiFiNINA.h>

#define STATE_SAVE_PERIOD UINT32_C(360 * 60 * 1000) // 360 minutes - 4 times a day
uint8_t bsecState[BSEC_MAX_STATE_BLOB_SIZE] = {0};
uint16_t stateUpdateCounter = 0;
//
// Create an rtc object
RTCZero rtc;
uint8_t RTC_year, RTC_month, RTC_day, RTC_hour, RTC_min, RTC_sec; // RTC system date time
bool set_RTC_check = 0;
bool SPS30_available = 1;
bool SPS30_readout = 0;
uint8_t SPS30_sleep, SPS30_wakeup;

int check_SGP41_readout = 0;
bool BME0x77_readout = 0;
int tempProf_idx = 0;
int n_BME0x76_error = 0;
bool BME0x76_available = 1;

char ssid[] = "KAI Coffee";    //  your network SSID (name) 
char pass[] = "stayhealthy";   // your network password
int keyIndex = 0;            // your network key Index number (needed only for WEP)
WiFiClient  client;
String myStatus = "";

unsigned long myChannelNumber = 2143486;
const char * myWriteAPIKey = "7S2B59GXF6IWFU4E";

// chip select for SD card
// chip select for SD card
#if defined(ARDUINO_SAMD_MKRZERO)
const int SD_CS_PIN = 28;
#else
const int SD_CS_PIN = 4;
#endif

// file object
File logData;
File logBMEData;
File logBME1Data;
char filename[14] = {0}; // character array variable to store our converted date string for SD.open()
char BMEfilename[14] = {0};
int n_saveData = 0;
int n_saveBME = 0;
// char BME1filename[14] = {0};
int SDwrite_status;
bool check_SDcard;

int lastCheckSGP41Seconds = 0;
int lastCheckADCSeconds = 0;
int lastCheckBME0x77Seconds = 0;
int lastCheckBME0x76Seconds = 0;
int lastCheckMinutes = 0;
int lastminuteBME0x77_readout;
int lastCheckday = 0;
unsigned long startMillis, endMillis;

bool GPS_check = 0;
bool GPS_readout = 0;
bool check_readouttinyGPS = 0;
unsigned long startMillisGPS, endMillisGPS;
String output;


#if defined(ARDUINO_SAMD_MKRWIFI1010) || defined(ARDUINO_SAMD_NANO_33_IOT) || defined(ARDUINO_AVR_UNO_WIFI_REV2)
//WiFiSSLClient wifiClientSSL;
//WiFiClient wifinonSSL;
// create a WiFi UDP object for NTP to use
//WiFiUDP wifiUdp;
// create an NTP object
//NTP ntp(wifiUdp);
#elif defined(ARDUINO_SAMD_MKR1000)
#include <WiFi101.h>

#elif defined(ARDUINO_ESP8266_ESP12)
#include <ESP8266WiFi.h>

#elif defined(ARDUINO_SAMD_MKRGSM1400)
// Please enter your sensitive data in the Secret tab or arduino_secrets.h
// PIN Number
const char PINNUMBER[] = SECRET_PINNUMBER;
// APN data
const char GPRS_APN[] = SECRET_GPRS_APN;
const char GPRS_LOGIN[] = SECRET_GPRS_LOGIN;
const char GPRS_PASSWORD[] = SECRET_GPRS_PASSWORD;
// initialize the library instance
GSMClient client;
GSMSSLClient SimSslClient;
GPRS gprs;
GSM gsmAccess; //(true)
GSMScanner scannerNetworks;
GSMModem modemTest;

// Save data variables
String IMEI = "";
// A UDP instance to let us send and receive packets over UDP
GSMUDP Udp;
// create an NTP object
NTP ntp(Udp);
#endif

/*

*/
void setup()
{
    // put your setup code here, to run once:

    Serial.begin(9600);
    // while (!Serial);

    //Serial1.begin(9600);
    // initialize digital pin LED_BUILTIN as an output.
    pinMode(LED_BUILTIN, OUTPUT);

    digitalWrite(LED_BUILTIN, HIGH);
    // uncomment this line to add a small delay to allow time for connecting serial moitor to get full debug output

    rtc.begin(); // initialize RTC
    rtc.setTime(0, 0, 0);
    rtc.setDate(01, 01, 23);
    delay(5000);
    Serial.println(F("Initializing..."));
    // init_TinyGPS();
    // if (Serial1.available())
    // {
    //     if (tinygps.encode(Serial1.read()))
    //     {
    //         String msg = Serial1.readStringUntil('\r');
    //         Serial.println(msg);

    //         Serial.print("LAT=");
    //         Serial.println(tinygps.location.lat(), 6);
    //         Serial.print("LONG=");
    //         Serial.println(tinygps.location.lng(), 6);
    //         Serial.print("ALT=");
    //         Serial.println(tinygps.altitude.meters(), 6);
    //         delay(4 * 1000);
    //     }
    // }

    Wire.begin(); // Start I2C
    //  #if defined(ARDUINO_SAMD_MKRZERO)
    if (init_GNSS())
    {
        GPS_check = 1;
    }
    else
    {
        Serial.println("Wait for GPS signal");
        // lastCheckMinutes = rtc.getMinutes();
        // lastCheckSeconds = rtc.getSeconds();
        startMillisGPS = millis(); // Update the timer
        while ((endMillisGPS - startMillisGPS < 60000) && (GPS_check == 0))
        {
            if (myGNSS.getPVT())
            {
                if (readout_GPS())
                    GPS_check = 1;
            }
            endMillisGPS = millis(); // Update the timer
        }
    }
    RTC_year = rtc.getYear(); // GMT RTC sync with GPS server
    RTC_month = rtc.getMonth();
    RTC_day = rtc.getDay();
    RTC_hour = rtc.getHours();
    RTC_min = rtc.getMinutes();
    RTC_sec = rtc.getSeconds();

    Serial.println("System Date time: ");
    Serial.print(RTC_year);
    Serial.print("/");
    Serial.print(RTC_month);
    Serial.print("/");
    Serial.print(RTC_day);
    Serial.print("\t");

    // ...and time
    print2digits(RTC_hour);
    Serial.print(":");
    print2digits(RTC_min);
    Serial.print(":");
    print2digits(RTC_sec);
    Serial.println("");

    init_ads1115s();
    delay(500);
    init_SRI2C_single(); // SUNRISE_ADDR            = 0x68;
    // define SPS30_ADDRESS 0x69                 // I2c address
    if (init_I2CSPS30())
    {
        SPS30_available = 1;
        Serial.println("SPS30_available");
    }
    else
        SPS30_available = 0;

    Serial.print(F("\nStart EmulatedEEPROM on "));
    Serial.println(BOARD_NAME);
    Serial.println(FLASH_STORAGE_SAMD_VERSION);

    Serial.print("EEPROM length: ");
    Serial.println(EEPROM.length());
    // Init BME688
    // init_BME68x();
    // Init SGP4x
    // init_SGP4x();
    init_BME68xsSGP4x();
    init_MCP9600();
    //  init SPI
    SPI.begin();
    delay(100);

    // reserve 2kB for String used as a buffer for output
    output.reserve(2048);
    // init SD card
    if (!SD.begin(SD_CS_PIN))
    {
        Serial.println("Failed to initialize SD card!");
        check_SDcard = 0;
        digitalWrite(LED_BUILTIN, HIGH);
        // errLeds();
    }
    else
    {
        check_SDcard = 1;
        sprintf(filename, "D%02d%02d%02d.csv", rtc.getMonth(), rtc.getDay(), n_saveData); //%02d, rtc.getYear()
        logData = SD.open(filename, FILE_WRITE);
        delay(1000);

        // init the CSV file with headers
        // output = String(rtc.getYear()); // GMT RTC sync with NTP server
        // output += "-" + String(rtc.getMonth());
        // output += "-" + String(rtc.getDay());
        // output += " " + String(rtc.getHours());
        // output += ":" + String(rtc.getMinutes());
        // output += ":" + String(rtc.getSeconds());

        output = String("RTC_Date"); // Arduino system RTC
        output += "," + String("RTC_Time");

        output += "," + String("GPS_Lat");  // MKR GPS shield Lat
        output += "," + String("GPS_Long"); // Long
        output += "," + String("GPS_Alt");  // Altitude
        output += "," + String("n_satellites");
        output += "," + String("GPSDate"); // MKR GPS GMT date
        output += "," + String("GPSTime"); // MKR GPS GMT time

        output += "," + String("tinyGPSlat");  // Grove GPS shield Lat,
        output += "," + String("tinyGPSlong"); // Long
        output += "," + String("tinyGPSDateTime");
        output += "," + String("tinyGPSTime");

        output += "," + String("Stove_temp"); // K type thermocouple temperature

        output += "," + String("avg_AE1"); // OP2 Auxillary Electrode 1 (mV) to adc10
        output += "," + String("std_AE1"); // standard devation of 60 secs measurement
        output += "," + String("avg_WE1"); // OP1 Working Electrode 1 (mV) to adc13
        output += "," + String("std_WE1");
        output += "," + String("avg_Pt1000pos"); // Pt1000+ (mV) to adc11
        output += "," + String("std_Pt1000pos");
        // output += "," + String("avg_Pt1000neg"); // Pt1000- (mV) to adc12
        // output += "," + String("std_Pt1000neg");
        output += "," + String("avg_PIDOPWE4"); // PIDOP or Working Electrode 4 (mV) to adc31
        output += "," + String("std_PIDOPWE4");

        output += "," + String("avg_AE2"); // OP4 Auxillary Electrode 2 (mV) to adc23
        output += "," + String("std_AE2"); // standard devation of 60 secs measurement
        output += "," + String("avg_WE2"); // OP3 Working Electrode 2 (mV) to adc20
        output += "," + String("std_WE2");
        output += "," + String("avg_AE3"); // OP6 Auxillary Electrode 3 (mV) to adc22
        output += "," + String("std_AE3");
        output += "," + String("avg_WE3"); // OP5 Working Electrode 3 (mV) to adc21
        output += "," + String("std_WE3");

        output += "," + String("avg_AE4");  // OP8 Auxillary Electrode 4 (mV) to adc30
        output += "," + String("std_AE4");  // standard devation of 60 secs measurement
        output += "," + String("avg_TGS1"); // TGS1 (mV) to adc31
        output += "," + String("std_TGS1");
        output += "," + String("avg_NGM"); // NGM sensor (mV) to adc32
        output += "," + String("std_NGM");
        output += "," + String("avg_TGS3"); // TGS3 sensor (mV) to adc33
        output += "," + String("std_TGS3");
        // output += "," + String("avg_PIDOPWE4"); // PIDOP or Working Electrode 4 (mV) to adc31
        // output += "," + String("std_PIDOPWE4");
        // output += "," + String("avg_NGM"); // NGM sensor (mV) to adc32
        // output += "," + String("std_NGM");
        // output += "," + String("avg_TGS"); // TGS sensor (mV) to adc33
        // output += "," + String("std_TGS");

        output += "," + String("SRco2Val"); // CO2 ppm from Sunrise sensor

        output += "," + String("MassPM1");              // Mass Concentration PM1 [μg/m3]
        output += "," + String("MassPM2_5");            // Mass Concentration PM2.5 [μg/m3]
        output += "," + String("MassPM4");              // Mass Concentration PM4 [μg/m3]
        output += "," + String("MassPM10");             // Mass Concentration PM10 [μg/m3]
        output += "," + String("NumPM0_5");             // Number Concentration PM0.5 [#/cm3]
        output += "," + String("NumPM1");               // Number Concentration PM1 [#/cm3]
        output += "," + String("NumPM2_5");             // Number Concentration PM2.5 [#/cm3]
        output += "," + String("NumPM4");               // Number Concentration PM4 [#/cm3]
        output += "," + String("NumPM10");              // Number Concentration PM10 [#/cm3]
        output += "," + String("typ_PartSize");         // Typical Partsize [μm]
        output += "," + String("avg_PartSize");         // Average Partsize [μm]
        output += "," + String("actual_Error_Margin");  // Actual Error Margin [%]
        output += "," + String("running_Error_Margin"); // last_Error_Margin [%]

        output += "," + String("SGP4x_srawVoc");
        output += "," + String("SGP4x_voc_index");
        output += "," + String("SGP4x_srawNox");
        output += "," + String("SGP4x_nox_index");

        output += "," + String("BME0x76_iaq");
        output += "," + String("BME0x76_iaqAccuracy");
        output += "," + String("BME0x76_staticiaq");
        output += "," + String("BME0x76_CO2Equi");
        output += "," + String("BME0x76_breathVocEqui");
        output += "," + String("BME0x76_Stabstatus");
        output += "," + String("BME0x76_runstatus");
        //    output += ", " + String("BME0x76_gasresistance");
        output += "," + String("BME0x76_rawTemp");
        output += "," + String("BME0x76_temp");
        output += "," + String("BME0x76_rawRH");
        output += "," + String("BME0x76_RH");
        output += "," + String("BME0x76_pressure");
        output += "," + String("BME0x76_gasresistance");
        // output += "," + String("BME0x77_temp");
        // output += "," + String("BME0x77_RH");
        // output += "," + String("BME0x77_pressure"); // Pressure from BME688 sensor
        // output += "," + String("BME0x77_status");
        // output += "," + String("R00");
        // output += "," + String("E10"); // Rgas400start
        // output += "," + String("R01");
        // output += "," + String("E11"); // Rgas200
        // output += "," + String("R02");
        // output += "," + String("E12"); // Rgas225
        // output += "," + String("R03");
        // output += "," + String("E13"); // Rgas250
        // output += "," + String("R04");
        // output += "," + String("E14"); // Rgas275
        // output += "," + String("R05");
        // output += "," + String("E15"); // Rgas300
        // output += "," + String("R06");
        // output += "," + String("E16"); // Rgas325
        // output += "," + String("R07");
        // output += "," + String("E17"); // Rgas350
        // output += "," + String("R08");
        // output += "," + String("E18"); // Rgas375
        // output += "," + String("R09");
        // output += "," + String("E19"); // Rgas400end
        // output += ", " + String("G10");
        // output += ", " + String("G11");
        // output += ", " + String("G12");
        // output += ", " + String("G13");
        // output += ", " + String("G14");
        // output += ", " + String("G15");
        // output += ", " + String("G16");
        // output += ", " + String("G17");
        // output += ", " + String("G18");
        // output += ", " + String("G19");

        Serial.println(output);

        // print each of the sensor values
        SDwrite_status = logData.println(output);
        // close the file
        logData.close();
        output = "";

        sprintf(BMEfilename, "B%02d%02d%02d.csv", rtc.getMonth(), rtc.getDay(), n_saveBME);
        logBMEData = SD.open(BMEfilename, FILE_WRITE);
        output = String("RTC_Date"); // Arduino system RTC
        output += "," + String("RTC_Time");
        output += "," + String("GPSDate"); // MKR GPS GMT date
        output += "," + String("GPSTime"); // MKR GPS GMT time

        output += "," + String("BME0x76_temp");
        output += "," + String("BME0x76_RH");
        output += "," + String("BME0x76_pressure");

        output += "," + String("BME0x77_temp");
        output += "," + String("BME0x77_RH");
        output += "," + String("BME0x77_pressure"); // Pressure from BME688 sensor

        output += "," + String("R00");
        output += "," + String("R01");
        output += "," + String("R02");
        output += "," + String("R03");
        output += "," + String("R04");
        output += "," + String("R05");
        output += "," + String("R06");
        output += "," + String("R07");
        output += "," + String("R08");
        output += "," + String("R09");

        output += "," + String("R10");
        output += "," + String("R11");
        output += "," + String("R12");
        output += "," + String("R13");
        output += "," + String("R14");
        output += "," + String("R15");
        output += "," + String("R16");
        output += "," + String("R17");
        output += "," + String("R18");
        output += "," + String("R19");

        output += "," + String("R20");
        output += "," + String("R21");
        output += "," + String("R22");
        output += "," + String("R23");
        output += "," + String("R24");
        output += "," + String("R25");
        output += "," + String("R26");
        output += "," + String("R27");
        output += "," + String("R28");
        output += "," + String("R29");

        output += "," + String("R30");
        output += "," + String("R31");
        output += "," + String("R32");
        output += "," + String("R33");
        output += "," + String("R34");
        output += "," + String("R35");
        output += "," + String("R36");
        output += "," + String("R37");
        output += "," + String("R38");
        output += "," + String("R39");

        output += "," + String("R40");
        output += "," + String("R41");
        output += "," + String("R42");
        output += "," + String("R43");
        output += "," + String("R44");
        output += "," + String("R45");
        output += "," + String("R46");
        output += "," + String("R47");
        output += "," + String("R48");
        output += "," + String("R49");

        output += "," + String("R50");
        output += "," + String("R51");
        output += "," + String("R52");
        output += "," + String("R53");
        output += "," + String("R54");
        output += "," + String("R55");
        output += "," + String("R56");
        output += "," + String("R57");
        output += "," + String("R58");
        output += "," + String("R59");

        output += "," + String("R60");
        output += "," + String("R61");
        output += "," + String("R62");
        output += "," + String("R63");
        output += "," + String("R64");
        output += "," + String("R65");
        output += "," + String("R66");
        output += "," + String("R67");
        output += "," + String("R68");
        output += "," + String("R69");

        output += "," + String("R70");
        output += "," + String("R71");
        output += "," + String("R72");
        output += "," + String("R73");
        output += "," + String("R74");
        output += "," + String("R75");
        output += "," + String("R76");
        output += "," + String("R77");
        output += "," + String("R78");
        output += "," + String("R79");

        output += "," + String("R80");
        output += "," + String("R81");
        output += "," + String("R82");
        output += "," + String("R83");
        output += "," + String("R84");

        output += "," + String("R85");
        output += "," + String("R86");
        output += "," + String("R87");
        output += "," + String("R88");
        output += "," + String("R89");
        output += "," + String("R90");
        output += "," + String("R91");
        output += "," + String("R92");
        output += "," + String("R93");
        output += "," + String("R94");

        output += "," + String("R95");
        output += "," + String("R96");
        output += "," + String("R97");
        output += "," + String("R98");
        output += "," + String("R99");
        output += "," + String("R100");
        output += "," + String("R101");
        output += "," + String("R102");
        output += "," + String("R103");
        output += "," + String("R104");

        output += "," + String("R105");
        output += "," + String("R106");
        output += "," + String("R107");
        output += "," + String("R108");
        output += "," + String("R109");
        output += "," + String("R110");
        output += "," + String("R111");
        output += "," + String("R112");
        output += "," + String("R113");
        output += "," + String("R114");

        output += "," + String("R115");
        output += "," + String("R116");
        output += "," + String("R117");
        output += "," + String("R118");
        output += "," + String("R119");
        output += "," + String("R120");
        output += "," + String("R121");
        output += "," + String("R122");
        output += "," + String("R123");
        output += "," + String("R124");

        output += "," + String("R125");
        output += "," + String("R126");
        output += "," + String("R127");
        output += "," + String("R128");
        output += "," + String("R129");
        output += "," + String("R130");
        output += "," + String("R131");
        output += "," + String("R132");
        output += "," + String("R133");
        output += "," + String("R134");

        output += "," + String("R135");
        output += "," + String("R136");
        output += "," + String("R137");
        output += "," + String("R138");
        output += "," + String("R139");
        output += "," + String("R140");
        output += "," + String("R141");
        output += "," + String("R142");
        output += "," + String("R143");
        output += "," + String("R144");

        output += "," + String("R145");
        output += "," + String("R146");
        output += "," + String("R147");
        output += "," + String("R148");
        output += "," + String("R149");
        output += "," + String("R150");
        output += "," + String("R151");
        output += "," + String("R152");
        output += "," + String("R153");
        output += "," + String("R154");

        output += "," + String("R155");
        output += "," + String("R156");
        output += "," + String("R157");
        output += "," + String("R158");
        output += "," + String("R159");
        output += "," + String("R160");
        output += "," + String("R161");
        output += "," + String("R162");
        output += "," + String("R163");
        output += "," + String("R164");

        output += "," + String("R165");
        output += "," + String("R166");
        output += "," + String("R167");
        output += "," + String("R168");
        output += "," + String("R169");

        SDwrite_status = logBMEData.println(output);
        delay(50);
        // close the file
        logBMEData.close();
        output = "";

        // sprintf(BME1filename, "BME%02d%02d.csv", rtc.getMonth(), rtc.getDay());
        // logBME1Data = SD.open(BME1filename, FILE_WRITE);
        // output = String("RTC_Date"); // Arduino system RTC
        // output += "," + String("RTC_Time");
        // output += "," + String("GPSDate"); // MKR GPS GMT date
        // output += "," + String("GPSTime"); // MKR GPS GMT time

        // output += "," + String("BME0x76_temp");
        // output += "," + String("BME0x76_RH");
        // output += "," + String("BME0x76_pressure");

        // output += "," + String("BME0x77_temp");
        // output += "," + String("BME0x77_RH");
        // output += "," + String("BME0x77_pressure"); // Pressure from BME688 sensor

        // output += "," + String("R00");
        // output += "," + String("R01");
        // output += "," + String("R02");
        // output += "," + String("R03");
        // output += "," + String("R04");
        // output += "," + String("R05");
        // output += "," + String("R06");
        // output += "," + String("R07");
        // output += "," + String("R08");
        // output += "," + String("R09");

        // output += "," + String("R10");
        // output += "," + String("R11");
        // output += "," + String("R12");
        // output += "," + String("R13");
        // output += "," + String("R14");
        // output += "," + String("R15");
        // output += "," + String("R16");
        // output += "," + String("R17");
        // output += "," + String("R18");
        // output += "," + String("R19");

        // output += "," + String("R20");
        // output += "," + String("R21");
        // output += "," + String("R22");
        // output += "," + String("R23");
        // output += "," + String("R24");
        // output += "," + String("R25");
        // output += "," + String("R26");
        // output += "," + String("R27");
        // output += "," + String("R28");
        // output += "," + String("R29");

        // output += "," + String("R30");
        // output += "," + String("R31");
        // output += "," + String("R32");
        // output += "," + String("R33");
        // output += "," + String("R34");
        // output += "," + String("R35");
        // output += "," + String("R36");
        // output += "," + String("R37");
        // output += "," + String("R38");
        // output += "," + String("R39");

        // output += "," + String("R40");
        // output += "," + String("R41");
        // output += "," + String("R42");
        // output += "," + String("R43");
        // output += "," + String("R44");
        // output += "," + String("R45");
        // output += "," + String("R46");
        // output += "," + String("R47");
        // output += "," + String("R48");
        // output += "," + String("R49");

        // output += "," + String("R50");
        // output += "," + String("R51");
        // output += "," + String("R52");
        // output += "," + String("R53");
        // output += "," + String("R54");
        // output += "," + String("R55");
        // output += "," + String("R56");
        // output += "," + String("R57");
        // output += "," + String("R58");
        // output += "," + String("R59");

        // output += "," + String("R60");
        // output += "," + String("R61");
        // output += "," + String("R62");
        // output += "," + String("R63");
        // output += "," + String("R64");
        // output += "," + String("R65");
        // output += "," + String("R66");
        // output += "," + String("R67");
        // output += "," + String("R68");
        // output += "," + String("R69");

        // output += "," + String("R70");
        // output += "," + String("R71");
        // output += "," + String("R72");
        // output += "," + String("R73");
        // output += "," + String("R74");
        // output += "," + String("R75");
        // output += "," + String("R76");
        // output += "," + String("R77");
        // output += "," + String("R78");
        // output += "," + String("R79");

        // output += "," + String("R80");
        // output += "," + String("R81");
        // output += "," + String("R82");
        // output += "," + String("R83");
        // output += "," + String("R84");
        // SDwrite_status = logBME1Data.println(output);
        // delay(100);
        // // close the file
        // logBME1Data.close();
        // output = "";
        delay(50);
    }
    digitalWrite(LED_BUILTIN, LOW);

    while (!Serial) {
        ; // wait for serial port to connect. Needed for Leonardo native USB port only
    }
    
    // check for the WiFi module:
    if (WiFi.status() == WL_NO_MODULE) {
        Serial.println("Communication with WiFi module failed!");
        // don't continue
        while (true);
    }

    String fv = WiFi.firmwareVersion();
    if (fv != "1.0.0") {
        Serial.println("Please upgrade the firmware");
    }
    
    Serial.println("Inittializing wifi done");
    ThingSpeak.begin(client);  //Initialize ThingSpeak

    Serial.println("Inittializing Done");
}

void loop()
{

    // put your main code here, to run repeatedly:
    // RTC_year = rtc.getYear(); // GMT RTC sync with NTP server
    // RTC_month = rtc.getMonth();
    // RTC_day = rtc.getDay();
    // RTC_hour = rtc.getHours();
    // 240802 Move year month day hour into if RTC_sec > 5x to write data to SD card
    RTC_min = rtc.getMinutes();
    RTC_sec = rtc.getSeconds();
    // BME 0x76 BSEC basic config state: config/generic_33v_3s_4d/bsec_iaq.txt
    if (BME0x76_available)
    {
        if (iaqSensor.run() && (RTC_sec != lastCheckBME0x76Seconds))
        { // If new data on BME0x76 is available
            readout_BME0x76();
            lastCheckBME0x76Seconds = RTC_sec + 1;
            n_BME0x76_error = 0;
            delay(50);
            
        }
        else
        {
            //BME0x76_available = 0;
            checkIaqSensorStatus();
        }
    }

    if ((RTC_sec == 0) && (SPS30_available == 1) && (SPS30_readout == 0))
    {
        // Readout cooking stove temperature
        readout_Ktypetemp();
        // Readout CO2
        if (readout_SRI2Csingle())
        {
            Serial.print("Sunrise CO2: ");
            Serial.println(SRco2Val);
        }
        else
        {
            Serial.println("Sunrise:Not_OK");
        }

        // read all data
        SPS30_readout = read_allSPS30();
        // put the SPS30 to sleep
        SPS30_sleep = sps30.sleep();

        if (SPS30_sleep != SPS30_ERR_OK)
        {
#ifdef main_SERIAL_DEBUG
            Serial.print("ERROR: Could not set SPS30 to sleep. ");

            Serial.println(SPS30_sleep);
#endif
        }
        else
        {
#ifdef main_SERIAL_DEBUG
            Serial.print("SPS30 to sleep. ");
#endif
        }

// read the sensor values every second
#ifdef main_SERIAL_DEBUG
        endMillis = millis();
        Serial.print("Time to read SPS30 task: ");
        Serial.print(endMillis - startMillis);
        Serial.println(" ms");
#endif
    }

    // SGP 41 for VOCs, NOxs need 10 second for condition then read out
    if ((RTC_sec > 1) && (RTC_sec < 51) && (RTC_sec != lastCheckSGP41Seconds) && (check_SGP41_readout == 0))
    {

        if (condiandreadout_SGP41())
        {
            // Serial.println("Done readout SGP41");
            delay(50);
        }
        lastCheckSGP41Seconds = RTC_sec;
    }
    // THis work
    /*  if ( (RTC_sec != lastCheckBME0x77Seconds) && (tempProf_idx < 10)) //(RTC_sec > 0) && (RTC_sec < 54) &&
     {
         readout_BME0x77();
         lastCheckBME0x77Seconds = RTC_sec;
     } */
    // 230817 change to record more gas resistance value with 900 ms each step

    if (BME0x77_readout == 0)
    {
        if ((tempProf_idx < 85)) //(RTC_sec > 0) && (RTC_sec < 54) && (RTC_sec != lastCheckBME0x77Seconds) &&
        {
            readout_BME0x77();
            // lastCheckBME0x77Seconds = RTC_sec;
        }
        else
        {
            // establish wifi connection
            // Connect or reconnect to WiFi
            if(WiFi.status() != WL_CONNECTED){
                Serial.print("Attempting to connect to SSID: ");
                Serial.println(ssid);
                while(WiFi.status() != WL_CONNECTED){
                WiFi.begin(ssid, pass); // Connect to WPA/WPA2 network. Change this line if using open or WEP network
                Serial.print(".");
                delay(5000);     
                } 
                Serial.println("\nConnected.");
            }

            output = String(RTC_year);                // rtc.getYear() GMT RTC sync with NTP server
            output += "-" + String(RTC_month);        // rtc.getMonth()
            output += "-" + String(RTC_day);          // rtc.getDay()
            output += "," + String(RTC_hour);         // rtc.getHours()
            output += ":" + String(RTC_min);          // rtc.getMinutes()
            output += ":" + String(rtc.getSeconds()); // RTC_sec

            output += "," + String(GPSDate);
            output += "," + String(GPSTime);

            output += "," + String(BME0x76_temp);
            output += "," + String(BME0x76_RH);
            output += "," + String(BME0x76_pressure);
            output += "," + String(BME0x77_temp);
            output += "," + String(BME0x77_RH);
            output += "," + String(BME0x77_pressure); // Pressure from BME688 sensor


            // Write to ThingSpeak. There are up to 8 fields in a channel, allowing you to store up to 8 different
            // set the fields with the values
            ThingSpeak.setField(1, BME0x76_temp);
            ThingSpeak.setField(2, BME0x76_RH);
            ThingSpeak.setField(3, BME0x76_pressure);

            // set the status
            ThingSpeak.setStatus(myStatus);
            
            // write to the ThingSpeak channel
            int x = ThingSpeak.writeFields(myChannelNumber, myWriteAPIKey);
            if(x == 200){
                Serial.println("Channel update successful.");
            }
            else{
                Serial.println("Problem updating channel. HTTP error code " + String(x));
            }

            output += "," + String(Rgas0x76[0]);
            output += "," + String(Rgas0x76[1]);
            output += "," + String(Rgas0x76[2]);
            output += "," + String(Rgas0x76[3]);
            output += "," + String(Rgas0x76[4]);
            output += "," + String(Rgas0x76[5]);
            output += "," + String(Rgas0x76[6]);
            output += "," + String(Rgas0x76[7]);
            output += "," + String(Rgas0x76[8]);
            output += "," + String(Rgas0x76[9]);

            output += "," + String(Rgas0x76[10]);
            output += "," + String(Rgas0x76[11]);
            output += "," + String(Rgas0x76[12]);
            output += "," + String(Rgas0x76[13]);
            output += "," + String(Rgas0x76[14]);
            output += "," + String(Rgas0x76[15]);
            output += "," + String(Rgas0x76[16]);
            output += "," + String(Rgas0x76[17]);
            output += "," + String(Rgas0x76[18]);
            output += "," + String(Rgas0x76[19]);

            output += "," + String(Rgas0x76[20]);
            output += "," + String(Rgas0x76[21]);
            output += "," + String(Rgas0x76[22]);
            output += "," + String(Rgas0x76[23]);
            output += "," + String(Rgas0x76[24]);
            output += "," + String(Rgas0x76[25]);
            output += "," + String(Rgas0x76[26]);
            output += "," + String(Rgas0x76[27]);
            output += "," + String(Rgas0x76[28]);
            output += "," + String(Rgas0x76[29]);

            output += "," + String(Rgas0x76[30]);
            output += "," + String(Rgas0x76[31]);
            output += "," + String(Rgas0x76[32]);
            output += "," + String(Rgas0x76[33]);
            output += "," + String(Rgas0x76[34]);
            output += "," + String(Rgas0x76[35]);
            output += "," + String(Rgas0x76[36]);
            output += "," + String(Rgas0x76[37]);
            output += "," + String(Rgas0x76[38]);
            output += "," + String(Rgas0x76[39]);

            output += "," + String(Rgas0x76[40]);
            output += "," + String(Rgas0x76[41]);
            output += "," + String(Rgas0x76[42]);
            output += "," + String(Rgas0x76[43]);
            output += "," + String(Rgas0x76[44]);
            output += "," + String(Rgas0x76[45]);
            output += "," + String(Rgas0x76[46]);
            output += "," + String(Rgas0x76[47]);
            output += "," + String(Rgas0x76[48]);
            output += "," + String(Rgas0x76[49]);

            output += "," + String(Rgas0x76[50]);
            output += "," + String(Rgas0x76[51]);
            output += "," + String(Rgas0x76[52]);
            output += "," + String(Rgas0x76[53]);
            output += "," + String(Rgas0x76[54]);
            output += "," + String(Rgas0x76[55]);
            output += "," + String(Rgas0x76[56]);
            output += "," + String(Rgas0x76[57]);
            output += "," + String(Rgas0x76[58]);
            output += "," + String(Rgas0x76[59]);

            output += "," + String(Rgas0x76[60]);
            output += "," + String(Rgas0x76[61]);
            output += "," + String(Rgas0x76[62]);
            output += "," + String(Rgas0x76[63]);
            output += "," + String(Rgas0x76[64]);
            output += "," + String(Rgas0x76[65]);
            output += "," + String(Rgas0x76[66]);
            output += "," + String(Rgas0x76[67]);
            output += "," + String(Rgas0x76[68]);
            output += "," + String(Rgas0x76[69]);

            output += "," + String(Rgas0x76[70]);
            output += "," + String(Rgas0x76[71]);
            output += "," + String(Rgas0x76[72]);
            output += "," + String(Rgas0x76[73]);
            output += "," + String(Rgas0x76[74]);
            output += "," + String(Rgas0x76[75]);
            output += "," + String(Rgas0x76[76]);
            output += "," + String(Rgas0x76[77]);
            output += "," + String(Rgas0x76[78]);
            output += "," + String(Rgas0x76[79]);

            output += "," + String(Rgas0x76[80]);
            output += "," + String(Rgas0x76[81]);
            output += "," + String(Rgas0x76[82]);
            output += "," + String(Rgas0x76[83]);
            output += "," + String(Rgas0x76[84]);

            output += "," + String(Rgas[0]); // Rgas400start
            output += "," + String(Rgas[1]); // Rgas400
            output += "," + String(Rgas[2]); // Rgas400
            output += "," + String(Rgas[3]); // Rgas400
            output += "," + String(Rgas[4]); // Rgas400
            output += "," + String(Rgas[5]); // Rgas200
            output += "," + String(Rgas[6]); // Rgas200
            output += "," + String(Rgas[7]); // Rgas200
            output += "," + String(Rgas[8]); // Rgas200
            output += "," + String(Rgas[9]); // Rgas200

            output += "," + String(Rgas[10]); // Rgas225
            output += "," + String(Rgas[11]); // Rgas225
            output += "," + String(Rgas[12]); // Rgas225
            output += "," + String(Rgas[13]); // Rgas225
            output += "," + String(Rgas[14]); // Rgas225
            output += "," + String(Rgas[15]); // Rgas250
            output += "," + String(Rgas[16]); // Rgas250
            output += "," + String(Rgas[17]); // Rgas250
            output += "," + String(Rgas[18]); // Rgas250
            output += "," + String(Rgas[19]); // Rgas250

            output += "," + String(Rgas[20]); // Rgas275
            output += "," + String(Rgas[21]); // Rgas275
            output += "," + String(Rgas[22]); // Rgas275
            output += "," + String(Rgas[23]); // Rgas275
            output += "," + String(Rgas[24]); // Rgas275
            output += "," + String(Rgas[25]); // Rgas300
            output += "," + String(Rgas[26]); // Rgas300
            output += "," + String(Rgas[27]); // Rgas300
            output += "," + String(Rgas[28]); // Rgas300
            output += "," + String(Rgas[29]); // Rgas300

            output += "," + String(Rgas[30]); // Rgas325
            output += "," + String(Rgas[31]); // Rgas325
            output += "," + String(Rgas[32]); // Rgas325
            output += "," + String(Rgas[33]); // Rgas325
            output += "," + String(Rgas[34]); // Rgas325
            output += "," + String(Rgas[35]); // Rgas350
            output += "," + String(Rgas[36]); // Rgas350
            output += "," + String(Rgas[37]); // Rgas350
            output += "," + String(Rgas[38]); // Rgas350
            output += "," + String(Rgas[39]); // Rgas350

            output += "," + String(Rgas[40]); // Rgas375
            output += "," + String(Rgas[41]); // Rgas375
            output += "," + String(Rgas[42]); // Rgas375
            output += "," + String(Rgas[43]); // Rgas375
            output += "," + String(Rgas[44]); // Rgas375
            output += "," + String(Rgas[45]); // Rgas400
            output += "," + String(Rgas[46]); // Rgas400
            output += "," + String(Rgas[47]); // Rgas400
            output += "," + String(Rgas[48]); // Rgas400
            output += "," + String(Rgas[49]); // Rgas400

            output += "," + String(Rgas[50]); // Rgas375
            output += "," + String(Rgas[51]); // Rgas375
            output += "," + String(Rgas[52]); // Rgas375
            output += "," + String(Rgas[53]); // Rgas375
            output += "," + String(Rgas[54]); // Rgas375
            output += "," + String(Rgas[55]); // Rgas400
            output += "," + String(Rgas[56]); // Rgas400
            output += "," + String(Rgas[57]); // Rgas400
            output += "," + String(Rgas[58]); // Rgas400
            output += "," + String(Rgas[59]); // Rgas400

            output += "," + String(Rgas[60]); // Rgas375
            output += "," + String(Rgas[61]); // Rgas375
            output += "," + String(Rgas[62]); // Rgas375
            output += "," + String(Rgas[63]); // Rgas375
            output += "," + String(Rgas[64]); // Rgas375
            output += "," + String(Rgas[65]); // Rgas400
            output += "," + String(Rgas[66]); // Rgas400
            output += "," + String(Rgas[67]); // Rgas400
            output += "," + String(Rgas[68]); // Rgas400
            output += "," + String(Rgas[69]); // Rgas400

            output += "," + String(Rgas[70]); // Rgas375
            output += "," + String(Rgas[71]); // Rgas375
            output += "," + String(Rgas[72]); // Rgas375
            output += "," + String(Rgas[73]); // Rgas375
            output += "," + String(Rgas[74]); // Rgas375
            output += "," + String(Rgas[75]); // Rgas400
            output += "," + String(Rgas[76]); // Rgas400
            output += "," + String(Rgas[77]); // Rgas400
            output += "," + String(Rgas[78]); // Rgas400
            output += "," + String(Rgas[79]); // Rgas400

            output += "," + String(Rgas[80]); // Rgas375
            output += "," + String(Rgas[81]); // Rgas375
            output += "," + String(Rgas[82]); // Rgas375
            output += "," + String(Rgas[83]); // Rgas375
            output += "," + String(Rgas[84]); // Rgas375
            digitalWrite(LED_BUILTIN, HIGH);
            // startMillis = millis();
            sprintf(BMEfilename, "B%02d%02d%02d.csv", rtc.getMonth(), rtc.getDay(), n_saveBME);
            logBMEData = SD.open(BMEfilename, FILE_WRITE);
            if (logBMEData)
            {
                SDwrite_status = logBMEData.println(output);

                // close the file
                logBMEData.close();
                digitalWrite(LED_BUILTIN, LOW);
                Serial.println(output);
                output = "";
                tempProf_idx = 0;
                memset(Rgas, 0, sizeof(Rgas));         // Rgas[10] = {0,0,0,0,0,0,0,0,0,0};
                memset(Rgas0x76, 0, sizeof(Rgas0x76)); // Rgas0x76[10] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
                delay(100);
                // figure out the SD card status message
                // if (SDwrite_status > 0) {
                //      n_saveBME++;
                //      if (n_saveBME > 9) { //Close BME file to save 10 BME data point
                //         logBMEData.close();
                //         n_saveBME = 0;
                //      }
                // }
                // else {
                //    logBMEData.close();
                // }

                // if ((RTC_min >= 57)) {//(RTC_hour  == 11) ||  (RTC_hour  == 23) && //close and save data every hour
                //     // close the file
                //     logBMEData.close();
                // }
            }
            else
            {
                delay(100);
                logBMEData.close();
                Serial.println("error opening BME.csv file");
                Serial.println("Open new BME.csv file");
                n_saveBME++;
                sprintf(BMEfilename, "B%02d%02d%02d.csv", rtc.getMonth(), rtc.getDay(), n_saveBME);
                logBMEData = SD.open(BMEfilename, FILE_WRITE);
                if (logBMEData)
                {
                    SDwrite_status = logBMEData.println(output);
                    delay(20);
                    // close the file
                    logBMEData.close();
                    digitalWrite(LED_BUILTIN, LOW);
                    Serial.println(output);
                    output = "";
                    tempProf_idx = 0;
                    memset(Rgas, 0, sizeof(Rgas));         // Rgas[10] = {0,0,0,0,0,0,0,0,0,0};
                    memset(Rgas0x76, 0, sizeof(Rgas0x76)); // Rgas0x76[10] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
                }
                else
                {
                    // check if the SD card is available to write data without blocking
                    // and if the buffered data is enough for the full chunk size
                    unsigned int chunkSize = logBMEData.availableForWrite();
                    if (chunkSize && output.length() >= chunkSize)
                    {
                        // write to file and blink LED
                        // digitalWrite(LED_BUILTIN, HIGH);
                        logBMEData.write(output.c_str(), chunkSize);
                        digitalWrite(LED_BUILTIN, LOW);

                        // remove written data from buffer
                        output.remove(0, chunkSize);
                    }
                    else
                    {
                        // init SD card
                        if (!SD.begin(SD_CS_PIN))
                        {
                            SD.end();
                            Serial.println("Failed to initialize SD card!");
                            check_SDcard = 0;
                            delay(1000);
                            SD.begin(SD_CS_PIN);
                            digitalWrite(LED_BUILTIN, HIGH);
                            // errLeds();
                        }
                    }
                }
                output = "";
                tempProf_idx = 0;
                memset(Rgas, 0, sizeof(Rgas));         // Rgas[10] = {0,0,0,0,0,0,0,0,0,0};
                memset(Rgas0x76, 0, sizeof(Rgas0x76)); // Rgas0x76[10] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
                // endMillis = millis();
                // Serial.print("Time to write BMEdata to SD, reset mem task: ");
                // Serial.print(endMillis - startMillis);
                // Serial.println(" ms");
            }
            BME0x77_readout = 1;
            lastminuteBME0x77_readout = RTC_min;
        }

    } // if (BME0x77_readout == 0)

    if ((RTC_sec < 51) && (RTC_sec % 5 == 0) && (RTC_sec != lastCheckADCSeconds))
    {

        // startMillis = millis();
        //  read the sensor values every second

        read_singleallADS();

        // delay(100);

        // readout_SHT85();

        // AnemometerLoop(); // Get Anemometer dat

        // endMillis = millis();
        // Serial.print("Time to read SPS30, SGP41, 2 BME, 3ADS1115 task: ");
        // Serial.print(endMillis - startMillis);
        // Serial.print(" ms, lastCheckSeconds:");
        lastCheckADCSeconds = RTC_sec;
        // Serial.println(lastCheckSeconds);
    }
    if ((RTC_sec > 50) && (RTC_min != lastCheckMinutes)) // && (check_received_data == 0)
    {
        RTC_year = rtc.getYear(); // GMT RTC sync with NTP server
        RTC_month = rtc.getMonth();
        RTC_day = rtc.getDay();
        RTC_hour = rtc.getHours();
        // startMillis = millis();

        // calculate Avg, Std for CO, SO2, NO2, Pt1000, VOCs sensors
        calallsensStat();
// delay(100);

// wakeup SPS30
#ifdef main_SERIAL_DEBUG
        Serial.println("Wakeup SPS30. ");
#endif
        // if (SPS30_sleep == ERR_OK)
        // {
        SPS30_wakeup = sps30.wakeup();
        if (SPS30_wakeup != SPS30_ERR_OK)
        {
#ifdef main_SERIAL_DEBUG
            Serial.println((char *)"ERROR: Could not wakeup SPS30. Reinit I2CSPS30()");
#endif
            init_I2CSPS30();
        }
        else
            SPS30_readout = 0;
        // }

        // readout_SGP40();
        /* 230802 close to test BSEC lib
        //  This sketch displays information every time a new sentence is correctly encoded.
        while (Serial1.available() > 0 && check_readouttinyGPS == 0)
        {

            if (tinygps.encode(Serial1.read()))
            {
                Serial.println("TinyGPS data available");
                check_readouttinyGPS = readout_TinyGPS();
            }
        }
        check_readouttinyGPS = 0;
        if (millis() > 5000 && tinygps.charsProcessed() < 10)
        {
            Serial.println(F("No GPS detected: check wiring."));
            // while(true);
        }
        */
        // 230802 close to test BSEC lib
        if (myGNSS.getPVT() == true)
        {
            readout_GPS();
        }
        // Pack data prepare to save to SD card
        output = String(RTC_year);                // rtc.getYear() GMT RTC sync with NTP server
        output += "-" + String(RTC_month);        // rtc.getMonth()
        output += "-" + String(RTC_day);          // rtc.getDay()
        output += "," + String(RTC_hour);         // rtc.getHours()
        output += ":" + String(RTC_min);          // rtc.getMinutes()
        output += ":" + String(rtc.getSeconds()); // RTC_sec

        output += "," + String(latitude);  // MKR GPS shield , 7
        output += "," + String(longitude); //, 7
        output += "," + String(gps_altitude);
        output += "," + String(n_satellites);
        output += "," + String(GPSDate);
        output += "," + String(GPSTime);

        output += "," + String(tinyGPSlat);  // MKR GPS shield , 7
        output += "," + String(tinyGPSlong); //, 7
        output += "," + String(tinyGPSDateTime);
        output += "," + String(tinyGPSTime);

        output += "," + String(Stove_temp); // K type thermocouple temperature
        output += "," + String(avg_AE1, 5); // OP2 Auxillary Electrode 1 (mV) to adc10
        output += "," + String(std_AE1, 5); // standard devation of 60 secs measurement
        output += "," + String(avg_WE1, 5); // OP1 Working Electrode 1 (mV) to adc13
        output += "," + String(std_WE1, 5);
        output += "," + String(avg_Pt1000pos, 5); // Pt1000+ (mV) to adc11
        output += "," + String(std_Pt1000pos, 5);
        output += "," + String(avg_PIDOPWE4, 5); // PIDOP or Working Electrode 4 (mV) to adc31
        output += "," + String(std_PIDOPWE4, 5);

        output += "," + String(avg_AE2, 5); // OP4 Auxillary Electrode 2 (mV) to adc23
        output += "," + String(std_AE2, 5); // standard devation of 60 secs measurement
        output += "," + String(avg_WE2, 5); // OP3 Working Electrode 2 (mV) to adc20
        output += "," + String(std_WE2, 5);
        output += "," + String(avg_AE3, 5); // OP6 Auxillary Electrode 3 (mV) to adc22
        output += "," + String(std_AE3, 5);
        output += "," + String(avg_WE3, 5); // OP5 Working Electrode 3 (mV) to adc21
        output += "," + String(std_WE3, 5);

        output += "," + String(avg_AE4, 5);  // OP8 Auxillary Electrode 4 (mV) to adc30
        output += "," + String(std_AE4, 5);  // standard devation of 60 secs measurement
        output += "," + String(avg_TGS1, 5); // Pt1000- (mV) to adc12
        output += "," + String(std_TGS1, 5);
        output += "," + String(avg_NGM, 5); // NGM sensor (mV) to adc32
        output += "," + String(std_NGM, 5);
        output += "," + String(avg_TGS3, 5); // TGS sensor (mV) to adc33
        output += "," + String(std_TGS3, 5);

        output += "," + String(SRco2Val); // CO2 ppm from Sunrise sensor

        output += "," + String(MassPM1);              // Mass Concentration PM1 [μg/m3]
        output += "," + String(MassPM2_5);            // Mass Concentration PM2.5 [μg/m3]
        output += "," + String(MassPM4);              // Mass Concentration PM4 [μg/m3]
        output += "," + String(MassPM10);             // Mass Concentration PM10 [μg/m3]
        output += "," + String(NumPM0_5);             // Number Concentration PM0.5 [#/cm3]
        output += "," + String(NumPM1);               // Number Concentration PM1 [#/cm3]
        output += "," + String(NumPM2_5);             // Number Concentration PM2.5 [#/cm3]
        output += "," + String(NumPM4);               // Number Concentration PM4 [#/cm3]
        output += "," + String(NumPM10);              // Number Concentration PM10 [#/cm3]
        output += "," + String(typ_PartSize);         // Typical Partsize [μm]
        output += "," + String(avg_PartSize);         // Average Partsize [μm]
        output += "," + String(actual_Error_Margin);  // Actual Error Margin [%]
        output += "," + String(running_Error_Margin); // last_Error_Margin [%]

        output += "," + String(SGP4x_srawVoc);
        output += "," + String(SGP4x_voc_index);
        output += "," + String(SGP4x_srawNox);
        output += "," + String(SGP4x_nox_index);

        output += ", " + String(BME0x76_iaq); // index air quality
        output += ", " + String(BME0x76_iaqAccuracy);
        output += ", " + String(BME0x76_staticiaq);
        output += ", " + String(BME0x76_CO2Equi);
        output += ", " + String(BME0x76_breathVocEqui); // VOCs measurement from BME688
        output += ", " + String(BME0x76_Stabstatus);
        output += ", " + String(BME0x76_runstatus);

        output += "," + String(BME0x76_rawTemp);
        output += "," + String(BME0x76_temp);
        output += "," + String(BME0x76_rawRH);
        output += "," + String(BME0x76_RH);
        output += "," + String(BME0x76_pressure);
        output += "," + String(BME0x76_gasresistance);
        // output += "," + String(BME0x77_temp);
        // output += "," + String(BME0x77_RH);
        // output += "," + String(BME0x77_pressure); // Pressure from BME688 sensor
        // output += "," + String(BME0x77_status);

        // output += "," + String(Rgas0x76[0], 5);
        // output += "," + String(Rgas[0] / 400, 5); // Rgas400start
        // output += "," + String(Rgas0x76[1], 5);
        // output += "," + String(Rgas[1] / 200, 5); // Rgas200
        // output += "," + String(Rgas0x76[2], 5);
        // output += "," + String(Rgas[2] / 225, 5); // Rgas225
        // output += "," + String(Rgas0x76[3], 5);
        // output += "," + String(Rgas[3] / 250, 5); // Rgas250
        // output += "," + String(Rgas0x76[4], 5);
        // output += "," + String(Rgas[4] / 275, 5); // Rgas275
        // output += "," + String(Rgas0x76[5], 5);
        // output += "," + String(Rgas[5] / 300, 5); // Rgas300
        // output += "," + String(Rgas0x76[6], 5);
        // output += "," + String(Rgas[6] / 325, 5); // Rgas325
        // output += "," + String(Rgas0x76[7], 5);
        // output += "," + String(Rgas[7] / 350, 5); // Rgas350
        // output += "," + String(Rgas0x76[8], 5);
        // output += "," + String(Rgas[8] / 375, 5); // Rgas375
        // output += "," + String(Rgas0x76[9], 5);
        // output += "," + String(Rgas[9] / 400, 5); // Rgas400end

        // output += ", " + String(Rgas0x76[10]);
        // output += ", " + String(Rgas0x76[11]);
        // output += ", " + String(Rgas0x76[12]);
        // output += ", " + String(Rgas0x76[13]);
        // output += ", " + String(Rgas0x76[14]);
        // output += ", " + String(Rgas0x76[15]);
        // output += ", " + String(Rgas0x76[16]);
        // output += ", " + String(Rgas0x76[17]);
        // output += ", " + String(Rgas0x76[18]);
        // output += ", " + String(Rgas0x76[19]);
        digitalWrite(LED_BUILTIN, HIGH);
        sprintf(filename, "D%02d%02d%02d.csv", rtc.getMonth(), rtc.getDay(), n_saveData); //%02d, rtc.getYear()
        logData = SD.open(filename, FILE_WRITE);
        if (logData)
        {
            // logData.seek(EOF);
            // logData.println("Appended to the EOF");
            SDwrite_status = logData.println(output);
            delay(10);
            logData.close();
            digitalWrite(LED_BUILTIN, LOW);
            // figure out the SD card status message
            // if (SDwrite_status > 0) {
            //     //  n_saveData++;       // The idea of saving data after every 7 point does not work, all data lost before log.close().
            //     //  if (n_saveData > 6) { //Close BME file to save 7 data point
            //     //     logData.close();
            //     //     n_saveData = 0;
            //     //  }
            // }
            // else {
            //    logData.close();
            // }
            Serial.println(output);
            output = "";
            // if (  (RTC_min > 58)) {//(RTC_hour  == 11) ||  (RTC_hour  == 23) &&
            //     // close the file
            //     logData.close();
            // }
        }
        else
        {
            delay(100);
            logData.close();
            Serial.println("error opening logData.csv file");
            Serial.println("Open new logData.csv file");
            n_saveData++;
            sprintf(filename, "D%02d%02d%02d.csv", rtc.getMonth(), rtc.getDay(), n_saveData); //%02d,rtc.getYear(),
            logData = SD.open(filename, FILE_WRITE);
            if (logData)
            {

                SDwrite_status = logData.println(output);
                delay(10);
                logData.close();
                digitalWrite(LED_BUILTIN, LOW);

                Serial.println(output);
                output = "";
            }
            // check if the SD card is available to write data without blocking
            // and if the buffered data is enough for the full chunk size
            unsigned int chunkSize = logData.availableForWrite();
            if (chunkSize && output.length() >= chunkSize)
            {
                // write to file and blink LED

                logData.write(output.c_str(), chunkSize);
                digitalWrite(LED_BUILTIN, LOW);

                // remove written data from buffer
                output.remove(0, chunkSize);
            }
            else
            {
                // init SD card
                if (!SD.begin(SD_CS_PIN))
                {
                    Serial.println("Failed to initialize SD card!");
                    check_SDcard = 0;
                    delay(1000);
                    SD.begin(SD_CS_PIN);
                    digitalWrite(LED_BUILTIN, HIGH);
                    // errLeds();
                    NVIC_SystemReset(); // processor software reset
                }
            }
            output = "";
        }
        // delay(800);
        //    }

        lastCheckMinutes = RTC_min;
        SGP41_conditioning_s = 10;
        check_SGP41_readout = 0;
        SGP41_conditioning_sec = 0;

        n_BME0x76_readout = 0;
        delay(100);
        if ((BME0x77_readout == 1) && (RTC_min != lastminuteBME0x77_readout))
        {
            BME0x77_readout = 0;
        }

        if (BME0x76_available == 0)
        {

            if (iaqSensor.bme68xStatus < BME68X_OK)
            {
                Serial.println("Bad I2C communication with BME0x76, try to reiniitae");
                if (n_BME0x76_error < 2)
                {
                    init_BME0x76_ULP_LP();
                    BME0x76_available = 1;
                }
                else
                {
                    init_BME0x76();
                    BME0x76_available = 1;
                }
                n_BME0x76_error++;
            }
            if (n_BME0x76_error > 3)
            {
                BME0x76_available = 0;
            }
        }

        // endMillis = millis();
        // Serial.print("Time to read cal stat, save to SD, reset mem task: ");
        // Serial.print(endMillis - startMillis);
        // Serial.println(" ms");
    }

    // delay(200000); // Wait 200 seconds to update the channel again
}

// Helper function definitions
void checkIaqSensorStatus(void)
{
    if (iaqSensor.bsecStatus != BSEC_OK)
    {
        if (iaqSensor.bsecStatus < BSEC_OK)
        {
            output = "BSEC error code : " + String(iaqSensor.bsecStatus);
            Serial.println(output);

            // for (;;)
            // errLeds(); /* Halt in case of failure */
        }
        else
        {
            output = "BSEC warning code : " + String(iaqSensor.bsecStatus);
            Serial.println(output);
        }
    }

    if (iaqSensor.bme68xStatus != BME68X_OK)
    {
        if (iaqSensor.bme68xStatus < BME68X_OK)
        {
            output = "BME68X error code : " + String(iaqSensor.bme68xStatus);
            Serial.println(output);
            digitalWrite(LED_BUILTIN, HIGH);
            BME0x76_available = 0;
            Wire.end();
            // TWCR = 0; // reset TwoWire Control Register to default, inactive state
            delay(1000);
            Wire.begin();
            delay(1000);
            // for (;;)
            // errLeds(); /* Halt in case of failure */
            //     if (iaqSensor.bme68xStatus < BME68X_OK){
            //         if (n_BME0x76_error < 2 ) {
            //             init_BME0x76_ULP_LP();
            //     }
            //     else {
            //                init_BME0x76();
            //     }
            //      n_BME0x76_error++;
            //     }
            //    if (n_BME0x76_error > 3) {
            //         BME0x76_available = 0;
            //    }
        }
        else
        {
            output = "BME68X warning code : " + String(iaqSensor.bme68xStatus);
            Serial.println(output);
            digitalWrite(LED_BUILTIN, HIGH);
            Wire.end();
            delay(100);
            Wire.begin();
        }
    }
}

void loadState(void)
{
    if (EEPROM.read(0) == BSEC_MAX_STATE_BLOB_SIZE)
    {
        // Existing state in EEPROM
        Serial.println("Reading state from EEPROM");

        for (uint8_t i = 0; i < BSEC_MAX_STATE_BLOB_SIZE; i++)
        {
            bsecState[i] = EEPROM.read(i + 1);
            Serial.println(bsecState[i], HEX);
        }

        iaqSensor.setState(bsecState);
        checkIaqSensorStatus();
    }
    else
    {
        // Erase the EEPROM with zeroes
        Serial.println("Erasing EEPROM");

        for (uint8_t i = 0; i < BSEC_MAX_STATE_BLOB_SIZE + 1; i++)
            EEPROM.write(i, 0);

        EEPROM.commit();
    }
}

void updateState(void)
{
    bool update = false;
    if (stateUpdateCounter == 0)
    {
        /* First state update when IAQ accuracy is >= 3 */
        if (iaqSensor.iaqAccuracy >= 3)
        {
            update = true;
            stateUpdateCounter++;
        }
    }
    else
    {
        /* Update every STATE_SAVE_PERIOD minutes */
        if ((stateUpdateCounter * STATE_SAVE_PERIOD) < millis())
        {
            update = true;
            stateUpdateCounter++;
        }
    }

    if (update)
    {
        iaqSensor.getState(bsecState);
        checkIaqSensorStatus();

        Serial.println("Writing state to EEPROM");

        for (uint8_t i = 0; i < BSEC_MAX_STATE_BLOB_SIZE; i++)
        {
            EEPROM.write(i + 1, bsecState[i]);
            Serial.println(bsecState[i], HEX);
        }

        EEPROM.write(0, BSEC_MAX_STATE_BLOB_SIZE);
        EEPROM.commit();
    }
}