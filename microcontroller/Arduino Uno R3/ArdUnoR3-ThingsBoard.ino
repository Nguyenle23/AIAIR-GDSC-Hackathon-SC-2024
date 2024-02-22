#include "WiFiEsp.h"
#include <DHT.h>
#include "MQ135.h"
#include "MQ7.h"
#include <ArduinoJson.h>
#include <WiFiEspClient.h>

//----------DIGITAL PIN 4-----------
#define DHTPIN 4
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

//----------ANALOG PIN 3-----------
#define PIN_MQ135 A3
MQ135 mq135_sensor = MQ135(PIN_MQ135);

//----------ANALOG PIN 2-----------
#define A_PIN 2
#define VOLTAGE 5
MQ7 mq7(A_PIN, VOLTAGE);

//----------ANALOG PIN 1-----------
const int UVPin = A1;

//----------DIGITAL PIN 12 & ANALOG PIN 10-----------
const int ledPower = 12;
const int PMPin = A0;

char ssid[] = "DUC MY";
char pass[] = "thithien5522";

const char* server = "192.168.1.29";
const int port = 8080;
const char* accessToken = "airqualitywitharduino";

const String urlStr = "/api/v1/" + String(accessToken) + "/telemetry";

WiFiEspClient client;

#ifndef HAVE_HWSERIAL1
#include "SoftwareSerial.h"
SoftwareSerial Serial1(2, 3);  // RX, TX
#define ESP_BAUDRATE 19200
#else
#define ESP_BAUDRATE 115200
#endif

void setup() {
  //Initialize serial and wait for port to open
  Serial.begin(115200);
  while (!Serial) {
    ;  // wait for serial port to connect. Needed for Leonardo native USB port only
  }

  // initialize serial for ESP module
  setEspBaudRate(ESP_BAUDRATE);

  while (!Serial) {
    ;  // wait for serial port to connect. Needed for Leonardo native USB port only
  }

  Serial.print("Searching for ESP8266...");
  // initialize ESP module
  WiFi.init(&Serial1);

  // check for the presence of the shield
  if (WiFi.status() == WL_NO_SHIELD) {
    Serial.println("WiFi shield not present");
    // don't continue
    while (true)
      ;
  }
  Serial.println("found it!");

  mq7.calibrate();
  dht.begin();
}

void loop() {
  String resultTemperature = dataTemperature();
  String resultHumidity = dataHumidity();
  Serial.println();
  Serial.print("Nhiet do: ");
  Serial.println(resultTemperature);
  Serial.print("Do am: ");
  Serial.println(resultHumidity);

  String resultGas = dataGasSensor(resultTemperature.toFloat(), resultHumidity.toFloat());
  Serial.print("Gas: ");
  Serial.println(resultGas);

  String resultCO = dataCO();
  Serial.print("CO value: ");
  Serial.println(resultCO);

  String resultPM = dataPM25();
  Serial.print("PM25: ");
  Serial.println(resultPM);

  String resultUV = dataUVIndex();
  Serial.print("UV: ");
  Serial.println(resultUV);

  String resultDewPoint = getDewPoint(resultTemperature.toFloat(), resultHumidity.toFloat());
  Serial.print("Dew Point: ");
  Serial.println(resultDewPoint);
  Serial.println();

  // Create a JSON payload to send to ThingsBoard
  const size_t capacity = JSON_OBJECT_SIZE(7) + 120;
  DynamicJsonDocument jsonDocument(capacity);
  jsonDocument["temp"] = resultTemperature;
  jsonDocument["humi"] = resultHumidity;
  jsonDocument["mq135"] = resultGas;
  jsonDocument["mq7"] = resultCO;
  jsonDocument["pm2.5"] = resultPM;
  jsonDocument["uv_index"] = resultUV;
  jsonDocument["dewpoint"] = resultDewPoint;

  String payloadString;
  serializeJson(jsonDocument, payloadString);
  Serial.println(payloadString);

  // Connect or reconnect to WiFi
  if (WiFi.status() != WL_CONNECTED) {
    Serial.print(F("Attempting to connect to SSID: "));
    Serial.println(ssid);
    while (WiFi.status() != WL_CONNECTED) {
      WiFi.begin(ssid, pass);
      Serial.print(".");
      delay(5000);
    }
    Serial.println("\nConnected.");
  }

  // Connect to ThingsBoard
  if (client.connect(server, port)) {
    // Make an HTTP POST request with the payload
    client.println("POST " + urlStr + " HTTP/1.1");
    client.println("Host: " + String(server));
    client.println("Content-Type: application/json");
    client.println("Content-Length: " + String(payloadString.length()));
    client.println();
    client.println(payloadString);
    client.println();

    delay(6000);

    // Check the response from ThingsBoard
    while (client.available()) {
      String line = client.readStringUntil('\r');
      Serial.print(line);
    }

    client.stop();
  }
  delay(300000);
}


void setEspBaudRate(unsigned long baudrate) {
  long rates[6] = { 115200, 74880, 57600, 38400, 19200, 9600 };

  Serial.print("Setting ESP8266 baudrate to ");
  Serial.print(baudrate);
  Serial.println("...");

  for (int i = 0; i < 6; i++) {
    Serial1.begin(rates[i]);
    delay(100);
    Serial1.print("AT+UART_DEF=");
    Serial1.print(baudrate);
    Serial1.print(",8,1,0,0\r\n");
    delay(100);
  }

  Serial1.begin(baudrate);
}

String dataTemperature() {
  const int toleranceTem = -1;
  float correctTem = dht.readTemperature() + toleranceTem;
  String result = String(correctTem, 2);
  return result;
}

String dataHumidity() {
  const int toleranceHumi = 10;
  float correctHumi = dht.readHumidity() + toleranceHumi;
  String result = String(correctHumi, 2);
  return result;
}

String dataGasSensor(float temperature, float humidity) {
  if (isnan(temperature) || isnan(humidity)) {
    Serial.println(F("Failed to read from DHT sensor!"));
    return;
  }
  float correctPPM = mq135_sensor.getCorrectedPPM(temperature, humidity);
  String result = String(correctPPM, 4);
  return result;
}

String dataCO() {
  float correctCO = mq7.readPpm();
  String result = String(correctCO, 4);
  return result;
}

String dataUVIndex() {
  int sensor_value = analogRead(UVPin);
  float volts = sensor_value * 5.0 / 1024.0;
  float UV_index = volts * 10;
  String result = String(UV_index, 4);
  return result;
}

String dataPM25() {
  digitalWrite(ledPower, LOW);
  delayMicroseconds(280);
  float voMeasured = analogRead(PMPin);
  delayMicroseconds(40);
  digitalWrite(ledPower, HIGH);
  delayMicroseconds(9680);
  float calcVoltage = voMeasured * (5.0 / 1024);
  float dustDensity = ((0.172 * calcVoltage) - 0.0999);
  float finalResult;
  if (dustDensity < 0) {
    finalResult = abs(dustDensity);
    String result = String(finalResult, 4);
    return result;
  }
  String result = String(dustDensity, 4);
  return result;
}

String getDewPoint(float temperature, float humidity) {
  double a = 17.271;
  double b = 237.7;
  double temp = (a * temperature) / (b + temperature) + log(temperature / 100);
  double Td = (b * temp) / (a - temp);
  float TdFloat = (float)Td;
  String result = String(TdFloat, 4);
  return result;
}
