import 'package:flutter/material.dart';

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

  void _showUserDialog({Map<String, dynamic>? user, bool viewOnly = false}) {
    showDialog(
      context: context,
      builder: (ctx) {
        final nameController = TextEditingController(text: user?['name'] ?? '');
        final emailController = TextEditingController(
          text: user?['email'] ?? '',
        );
        final farmIdController = TextEditingController(
          text: user?['farmId'] ?? '',
        );
        String status = user?['status'] ?? 'Active';
        String role = user?['role'] ?? 'Farmer';
        return AlertDialog(
          title: Text(
            viewOnly
                ? 'User Info'
                : user == null
                ? 'Add User'
                : 'Edit User',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  enabled: !viewOnly,
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  enabled: !viewOnly,
                ),
                TextField(
                  controller: farmIdController,
                  decoration: const InputDecoration(labelText: 'Farm ID'),
                  enabled: !viewOnly,
                ),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: ['Active', 'Inactive']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: viewOnly ? null : (v) => status = v ?? status,
                  disabledHint: Text(status),
                ),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: ['Farmer', 'Admin']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: viewOnly ? null : (v) => role = v ?? role,
                  disabledHint: Text(role),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
            if (!viewOnly)
              TextButton(
                onPressed: () {
                  setState(() {
                    if (user == null) {
                      users.add({
                        'name': nameController.text,
                        'email': emailController.text,
                        'farmId': farmIdController.text,
                        'status': status,
                        'role': role,
                      });
                    } else {
                      user['name'] = nameController.text;
                      user['email'] = emailController.text;
                      user['farmId'] = farmIdController.text;
                      user['status'] = status;
                      user['role'] = role;
                    }
                  });
                  Navigator.of(ctx).pop();
                },
                child: Text(user == null ? 'Add' : 'Save'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPage() {
    switch (selectedIndex) {
      case 0:
        return Center(child: Text('Dashboard'));
      case 1:
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'User Management',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.person_add),
                      label: const Text('Add New User'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22c55e),
                      ),
                      onPressed: () => _showUserDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Farm ID')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Role')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: users.map((user) {
                        return DataRow(
                          cells: [
                            DataCell(Text(user['name'])),
                            DataCell(Text(user['email'])),
                            DataCell(Text(user['farmId'])),
                            DataCell(Text(user['status'])),
                            DataCell(Text(user['role'])),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.visibility,
                                      color: Colors.blue,
                                    ),
                                    tooltip: 'View',
                                    onPressed: () => _showUserDialog(
                                      user: user,
                                      viewOnly: true,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.orange,
                                    ),
                                    tooltip: 'Edit',
                                    onPressed: () =>
                                        _showUserDialog(user: user),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Delete',
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Delete User'),
                                          content: const Text(
                                            'Are you sure you want to delete this user?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  users.remove(user);
                                                });
                                                Navigator.of(ctx).pop();
                                              },
                                              child: const Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      case 2:
        return Center(child: Text('Sensor Data'));
      case 3:
        return Center(child: Text('Irrigation Settings'));
      case 4:
        return Center(child: Text('Reports & Analytics'));
      case 5:
        return Center(child: Text('System Health'));
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
