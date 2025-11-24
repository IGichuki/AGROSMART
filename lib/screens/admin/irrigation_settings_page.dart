import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IrrigationSettingsPage extends StatefulWidget {
  const IrrigationSettingsPage({Key? key}) : super(key: key);

  @override
  State<IrrigationSettingsPage> createState() => _IrrigationSettingsPageState();
}

class _IrrigationSettingsPageState extends State<IrrigationSettingsPage> {
  List<String> crops = [];
  String? selectedCrop;
  String? selectedCounty;
  Map<String, dynamic>? thresholds;
  final List<String> counties = [
    'Baringo',
    'Bomet',
    'Bungoma',
    'Busia',
    'Elgeyo Marakwet',
    'Embu',
    'Garissa',
    'Homa Bay',
    'Isiolo',
    'Kajiado',
    'Kakamega',
    'Kericho',
    'Kiambu',
    'Kilifi',
    'Kirinyaga',
    'Kisii',
    'Kisumu',
    'Kitui',
    'Kwale',
    'Laikipia',
    'Lamu',
    'Machakos',
    'Makueni',
    'Mandera',
    'Marsabit',
    'Meru',
    'Migori',
    'Mombasa',
    'Murang’a',
    'Nairobi',
    'Nakuru',
    'Nandi',
    'Narok',
    'Nyamira',
    'Nyandarua',
    'Nyeri',
    'Samburu',
    'Siaya',
    'Taita Taveta',
    'Tana River',
    'Tharaka Nithi',
    'Trans Nzoia',
    'Turkana',
    'Uasin Gishu',
    'Vihiga',
    'Wajir',
    'West Pokot',
  ];
  // Realistic region-based thresholds for Kenyan counties (FAO/KALRO best-practice)
  final Map<String, Map<String, dynamic>> countyThresholds = {
    // Onion-specific irrigation thresholds for Kenyan counties/regions (FAO/KALRO best-practice)
    // All values below are for onions only.
    'Kisumu': {
      'soilMoistureMin': 30,
      'soilMoistureMax': 50,
      'temperature': 22,
      'humidity': 70,
      'light': 9000,
      'rain': 160,
    },
    'Homa Bay': {
      'soilMoistureMin': 29,
      'soilMoistureMax': 49,
      'temperature': 22,
      'humidity': 68,
      'light': 8800,
      'rain': 155,
    },
    'Migori': {
      'soilMoistureMin': 30,
      'soilMoistureMax': 50,
      'temperature': 21,
      'humidity': 69,
      'light': 8900,
      'rain': 158,
    },
    'Siaya': {
      'soilMoistureMin': 28,
      'soilMoistureMax': 48,
      'temperature': 21,
      'humidity': 67,
      'light': 8700,
      'rain': 150,
    },
    'Kisii': {
      'soilMoistureMin': 31,
      'soilMoistureMax': 51,
      'temperature': 20,
      'humidity': 72,
      'light': 8500,
      'rain': 170,
    },
    'Nyamira': {
      'soilMoistureMin': 30,
      'soilMoistureMax': 50,
      'temperature': 20,
      'humidity': 71,
      'light': 8400,
      'rain': 165,
    },
    'Nakuru': {
      'soilMoistureMin': 25,
      'soilMoistureMax': 45,
      'temperature': 19,
      'humidity': 60,
      'light': 8000,
      'rain': 100,
    },
    'Kericho': {
      'soilMoistureMin': 27,
      'soilMoistureMax': 47,
      'temperature': 18,
      'humidity': 65,
      'light': 8100,
      'rain': 120,
    },
    'Bomet': {
      'soilMoistureMin': 26,
      'soilMoistureMax': 46,
      'temperature': 19,
      'humidity': 63,
      'light': 8050,
      'rain': 110,
    },
    'Nandi': {
      'soilMoistureMin': 28,
      'soilMoistureMax': 48,
      'temperature': 18,
      'humidity': 64,
      'light': 8200,
      'rain': 115,
    },
    'Uasin Gishu': {
      'soilMoistureMin': 24,
      'soilMoistureMax': 44,
      'temperature': 17,
      'humidity': 62,
      'light': 8000,
      'rain': 90,
    },
    'Trans Nzoia': {
      'soilMoistureMin': 25,
      'soilMoistureMax': 45,
      'temperature': 18,
      'humidity': 63,
      'light': 8100,
      'rain': 100,
    },
    'Kitui': {
      'soilMoistureMin': 15,
      'soilMoistureMax': 28,
      'temperature': 26,
      'humidity': 40,
      'light': 9500,
      'rain': 40,
    },
    'Machakos': {
      'soilMoistureMin': 17,
      'soilMoistureMax': 30,
      'temperature': 25,
      'humidity': 43,
      'light': 9400,
      'rain': 50,
    },
    'Makueni': {
      'soilMoistureMin': 16,
      'soilMoistureMax': 29,
      'temperature': 27,
      'humidity': 39,
      'light': 9600,
      'rain': 35,
    },
    'Embu': {
      'soilMoistureMin': 19,
      'soilMoistureMax': 33,
      'temperature': 24,
      'humidity': 45,
      'light': 9300,
      'rain': 60,
    },
    'Tharaka Nithi': {
      'soilMoistureMin': 18,
      'soilMoistureMax': 31,
      'temperature': 25,
      'humidity': 42,
      'light': 9350,
      'rain': 45,
    },
    'Mombasa': {
      'soilMoistureMin': 27,
      'soilMoistureMax': 42,
      'temperature': 27,
      'humidity': 75,
      'light': 10000,
      'rain': 180,
    },
    'Kilifi': {
      'soilMoistureMin': 25,
      'soilMoistureMax': 40,
      'temperature': 26,
      'humidity': 73,
      'light': 9900,
      'rain': 170,
    },
    'Kwale': {
      'soilMoistureMin': 26,
      'soilMoistureMax': 41,
      'temperature': 26,
      'humidity': 74,
      'light': 9950,
      'rain': 175,
    },
    'Lamu': {
      'soilMoistureMin': 24,
      'soilMoistureMax': 39,
      'temperature': 25,
      'humidity': 72,
      'light': 9800,
      'rain': 160,
    },
    'Garissa': {
      'soilMoistureMin': 8,
      'soilMoistureMax': 18,
      'temperature': 30,
      'humidity': 25,
      'light': 10500,
      'rain': 10,
    },
    'Wajir': {
      'soilMoistureMin': 7,
      'soilMoistureMax': 16,
      'temperature': 31,
      'humidity': 22,
      'light': 10600,
      'rain': 8,
    },
    'Mandera': {
      'soilMoistureMin': 6,
      'soilMoistureMax': 15,
      'temperature': 32,
      'humidity': 20,
      'light': 10700,
      'rain': 6,
    },
    'Marsabit': {
      'soilMoistureMin': 9,
      'soilMoistureMax': 19,
      'temperature': 29,
      'humidity': 27,
      'light': 10400,
      'rain': 12,
    },
    'Isiolo': {
      'soilMoistureMin': 10,
      'soilMoistureMax': 20,
      'temperature': 28,
      'humidity': 29,
      'light': 10300,
      'rain': 15,
    },
    'Nairobi': {
      'soilMoistureMin': 22,
      'soilMoistureMax': 36,
      'temperature': 21,
      'humidity': 55,
      'light': 8500,
      'rain': 80,
    },
    // Default for other counties (onion best-practice)
  };

