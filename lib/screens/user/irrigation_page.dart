import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class IrrigationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Irrigation Control'),
        backgroundColor: Colors.green[700],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed('/user-dashboard'),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                final state = context
                    .findAncestorStateOfType<_IrrigationContentState>();
                state?.refreshPage();
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _IrrigationContent(),
      ),
    );
  }
}

class _IrrigationContent extends StatefulWidget {
  @override
  State<_IrrigationContent> createState() => _IrrigationContentState();
}

class _IrrigationContentState extends State<_IrrigationContent> {
  String? selectedLocation;
  bool isLoadingLocation = true;
  final Map<String, Map<String, dynamic>> countyThresholds = {
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

  Timer? autoIrrigationTimer;

  @override
  void initState() {
    super.initState();
    _loadLocation();
    _setupAutoIrrigation();
  }

  @override
  void dispose() {
    autoIrrigationTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadLocation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = doc.data();
    setState(() {
      selectedLocation = data?['location'] as String?;
      isLoadingLocation = false;
    });
  }

  void refreshPage() {
    setState(() {
      // Add logic to reload or refresh data if needed
    });
  }

  bool isIrrigating = false;
  DateTime? lastIrrigation;
  Duration? lastDuration;
  DateTime? nextScheduled;
  List<Map<String, dynamic>> history = [];
  bool isAutoMode = false;
  Duration manualDuration = Duration(minutes: 10);

  void startIrrigation() {
    setState(() {
      isIrrigating = true;
      lastIrrigation = DateTime.now();
      lastDuration = manualDuration;
      history.insert(0, {
        'date': lastIrrigation,
        'duration': manualDuration,
        'mode': isAutoMode ? 'Auto' : 'Manual',
      });
    });
    // Send command to hardware via Firebase
    FirebaseDatabase.instance.ref('/pump/manual').set(1);
    Future.delayed(manualDuration, stopIrrigation);
  }

  void stopIrrigation() {
    setState(() {
      isIrrigating = false;
    });
    // Send command to hardware via Firebase
    FirebaseDatabase.instance.ref('/pump/manual').set(0);
  }

  void scheduleIrrigation(DateTime dateTime, Duration duration) {
    setState(() {
      nextScheduled = dateTime;
    });
    // TODO: Schedule irrigation in backend
  }

  void _setupAutoIrrigation() {
    autoIrrigationTimer?.cancel();
    if (isAutoMode) {
      autoIrrigationTimer = Timer.periodic(Duration(seconds: 30), (
        timer,
      ) async {
        await _checkAndAutoIrrigate();
      });
      print('[AutoIrrigation] Timer started.');
    } else {
      print('[AutoIrrigation] Timer cancelled.');
    }
  }

  Future<void> _checkAndAutoIrrigate() async {
    if (!isAutoMode) return;
    final sensorData = await _fetchSensorData();
    if (sensorData == null) {
      print('[AutoIrrigation] No sensor data available.');
      return;
    }
    // Robust mapping: handle both digital and analog
    int soilMoisture = 1;
    int rain = 1;
    int light = 1;
    if (sensorData['soilMoisture'] != null) {
      var s = sensorData['soilMoisture'];
      if (s is int) {
        soilMoisture = (s == 0) ? 0 : 1;
      } else if (s is double) {
        soilMoisture = (s < 0.5) ? 0 : 1;
      }
    }
    if (sensorData['rain'] != null) {
      var r = sensorData['rain'];
      if (r is int) {
        rain = (r == 0) ? 0 : 1;
      } else if (r is double) {
        rain = (r < 0.5) ? 0 : 1;
      }
    }
    if (sensorData['light'] != null) {
      var l = sensorData['light'];
      if (l is int) {
        light = (l == 1) ? 1 : 0;
      } else if (l is double) {
        light = (l > 0.5) ? 1 : 0;
      }
    }
    print(
      '[AutoIrrigation] Sensor values: soilMoisture=$soilMoisture, rain=$rain, light=$light',
    );
    bool shouldIrrigate = (soilMoisture == 0) && (rain == 0) && (light == 1);
    print('[AutoIrrigation] Should irrigate: $shouldIrrigate');
    if (shouldIrrigate) {
      if (!isIrrigating) {
        startIrrigation();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Auto irrigation started!')));
        }
      }
    } else {
      if (isIrrigating) {
        stopIrrigation();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Auto irrigation stopped!')));
        }
      }
    }
  }

  Future<Map<String, dynamic>?> _fetchSensorData() async {
    // Fetch latest sensor data from Realtime Database at /sensorData
    final ref = FirebaseDatabase.instance.ref('/sensorData');
    final snapshot = await ref.get();
    if (!snapshot.exists) return null;
    // If multiple sensor data entries, get the latest by timestamp
    Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
    Map<String, dynamic>? latest;
    int latestTimestamp = 0;
    data.forEach((key, value) {
      if (value is Map && value['timestamp'] != null) {
        int ts = 0;
        try {
          ts = value['timestamp'] is int
              ? value['timestamp']
              : int.parse(value['timestamp'].toString());
        } catch (_) {}
        if (ts > latestTimestamp) {
          latestTimestamp = ts;
          latest = Map<String, dynamic>.from(value);
        }
      }
    });
    return latest;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLoadingLocation)
            const Center(child: CircularProgressIndicator()),
          if (!isLoadingLocation &&
              selectedLocation != null &&
              countyThresholds[selectedLocation!] != null)
            Card(
              color: Colors.green[50],
              margin: const EdgeInsets.only(bottom: 18),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Irrigation Thresholds for $selectedLocation (Onions)',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...countyThresholds[selectedLocation!]!.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text('${entry.key}: ${entry.value}'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isIrrigating
                            ? Icons.water_drop
                            : Icons.water_drop_outlined,
                        color: isIrrigating ? Colors.blue : Colors.grey,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isIrrigating
                            ? 'Irrigation Active'
                            : 'Irrigation Inactive',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isIrrigating ? Colors.blue : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Last Irrigation: ' +
                        (lastIrrigation != null
                            ? '${lastIrrigation!.toLocal().toString().split('.')[0]} (${lastDuration?.inMinutes ?? 0} min)'
                            : '--'),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Next Scheduled: ' +
                        (nextScheduled != null
                            ? nextScheduled!.toLocal().toString().split('.')[0]
                            : '--'),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Control Panel',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: isAutoMode,
                        onChanged: (val) {
                          if (isAutoMode && !val) {
                            // Switching from auto to manual, stop irrigation
                            if (isIrrigating) {
                              stopIrrigation();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Irrigation stopped (manual mode).',
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                          setState(() {
                            isAutoMode = val;
                          });
                          _setupAutoIrrigation();
                        },
                        activeColor: Colors.green,
                      ),
                      Text(isAutoMode ? 'Auto' : 'Manual'),
                    ],
                  ),
                  if (!isAutoMode) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Duration:'),
                        const SizedBox(width: 8),
                        DropdownButton<int>(
                          value: manualDuration.inMinutes,
                          items: [5, 10, 15, 20, 30]
                              .map(
                                (min) => DropdownMenuItem(
                                  value: min,
                                  child: Text('$min min'),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                manualDuration = Duration(minutes: val);
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.play_arrow),
                          label: Text('Start'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: isIrrigating ? null : startIrrigation,
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          icon: Icon(Icons.stop),
                          label: Text('Stop'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: isIrrigating ? stopIrrigation : null,
                        ),
                      ],
                    ),
                  ],
                  if (isAutoMode) ...[
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: Icon(Icons.schedule),
                      label: Text('Set Schedule'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        // TODO: Show schedule picker dialog
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Irrigation History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: history.isEmpty
                ? Center(child: Text('No irrigation events yet.'))
                : ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, idx) {
                      final item = history[idx];
                      return ListTile(
                        leading: Icon(Icons.history, color: Colors.grey[700]),
                        title: Text(
                          '${item['date'].toLocal().toString().split('.')[0]}',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          '${item['duration'].inMinutes} min • ${item['mode']}',
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
