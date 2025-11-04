// AGROSMART ESP32-CAM + Firebase (using Database Secret)
#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <addons/TokenHelper.h>
#include <DHT.h>

// WiFi credentials
#define WIFI_SSID "Kiragu"
#define WIFI_PASSWORD "Kiragu@1976"

// Firebase credentials
#define DATABASE_URL "https://agrosmart-c2d80-default-rtdb.firebaseio.com/"
#define DATABASE_SECRET "qnxUZuxht2SkAJp6BLqcDQozJutEiApcSIbQZAxr"

// Sensor pins (match wiring guide)
#define DHTPIN 14      // DHT22 DATA to GPIO 14
#define DHTTYPE DHT22
#define SOIL_PIN 34    // Soil AO to GPIO 34
#define LDR_PIN 32     // LDR AO to GPIO 32
#define RAIN_PIN 35    // Rain AO to GPIO 35
#define RELAY_PIN 13   // Relay IN to GPIO 13

DHT dht(DHTPIN, DHTTYPE);

FirebaseData fbdo;
FirebaseConfig config;

void setup() {
  Serial.begin(115200);
  Serial.println();
  Serial.println("🔌 Connecting to WiFi...");
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\n✅ WiFi connected!");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());

  pinMode(SOIL_PIN, INPUT);
  pinMode(LDR_PIN, INPUT);
  pinMode(RAIN_PIN, INPUT);
  pinMode(RELAY_PIN, OUTPUT);
  dht.begin();

  config.database_url = DATABASE_URL;
  config.signer.tokens.legacy_token = DATABASE_SECRET;

  Firebase.begin(&config, nullptr);
  Firebase.reconnectWiFi(true);

  Serial.println("🔥 Firebase initialized!");
}

void loop() {
  // Read sensors
  float temperature = dht.readTemperature();
  float humidity = dht.readHumidity();
  int soil = analogRead(SOIL_PIN);
  int light = analogRead(LDR_PIN);
  int rain = analogRead(RAIN_PIN);

  // Print sensor values to Serial
  Serial.print("T: "); Serial.print(temperature); Serial.print(" C, ");
  Serial.print("H: "); Serial.print(humidity); Serial.print(" %, ");
  Serial.print("S: "); Serial.print(soil); Serial.print(", ");
  Serial.print("L: "); Serial.print(light); Serial.print(", ");
  Serial.print("R: "); Serial.println(rain);

  // Control relay (example: turn on if soil < 500)
  if (soil < 500) {
    digitalWrite(RELAY_PIN, HIGH); // Turn on pump
  } else {
    digitalWrite(RELAY_PIN, LOW); // Turn off pump
  }

  // Upload to Firebase only if readings are valid
  if (Firebase.ready()) {
    String path = "/sensors/";
    bool success = true;
    if (!isnan(temperature)) success &= Firebase.RTDB.setFloat(&fbdo, path + "temperature", temperature);
    if (!isnan(humidity)) success &= Firebase.RTDB.setFloat(&fbdo, path + "humidity", humidity);
    success &= Firebase.RTDB.setInt(&fbdo, path + "soil", soil);
    success &= Firebase.RTDB.setInt(&fbdo, path + "light", light);
    success &= Firebase.RTDB.setInt(&fbdo, path + "rain", rain);

    if (success && fbdo.httpCode() == 200) {
      Serial.println("✅ Sensor data sent to Firebase!");
    } else {
      Serial.print("❌ Error: [");
      Serial.print(fbdo.errorReason());
      Serial.println("]");
    }
  } else {
    Serial.println("⚠️ Firebase not ready...");
  }
  delay(5000);
}
