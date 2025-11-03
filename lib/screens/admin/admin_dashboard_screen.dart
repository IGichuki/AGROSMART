import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agrosmart/screens/admin/user_management_page.dart';
import 'package:agrosmart/screens/admin/irrigation_settings_page.dart';
import 'package:agrosmart/screens/admin/system_health_page.dart';
import 'package:agrosmart/simulation/sensor_simulator.dart';

// Sensor tip model
class _SensorTip {
  final IconData icon;
  final Color color;
  final String title;
  final String text;
  const _SensorTip({
    required this.icon,
    required this.color,
    required this.title,
    required this.text,
  });
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<Map<String, dynamic>> dashboardData;
  final SensorSimulator _simulator = SensorSimulator();

  @override
  void initState() {
    super.initState();
    dashboardData = fetchDashboardData();
  }

  Future<Map<String, dynamic>> fetchDashboardData() async {
    // Fetch real data from Firestore
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();
    final sensorsSnapshot = await FirebaseFirestore.instance
        .collection('sensors')
        .where('active', isEqualTo: true)
        .get();
    final irrigationSnapshot = await FirebaseFirestore.instance
        .collection('irrigation_events')
        .get();
    final systemHealthSnapshot = await FirebaseFirestore.instance
        .collection('system_health')
        .limit(1)
        .get();

    final usersCount = usersSnapshot.size;
    final activeSensorsCount = sensorsSnapshot.size;
    final irrigationEventsCount = irrigationSnapshot.size;
    final systemHealth = systemHealthSnapshot.docs.isNotEmpty
        ? systemHealthSnapshot.docs.first.data()['status'] ?? 'Unknown'
        : 'Unknown';

    return {
      'users': usersCount,
      'activeSensors': activeSensorsCount,
      'irrigationEvents': irrigationEventsCount,
      'systemHealth': systemHealth,
    };
  }

  void _reloadDashboard() {
    setState(() {
      dashboardData = fetchDashboardData();
    });
  }

  void _logout() {
    // Implement logout logic
    Navigator.of(context).pop();
  }

  Widget buildSimulationControls() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sensor Data Simulation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (!_simulator.isRunning) {
                      _simulator.start();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sensor simulation started!'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Simulation already running.'),
                        ),
                      );
                    }
                  },
                  child: const Text('Simulate Data'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_simulator.isRunning) {
                      _simulator.stop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sensor simulation stopped.'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Simulation is not running.'),
                        ),
                      );
                    }
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadDashboard,
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: dashboardData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final data = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          child: _buildOverviewCard(
                            'Users',
                            data['users'].toString(),
                            Icons.people,
                            Colors.blue,
                          ),
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: _buildOverviewCard(
                            'Sensors',
                            data['activeSensors'].toString(),
                            Icons.sensors,
                            Colors.green,
                          ),
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: _buildOverviewCard(
                            'Irrigation',
                            data['irrigationEvents'].toString(),
                            Icons.water,
                            Colors.teal,
                          ),
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: _buildOverviewCard(
                            'Health',
                            data['systemHealth'],
                            Icons.health_and_safety,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.2,
                      children: [
                        _buildSectionCard(
                          title: 'User Management',
                          icon: Icons.manage_accounts,
                          color: Colors.indigo,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UserManagementPage(),
                            ),
                          ),
                        ),
                        _buildSectionCard(
                          title: 'Irrigation Settings',
                          icon: Icons.settings_input_component,
                          color: Colors.cyan,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const IrrigationSettingsPage(),
                            ),
                          ),
                        ),
                        _buildSectionCard(
                          title: 'System Health',
                          icon: Icons.monitor_heart,
                          color: Colors.deepOrange,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SystemSettingsPage(),
                            ),
                          ),
                        ),
                        _buildSectionCard(
                          title: 'Sensor Simulation',
                          icon: Icons.science,
                          color: Colors.purple,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Scaffold(
                                appBar: AppBar(
                                  title: const Text('Sensor Simulator'),
                                ),
                                body: const Center(
                                  child: Text('Sensor simulation running...'),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  buildSimulationControls(),
                  const SizedBox(height: 32),
                  AnimatedSensorInfo(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverviewCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 90,
        height: 90,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 36),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedSensorInfo extends StatefulWidget {
  @override
  State<AnimatedSensorInfo> createState() => _AnimatedSensorInfoState();
}

class _AnimatedSensorInfoState extends State<AnimatedSensorInfo> {
  final List<_SensorTip> tips = [
    _SensorTip(
      icon: Icons.water_drop,
      color: Colors.teal,
      title: 'Soil Moisture',
      text: 'Use a percentage (e.g., 20–80%), changes gradually.',
    ),
    _SensorTip(
      icon: Icons.thermostat,
      color: Colors.orange,
      title: 'Temperature (dht22)',
      text: 'Use °C, e.g., 15–35°C, small random drift.',
    ),
    _SensorTip(
      icon: Icons.cloud,
      color: Colors.blue,
      title: 'Humidity',
      text: 'Use %, e.g., 40–90%, changes slowly.',
    ),
    _SensorTip(
      icon: Icons.wb_sunny,
      color: Colors.yellow,
      title: 'Light (ldr)',
      text: 'Use lux, e.g., 100–1000, varies with time of day.',
    ),
    _SensorTip(
      icon: Icons.grain,
      color: Colors.indigo,
      title: 'Rain',
      text: 'Use 0 (no rain) or 1 (rain), changes rarely.',
    ),
  ];
  int _current = 0;
  late final PageController _controller;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _current = (_current + 1) % tips.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tip = tips[_current];
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(tip.icon, color: tip.color, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(tip.text, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
