import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../widgets/weather_widget.dart';

// A reusable scaffold for all user dashboard pages, with consistent header and bottom nav.
class UserDashboardScaffold extends StatelessWidget {
  final String lastName;
  final Widget body;
  final int
  currentIndex; // 0:dashboard, 1:analytics, 2:irrigation, 3:settings, 4:profile
  UserDashboardScaffold({
    Key? key,
    required this.lastName,
    required this.body,
    required this.currentIndex,
  }) : super(key: key);

  void _onNavTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    final args = {'lastName': lastName, 'navIndex': index};
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(
          context,
          '/user-dashboard',
          arguments: args,
        );
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/analytics', arguments: args);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/irrigation', arguments: args);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/settings', arguments: args);
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile', arguments: args);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FDF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF22c55e),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(
                FontAwesomeIcons.droplet,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'AGROSMART',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF22c55e),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF22c55e)),
            tooltip: 'Logout',
            onPressed: () async {
              // If using Firebase Auth
              // await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: currentIndex == 0
          ? RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Text(
                      lastName.isNotEmpty ? 'Welcome $lastName' : 'Welcome!',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: WeatherWidget(),
                  ),
                  Expanded(child: body),
                  AnimatedSensorInfo(),
                ],
              ),
            )
          : body,
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _NavButton(
                icon: Icons.dashboard,
                label: 'Dashboard',
                isActive: currentIndex == 0,
                onTap: () => _onNavTap(context, 0),
              ),
            ),
            Expanded(
              child: _NavButton(
                icon: Icons.bar_chart,
                label: 'Analytics',
                isActive: currentIndex == 1,
                onTap: () => _onNavTap(context, 1),
              ),
            ),
            Expanded(
              child: _NavButton(
                icon: Icons.opacity,
                label: 'Irrigation',
                isActive: currentIndex == 2,
                onTap: () => _onNavTap(context, 2),
              ),
            ),
            Expanded(
              child: _NavButton(
                icon: Icons.settings,
                label: 'Settings',
                isActive: currentIndex == 3,
                onTap: () => _onNavTap(context, 3),
              ),
            ),
            Expanded(
              child: _NavButton(
                icon: Icons.person,
                label: 'Profile',
                isActive: currentIndex == 4,
                onTap: () => _onNavTap(context, 4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _NavButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0x1A22c55e) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? const Color(0xFF22c55e) : Colors.grey),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFF22c55e) : Colors.grey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Animated info section for user dashboard
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
      text:
          'Displayed as a percentage (e.g., 20%–80%). Values change gradually to reflect real soil conditions.',
    ),
    _SensorTip(
      icon: Icons.thermostat,
      color: Colors.orange,
      title: 'Temperature (DHT22)',
      text:
          'Shown in °C, typically 15°C–35°C. Small random fluctuations make readings realistic.',
    ),
    _SensorTip(
      icon: Icons.cloud,
      color: Colors.blue,
      title: 'Humidity',
      text:
          'Presented as a percentage (e.g., 40%–90%). Changes are slow and steady.',
    ),
    _SensorTip(
      icon: Icons.wb_sunny,
      color: Colors.yellow[700]!,
      title: 'Light (LDR)',
      text:
          'Indicated in lux (e.g., 100–1000 lux). Values vary according to the time of day.',
    ),
    _SensorTip(
      icon: Icons.grain,
      color: Colors.indigo,
      title: 'Rain',
      text: '0 means no rain, 1 means rain. This value changes infrequently.',
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
        _controller.animateToPage(
          _current,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.green.withOpacity(0.08), blurRadius: 8),
        ],
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.16,
        child: PageView.builder(
          controller: _controller,
          itemCount: tips.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, i) {
            final tip = tips[i];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: tip.color.withOpacity(0.18),
                  child: Icon(tip.icon, color: tip.color, size: 32),
                  radius: 32,
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tip.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: tip.color,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        tip.text,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

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
