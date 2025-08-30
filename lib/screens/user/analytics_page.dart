import 'package:flutter/material.dart';
import 'user_dashboard_screen.dart';

class AnalyticsPage extends StatelessWidget {
  final String lastName;
  final int navIndex;
  const AnalyticsPage({super.key, required this.lastName, this.navIndex = 1});

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
              'Welcome to Analytics',
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
                      'Analytics Overview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Here you will see farm analytics, charts, and reports.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Icon(Icons.bar_chart, size: 80, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
