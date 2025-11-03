import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class SettingsPage extends StatelessWidget {
  final String? lastName;
  final int? navIndex;
  final List<Map<String, dynamic>> sensors = const [
    {
      "name": "Soil Moisture",
      "icon": Icons.water_drop,
      "key": "soil_moisture",
      "color": Colors.teal,
    },
    {
      "name": "Temperature & Humidity",
      "icon": Icons.thermostat,
      "key": "dht22",
      "color": Colors.orange,
    },
    {
      "name": "Light Sensor",
      "icon": Icons.wb_sunny,
      "key": "ldr",
      "color": Colors.yellow,
    },
    {
      "name": "Rain Sensor",
      "icon": Icons.grain,
      "key": "rain",
      "color": Colors.blue,
    },
    {
      "name": "Water Pump",
      "icon": Icons.opacity,
      "key": "water_pump",
      "color": Colors.indigo,
    },
  ];

  const SettingsPage({Key? key, this.lastName, this.navIndex})
    : super(key: key);

  static Widget tipBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.green[400], size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/user-dashboard'),
          tooltip: 'Back',
        ),
        title: const Text('System Health'),
        backgroundColor: Colors.green[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/settings'),
            tooltip: 'Reload',
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Reset All Sensors',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Reset'),
                  content: const Text(
                    'Are you sure you want to reset all sensor graphs? This will delete all historical sensor data.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                // Delete all historical sensor data
                for (final sensor in sensors) {
                  final col = FirebaseFirestore.instance
                      .collection('sensors')
                      .doc(sensor['key'])
                      .collection('values');
                  final snapshots = await col.get();
                  for (final doc in snapshots.docs) {
                    await doc.reference.delete();
                  }
                }
                // Optionally show a snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All sensor graphs have been reset.'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sensors Overview',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green[900],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: sensors.map((sensor) {
                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('sensors')
                        .doc(sensor['key'])
                        .snapshots(),
                    builder: (context, snapshot) {
                      final status =
                          snapshot.data?.data() as Map<String, dynamic>?;
                      final value = status?['value'];
                      final timestamp = status?['timestamp'] is Timestamp
                          ? (status?['timestamp'] as Timestamp).toDate()
                          : null;
                      final connected =
                          value != null &&
                          timestamp != null &&
                          DateTime.now().difference(timestamp).inSeconds < 60;
                      final timeStr = timestamp != null
                          ? "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}"
                          : '--';
                      return Material(
                        color: Colors.white,
                        elevation: 4,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return SensorChartDialog(sensor: sensor);
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: sensor['color']
                                        .withOpacity(0.15),
                                    radius: 24,
                                    child: Icon(
                                      sensor['icon'],
                                      color: sensor['color'],
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    sensor['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    connected ? 'Connected' : 'Disconnected',
                                    style: TextStyle(
                                      color: connected
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Last: $timeStr',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  if (value != null)
                                    Text(
                                      'Value: $value',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            // Enhanced Tips section
            Text(
              'Tips',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            // Limit tips section height to 1/4 of screen
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.25,
              child: SingleChildScrollView(
                child: Card(
                  color: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 18.0,
                      horizontal: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.green[700],
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'How to read the graphs:',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.green[900],
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SettingsPage.tipBullet(
                          'The x-axis shows the order of recent sensor readings.',
                        ),
                        SettingsPage.tipBullet(
                          'The y-axis shows the actual sensor value (e.g., moisture, temperature, etc.).',
                        ),
                        SettingsPage.tipBullet(
                          'Tap a sensor card to view its recent data as a graph.',
                        ),
                        SettingsPage.tipBullet(
                          '"Connected" means the sensor sent data in the last minute.',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class SensorChartDialog extends StatelessWidget {
  final Map<String, dynamic> sensor;
  const SensorChartDialog({Key? key, required this.sensor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: sensor['color'].withOpacity(0.15),
                  child: Icon(sensor['icon'], color: sensor['color'], size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    sensor['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('sensors')
                  .doc(sensor['key'])
                  .collection('values')
                  .orderBy('timestamp', descending: false)
                  .limit(20)
                  .snapshots(),
              builder: (context, snap) {
                List<FlSpot> chartSpots = [];
                if (snap.hasData) {
                  int i = 0;
                  for (var doc in snap.data!.docs) {
                    final v = doc['value'];
                    if (v != null && v is num) {
                      chartSpots.add(FlSpot(i.toDouble(), v.toDouble()));
                      i++;
                    }
                  }
                }
                return SizedBox(
                  height: 200,
                  child: chartSpots.isEmpty
                      ? const Center(child: Text('No data available'))
                      : LineChart(
                          LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                                spots: chartSpots,
                                isCurved: true,
                                gradient: LinearGradient(
                                  colors: [
                                    sensor['color'],
                                    sensor['color'].withOpacity(0.5),
                                  ],
                                ),
                                barWidth: 3,
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      sensor['color'].withOpacity(0.3),
                                      sensor['color'].withOpacity(0.1),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, _, __, ___) {
                                    if (chartSpots.isNotEmpty &&
                                        spot.x == chartSpots.last.x &&
                                        spot.y == chartSpots.last.y) {
                                      return FlDotCirclePainter(
                                        radius: 6,
                                        color: Colors.red,
                                        strokeWidth: 2,
                                        strokeColor: Colors.white,
                                      );
                                    }
                                    return FlDotCirclePainter(
                                      radius: 3,
                                      color: sensor['color'],
                                    );
                                  },
                                ),
                              ),
                            ],
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize:
                                      40, // increase space for y-axis labels
                                  getTitlesWidget: (value, meta) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign
                                            .right, // ensure horizontal alignment
                                      ),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true),
                              ),
                            ),
                            gridData: FlGridData(show: true),
                            borderData: FlBorderData(show: false),
                            lineTouchData: LineTouchData(
                              enabled: true,
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipItems: (touchedSpots) {
                                  return touchedSpots.map((touchedSpot) {
                                    return LineTooltipItem(
                                      "${touchedSpot.y.toStringAsFixed(2)}",
                                      const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                          ),
                        ),
                );
              },
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
