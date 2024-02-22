#include <Arduino.h>
#include <WiFiNINA.h>

const char* ssid = "Home 98";
const char* pass = "home@123";

const char* server = "192.168.1.29";
const int port = 8080;
const char* accessToken = "arduinomkr1010";

const String urlStr = "/api/v1/" + String(accessToken) + "/telemetry";
String payloadString;
const size_t capacity = JSON_OBJECT_SIZE(7) + 120;

WiFiClient client;

void setup() {
  Serial.begin(115200);
  while (!Serial) {
    ;  // wait for serial port to connect. Needed for Leonardo native USB port only
  }

  Serial.print("Connecting to: ");
  Serial.println(ssid);
  WiFi.begin(ssid, pass);

  // check for the presence of the shield
  while (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi shield not present");
    // don't continue
    while (true)
      ;
  }
  Serial.println("Prepare for pushing");
}

void loop() {
  String resultTemperature = "30";
  String resultHumidity = "60";
  String resultGas = "0.2";
  String resultCO = "0.005";
  String resultPM = "3.402";
  String resultUV = "0.23";
  String resultDewPoint = "0.23";

  // Create a JSON payload to send to ThingsBoard
  DynamicJsonDocument jsonDocument(capacity);
  jsonDocument["temperature"] = resultTemperature;
  jsonDocument["humidity"] = resultHumidity;
  jsonDocument["co2_values"] = resultGas;
  jsonDocument["co_values"] = resultCO;
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
  delay(180000);
}