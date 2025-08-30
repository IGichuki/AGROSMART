import 'package:flutter/material.dart';
import 'user_management_page.dart';
import 'sensor_data_page.dart';
import 'irrigation_settings_page.dart';
import 'reports_analytics_page.dart';
import 'system_health_page.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int selectedIndex = 0;
  bool sidebarExpanded = true;

  final List<_SidebarItemData> sidebarItems = [
    _SidebarItemData('Dashboard', Icons.dashboard),
    _SidebarItemData('User Management', Icons.people),
    _SidebarItemData('Sensor Data', Icons.sensors),
    _SidebarItemData('Irrigation Settings', Icons.water),
    _SidebarItemData('Reports & Analytics', Icons.bar_chart),
    _SidebarItemData('System Health', Icons.health_and_safety),
    _SidebarItemData('Settings', Icons.settings),
  ];

  // Mock user data for User Management
  List<Map<String, dynamic>> users = [
    {
      'name': 'John Doe',
      'email': 'john@example.com',
      'farmId': 'FARM001',
      'status': 'Active',
      'role': 'Farmer',
    },
    {
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'farmId': 'FARM002',
      'status': 'Inactive',
      'role': 'Farmer',
    },
  ];

  // Removed unused and broken _showUserDialog function

  Widget _buildPage() {
    switch (selectedIndex) {
      case 0:
        return Center(child: Text('Dashboard'));
      case 1:
        return const UserManagementPage();
      case 2:
        return const SensorDataPage();
      case 3:
        return const IrrigationSettingsPage();
      case 4:
        return const ReportsAnalyticsPage();
      case 5:
        return const SystemHealthPage();
      case 6:
        return Center(child: Text('Settings'));
      default:
        return Center(child: Text('Page'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF6),
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: sidebarExpanded ? 210 : 64,
            decoration: const BoxDecoration(
              color: Color(0xFF1B5E20),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: Column(
              children: [
                // Add top padding to align with header
                const SizedBox(height: 64),
                // Logo
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: sidebarExpanded ? 12.0 : 0,
                  ),
                  child: sidebarExpanded
                      ? Row(
                          children: [
                            Image.asset('assets/agricon.jpg', height: 36),
                            const Padding(
                              padding: EdgeInsets.only(left: 12.0),
                              child: Text(
                                'AGROSMART',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Center(
                          child: Image.asset('assets/agricon.jpg', height: 36),
                        ),
                ),
                const SizedBox(height: 32),
                // Sidebar items
                ...List.generate(sidebarItems.length, (i) {
                  final item = sidebarItems[i];
                  return Material(
                    color: selectedIndex == i
                        ? Colors.white.withOpacity(0.08)
                        : Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(() => selectedIndex = i),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8,
                        ),
                        child: Row(
                          children: [
                            Icon(item.icon, color: Colors.white, size: 24),
                            if (sidebarExpanded)
                              Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Text(
                                  item.label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const Spacer(),
                // Logout button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () async {
                        // Sign out and go to login
                        try {
                          await Future.delayed(
                            const Duration(milliseconds: 100),
                          );
                          // If using FirebaseAuth:
                          // await FirebaseAuth.instance.signOut();
                        } catch (e) {}
                        if (mounted) {
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/login', (route) => false);
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Colors.red[200], size: 22),
                          if (sidebarExpanded)
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text(
                                'Logout',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Collapse/Expand button
                IconButton(
                  icon: Icon(
                    sidebarExpanded ? Icons.chevron_left : Icons.chevron_right,
                    color: Colors.white,
                  ),
                  onPressed: () =>
                      setState(() => sidebarExpanded = !sidebarExpanded),
                  tooltip: sidebarExpanded ? 'Collapse' : 'Expand',
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: SafeArea(
              child: Column(
                children: [
                  // Top bar
                  Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Spacer(),
                        // Notifications
                        IconButton(
                          icon: const Icon(
                            Icons.notifications,
                            color: Color(0xFF388E3C),
                          ),
                          onPressed: () {},
                          tooltip: 'Notifications',
                        ),
                        // Profile dropdown
                        PopupMenuButton<String>(
                          icon: const CircleAvatar(
                            backgroundColor: Color(0xFF22c55e),
                            child: Icon(
                              Icons.admin_panel_settings,
                              color: Colors.white,
                            ),
                          ),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'settings',
                              child: Text('Admin Settings'),
                            ),
                            const PopupMenuItem(
                              value: 'logout',
                              child: Text('Logout'),
                            ),
                          ],
                          onSelected: (value) {
                            // TODO: Implement actions
                          },
                        ),
                      ],
                    ),
                  ),
                  // Main page content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: _buildPage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItemData {
  final String label;
  final IconData icon;
  const _SidebarItemData(this.label, this.icon);
}
