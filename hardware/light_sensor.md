# Light Sensor

This file describes the light sensor (e.g., LDR/photodiode) and its integration.

## How to Connect
- One leg of LDR: Connect to 3.3V or 5V (power).
- Other leg of LDR: Connect to analog pin (e.g., A1 on Arduino, GPIO32 on ESP32).
- Place a resistor (e.g., 10kΩ) between the analog pin and GND to form a voltage divider.

## Example Arduino Code
```cpp
int lightSensorPin = A1;
void setup() {
  Serial.begin(9600);
}
void loop() {
  int value = analogRead(lightSensorPin);
  Serial.print("Light Level: ");
  Serial.println(value);
  delay(1000);
}
```
- Connect analog output to microcontroller analog pin.
- Use readings in microcontroller code to send to database.