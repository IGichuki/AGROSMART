import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_dashboard_screen.dart';

class ProfilePage extends StatefulWidget {
  final String lastName;
  const ProfilePage({super.key, required this.lastName});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int selectedSection = 0;
  bool sidebarExpanded = true;

  final List<_SidebarSection> sections = [
    _SidebarSection('User Info', Icons.person, 0),
    _SidebarSection('Farm Details', Icons.agriculture, 1),
    _SidebarSection('Account Settings', Icons.settings, 2),
    _SidebarSection('App Settings', Icons.devices_other, 3),
    _SidebarSection('Support & Legal', Icons.help_outline, 4),
  ];

  Widget _buildSectionContent() {
    switch (selectedSection) {
      case 0:
        return _UserInfoSection(lastName: widget.lastName);
      case 1:
        return _FarmDetailsSection();
      case 2:
        return _AccountSettingsSection();
      case 3:
        return _AppSettingsSection();
      case 4:
        return _SupportLegalSection();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return UserDashboardScaffold(
      lastName: widget.lastName,
      currentIndex: 4,
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: sidebarExpanded ? 180 : 60,
            decoration: BoxDecoration(
              color: const Color(0xFF22c55e),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                IconButton(
                  icon: Icon(
                    sidebarExpanded ? Icons.chevron_left : Icons.chevron_right,
                    color: Colors.white,
                  ),
                  onPressed: () =>
                      setState(() => sidebarExpanded = !sidebarExpanded),
                  tooltip: sidebarExpanded ? 'Collapse' : 'Expand',
                ),
                const SizedBox(height: 10),
                ...sections.map(
                  (section) => _SidebarItem(
                    icon: section.icon,
                    label: section.label,
                    expanded: sidebarExpanded,
                    selected: selectedSection == section.index,
                    onTap: () =>
                        setState(() => selectedSection = section.index),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _SidebarItem(
                    icon: Icons.logout,
                    label: 'Logout',
                    expanded: sidebarExpanded,
                    selected: false,
                    isLogout: true,
                    onTap: () {
                      // TODO: Implement logout logic
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text(
                            'Are you sure you want to logout?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.of(ctx).pop();
                                // Sign out from Firebase if available
                                try {
                                  await FirebaseAuth.instance.signOut();
                                } catch (e) {}
                                // Navigate to LoginScreen and clear stack
                                if (mounted) {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/login',
                                    (route) => false,
                                  );
                                }
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFFF9FDF9),
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: SingleChildScrollView(child: _buildSectionContent()),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarSection {
  final String label;
  final IconData icon;
  final int index;
  _SidebarSection(this.label, this.icon, this.index);
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool expanded;
  final bool selected;
  final bool isLogout;
  final VoidCallback onTap;
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.expanded,
    required this.selected,
    this.isLogout = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.white.withOpacity(0.15) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            children: [
              Icon(icon, color: isLogout ? Colors.red : Colors.white, size: 24),
              if (expanded)
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isLogout ? Colors.red : Colors.white,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 15,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Section widgets
class _UserInfoSection extends StatelessWidget {
  final String lastName;
  const _UserInfoSection({required this.lastName});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFF22c55e),
              child: const Icon(Icons.person, color: Colors.white, size: 44),
            ),
            const SizedBox(height: 18),
            Text(
              'John Doe',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'johndoe@email.com',
              style: TextStyle(color: Colors.grey[700]),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              'Last Name: $lastName',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _FarmDetailsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF22c55e),
                    child: const Icon(Icons.agriculture, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Farm Details',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Divider(height: 24),
            ListTile(
              leading: Icon(Icons.home_outlined, color: Color(0xFF22c55e)),
              title: Text('Farm Name', overflow: TextOverflow.ellipsis),
              subtitle: Text('Onion Farm', overflow: TextOverflow.ellipsis),
            ),
            ListTile(
              leading: Icon(
                Icons.location_on_outlined,
                color: Color(0xFF22c55e),
              ),
              title: Text('Location', overflow: TextOverflow.ellipsis),
              subtitle: Text('Nakuru, Kenya', overflow: TextOverflow.ellipsis),
            ),
            ListTile(
              leading: Icon(Icons.grass, color: Color(0xFF22c55e)),
              title: Text('Crop Type', overflow: TextOverflow.ellipsis),
              subtitle: Text('Onion', overflow: TextOverflow.ellipsis),
            ),
            SwitchListTile(
              value: true,
              onChanged: (v) {},
              title: Text('Notifications', overflow: TextOverflow.ellipsis),
              secondary: Icon(
                Icons.notifications_active_outlined,
                color: Color(0xFF22c55e),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountSettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF22c55e),
                    child: const Icon(Icons.settings, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Account Settings',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Divider(height: 24),
            ListTile(
              leading: Icon(Icons.lock_outline, color: Color(0xFF22c55e)),
              title: Text('Change Password', overflow: TextOverflow.ellipsis),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.email_outlined, color: Color(0xFF22c55e)),
              title: Text('Update Email', overflow: TextOverflow.ellipsis),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.language, color: Color(0xFF22c55e)),
              title: Text('Language & Units', overflow: TextOverflow.ellipsis),
              subtitle: Text(
                'English, °C, % moisture',
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {},
            ),
            SwitchListTile(
              value: false,
              onChanged: (v) {},
              title: Text('Dark Mode', overflow: TextOverflow.ellipsis),
              secondary: Icon(
                Icons.dark_mode_outlined,
                color: Color(0xFF22c55e),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppSettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.devices_other, color: Color(0xFF22c55e)),
                SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'App Settings',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ListTile(
              leading: Icon(Icons.sensors),
              title: Text('Connected Devices', overflow: TextOverflow.ellipsis),
              subtitle: Text(
                '2 sensors connected',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ListTile(
              leading: Icon(Icons.sync),
              title: Text('Data Sync Status', overflow: TextOverflow.ellipsis),
              subtitle: Text(
                'Last sync: 2 mins ago',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ListTile(
              leading: Icon(Icons.verified_user),
              title: Text('User Role', overflow: TextOverflow.ellipsis),
              subtitle: Text('Farmer', overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportLegalSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.help_outline, color: Color(0xFF22c55e)),
                SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'Support & Legal',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ListTile(
              leading: Icon(Icons.help_center_outlined),
              title: Text(
                'Help Center / FAQs',
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.support_agent),
              title: Text('Contact Support', overflow: TextOverflow.ellipsis),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.description_outlined),
              title: Text(
                'Terms & Conditions',
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.privacy_tip_outlined),
              title: Text('Privacy Policy', overflow: TextOverflow.ellipsis),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
