import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsDashboard extends StatefulWidget {
  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  int timeIndex = 0; // 0: Day, 1: Last Week, 2: Last Month
  int trendIndex = 0; // 0: Temperature, 1: Humidity, 2: Soil Moisture

  // Example data
  final List<List<double>> tempData = [
    [23, 24, 22, 25, 24, 23, 22], // Day
    [22, 23, 24, 25, 23, 22, 21], // Week
    [21, 22, 23, 24, 23, 22, 21], // Month
  ];
  final List<List<double>> humidityData = [
    [60, 62, 61, 63, 64, 62, 61],
    [59, 60, 61, 62, 63, 61, 60],
    [58, 59, 60, 61, 62, 60, 59],
  ];
  final List<List<double>> soilData = [
    [40, 42, 41, 43, 44, 42, 41],
    [39, 40, 41, 42, 43, 41, 40],
    [38, 39, 40, 41, 42, 40, 39],
  ];

  List<double> get currentData {
    if (trendIndex == 0) return tempData[timeIndex];
    if (trendIndex == 1) return humidityData[timeIndex];
    return soilData[timeIndex];
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
              // TODO: Refresh logic
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Segmented control
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
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
                  "Average Temperature",
                  "${_avg(tempData[timeIndex])} °C",
                ),
                _statCard(
                  "Average Humidity",
                  "${_avg(humidityData[timeIndex])} %",
                ),
                _statCard(
                  "Average Soil Moisture",
                  "${_avg(soilData[timeIndex])} %",
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
              ],
            ),
            SizedBox(height: 18),
            // Graph
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                ),
                padding: EdgeInsets.all(16),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true, drawVerticalLine: false),
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
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          currentData.length,
                          (i) => FlSpot(i.toDouble(), currentData[i]),
                        ),
                        isCurved: true,
                        color: trendIndex == 0
                            ? Colors.orange
                            : trendIndex == 1
                            ? Colors.green
                            : Colors.blue,
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
