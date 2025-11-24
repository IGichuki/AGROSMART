// #include <WiFi.h>
// #include <FirebaseESP32.h>
// #include <DHT.h>
// #include <time.h>

// // WiFi
// #define WIFI_SSID "Kiragu"
// #define WIFI_PASSWORD "Kiragu@1976"

// // Firebase
// #define FIREBASE_HOST "agrosmart-c2d80-default-rtdb.firebaseio.com"
// #define FIREBASE_AUTH "qnxUZuxht2SkAJp6BLqcDQozJutEiApcSIbQZAxr"

// // Sensor pins
// #define SOIL_PIN 12    
// #define RAIN_PIN 14     
// #define LIGHT_DO_PIN 15 
// #define DHT_PIN 2        
// #define DHT_TYPE DHT22   

// // Relay pin (pump)
// #define RELAY_PIN 13

// DHT dht(DHT_PIN, DHT_TYPE);

// FirebaseData fbdo;
// FirebaseAuth auth;
// FirebaseConfig config;

// void setup() {
//   Serial.begin(115200);

//   // WiFi
//   WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
//   while (WiFi.status() != WL_CONNECTED) {
//     delay(500);
//     Serial.print(".");
//   }
//   Serial.println("WiFi connected!");

//   // Firebase
//   config.host = FIREBASE_HOST;
//   config.signer.tokens.legacy_token = FIREBASE_AUTH;
//   Firebase.begin(&config, &auth);
//   Firebase.reconnectWiFi(true);

//   dht.begin();

//   // Relay
//   pinMode(RELAY_PIN, OUTPUT);
//   digitalWrite(RELAY_PIN, LOW); // pump OFF initially

//   // Time (NTP)
//   configTime(0, 0, "pool.ntp.org", "time.nist.gov");
//   Serial.println("Syncing time...");
//   time_t now = time(nullptr);
//   while (now < 100000) {
//     delay(500);
//     Serial.print("#");
//     now = time(nullptr);
//   }
//   Serial.println("\nTime synchronized.");
// }

// void loop() {

//   // === Read Sensors ===
//   int soilMoisture = analogRead(SOIL_PIN);
//   int rainValue = analogRead(RAIN_PIN);
//   int lightLevel = !digitalRead(LIGHT_DO_PIN); // invert DO
//   float temperature = dht.readTemperature();
//   float humidity = dht.readHumidity();
//   unsigned long timestamp = time(nullptr);

//   // Print readings
//   Serial.println("Sending to Firebase:");
//   Serial.print("Soil: "); Serial.println(soilMoisture);
//   Serial.print("Rain: "); Serial.println(rainValue);
//   Serial.print("Light: "); Serial.println(lightLevel);
//   Serial.print("Temp: "); Serial.println(temperature);
//   Serial.print("Humidity: "); Serial.println(humidity);
//   Serial.print("Timestamp: "); Serial.println(timestamp);

//   // === Send Sensor Data ===
//   FirebaseJson json;
//   json.set("soilMoisture", soilMoisture);
//   json.set("rain", rainValue);
//   json.set("light", lightLevel);
//   json.set("temperature", temperature);
//   json.set("humidity", humidity);
//   json.set("timestamp", timestamp);

//   if (Firebase.pushJSON(fbdo, "/sensorData", json)) {
//     Serial.println("Sensor data sent.");
//   } else {
//     Serial.println("Send failed: " + fbdo.errorReason());
//   }

//   // === MANUAL PUMP CONTROL ===
//   if (Firebase.getInt(fbdo, "/pump/manual")) {
//     int pumpCommand = fbdo.intData();

//     if (pumpCommand == 1) {
//       digitalWrite(RELAY_PIN, HIGH);
//       Serial.println("Pump turned ON (manual).");
//     } else {
//       digitalWrite(RELAY_PIN, LOW);
//       Serial.println("Pump turned OFF (manual).");
//     }
//   } else {
//     Serial.println("Error reading pump/manual: " + fbdo.errorReason());
//   }

//   delay(3000);
// }
