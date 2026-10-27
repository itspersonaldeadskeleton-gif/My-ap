import 'package:flutter/material.dart';

/// Placeholder body for features built in later steps.
class ComingSoon extends StatelessWidget {
  const ComingSoon({super.key, required this.title, required this.step, required this.icon});
  final String title;
  final String step;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Semantics(
          label: '$title arrives in $step',
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 56, color: t.colorScheme.primary),
            const SizedBox(height: 16),
            Text('Coming in $step', style: t.textTheme.titleMedium),
          ]),
        ),
      ),
    );
  }
}