  @override
  void initState() {
    super.initState();
    _fetchCrops();
  }

  Future<void> _fetchCrops() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('cropThresholds')
        .get();
    setState(() {
      crops = snapshot.docs.map((doc) => doc.id).whereType<String>().toList();
      if (selectedCrop == null && crops.isNotEmpty) {
        selectedCrop = crops.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Irrigation Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Crop:',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Crop',
                border: OutlineInputBorder(),
              ),
              value: selectedCrop,
              items: crops
                  .map(
                    (crop) => DropdownMenuItem(value: crop, child: Text(crop)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCrop = value;
                });
              },
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select County',
                border: OutlineInputBorder(),
              ),
              value: selectedCounty,
              items: counties
                  .map(
                    (county) =>
                        DropdownMenuItem(value: county, child: Text(county)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCounty = value;
                  thresholds =
                      countyThresholds[value!] ??
                      {
                        'soilMoistureMin': 25,
                        'soilMoistureMax': 40,
                        'temperature': 22,
                        'humidity': 60,
                        'light': 8000,
                        'rain': 100,
                      };
                });
              },
            ),
            const SizedBox(height: 24),
            Builder(
              builder: (context) {
                if (selectedCounty == null) {
                  return const Text('Select a county to view thresholds.');
                }
                final displayThresholds =
                    thresholds ??
                    countyThresholds[selectedCounty!] ??
                    {
                      'soilMoistureMin': 25,
                      'soilMoistureMax': 40,
                      'temperature': 22,
                      'humidity': 60,
                      'light': 8000,
                      'rain': 100,
                    };
                return Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thresholds for $selectedCounty',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Soil Moisture Min: ${displayThresholds['soilMoistureMin']}%',
                        ),
                        Text(
                          'Soil Moisture Max: ${displayThresholds['soilMoistureMax']}%',
                        ),
                        Text(
                          'Temperature: ${displayThresholds['temperature']}°C',
                        ),
                        Text('Humidity: ${displayThresholds['humidity']}%'),
                        Text(
                          'Light Intensity: ${displayThresholds['light']} lux',
                        ),
                        Text('Rain: ${displayThresholds['rain']} mm'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
