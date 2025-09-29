# Soil Moisture Sensor

This file describes the soil moisture sensor and its integration.

## How to Connect
- VCC (Power): Connect to 3.3V or 5V on the microcontroller (check sensor specs).
- GND: Connect to GND on the microcontroller.
- Signal/Analog Output: Connect to an analog pin (e.g., A0 on Arduino, GPIO34 on ESP32).

## Typical Sensor: Capacitive/Resistive
- Connect analog output to microcontroller analog pin.
- Power: 3.3V or 5V depending on sensor.

## Example Arduino Code
```cpp
int soilMoisturePin = A0;
void setup() {
  Serial.begin(9600);
}
void loop() {
  int value = analogRead(soilMoisturePin);
  Serial.print("Soil Moisture: ");
  Serial.println(value);
  delay(1000);
}
```
- Use the value to determine soil moisture level and send to database via microcontroller.