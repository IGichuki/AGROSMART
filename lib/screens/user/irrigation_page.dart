import 'package:flutter/material.dart';
import 'user_dashboard_screen.dart';

class IrrigationPage extends StatelessWidget {
  final String lastName;
  const IrrigationPage({super.key, required this.lastName});

  @override
  Widget build(BuildContext context) {
    return UserDashboardScaffold(
      lastName: lastName,
      body: const Center(
        child: Text(
          'You are in Irrigation page',
          style: TextStyle(fontSize: 22),
        ),
      ),
      currentIndex: 2,
    );
  }
}
