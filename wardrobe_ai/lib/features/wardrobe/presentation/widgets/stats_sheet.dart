import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/color_utils.dart';
import '../filters.dart';

/// Bottom sheet: most worn, never worn, colour breakdown.
class StatsSheet extends ConsumerWidget {
  const StatsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    return ref.watch(statsProvider).when(
          loading: () => const SizedBox(
              height: 200, child: Center(child: CircularProgressIndicator())),
          error: (_, __) => const SizedBox(
              height: 200, child: Center(child: Text('Could not load stats'))),
          data: (s) {
            final maxC = s.colors.values.fold<int>(1, (a, b) => b > a ? b : a);
            return ListView(padding: const EdgeInsets.all(20), shrinkWrap: true, children: [
              Text('Wardrobe stats', style: t.headlineSmall),
              const SizedBox(height: 16),
              Text('Most worn', style: t.titleMedium),
              if (s.mostWorn.isEmpty)
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Nothing worn yet. Wear counts start in Step 4.')),
              for (final i in s.mostWorn)
                ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(i.name),
                    trailing: Text('${i.wearCount}×')),
              const SizedBox(height: 12),
              Text('Never worn (${s.neverWorn.length})', style: t.titleMedium),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 4, children: [
                for (final i in s.neverWorn.take(12)) Chip(label: Text(i.name)),
              ]),
              const SizedBox(height: 16),
              Text('Colour breakdown', style: t.titleMedium),
              const SizedBox(height: 8),
              for (final e in s.colors.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    SizedBox(width: 64, child: Text(e.key)),
                    Expanded(
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: e.value / maxC,
                        child: Container(
                          height: 14,
                          decoration: BoxDecoration(
                            color: _swatch(e.key),
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(color: Colors.black26, width: .5),
                          ),
                        ),
                      ),
                    ),
                    Text(' ${e.value}'),
                  ]),
                ),
            ]);
          },
        );
  }

  Color _swatch(String family) => switch (family) {
        'black' => const Color(0xFF151515),
        'white' => const Color(0xFFF5F5F0),
        'grey' => const Color(0xFF8E9196),
        'beige' => const Color(0xFFD8C3A5),
        'brown' => const Color(0xFF5A3A25),
        'red' => const Color(0xFFB4442D),
        'orange' => const Color(0xFFE08A3C),
        'yellow' => const Color(0xFFE8C547),
        'green' => const Color(0xFF5E6B3F),
        'blue' => const Color(0xFF2E4A7A),
        'purple' => const Color(0xFF7A4E9E),
        _ => hexToColor('#E58AA8'),
      };
}
