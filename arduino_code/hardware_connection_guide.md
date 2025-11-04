# Hardware Connection Guide for AGROSMART

This guide provides step-by-step instructions for connecting all hardware components in your AGROSMART project and integrating them with Firebase for data storage.

## Components List
- ESP32-CAM WiFi + Bluetooth Module (with OV2640 2MP Camera)
- ESP32-CAM Antenna
- MB102 Breadboard Power Module (3.3V/5V)
- 830-point Solderless Breadboard
- 65 Flexible Jumper Wires
- Soil Moisture Sensor (Hygrometer)
- DHT22 Digital Temperature & Humidity Sensor
- LDR Photoresistor Light Sensor
- Rain/Snow Detection Sensor
- Schottky Rectifier Diodes (1N4007 ×2)
- I2C LCD1602 Blue Screen Module
- LED Traffic Light Module
- 5mm White LED (×2)
- 10K Ohm Potentiometer
- 5V 1-Channel Relay Module
- Micro Submersible DC Motor Water Pump (with silicone tube & amphibious type)
- FTDI USB-to-Serial Adapter
- Female-to-Female Jumper Cables

## Step-by-Step Connection Instructions

### 1. Power Setup
- Place the MB102 power module on the breadboard.
- Connect the power module to a 5V USB supply.
- Use jumper wires to distribute 3.3V and 5V rails as needed.

### 2. ESP32-CAM Setup
- Mount ESP32-CAM on the breadboard.
- Connect the FTDI adapter to ESP32-CAM for programming:
  - FTDI TX → ESP32 RX
  - FTDI RX → ESP32 TX
  - FTDI GND → ESP32 GND
  - FTDI 5V → ESP32 5V
- Attach the antenna to ESP32-CAM.
- Connect ESP32-CAM GND and 3.3V/5V to breadboard rails.

### 3. Sensor Connections
**Soil Moisture Sensor (Analog Output):**
  - VCC → 5V rail
  - GND → GND rail
  - AO (Signal) → ESP32-CAM GPIO14
**DHT22 Temperature & Humidity Sensor:**
  - VCC → 5V rail
  - GND → GND rail
  - Data → ESP32-CAM GPIO2
**LDR Light Sensor (Analog Output):**
  - VCC → 5V rail
  - GND → GND rail
  - AO (Signal) → ESP32-CAM GPIO12 and 10K Ohm resistor to GND
**Rain Sensor (Digital Output):**
  - VCC → 5V rail
  - GND → GND rail
  - DO (Signal) → ESP32-CAM GPIO15

### 4. Output Devices
**Relay Module (for Water Pump):**
  - VCC → 5V rail
  - GND → GND rail
  - IN → ESP32-CAM GPIO13
- **Water Pump:**
  - Connect pump power to relay output
  - Silicone tube to water source
- **LED Traffic Light Module & White LEDs:**
  - Connect to ESP32-CAM GPIO14 (pin 14), GPIO16 (pin 16)
**LCD1602 I2C Module:**
  - VCC → 5V rail
  - GND → GND rail
  - SDA → ESP32-CAM GPIO1
  - SCL → ESP32-CAM GPIO3

### 5. Diodes & Potentiometer
- Use diodes for reverse current protection on relay and pump circuits.
- Potentiometer can be used for analog input (e.g., connect one end to 3.3V, other to GND, wiper to ESP32-CAM analog pin).

### 6. Jumper Wires
- Use jumper wires to make all necessary connections as described above.

### 7. Programming & Testing
- Use FTDI to upload code to ESP32-CAM.
- Power up the breadboard and ESP32-CAM.
- Test each sensor and output device individually.

### 8. Firebase Integration
- In your ESP32-CAM code, use WiFi to connect to the internet.
- Use Firebase libraries to send sensor data to your Firebase project.
- Ensure your Firebase rules allow data writes from your device.

## Tips
- Double-check all connections before powering up.
- Use a multimeter to verify voltages.
- Refer to each module’s datasheet for pinouts.

## Pin Summary (matches code)
## Pin Summary (matches code)
- Soil Moisture AO: GPIO 14
- DHT22 DATA: GPIO 2
- LDR AO: GPIO 12
- Rain DO: GPIO 15
- Relay IN: GPIO 13
- LCD I2C SDA: GPIO 1
- LCD I2C SCL: GPIO 3

## Example Wiring Diagram
(Add a hand-drawn or Fritzing diagram here for clarity.)

## Troubleshooting
- If a sensor doesn’t work, check wiring and pin assignments.
- If ESP32-CAM won’t program, check FTDI connections and boot mode.
- For WiFi/Firebase issues, check credentials and network signal.

---
For more details, see the datasheets for each module and the ESP32-CAM documentation.
