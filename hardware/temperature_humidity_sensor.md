# Temperature & Humidity Sensor

This file describes the temperature and humidity sensor (e.g., DHT11/DHT22) and its integration.

## How to Connect
- VCC: Connect to 3.3V or 5V on the microcontroller.
- GND: Connect to GND on the microcontroller.
- DATA: Connect to a digital pin (e.g., D2 on Arduino, GPIO15 on ESP32).
- Use a 10kΩ pull-up resistor between DATA and VCC for stable readings.

## Example Arduino Code (DHT)
```cpp
#include <DHT.h>
#define DHTPIN 2
#define DHTTYPE DHT22
DHT dht(DHTPIN, DHTTYPE);
void setup() {
  Serial.begin(9600);
  dht.begin();
}
void loop() {
  float h = dht.readHumidity();
  float t = dht.readTemperature();
  Serial.print("Humidity: ");
  Serial.print(h);
  Serial.print("%  Temperature: ");
  Serial.print(t);
  Serial.println("°C");
  delay(2000);
}
```
- Connect DHT sensor data pin to microcontroller digital pin.
- Use readings in microcontroller code to send to database.