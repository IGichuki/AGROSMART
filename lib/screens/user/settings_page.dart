import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

class SettingsPage extends StatelessWidget {
  final List<Map<String, dynamic>> sensors = const [
    {
      "name": "Soil Moisture",
      "icon": Icons.water_drop,
      "key": "soilMoisture",
      "color": Colors.teal,
    },
    {
      "name": "Temperature",
      "icon": Icons.thermostat,
      "key": "temperature",
      "color": Colors.orange,
    },
    {
      "name": "Humidity",
      "icon": Icons.water,
      "key": "humidity",
      "color": Colors.blueAccent,
    },
    {
      "name": "Light Sensor",
      "icon": Icons.wb_sunny,
      "key": "light",
      "color": Colors.yellow,
    },
    {
      "name": "Rain Sensor",
      "icon": Icons.grain,
      "key": "rain",
      "color": Colors.blue,
    },
  ];

  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Health'),
        backgroundColor: Colors.green[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/user-dashboard', (route) => false),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Force rebuild to reload data
              (context as Element).reassemble();
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
              child: StreamBuilder<DatabaseEvent>(
                stream: FirebaseDatabase.instance
                    .ref()
                    .child('sensorData')
                    .onValue,
                builder: (context, snapshot) {
                  Map<String, dynamic>? latestData;
                  if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data!.snapshot.value != null) {
                    final value = snapshot.data!.snapshot.value;
                    if (value is Map) {
                      final entries = Map<String, dynamic>.from(value);
                      if (entries.isNotEmpty) {
                        final lastKey = entries.keys.last;
                        final lastEntry = entries[lastKey];
                        if (lastEntry is Map) {
                          latestData = Map<String, dynamic>.from(lastEntry);
                        }
                      }
                    }
                  }
                  return GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: sensors.map((sensor) {
                      final sensorKey = sensor['key'];
                      final sensorValue = latestData != null
                          ? latestData[sensorKey]
                          : null;
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
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  backgroundColor: sensor['color'].withOpacity(
                                    0.15,
                                  ),
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
                                  sensorValue != null
                                      ? 'Value: $sensorValue'
                                      : 'No data',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void startPump() async {
    print('Start button pressed');
    try {
      await FirebaseDatabase.instance.ref('/pump/manual').set(1);
      print('Pump ON sent');
    } catch (e) {
      print('Error sending pump ON: $e');
    }
  }

  void stopPump() async {
    print('Stop button pressed');
    try {
      await FirebaseDatabase.instance.ref('/pump/manual').set(0);
      print('Pump OFF sent');
    } catch (e) {
      print('Error sending pump OFF: $e');
    }
  }
}

class SensorChartDialog extends StatefulWidget {
  final Map<String, dynamic> sensor;
  const SensorChartDialog({Key? key, required this.sensor}) : super(key: key);

  @override
  State<SensorChartDialog> createState() => _SensorChartDialogState();
}

class _SensorChartDialogState extends State<SensorChartDialog> {
  List<double> sensorValues = [];
  List<String> xLabels = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchSensorHistory();
  }

  Future<void> _fetchSensorHistory() async {
    final ref = FirebaseDatabase.instance.ref().child('sensorData');
    final snapshot = await ref.get();
    List<double> values = [];
    List<String> labels = [];
    if (snapshot.value is Map) {
      final entries = Map<String, dynamic>.from(snapshot.value as Map);
      // Get last 20 entries
      final lastEntries = entries.entries
          .toList()
          .reversed
          .take(20)
          .toList()
          .reversed;
      for (final entry in lastEntries) {
        final data = entry.value;
        if (data is Map && data[widget.sensor['key']] != null) {
          final val = data[widget.sensor['key']];
          double? parsed;
          if (val is int || val is double) {
            parsed = val.toDouble();
          } else if (val is String) {
            parsed = double.tryParse(val);
          }
          if (parsed != null) {
            values.add(parsed);
            // Use timestamp for x-axis label if available
            if (data['timestamp'] != null) {
              int ts = data['timestamp'] is int
                  ? data['timestamp']
                  : int.tryParse(data['timestamp'].toString()) ?? 0;
              final dt = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
              labels.add("${dt.hour}:${dt.minute.toString().padLeft(2, '0')}");
            } else {
              labels.add(entry.key.substring(0, 6));
            }
          }
        }
      }
    }
    setState(() {
      sensorValues = values;
      xLabels = labels;
      loading = false;
    });
  }

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
                  backgroundColor: widget.sensor['color'].withOpacity(0.15),
                  child: Icon(
                    widget.sensor['icon'],
                    color: widget.sensor['color'],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.sensor['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 180,
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : sensorValues.isEmpty
                  ? const Center(child: Text('No data available'))
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                int idx = value.toInt();
                                if (idx >= 0 && idx < xLabels.length) {
                                  return Text(
                                    xLabels[idx],
                                    style: const TextStyle(fontSize: 10),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                              interval: 1,
                              reservedSize: 32,
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              sensorValues.length,
                              (i) => FlSpot(i.toDouble(), sensorValues[i]),
                            ),
                            isCurved: true,
                            color: widget.sensor['color'],
                            barWidth: 4,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: widget.sensor['color'].withOpacity(0.08),
                            ),
                          ),
                        ],
                      ),
                    ),
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
