import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- Placeholder widgets for missing sections ---

class _AccountSettingsSection extends StatelessWidget {
  const _AccountSettingsSection({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
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
                        SnackBar(
                          content: Text('Failed to send reset email: $e'),
                        ),
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
                title: Text(
                  'Language & Units',
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  'English, °C, % moisture',
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppSettingsSection extends StatelessWidget {
  const _AppSettingsSection({Key? key}) : super(key: key);
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
  const _SupportLegalSection({Key? key}) : super(key: key);
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
    // Debug print for UID
    // ignore: avoid_print
    print('Looking up user with UID: ${user.uid}');
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          // ignore: avoid_print
          print('Firestore error: \\${snapshot.error}');
          return Center(child: Text('Error: \\${snapshot.error}'));
        }
        // ignore: avoid_print
        print('Snapshot data: \\${snapshot.data}');
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('User data not found.'),
                const SizedBox(height: 8),
                Text(
                  'UID: ${user.uid}',
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ],
            ),
          );
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
  // Onion-specific irrigation thresholds for Kenyan counties/regions (FAO/KALRO best-practice)
  final Map<String, Map<String, dynamic>> countyThresholds = {
    'Kisumu': {
      'soilMoistureMin': 30,
      'soilMoistureMax': 50,
      'temperature': 22,
      'humidity': 70,
      'light': 9000,
      'rain': 160,
    },
    'Homa Bay': {
      'soilMoistureMin': 29,
      'soilMoistureMax': 49,
      'temperature': 22,
      'humidity': 68,
      'light': 8800,
      'rain': 155,
    },
    'Migori': {
      'soilMoistureMin': 30,
      'soilMoistureMax': 50,
      'temperature': 21,
      'humidity': 69,
      'light': 8900,
      'rain': 158,
    },
    'Siaya': {
      'soilMoistureMin': 28,
      'soilMoistureMax': 48,
      'temperature': 21,
      'humidity': 67,
      'light': 8700,
      'rain': 150,
    },
    'Kisii': {
      'soilMoistureMin': 31,
      'soilMoistureMax': 51,
      'temperature': 20,
      'humidity': 72,
      'light': 8500,
      'rain': 170,
    },
    'Nyamira': {
      'soilMoistureMin': 30,
      'soilMoistureMax': 50,
      'temperature': 20,
      'humidity': 71,
      'light': 8400,
      'rain': 165,
    },
    'Nakuru': {
      'soilMoistureMin': 25,
      'soilMoistureMax': 45,
      'temperature': 19,
      'humidity': 60,
      'light': 8000,
      'rain': 100,
    },
    'Kericho': {
      'soilMoistureMin': 27,
      'soilMoistureMax': 47,
      'temperature': 18,
      'humidity': 65,
      'light': 8100,
      'rain': 120,
    },
    'Bomet': {
      'soilMoistureMin': 26,
      'soilMoistureMax': 46,
      'temperature': 19,
      'humidity': 63,
      'light': 8050,
      'rain': 110,
    },
    'Nandi': {
      'soilMoistureMin': 28,
      'soilMoistureMax': 48,
      'temperature': 18,
      'humidity': 64,
      'light': 8200,
      'rain': 115,
    },
    'Uasin Gishu': {
      'soilMoistureMin': 24,
      'soilMoistureMax': 44,
      'temperature': 17,
      'humidity': 62,
      'light': 8000,
      'rain': 90,
    },
    'Trans Nzoia': {
      'soilMoistureMin': 25,
      'soilMoistureMax': 45,
      'temperature': 18,
      'humidity': 63,
      'light': 8100,
      'rain': 100,
    },
    'Kitui': {
      'soilMoistureMin': 15,
      'soilMoistureMax': 28,
      'temperature': 26,
      'humidity': 40,
      'light': 9500,
      'rain': 40,
    },
    'Machakos': {
      'soilMoistureMin': 17,
      'soilMoistureMax': 30,
      'temperature': 25,
      'humidity': 43,
      'light': 9400,
      'rain': 50,
    },
    'Makueni': {
      'soilMoistureMin': 16,
      'soilMoistureMax': 29,
      'temperature': 27,
      'humidity': 39,
      'light': 9600,
      'rain': 35,
    },
    'Embu': {
      'soilMoistureMin': 19,
      'soilMoistureMax': 33,
      'temperature': 24,
      'humidity': 45,
      'light': 9300,
      'rain': 60,
    },
    'Tharaka Nithi': {
      'soilMoistureMin': 18,
      'soilMoistureMax': 31,
      'temperature': 25,
      'humidity': 42,
      'light': 9350,
      'rain': 45,
    },
    'Mombasa': {
      'soilMoistureMin': 27,
      'soilMoistureMax': 42,
      'temperature': 27,
      'humidity': 75,
      'light': 10000,
      'rain': 180,
    },
    'Kilifi': {
      'soilMoistureMin': 25,
      'soilMoistureMax': 40,
      'temperature': 26,
      'humidity': 73,
      'light': 9900,
      'rain': 170,
    },
    'Kwale': {
      'soilMoistureMin': 26,
      'soilMoistureMax': 41,
      'temperature': 26,
      'humidity': 74,
      'light': 9950,
      'rain': 175,
    },
    'Lamu': {
      'soilMoistureMin': 24,
      'soilMoistureMax': 39,
      'temperature': 25,
      'humidity': 72,
      'light': 9800,
      'rain': 160,
    },
    'Garissa': {
      'soilMoistureMin': 8,
      'soilMoistureMax': 18,
      'temperature': 30,
      'humidity': 25,
      'light': 10500,
      'rain': 10,
    },
    'Wajir': {
      'soilMoistureMin': 7,
      'soilMoistureMax': 16,
      'temperature': 31,
      'humidity': 22,
      'light': 10600,
      'rain': 8,
    },
    'Mandera': {
      'soilMoistureMin': 6,
      'soilMoistureMax': 15,
      'temperature': 32,
      'humidity': 20,
      'light': 10700,
      'rain': 6,
    },
    'Marsabit': {
      'soilMoistureMin': 9,
      'soilMoistureMax': 19,
      'temperature': 29,
      'humidity': 27,
      'light': 10400,
      'rain': 12,
    },
    'Isiolo': {
      'soilMoistureMin': 10,
      'soilMoistureMax': 20,
      'temperature': 28,
      'humidity': 29,
      'light': 10300,
      'rain': 15,
    },
    'Nairobi': {
      'soilMoistureMin': 22,
      'soilMoistureMax': 36,
      'temperature': 21,
      'humidity': 55,
      'light': 8500,
      'rain': 80,
    },
    // Default for other counties (onion best-practice)
  };
  String? selectedCrop;
  String? selectedLocation;
  bool isLoadingLocation = true;
  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = doc.data();
    setState(() {
      selectedLocation = data?['location'] as String?;
      isLoadingLocation = false;
    });
  }

