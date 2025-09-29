import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  final String lastName;
  const ProfilePage({super.key, required this.lastName});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 0;

  final List<Widget> _sections = [
    const _UserInfoSection(),
    _FarmDetailsSection(),
    _AccountSettingsSection(),
    _AppSettingsSection(),
    _SupportLegalSection(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.lastName}'),
        backgroundColor: const Color(0xFF22c55e),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/user-dashboard');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        try {
                          await FirebaseAuth.instance.signOut();
                        } catch (e) {}
                        if (mounted) {
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/login', (route) => false);
                        }
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _sections[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User Info'),
          BottomNavigationBarItem(
            icon: Icon(Icons.agriculture),
            label: 'Farm Details',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Account Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.devices_other),
            label: 'App Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            label: 'Support',
          ),
        ],
        selectedItemColor: const Color(0xFF22c55e),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}

class _UserInfoSection extends StatelessWidget {
  const _UserInfoSection();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('No user logged in.'));
    }
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('User data not found.'));
        }
        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final firstName = data?['firstName'] ?? '';
        final lastName = data?['lastName'] ?? '';
        final email = data?['email'] ?? user.email ?? '';
        final phone = data?['phone'] ?? '';
        return Center(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '$firstName $lastName',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    email,
                    style: TextStyle(color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (phone.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      phone,
                      style: TextStyle(color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FarmDetailsSection extends StatefulWidget {
  const _FarmDetailsSection({Key? key}) : super(key: key);

  @override
  State<_FarmDetailsSection> createState() => _FarmDetailsSectionState();
}

class _FarmDetailsSectionState extends State<_FarmDetailsSection> {
  String? selectedCrop;
  Future<List<String>> _fetchCrops() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('cropThresholds')
        .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

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
            FutureBuilder<List<String>>(
              future: _fetchCrops(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(
                    title: Text('Crop Type'),
                    subtitle: Text('Loading...'),
                  );
                } else if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return ListTile(
                    title: Text('Crop Type'),
                    subtitle: Text('No crops available'),
                  );
                } else {
                  return ListTile(
                    leading: Icon(Icons.grass, color: Color(0xFF22c55e)),
                    title: Text('Crop Type', overflow: TextOverflow.ellipsis),
                    subtitle: DropdownButton<String>(
                      value: selectedCrop ?? snapshot.data!.first,
                      items: snapshot.data!
                          .map(
                            (crop) => DropdownMenuItem(
                              value: crop,
                              child: Text(crop),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCrop = value;
                        });
                      },
                    ),
                  );
                }
              },
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
              onTap: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No user logged in.')),
                  );
                  return;
                }
                final email = user.email;
                if (email == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No email found for user.')),
                  );
                  return;
                }
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Change Password'),
                    content: const Text(
                      'Are you sure you want to change your password? An email will be sent to your address.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Yes'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: email,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Password reset email sent. Please check your inbox.',
                        ),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to send reset email: $e')),
                    );
                  }
                }
              },
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
