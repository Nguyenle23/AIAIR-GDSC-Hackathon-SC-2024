#include "WiFiEsp.h"
#include "ThingSpeak.h"
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

char ssid[] = "DUC MY";
char pass[] = "thithien5522";

WiFiEspClient  client;

#ifndef HAVE_HWSERIAL1
  #include "SoftwareSerial.h"
  SoftwareSerial Serial1(2, 3);                     // RX, TX
  #define ESP_BAUDRATE  19200
#else
  #define ESP_BAUDRATE  115200
#endif

unsigned long myChannelNumber = 2044945;
const char * myWriteAPIKey = "0T1DJ1PWCLC6JPFH";

// Initialize our values
String myStatus = "";

void setup() {
  //Initialize serial and wait for port to open
  Serial.begin(115200);  
  while(!Serial){
    ; // wait for serial port to connect. Needed for Leonardo native USB port only
  }

  // initialize serial for ESP module
  setEspBaudRate(ESP_BAUDRATE);

  while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo native USB port only
  }

  Serial.print("Searching for ESP8266...");
  // initialize ESP module
  WiFi.init(&Serial1);

  // check for the presence of the shield
  if (WiFi.status() == WL_NO_SHIELD) {
    Serial.println("WiFi shield not present");
    // don't continue
    while (true);
  }
  Serial.println("found it!");

  mq7.calibrate();
  dht.begin();

  ThingSpeak.begin(client);  // Initialize ThingSpeak
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

  float resultCO = dataCO();
  Serial.print("CO value: ");
  Serial.println(resultCO);

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

  // Connect or reconnect to WiFi
  if(WiFi.status() != WL_CONNECTED){
    Serial.print("Attempting to connect to SSID: ");
    Serial.println(ssid);
    while(WiFi.status() != WL_CONNECTED){
      WiFi.begin(ssid, pass);
      Serial.print(".");
      delay(5000);
    }
    Serial.println("\nConnected.");
  }

  // set the fields with the values
  ThingSpeak.setField(1, resultTemperature);
  ThingSpeak.setField(2, resultHumidity);
  ThingSpeak.setField(3, resultGas);
  ThingSpeak.setField(4, resultCO);
  ThingSpeak.setField(5, resultUV);
  ThingSpeak.setField(6, resultPM);
  ThingSpeak.setField(7, resultDewPoint);

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

  // wait for 2.5min to update channel again
  // delay(150000);

  // wait for 5min to update channel again
  delay(300000);
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
  float correctPPM = mq135_sensor.getCorrectedPPM(temperature, humidity);
  return correctPPM;
}

float dataCO() {
  float correctCO = mq7.readPpm();
  return correctCO;
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