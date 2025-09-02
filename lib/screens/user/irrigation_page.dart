import 'package:flutter/material.dart';
import 'user_dashboard_screen.dart';

class IrrigationPage extends StatelessWidget {
  final String lastName;
  final int navIndex;
  const IrrigationPage({super.key, required this.lastName, this.navIndex = 2});

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
              'Welcome to Irrigation',
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
                      'Irrigation Overview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Here you will see irrigation schedules, controls, and status.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Icon(Icons.opacity, size: 80, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