  Future<void> _saveLocation(String? location) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || location == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'location': location,
    });
  }

  final List<String> counties = [
    'Baringo',
    'Bomet',
    'Bungoma',
    'Busia',
    'Elgeyo Marakwet',
    'Embu',
    'Garissa',
    'Homa Bay',
    'Isiolo',
    'Kajiado',
    'Kakamega',
    'Kericho',
    'Kiambu',
    'Kilifi',
    'Kirinyaga',
    'Kisii',
    'Kisumu',
    'Kitui',
    'Kwale',
    'Laikipia',
    'Lamu',
    'Machakos',
    'Makueni',
    'Mandera',
    'Marsabit',
    'Meru',
    'Migori',
    'Mombasa',
    'Murang’a',
    'Nairobi',
    'Nakuru',
    'Nandi',
    'Narok',
    'Nyamira',
    'Nyandarua',
    'Nyeri',
    'Samburu',
    'Siaya',
    'Taita Taveta',
    'Tana River',
    'Tharaka Nithi',
    'Trans Nzoia',
    'Turkana',
    'Uasin Gishu',
    'Vihiga',
    'Wajir',
    'West Pokot',
  ];
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
            ListTile(
              leading: Icon(
                Icons.location_on_outlined,
                color: Color(0xFF22c55e),
              ),
              title: Text('Location', overflow: TextOverflow.ellipsis),
              subtitle: isLoadingLocation
                  ? const CircularProgressIndicator()
                  : DropdownButton<String>(
                      value: selectedLocation,
                      hint: const Text('Select your county'),
                      items: counties.map((county) {
                        return DropdownMenuItem<String>(
                          value: county,
                          child: Text(county),
                        );
                      }).toList(),
                      onChanged: (value) async {
                        setState(() {
                          selectedLocation = value;
                        });
                        await _saveLocation(value);
                      },
                    ),
            ),
            // Thresholds card removed as requested
          ],
        ),
      ),
    );
  }
}
