if defined(ESP8266)
#include <ESP8266WiFi.h>
#include <FirebaseESP8266.h>
#endif
#include "DHT.h"
#include "MQ135.h"
#include "MQ7.h"

#include <addons/TokenHelper.h>
#include <addons/RTDBHelper.h>

#define WIFI_SSID "KAI Coffee"
#define WIFI_PASSWORD "stayhealthy"

#define API_KEY "AIzaSyAnGJFMtdu7KI5VvoxgKUIGqOC52hDiIh8"

//<databaseName>.firebaseio.com or <databaseName>.<region>.firebasedatabase.app
#define DATABASE_URL "https://hackathon-4a537-default-rtdb.asia-southeast1.firebasedatabase.app" 

#define USER_EMAIL "dodien981@gmail.com"
#define USER_PASSWORD "Shinobikonoha123"

FirebaseData fbdo;

FirebaseAuth auth;
FirebaseConfig config;

unsigned long sendDataPrevMillis = 0;

unsigned long count = 0;

#define DHTPIN 2        // Digital pin connected to the DHT sensor
#define DHTTYPE DHT11   // DHT 11
DHT dht(DHTPIN, DHTTYPE);

#define PIN_MQ135 D0    
MQ135 mq135_sensor = MQ135(PIN_MQ135);

#define A_PIN 3
#define VOLTAGE 5
MQ7 mq7(A_PIN, VOLTAGE);   

const int ledPower = 8;
const int PMPin = A4;

void setup()
{

  Serial.begin(115200);
  dht.begin();
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  Serial.printf("Firebase Client v%s\n\n", FIREBASE_CLIENT_VERSION);

  config.api_key = API_KEY;

  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  config.database_url = DATABASE_URL;

  config.token_status_callback = tokenStatusCallback; //see addons/TokenHelper.h

  Firebase.begin(&config, &auth);

  Firebase.reconnectWiFi(true);

  Firebase.setDoubleDigits(5);

  mq7.calibrate();
  dht.begin();
}

void loop()
{
  float h = dht.readHumidity();
  float t = dht.readTemperature();
  float co2 = dataGasSensor(t, h);
  float co = dataCO();
  float pm25 = dataPM25();

  if (Firebase.ready() && (millis() - sendDataPrevMillis > 15000 || sendDataPrevMillis == 0))
  {
    sendDataPrevMillis = millis();
    Serial.printf("Set Temperature... ");

    Serial.printf("Get Temperature... ");

    Serial.printf("Set Humidity... ");

    Serial.printf("Get Humidity... ");

    // Create a JSON object for the data
    FirebaseJson json;
    json.set("temp", t);
    json.set("humid", h);
    json.set("co2", co2);
    json.set("co", co);
    json.set("bm", pm25);

    // Generate a unique key based on the current timestamp
    String path = "/sensorData/" + String(count);

    // Push the data to Firebase under the generated path
    if (Firebase.setJSON(fbdo, path, json))
    {
      Serial.println("Data submitted successfully");
    }
    else
    {
      Serial.println("Failed to send data to Firebase");
      Serial.println(fbdo.errorReason());
    }
    
    Serial.println();
  
    count++;
  }
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
