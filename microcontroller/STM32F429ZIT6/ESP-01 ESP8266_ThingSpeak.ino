
#include <SoftwareSerial.h>
#include <ESP8266WiFi.h>
#include "secrets.h"
#include "ThingSpeak.h"

char ssid[] = "Feel Coffee & Tea Express 2";        
char pass[] = "giaohangmienphi";

WiFiClient client;

unsigned long myChannelNumber = 2044945;
const char* myWriteAPIKey = "0T1DJ1PWCLC6JPFH";

String myStatus = "";
SoftwareSerial mySUART(4, 5);  //RX D2, TX D1
void setup() {
  Serial.begin(115200);  // Initialize serial
  mySUART.begin(115200);
  while (!Serial) {
    ;  // wait for serial port to connect. Needed for Leonardo native USB port only
  }

  WiFi.mode(WIFI_STA);
  // Connect or reconnect to WiFi
  if (WiFi.status() != WL_CONNECTED) {
    Serial.print("Attempting to connect to SSID: ");
    Serial.println(SECRET_SSID);
    while (WiFi.status() != WL_CONNECTED) {
      WiFi.begin(ssid, pass);
      Serial.print(".");
      delay(5000);
    }
    Serial.println("\nConnected.");
  }
  ThingSpeak.begin(client);  // Initialize ThingSpeak
}

String chuoi = "90,95,99", chuoi1, chuoi2, chuoi3, chuoi4, chuoi5, chuoi6, chuoi7, chuoi8, chuoi9;  // định dạng kiễu dữ liệu được truyền từ STM
int a;
byte moc;
unsigned long time_post;

void loop() {
  if (mySUART.available()) {
    chuoi = mySUART.readString();  //Serial đọc chuỗi
    a = 1;
  }
  if (a == 1) {
    Serial.print(chuoi);
    for (int i = 0; i < chuoi.length(); i++) {
      if (chuoi.charAt(i) == ',') {
        moc = i;  //Tìm vị trí của dấu ","
        i = chuoi.length();
      }
    }
    chuoi1 = chuoi;
    chuoi1.remove(moc);  //Tách giá trị thanh trượt 1 ra chuoi1
    chuoi.remove(0, moc + 1);
    //val1 = chuoi1.toInt(); //Chuyển chuoi1 thành số
    //val2 = chuoi2.toInt(); //Chuyển chuoi2 thành số
    //In ra serial

    for (int i = 0; i < chuoi.length(); i++) {
      if (chuoi.charAt(i) == ',') {
        moc = i;  //Tìm vị trí của dấu ","
        i = chuoi.length();
      }
    }
    chuoi2 = chuoi;
    chuoi2.remove(moc);  //Tách giá trị thanh trượt 1 ra chuoi1
    chuoi.remove(0, moc + 1);

    for (int i = 0; i < chuoi.length(); i++) {
      if (chuoi.charAt(i) == ',') {
        moc = i;  //Tìm vị trí của dấu ","
        i = chuoi.length();
      }
    }
    chuoi3 = chuoi;
    chuoi3.remove(moc);  //Tách giá trị thanh trượt 1 ra chuoi1
    chuoi.remove(0, moc + 1);

    for (int i = 0; i < chuoi.length(); i++) {
      if (chuoi.charAt(i) == ',') {
        moc = i;  //Tìm vị trí của dấu ","
        i = chuoi.length();
      }
    }
    chuoi4 = chuoi;
    chuoi4.remove(moc);  //Tách giá trị thanh trượt 1 ra chuoi1
    chuoi.remove(0, moc + 1);

    for (int i = 0; i < chuoi.length(); i++) {
      if (chuoi.charAt(i) == ',') {
        moc = i;  //Tìm vị trí của dấu ","
        i = chuoi.length();
      }
    }
    chuoi5 = chuoi;
    chuoi5.remove(moc);  //Tách giá trị thanh trượt 1 ra chuoi1
    chuoi.remove(0, moc + 1);

    for (int i = 0; i < chuoi.length(); i++) {
      if (chuoi.charAt(i) == ',') {
        moc = i;  //Tìm vị trí của dấu ","
        i = chuoi.length();
      }
    }
    chuoi6 = chuoi;
    chuoi6.remove(moc);  //Tách giá trị thanh trượt 1 ra chuoi1
    chuoi.remove(0, moc + 1);

    for (int i = 0; i < chuoi.length(); i++) {
      if (chuoi.charAt(i) == ',') {
        moc = i;  //Tìm vị trí của dấu ","
        i = chuoi.length();
      }
    }
    chuoi7 = chuoi;
    a = 0;
  }
  if ((unsigned long)(millis() - time_post) > 240000) {
    ThingSpeak.setField(1, chuoi1);
    ThingSpeak.setField(2, chuoi2);
    ThingSpeak.setField(3, chuoi3);
    ThingSpeak.setField(4, chuoi4);
    ThingSpeak.setField(5, chuoi5);
    ThingSpeak.setField(6, chuoi6);
    ThingSpeak.setField(7, chuoi7);

    ThingSpeak.setStatus(myStatus);

    // write to the ThingSpeak channel
    int x = ThingSpeak.writeFields(myChannelNumber, myWriteAPIKey);
    if (x == 200) {
      Serial.println("Channel update successful.");
      Serial.println("----");
      Serial.println("Wait for next 4mins to update data again");
    } else {
      Serial.println("Problem updating channel. HTTP error code " + String(x));
    }
    time_post = millis();
  }
}
