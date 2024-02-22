#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266HTTPClient.h>
#include <ArduinoJson.h>
#include <SoftwareSerial.h>

const char* ssid = "DUC MY";
const char* password = "thithien5522";
const char* server = "192.168.1.29";
const int port = 8080;
const char* accessToken = "airmonitoringthingsboard";

const String urlStr = "/api/v1/" + String(accessToken) + "/telemetry";

WiFiClient clientWifi;
SoftwareSerial mySUART(4, 5);  // RX D2, TX D1

String payload;
HTTPClient http;

String stringFormat = "90,95,99", temp, humi, mq135, mq7, pm25, uv_index, dewpoint;
int a;
byte moc;
unsigned long time_post;

void setup() {
  Serial.begin(115200);
  mySUART.begin(115200);
  while (!Serial) {
    ;  // wait for serial port to connect. Needed for Leonardo native USB port only
  }

  WiFi.mode(WIFI_STA);
  if (WiFi.status() != WL_CONNECTED) {
    Serial.print("Attempting to connect to SSID: ");
    while (WiFi.status() != WL_CONNECTED) {
      WiFi.begin(ssid, password);
      Serial.print(".");
      delay(5000);
    }
    Serial.println("\nConnected.");
    Serial.println("\nWait for 10s to collect data from stm32 and push to ThingsBoard");
  }
}

void loop() {
  if (mySUART.available()) {
    stringFormat = mySUART.readString();
  }
  // if (WiFi.status() == WL_CONNECTED) {
  if ((unsigned long)(millis() - time_post) > 10000) {
    Serial.print(stringFormat);
    DynamicJsonDocument doc(256);  // Increase the capacity to accommodate larger data
    // Split the input string into individual values
    String inputString = "29.7,46.0,0.72296,2.01194,0.56211,1.95312,14.54542";
    int index = 0;

    // Define the keys for each value
    const char* keys[] = { "temperature", "humidity", "mq135", "mq7", "pm2.5", "uv_index", "dewpoint" };

    // Tokenize the input string based on the comma delimiter
    char* value = strtok(const_cast<char*>(stringFormat.c_str()), ",");
    while (value != NULL && index < 7) {
      // Add the key-value pair to the JSON document
      doc[keys[index]] = value;

      // Move to the next value
      value = strtok(NULL, ",");
      index++;
    }

    // Serialize the JSON document to a string
    String payload;
    serializeJson(doc, payload);

    Serial.println(payload);

    // DynamicJsonDocument jsonDocument(512);
    // jsonDocument["temperature"] = temp;
    // jsonDocument["humidity"] = humi;
    // jsonDocument["mq135"] = mq135;
    // jsonDocument["mq7"] = mq7;
    // jsonDocument["pm2.5"] = pm25;
    // jsonDocument["uv_index"] = uv_index;

    // serializeJson(jsonDocument, payload);
    // Serial.println(payload);

    http.begin(clientWifi, server, port, urlStr);
    http.addHeader("Content-Type", "application/json");
    http.addHeader("X-Authorization", accessToken);

    int httpResponseCode = http.POST(payload);

    if (httpResponseCode == 200) {
      Serial.println("Data pushed to ThingsBoard successfully!");
      http.end();
    } else {
      Serial.print("Failed to push data to ThingsBoard. Error code: ");
      Serial.println(httpResponseCode);
    }
    // delay(30000);
    time_post = millis();
  }
  // }
  //   if (mySUART.available()) {
  //   stringFormat = mySUART.readString();
  //   a = 1;
  // }
  // if (a == 1) {
  //   Serial.print(stringFormat);
  //   for (int i = 0; i < stringFormat.length(); i++) {
  //     if (stringFormat.charAt(i) == ',') {
  //       moc = i;
  //       i = stringFormat.length();
  //     }
  //   }
  //   temp = stringFormat;
  //   temp.remove(moc);
  //   stringFormat.remove(0, moc + 1);
  //   //val1 = temp.toInt(); //Chuyển temp thành số
  //   //val2 = humi.toInt(); //Chuyển humi thành số
  //   //In ra serial

  //   for (int i = 0; i < stringFormat.length(); i++) {
  //     if (stringFormat.charAt(i) == ',') {
  //       moc = i;
  //       i = stringFormat.length();
  //     }
  //   }
  //   humi = stringFormat;
  //   humi.remove(moc);
  //   stringFormat.remove(0, moc + 1);

  //   for (int i = 0; i < stringFormat.length(); i++) {
  //     if (stringFormat.charAt(i) == ',') {
  //       moc = i;
  //       i = stringFormat.length();
  //     }
  //   }
  //   mq135 = stringFormat;
  //   mq135.remove(moc);
  //   stringFormat.remove(0, moc + 1);

  //   for (int i = 0; i < stringFormat.length(); i++) {
  //     if (stringFormat.charAt(i) == ',') {
  //       moc = i;
  //       i = stringFormat.length();
  //     }
  //   }
  //   mq7 = stringFormat;
  //   mq7.remove(moc);
  //   stringFormat.remove(0, moc + 1);

  //   for (int i = 0; i < stringFormat.length(); i++) {
  //     if (stringFormat.charAt(i) == ',') {
  //       moc = i;
  //       i = stringFormat.length();
  //     }
  //   }
  //   pm25 = stringFormat;
  //   pm25.remove(moc);
  //   stringFormat.remove(0, moc + 1);

  //   for (int i = 0; i < stringFormat.length(); i++) {
  //     if (stringFormat.charAt(i) == ',') {
  //       moc = i;
  //       i = stringFormat.length();
  //     }
  //   }
  //   uv_index = stringFormat;
  //   a = 0;
  // }
}
