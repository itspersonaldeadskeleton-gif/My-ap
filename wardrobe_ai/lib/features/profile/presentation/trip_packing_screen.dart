import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../wardrobe/presentation/wardrobe_providers.dart';
import '../../wardrobe/presentation/widgets/item_thumb.dart';
import '../domain/packing_list.dart';

/// Trip packing list built from your wardrobe. Check items off as you pack.
class TripPackingScreen extends ConsumerStatefulWidget {
  const TripPackingScreen({super.key});
  @override
  ConsumerState<TripPackingScreen> createState() => _TripPackingScreenState();
}

class _TripPackingScreenState extends ConsumerState<TripPackingScreen> {
  double _days = 5;
  String _climate = 'Mild';
  TripStyle _style = TripStyle.mixed;
  final _checked = <String>{};

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(wardrobeItemsProvider).valueOrNull ?? const [];
    final list = PackingListBuilder.build(
        items: items, days: _days.round(), climate: _climate, style: _style);
    final t = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip packing list'),
        actions: [
          IconButton(
            tooltip: 'Share list',
            icon: const Icon(Icons.ios_share),
            onPressed: () => Share.share(list.toText(_days.round(), _climate)),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text('Trip length: ${_days.round()} day${_days.round() == 1 ? '' : 's'}', style: t.textTheme.titleSmall),
        Slider(
          min: 1, max: 14, divisions: 13, value: _days,
          label: '${_days.round()}',
          onChanged: (v) => setState(() => _days = v),
        ),
        Text('Climate', style: t.textTheme.titleSmall),
        const SizedBox(height: 6),
        Wrap(spacing: 8, children: [
          for (final c in const ['Hot', 'Mild', 'Cool', 'Cold', 'Rainy'])
            ChoiceChip(label: Text(c), selected: _climate == c, onSelected: (_) => setState(() => _climate = c)),
        ]),
        const SizedBox(height: 14),
        Text('Trip style', style: t.textTheme.titleSmall),
        const SizedBox(height: 6),
        Wrap(spacing: 8, children: [
          for (final s in TripStyle.values)
            ChoiceChip(
              label: Text(s.name[0].toUpperCase() + s.name.substring(1)),
              selected: _style == s,
              onSelected: (_) => setState(() => _style = s),
            ),
        ]),
        const SizedBox(height: 16),
        if (list.sections.isEmpty)
          const Text('Add some clothes to your wardrobe to build a packing list.'),
        for (final e in list.sections.entries) ...[
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text('${e.key} (${e.value.length})', style: t.textTheme.titleMedium),
          ),
          for (final i in e.value)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _checked.contains('i-${i.id}'),
              onChanged: (v) => setState(() => v == true ? _checked.add('i-${i.id}') : _checked.remove('i-${i.id}')),
              secondary: SizedBox(
                width: 44, height: 44,
                child: ClipRRect(borderRadius: BorderRadius.circular(10), child: ItemThumb(item: i)),
              ),
              title: Text(i.name),
              subtitle: Text('${i.fabric} · formality ${i.formality}'),
            ),
        ],
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 4),
          child: Text('Essentials', style: t.textTheme.titleMedium),
        ),
        for (final e in list.essentials)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _checked.contains('e-$e'),
            onChanged: (v) => setState(() => v == true ? _checked.add('e-$e') : _checked.remove('e-$e')),
            title: Text(e),
          ),
      ]),
    );
  }
}
