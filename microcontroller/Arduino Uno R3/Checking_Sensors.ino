#include "WiFiEsp.h"
#include <DHT.h>
#include "MQ135.h"
#include "MQ7.h"

#define DHTPIN 7
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

#define PIN_MQ135 A0    
MQ135 mq135_sensor = MQ135(PIN_MQ135);   

#define A_PIN 1
#define VOLTAGE 5
MQ7 mq7(A_PIN, VOLTAGE);

const int UVPin = A2;

const int ledPower = 8;
const int PMPin = A3;

char ssid[] = "KAI Coffee";
char pass[] = "stayhealthy";

WiFiEspClient  client;

#ifndef HAVE_HWSERIAL1
  #include "SoftwareSerial.h"
  SoftwareSerial Serial1(2, 3);                     // RX, TX
  #define ESP_BAUDRATE  19200
#else
  #define ESP_BAUDRATE  115200
#endif

// Initialize our values
String myStatus = "";

void setup() {
  //Initialize serial and wait for port to open
  Serial.begin(115200);  
  while(!Serial){
    ; // wait for serial port to connect. Needed for Leonardo native USB port only
  }
	Serial.println("Calibrating MQ7");
	mq7.calibrate();		                  // calculates R0
	Serial.println("Calibration done!");
  dht.begin();
}

void loop() {

  float resultTemperature = dataTemperature();
  float resultHumidity = dataHumidity();
  Serial.print("Nhiet do: ");
  Serial.println(resultTemperature);
  Serial.print("Do am: ");
  Serial.println(resultHumidity);

  float resultGas = dataGasSensor(resultTemperature, resultHumidity);
  Serial.print("Gas: ");
  Serial.println(resultGas);

  Serial.print("PPM: "); 
  Serial.println(mq7.readPpm());

  float resultUV = dataUVIndex();
  Serial.print("UV: ");
  Serial.println(resultUV);

  float resultPM = dataPM25();
  Serial.print("PM25: ");
  Serial.println(resultPM);

  float resultDewPoint = getDewPoint(resultTemperature, resultHumidity);
  Serial.print("Dew Point: ");
  Serial.println(resultDewPoint);
  Serial.println();

  delay(10000);
}

void setEspBaudRate(unsigned long baudrate){
  long rates[6] = {115200,74880,57600,38400,19200,9600};

  Serial.print("Setting ESP8266 baudrate to ");
  Serial.print(baudrate);
  Serial.println("...");

  for(int i = 0; i < 6; i++){
    Serial1.begin(rates[i]);
    delay(100);
    Serial1.print("AT+UART_DEF=");
    Serial1.print(baudrate);
    Serial1.print(",8,1,0,0\r\n");
    delay(100);
  }

  Serial1.begin(baudrate);
}

float dataTemperature() {
  const int toleranceTem = -1;
  float correctTem = dht.readTemperature() + toleranceTem;
  return correctTem;
}

float dataHumidity() {
  const int toleranceHumi = 10;
  float correctHumi = dht.readHumidity() + toleranceHumi;
  return correctHumi;
}

float dataGasSensor(float temperature, float humidity) {
  if (isnan(temperature) || isnan(humidity)) {
    Serial.println(F("Failed to read from DHT sensor!"));
    return;
  }
  float correctedPPM = mq135_sensor.getCorrectedPPM(temperature, humidity);
  return correctedPPM;
}

float dataUVIndex() {
  int sensor_value = analogRead(UVPin); 
  float volts = sensor_value * 5.0 / 1024.0;
  float UV_index = volts * 10;
  return UV_index;
}

float dataPM25() {
  digitalWrite(ledPower, LOW); 
  delayMicroseconds(280);  
  float voMeasured = analogRead(PMPin); 
  delayMicroseconds(40); 
  digitalWrite(ledPower,HIGH); 
  delayMicroseconds(9680); 
  float calcVoltage = voMeasured * (5.0 / 1024); 
  float dustDensity = (0.172 * calcVoltage - 0.0999);
  if (dustDensity < 0)                
  {
    dustDensity = 0.00;
  }
  return dustDensity;
}

float getDewPoint(float temperature, float humidity) {
  double a = 17.271;
  double b = 237.7;
  double temp = (a * temperature) / (b + temperature) + log(temperature/100);
  double Td = (b * temp) / (a - temp);
  float TdFloat = (float)Td;
  return TdFloat;
}




