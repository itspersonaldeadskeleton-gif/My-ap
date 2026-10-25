import 'package:flutter/material.dart';

class StyleScreen extends StatelessWidget {
  const StyleScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Style My Day')),
      body: const Center(child: Text('Style')),
    );
  }
}
