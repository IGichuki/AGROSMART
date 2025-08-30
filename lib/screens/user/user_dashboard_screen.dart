import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x11000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SizedBox(height: 16),
                      Text(
                        'AGROSMART',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF22c55e),
                        ),
                      ),
                      Text(
                        'Onion Farm Monitor',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22c55e),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.wifi, color: Colors.white, size: 18),
                          SizedBox(width: 4),
                          Text(
                            'Connected',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.settings, color: Colors.grey, size: 22),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: currentIndex == 0
          ? SingleChildScrollView(child: Column(children: [body]))
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
