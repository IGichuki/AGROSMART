import 'package:flutter/material.dart';

class SystemHealthPage extends StatelessWidget {
  const SystemHealthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('System Health')),
      body: const Center(child: Text('System Health Content')),
    );
  }
}
