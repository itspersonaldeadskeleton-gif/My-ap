import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'questionnaire_providers.dart';

/// "Plan" tab landing: starts a fresh questionnaire.
class PlanIntroScreen extends ConsumerWidget {
  const PlanIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Plan an outfit')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.auto_awesome, size: 40, color: t.colorScheme.primary),
              const SizedBox(height: 16),
              Text('What are you dressing for?', style: t.textTheme.headlineMedium),
              const SizedBox(height: 8),
              const Text('Answer a few quick questions about the occasion, weather and your mood. '
                  'We will use them to pick outfits from your wardrobe.'),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  ref.read(questionnaireProvider.notifier).reset();
                  context.push('/questionnaire');
                },
                child: const Text('Start'),
              ),
            ]),
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08),
      ),
    );
  }
}
