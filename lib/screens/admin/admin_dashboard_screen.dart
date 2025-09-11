import 'package:agrosmart/screens/admin/user_management_page.dart';
import 'package:agrosmart/screens/admin/irrigation_settings_page.dart';
import 'package:agrosmart/screens/admin/system_health_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  Future<Map<String, int>> fetchDashboardData() async {
    final firestore = FirebaseFirestore.instance;
    final usersSnapshot = await firestore.collection('users').get();
    final sensorsSnapshot = await firestore.collection('sensors').get();
    final reportsSnapshot = await firestore.collection('reports').get();

    return {
      'users': usersSnapshot.size,
      'sensors': sensorsSnapshot.size,
      'reports': reportsSnapshot.size,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Admin Dashboard'),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                // Add your reload logic here
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminDashboardScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF43cea2),
              Color(0xFF185a9d),
            ], // Updated gradient to match LoginScreen
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<Map<String, int>>(
            future: fetchDashboardData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error loading data'));
              } else if (snapshot.hasData) {
                final data = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Dashboard',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.5),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildOverviewCard(
                            'Users',
                            data['users'].toString(),
                            Icons.people,
                            Colors.blue,
                          ),
                          _buildOverviewCard(
                            'Sensors',
                            data['sensors'].toString(),
                            Icons.sensors,
                            Colors.teal, // Adjusted color
                          ),
                          _buildOverviewCard(
                            'Reports',
                            data['reports'].toString(),
                            Icons.bar_chart,
                            Colors.orange,
                          ),
                        ],
                      ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.5),
                      const SizedBox(height: 32),
                      Text(
                        'Sections',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87, // Neutral text color
                        ),
                      ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.5),
                      const SizedBox(height: 16),
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            _buildSectionCard(
                              context,
                              title: 'User Management',
                              icon: Icons.people,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const UserManagementPage(),
                                ),
                              ),
                            ),
                            _buildSectionCard(
                              context,
                              title: 'Sensor Data',
                              icon: Icons.sensors,
                              onTap: () =>
                                  Navigator.pushNamed(context, '/sensor-data'),
                            ),
                            _buildSectionCard(
                              context,
                              title: 'Irrigation Settings',
                              icon: Icons.water,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const IrrigationSettingsPage(),
                                ),
                              ),
                            ),
                            _buildSectionCard(
                              context,
                              title: 'Reports & Analytics',
                              icon: Icons.bar_chart,
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/reports-analytics',
                              ),
                            ),
                            _buildSectionCard(
                              context,
                              title: 'System Settings',
                              icon: Icons.settings,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SystemSettingsPage(),
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.5),
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(child: Text('No data available'));
              }
            },
          ),
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
    return Expanded(
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ).animate().scale(duration: 300.ms),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 50, color: Theme.of(context).primaryColor),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
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
