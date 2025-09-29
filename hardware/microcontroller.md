# Microcontroller Integration

This file contains example code and instructions for connecting hardware components to enable data flow into the database (e.g., Firebase Firestore).

## How to Connect Everything
- Soil Moisture Sensor: Connect VCC to 3.3V/5V, GND to GND, Signal to analog pin (e.g., GPIO34).
- Temperature & Humidity Sensor (DHT): VCC to 3.3V/5V, GND to GND, DATA to digital pin (e.g., GPIO15) with 10kΩ pull-up resistor to VCC.
- Light Sensor (LDR): One leg to 3.3V/5V, other leg to analog pin (e.g., GPIO32), 10kΩ resistor between analog pin and GND.

## Example ESP32/Arduino Code (All Sensors, Firebase)
```cpp
#include <WiFi.h>
#include <FirebaseESP32.h>
#include <DHT.h>

#define WIFI_SSID "your_wifi_ssid"
#define WIFI_PASSWORD "your_wifi_password"
#define FIREBASE_HOST "your_project_id.firebaseio.com"
#define FIREBASE_AUTH "your_firebase_database_secret"

#define SOIL_MOISTURE_PIN 34
#define LIGHT_SENSOR_PIN 32
#define DHTPIN 15
#define DHTTYPE DHT22

DHT dht(DHTPIN, DHTTYPE);
FirebaseData firebaseData;

void setup() {
  Serial.begin(115200);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("WiFi connected");

  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Firebase.reconnectWiFi(true);
  dht.begin();
}

void loop() {
  int soilMoisture = analogRead(SOIL_MOISTURE_PIN);
  int lightLevel = analogRead(LIGHT_SENSOR_PIN);
  float temperature = dht.readTemperature();
  float humidity = dht.readHumidity();

  // Send data to Firebase
  Firebase.setInt(firebaseData, "/sensors/soilMoisture", soilMoisture);
  Firebase.setInt(firebaseData, "/sensors/light", lightLevel);
  Firebase.setFloat(firebaseData, "/sensors/temperature", temperature);
  Firebase.setFloat(firebaseData, "/sensors/humidity", humidity);

  delay(5000); // Send every 5 seconds
}
```
- Replace WiFi and Firebase credentials with your own.
- Use appropriate libraries for your sensors.
- This code enables data flow from hardware to the database.