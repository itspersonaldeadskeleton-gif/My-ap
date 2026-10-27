import 'package:flutter/material.dart';

/// Animated progress bar with "Question x of y".
class StepProgress extends StatelessWidget {
  const StepProgress({super.key, required this.index, required this.total});
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Question ${index + 1} of $total',
        child: ExcludeSemantics(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Question ${index + 1} of $total',
                style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 6),
            TweenAnimationBuilder<double>(
              tween: Tween(end: (index + 1) / total),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ]),
        ),
      );
}
