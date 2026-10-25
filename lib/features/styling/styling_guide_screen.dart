import 'package:flutter/material.dart';

class StylingGuideScreen extends StatefulWidget {
  const StylingGuideScreen({super.key});

  @override
  State<StylingGuideScreen> createState() => _StylingGuideScreen_State();
}

class _StylingGuideScreen_State extends State<StylingGuideScreen> {
  final List<bool> _checked = [false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Styling Guide')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Get Ready With Me',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...List.generate(_checked.length, (i) {
            return CheckboxListTile(
              value: _checked[i],
              title: Text('Step ${i + 1}'),
              subtitle: const Text('Thumbnail placeholder'),
              secondary: Container(
                width: 56,
                height: 56,
                color: Colors.grey[300],
                child: const Icon(Icons.image, color: Colors.grey)),
              );
          }),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Get Ready With Me'),
          ),
        ],
      ),
    );
  }
}