import 'package:flutter/material.dart';

class ELearningScreen extends StatelessWidget {
  const ELearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('E-Learning Portal')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_rounded, size: 80, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            const Text('Blackboard / Moodle integration coming soon.', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
