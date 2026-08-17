import 'package:flutter/material.dart';

class ProblemPage extends StatelessWidget {
  const ProblemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report a Problem'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What issue are you facing?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // Your input boxes and data collection widgets go here!
            Text('Design your Figma input fields here.'),
          ],
        ),
      ),
    );
  }
}
