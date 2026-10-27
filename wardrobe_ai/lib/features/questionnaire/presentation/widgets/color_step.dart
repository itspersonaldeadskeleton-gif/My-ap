import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../questionnaire_options.dart';
import '../questionnaire_providers.dart';

/// Pick colours to wear or avoid. A color can only be in one list.
class ColorStep extends ConsumerStatefulWidget {
  const ColorStep({super.key});
  @override
  ConsumerState<ColorStep> createState() => _ColorStepState();
}

class _ColorStepState extends ConsumerState<ColorStep> {
  bool _avoid = false;

  void _toggle(String name) {
    HapticFeedback.selectionClick();
    ref.read(questionnaireProvider.notifier).update((s) {
      final wear = [...s.colorsWear], avoid = [...s.colorsAvoid];
      final list = _avoid ? avoid : wear, other = _avoid ? wear : avoid;
      other.remove(name);
      list.contains(name) ? list.remove(name) : list.add(name);
      return s.copyWith(colorsWear: wear, colorsAvoid: avoid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final a = ref.watch(questionnaireProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SegmentedButton<bool>(
        segments: const [
          ButtonSegment(value: false, icon: Icon(Icons.check), label: Text('Wear')),
          ButtonSegment(value: true, icon: Icon(Icons.block), label: Text('Avoid')),
        ],
        selected: {_avoid},
        onSelectionChanged: (s) => setState(() => _avoid = s.first),
      ),
      const SizedBox(height: 20),
      Wrap(spacing: 14, runSpacing: 14, children: [
        for (final c in paletteOpts)
          Builder(builder: (_) {
            final wear = a.colorsWear.contains(c.name);
            final avoid = a.colorsAvoid.contains(c.name);
            return Semantics(
              button: true,
              label: '${c.name}${wear ? ', wearing' : avoid ? ', avoiding' : ''}',
              excludeSemantics: true,
              onTap: () => _toggle(c.name),
              child: GestureDetector(
                onTap: () => _toggle(c.name),
                child: SizedBox(
                  width: 64,
                  child: Column(children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: c.color, shape: BoxShape.circle,
                        border: Border.all(
                          color: wear ? Colors.green : avoid ? Colors.red : Colors.black26,
                          width: wear || avoid ? 3 : 1,
                        ),
                      ),
                      child: wear || avoid
                          ? Icon(wear ? Icons.check : Icons.block,
                              color: c.color.computeLuminance() > .5 ? Colors.black : Colors.white)
                          : null,
                    ),
                    const SizedBox(height: 4),
                    Text(c.name, style: Theme.of(context).textTheme.labelSmall),
                  ]),
                ),
              ),
            );
          }),
      ]),
    ]);
  }
}
