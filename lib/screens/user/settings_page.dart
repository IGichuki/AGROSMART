import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

import 'user_dashboard_screen.dart';

class SystemHealthStatusSection extends StatefulWidget {
  @override
  State<SystemHealthStatusSection> createState() =>
      _SystemHealthStatusSectionState();
}

class _SystemHealthStatusSectionState extends State<SystemHealthStatusSection> {
  bool _checking = false;
  bool _firebaseConnected = true;
  Map<String, dynamic> _sensorStatus = {};

  final List<Map<String, dynamic>> sensors = [
    {"name": "Soil Moisture Sensor", "icon": "🌱", "key": "soil_moisture"},
    {"name": "DHT22 Temp & Humidity", "icon": "🌡️", "key": "dht22"},
    {"name": "LDR Light Sensor", "icon": "☀️", "key": "ldr"},
    {"name": "Rain Sensor", "icon": "🌧️", "key": "rain"},
    {"name": "Water Pump Relay", "icon": "💧", "key": "water_pump"},
  ];

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    setState(() {
      _checking = true;
    });
    try {
      final firestore = FirebaseFirestore.instance;
      Map<String, dynamic> status = {};
      for (var sensor in sensors) {
        final snap = await firestore
            .collection('sensors')
            .doc(sensor['key'])
            .get();
        if (snap.exists && snap.data() != null) {
          final data = snap.data()!;
          final ts = data['timestamp'];
          final dt = ts is Timestamp
              ? ts.toDate()
              : DateTime.tryParse(ts?.toString() ?? '');
          final value = data['value'];
          final now = DateTime.now();
          final connected =
              dt != null && now.difference(dt).inSeconds <= 60 && value != null;
          status[sensor['key']] = {
            'connected': connected,
            'lastUpdate': dt,
            'value': value,
          };
        } else {
          status[sensor['key']] = {
            'connected': false,
            'lastUpdate': null,
            'value': null,
          };
        }
      }
      setState(() {
        _sensorStatus = status;
        _firebaseConnected = true;
        _checking = false;
      });
    } catch (e) {
      setState(() {
        _firebaseConnected = false;
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.health_and_safety,
                    color: Colors.green,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'System Health',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _firebaseConnected
                        ? Colors.green[100]
                        : Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _firebaseConnected ? Icons.check_circle : Icons.warning,
                        color: _firebaseConnected ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _firebaseConnected ? 'Connected' : 'Disconnected',
                        style: TextStyle(
                          color: _firebaseConnected
                              ? Colors.green[700]
                              : Colors.red[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: sensors.map((sensor) {
                  final status = _sensorStatus[sensor['key']];
                  final connected = status?['connected'] ?? false;
                  final lastUpdate = status?['lastUpdate'] as DateTime?;
                  final value = status?['value'];
                  final timeStr = lastUpdate != null
                      ? "${lastUpdate.hour.toString().padLeft(2, '0')}:${lastUpdate.minute.toString().padLeft(2, '0')}:${lastUpdate.second.toString().padLeft(2, '0')}"
                      : '--';
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6.0,
                      horizontal: 4.0,
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: connected ? Colors.green : Colors.red,
                          width: 2,
                        ),
                      ),
                      onPressed: () async {
                        List<FlSpot> chartSpots = [];
                        try {
                          final firestore = FirebaseFirestore.instance;
                          final query = await firestore
                              .collection('sensors')
                              .doc(sensor['key'])
                              .collection('values')
                              .orderBy('timestamp', descending: false)
                              .limit(10)
                              .get();
                          int i = 0;
                          for (var doc in query.docs) {
                            final v = doc.data()['value'];
                            if (v != null && v is num) {
                              chartSpots.add(
                                FlSpot(i.toDouble(), v.toDouble()),
                              );
                              i++;
                            }
                          }
                        } catch (e) {
                          chartSpots = [];
                        }
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    Text(
                                      sensor['icon'],
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(sensor['name']),
                                  ],
                                ),
                              ),
                              content: SizedBox(
                                width: 320,
                                height: 220,
                                child: LineChart(
                                  LineChartData(
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: chartSpots,
                                        isCurved: true,
                                        color: Colors.blue,
                                        barWidth: 3,
                                        dotData: FlDotData(show: false),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                sensor['icon'],
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                sensor['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            connected ? 'Connected' : 'Disconnected',
                            style: TextStyle(
                              color: connected ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text('Last: $timeStr'),
                          if (value != null) Text('Value: $value'),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _checking
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.refresh),
                label: const Text('Refresh Status'),
                onPressed: _checking ? null : _fetchStatus,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  final String lastName;
  final int navIndex;
  const SettingsPage({super.key, required this.lastName, this.navIndex = 3});

  @override
  Widget build(BuildContext context) {
    return UserDashboardScaffold(
      lastName: lastName,
      currentIndex: navIndex,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [const SizedBox(height: 32), SystemHealthStatusSection()],
        ),
      ),
    );
  }
}
