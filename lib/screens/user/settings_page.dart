import 'package:flutter/material.dart';
import 'user_dashboard_screen.dart';

class SettingsPage extends StatelessWidget {
  final String lastName;
  final int navIndex;
  const SettingsPage({super.key, required this.lastName, this.navIndex = 3});

  @override
  Widget build(BuildContext context) {
    return UserDashboardScaffold(
      lastName: lastName,
      currentIndex: navIndex,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Welcome to Settings',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: const [
                    Text(
                      'Settings Overview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Here you will be able to adjust your preferences and account settings.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Icon(Icons.settings, size: 80, color: Colors.orange),
          ],
        ),
      ),
    );
  }
}
