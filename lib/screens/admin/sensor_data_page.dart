import 'package:flutter/material.dart';

class SensorDataPage extends StatelessWidget {
  const SensorDataPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sensor Data')),
      body: const Center(child: Text('Sensor Data Content')),
    );
  }
}
