import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_database/firebase_database.dart';

class AnalyticsDashboard extends StatefulWidget {
  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  int timeIndex = 0; // 0: Day, 1: Last Week, 2: Last Month
  int trendIndex =
      0; // 0: Temperature, 1: Humidity, 2: Soil Moisture, 3: Light, 4: Rain

  List<Map<String, dynamic>> sensorHistory = [];
  bool isLoading = true;

  // Data for each sensor by time range
  List<Map<String, dynamic>> dayData = [];
  List<Map<String, dynamic>> weekData = [];
  List<Map<String, dynamic>> monthData = [];

  @override
  void initState() {
    super.initState();
    _fetchSensorHistory();
  }

  Future<void> _fetchSensorHistory() async {
    final ref = FirebaseDatabase.instance.ref('/sensorData');
    final snapshot = await ref.get();
    if (!snapshot.exists) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
    List<Map<String, dynamic>> history = [];
    data.forEach((key, value) {
      if (value is Map && value['timestamp'] != null) {
        history.add({
          'timestamp': value['timestamp'] is int
              ? value['timestamp']
              : int.tryParse(value['timestamp'].toString()) ?? 0,
          'temperature': (value['temperature'] ?? 0).toDouble(),
          'humidity': (value['humidity'] ?? 0).toDouble(),
          'soilMoisture': (value['soilMoisture'] ?? 0).toDouble(),
          'light': (value['light'] ?? 0).toDouble(),
          'rain': (value['rain'] ?? 0).toDouble(),
        });
      }
    });
    history.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    dayData = history.where((e) => now - e['timestamp'] <= 86400).toList();
    weekData = history.where((e) => now - e['timestamp'] <= 604800).toList();
    monthData = history.where((e) => now - e['timestamp'] <= 2592000).toList();
    setState(() {
      sensorHistory = history;
      isLoading = false;
    });
  }

  List<Map<String, dynamic>> get currentRangeData {
    if (timeIndex == 0) return dayData;
    if (timeIndex == 1) return weekData;
    return monthData;
  }

  List<FlSpot> get currentSpots {
    final data = currentRangeData;
    if (data.isEmpty) return [];
    if (trendIndex == 0) {
      return List.generate(
        data.length,
        (i) => FlSpot(i.toDouble(), data[i]['temperature']),
      );
    } else if (trendIndex == 1) {
      return List.generate(
        data.length,
        (i) => FlSpot(i.toDouble(), data[i]['humidity']),
      );
    } else if (trendIndex == 2) {
      return List.generate(
        data.length,
        (i) => FlSpot(i.toDouble(), data[i]['soilMoisture']),
      );
    } else if (trendIndex == 3) {
      return List.generate(
        data.length,
        (i) => FlSpot(i.toDouble(), data[i]['light']),
      );
    } else {
      return List.generate(
        data.length,
        (i) => FlSpot(i.toDouble(), data[i]['rain']),
      );
    }
  }

  double _avgSensor(int sensorIdx) {
    final data = currentRangeData;
    if (data.isEmpty) return 0;
    double sum = 0;
    for (var e in data) {
      if (sensorIdx == 0)
        sum += e['temperature'];
      else if (sensorIdx == 1)
        sum += e['humidity'];
      else if (sensorIdx == 2)
        sum += e['soilMoisture'];
      else if (sensorIdx == 3)
        sum += e['light'];
      else
        sum += e['rain'];
    }
    return sum / data.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 2,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Analytics Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              _fetchSensorHistory();
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Segmented control
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 8),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _segmentedButton("Day", 0),
                        _segmentedButton("Last Week", 1),
                        _segmentedButton("Last Month", 2),
                      ],
                    ),
                  ),
                  SizedBox(height: 18),
                  // Statistic cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _statCard(
                        "Avg Temp",
                        "${_avgSensor(0).toStringAsFixed(1)} °C",
                      ),
                      _statCard(
                        "Avg Humidity",
                        "${_avgSensor(1).toStringAsFixed(1)} %",
                      ),
                      _statCard(
                        "Avg Soil Moisture",
                        "${_avgSensor(2).toStringAsFixed(1)} %",
                      ),
                      _statCard(
                        "Avg Light",
                        "${_avgSensor(3).toStringAsFixed(1)}",
                      ),
                      _statCard(
                        "Avg Rain",
                        "${_avgSensor(4).toStringAsFixed(1)}",
                      ),
                    ],
                  ),
                  SizedBox(height: 28),
                  Text(
                    "Current Trend Analysis",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  // Pill-style tabs
                  Row(
                    children: [
                      _pillTab("Temperature", 0, Colors.orange),
                      SizedBox(width: 8),
                      _pillTab("Humidity", 1, Colors.green),
                      SizedBox(width: 8),
                      _pillTab("Soil Moisture", 2, Colors.blue),
                      SizedBox(width: 8),
                      _pillTab("Light", 3, Colors.purple),
                      SizedBox(width: 8),
                      _pillTab("Rain", 4, Colors.grey),
                    ],
                  ),
                  SizedBox(height: 18),
                  // Graph
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 8),
                        ],
                      ),
                      padding: EdgeInsets.all(16),
                      child: currentSpots.isEmpty
                          ? Center(
                              child: Text(
                                'No data available for selected range.',
                              ),
                            )
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
                                      reservedSize: 32,
                                      getTitlesWidget: (value, meta) {
                                        final idx = value.toInt();
                                        if (idx < 0 ||
                                            idx >= currentRangeData.length)
                                          return Container();
                                        final ts =
                                            currentRangeData[idx]['timestamp'];
                                        final dt =
                                            DateTime.fromMillisecondsSinceEpoch(
                                              ts * 1000,
                                            );
                                        return Text(
                                          '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}',
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: currentSpots,
                                    isCurved: true,
                                    color: trendIndex == 0
                                        ? Colors.orange
                                        : trendIndex == 1
                                        ? Colors.green
                                        : trendIndex == 2
                                        ? Colors.blue
                                        : trendIndex == 3
                                        ? Colors.purple
                                        : Colors.grey,
                                    barWidth: 4,
                                    dotData: FlDotData(show: true),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: Colors.green.withOpacity(0.08),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _segmentedButton(String label, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => timeIndex = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: timeIndex == index ? Colors.green[700] : Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: timeIndex == index ? Colors.white : Colors.green[700],
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(String title, String value) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6),
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pillTab(String label, int index, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => trendIndex = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: trendIndex == index ? color : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: trendIndex == index ? Colors.white : color,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _avg(List<double> data) =>
      (data.reduce((a, b) => a + b) / data.length).toStringAsFixed(1);
}
