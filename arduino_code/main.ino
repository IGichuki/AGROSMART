// // AGROSMART Arduino Code for ESP32-CAM and Sensors
// // This code reads sensor data and sends it to Firebase

// #include <WiFi.h>
// #include <Firebase_ESP_Client.h>
// #include <DHT.h>
// #include <Wire.h>
// #include <LiquidCrystal_I2C.h>

// // WiFi credentials
// #define WIFI_SSID "YOUR_WIFI_SSID"
// #define WIFI_PASSWORD "YOUR_WIFI_PASSWORD"

// // Firebase credentials
// #define API_KEY "YOUR_FIREBASE_API_KEY"
// #define DATABASE_URL "YOUR_FIREBASE_DATABASE_URL"
// #define USER_EMAIL "YOUR_FIREBASE_USER_EMAIL"
// #define USER_PASSWORD "YOUR_FIREBASE_USER_PASSWORD"

// // DHT22 setup
// #define DHTPIN 15
// #define DHTTYPE DHT22
// DHT dht(DHTPIN, DHTTYPE);

// // Soil moisture sensor
// #define SOIL_PIN 34

// // LDR sensor
// #define LDR_PIN 35

// // Rain sensor
// #define RAIN_PIN 13

// // Relay and pump
// #define RELAY_PIN 12
// #define PUMP_PIN 12 // Controlled by relay

// // LCD
// LiquidCrystal_I2C lcd(0x27, 16, 2);

// // Firebase objects
// FirebaseData fbdo;
// FirebaseAuth auth;
// FirebaseConfig config;

// void setup() {
//   Serial.begin(115200);
//   pinMode(SOIL_PIN, INPUT);
//   pinMode(LDR_PIN, INPUT);
//   pinMode(RAIN_PIN, INPUT);
//   pinMode(RELAY_PIN, OUTPUT);
//   dht.begin();
//   lcd.begin();
//   lcd.backlight();

//   WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
//   while (WiFi.status() != WL_CONNECTED) {
//     delay(500);
//     Serial.print(".");
//   }
//   Serial.println("\nWiFi connected!");

//   config.api_key = API_KEY;
//   config.database_url = DATABASE_URL;
//   auth.user.email = USER_EMAIL;
//   auth.user.password = USER_PASSWORD;
//   Firebase.begin(&config, &auth);
//   Firebase.reconnectWiFi(true);
// }

// void loop() {
//   // Read sensors
//   float temperature = dht.readTemperature();
//   float humidity = dht.readHumidity();
//   int soil = analogRead(SOIL_PIN);
//   int light = analogRead(LDR_PIN);
//   int rain = digitalRead(RAIN_PIN);

//   // Display on LCD
//   lcd.setCursor(0, 0);
//   lcd.print("T:"); lcd.print(temperature); lcd.print("C ");
//   lcd.print("H:"); lcd.print(humidity); lcd.print("%");
//   lcd.setCursor(0, 1);
//   lcd.print("S:"); lcd.print(soil);
//   lcd.print(" L:"); lcd.print(light);
//   lcd.print(" R:"); lcd.print(rain);

//   // Send to Firebase
//   if (Firebase.ready()) {
//     String path = "/sensors/";
//     Firebase.setFloat(fbdo, path + "temperature", temperature);
//     Firebase.setFloat(fbdo, path + "humidity", humidity);
//     Firebase.setInt(fbdo, path + "soil", soil);
//     Firebase.setInt(fbdo, path + "light", light);
//     Firebase.setInt(fbdo, path + "rain", rain);
//   }

//   // Control pump via relay (example: if soil is dry)
//   if (soil < 500) {
//     digitalWrite(RELAY_PIN, HIGH); // Turn on pump
//   } else {
//     digitalWrite(RELAY_PIN, LOW); // Turn off pump
//   }

//   delay(5000); // Read and send every 5 seconds
// }
