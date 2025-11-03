import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class SensorSimulator {
  Timer? _timer;
  bool _isRunning = false;

  // Store last values for gradual change
  double _soilMoisture = 50;
  double _temperature = 25;
  double _humidity = 60;
  double _light = 500;
  int _rain = 0;

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _sendMockData();
    });
  }

  void stop() {
    _timer?.cancel();
    _isRunning = false;
  }

  void _sendMockData() {
    final random = Random();
    final timestamp = DateTime.now();

    // Gradual change logic
    _soilMoisture += random.nextDouble() * 4 - 2; // drift -2 to +2
    _soilMoisture = _soilMoisture.clamp(20, 80);

    _temperature += random.nextDouble() * 1.5 - 0.75; // drift -0.75 to +0.75
    _temperature = _temperature.clamp(15, 35);

    _humidity += random.nextDouble() * 3 - 1.5; // drift -1.5 to +1.5
    _humidity = _humidity.clamp(40, 90);

    // Simulate day/night light
    final hour = timestamp.hour;
    double baseLight = (hour >= 6 && hour <= 18)
        ? 700 +
              random.nextDouble() *
                  300 // day
        : 100 + random.nextDouble() * 100; // night
    _light += random.nextDouble() * 20 - 10;
    _light = (_light * 0.7 + baseLight * 0.3).clamp(100, 1000);

    // Rain: 5% chance to toggle
    if (random.nextDouble() < 0.05) {
      _rain = _rain == 0 ? 1 : 0;
    }

    final sensorValues = {
      'soil_moisture': _soilMoisture.round(),
      'dht22': double.parse(_temperature.toStringAsFixed(1)),
      'humidity': _humidity.round(),
      'ldr': _light.round(),
      'rain': _rain,
    };

    sensorValues.forEach((key, value) {
      // Update latest value
      FirebaseFirestore.instance.collection('sensors').doc(key).set({
        'value': value,
        'timestamp': timestamp,
      });
      // Add to historical values subcollection
      FirebaseFirestore.instance
          .collection('sensors')
          .doc(key)
          .collection('values')
          .add({'value': value, 'timestamp': timestamp});
    });
  }

  bool get isRunning => _isRunning;
}
