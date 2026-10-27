import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/providers.dart';
import 'filters.dart';
import 'widgets/item_card.dart';
import 'widgets/stats_sheet.dart';

/// Wardrobe grid with search, category chips, filter sheet and stats.
class WardrobeScreen extends ConsumerWidget {
  const WardrobeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(filteredItemsProvider);
    final cat = ref.watch(categoryFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Wardrobe'),
        actions: [
          IconButton(
            tooltip: 'Wardrobe stats',
            icon: const Icon(Icons.insights_outlined),
            onPressed: () => showModalBottomSheet(
                context: context, isScrollControlled: true, showDragHandle: true,
                builder: (_) => const StatsSheet()),
          ),
          IconButton(
            tooltip: 'Filters',
            icon: const Icon(Icons.tune),
            onPressed: () => showModalBottomSheet(
                context: context, isScrollControlled: true, showDragHandle: true,
                builder: (_) => const _FilterSheet()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add'),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Add item'),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: TextField(
            onChanged: (v) => ref.read(queryProvider.notifier).state = v,
            decoration: InputDecoration(
              hintText: 'Search name, fabric, pattern…',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
        ),
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (final c in [null, ...AppConstants.categories])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c ?? 'All'),
                    selected: cat == c,
                    onSelected: (_) =>
                        ref.read(categoryFilterProvider.notifier).state = c,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: items.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                const Text('Could not load your wardrobe.'),
                const SizedBox(height: 12),
                FilledButton(
                    onPressed: () => ref.invalidate(filteredItemsProvider),
                    child: const Text('Retry')),
              ]),
            ),
            data: (list) => list.isEmpty
                ? Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Text('No items match your filters.'),
                      TextButton(
                        onPressed: () {
                          ref.read(categoryFilterProvider.notifier).state = null;
                          ref.read(colorFilterProvider.notifier).state = null;
                          ref.read(seasonFilterProvider.notifier).state = null;
                          ref.read(maxFormalityProvider.notifier).state = null;
                          ref.read(favOnlyProvider.notifier).state = false;
                          ref.read(queryProvider.notifier).state = '';
                        },
                        child: const Text('Clear filters'),
                      ),
                    ]),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, mainAxisSpacing: 14,
                      crossAxisSpacing: 14, childAspectRatio: 0.8,
                    ),
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final item = list[i];
                      return ItemCard(
                        item: item,
                        onTap: () => context.push('/add', extra: item), // edit tags
                        onFavorite: () {
                          HapticFeedback.selectionClick();
                          ref.read(appDatabaseProvider)
                              .toggleFavorite(item.id, !item.isFavorite);
                        },
                      )
                          .animate(delay: (40 * (i % 10)).ms)
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.06, curve: Curves.easeOut);
                    },
                  ),
          ),
        ),
      ]),
    );
  }
}

class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = ref.watch(colorFilterProvider);
    final season = ref.watch(seasonFilterProvider);
    final maxF = ref.watch(maxFormalityProvider);
    final fav = ref.watch(favOnlyProvider);
    final t = Theme.of(context).textTheme;

    return ListView(padding: const EdgeInsets.all(20), shrinkWrap: true, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Filters', style: t.headlineSmall),
        TextButton(
          onPressed: () {
            ref.read(colorFilterProvider.notifier).state = null;
            ref.read(seasonFilterProvider.notifier).state = null;
            ref.read(maxFormalityProvider.notifier).state = null;
            ref.read(favOnlyProvider.notifier).state = false;
            ref.read(categoryFilterProvider.notifier).state = null;
          },
          child: const Text('Clear all'),
        ),
      ]),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Favorites only'),
        value: fav,
        onChanged: (v) => ref.read(favOnlyProvider.notifier).state = v,
      ),
      Text('Colour', style: t.titleSmall),
      Wrap(spacing: 8, children: [
        for (final c in colorFamilies)
          ChoiceChip(
            label: Text(c), selected: color == c,
            onSelected: (v) => ref.read(colorFilterProvider.notifier).state = v ? c : null,
          ),
      ]),
      const SizedBox(height: 12),
      Text('Season', style: t.titleSmall),
      Wrap(spacing: 8, children: [
        for (final s in AppConstants.seasons.skip(1))
          ChoiceChip(
            label: Text(s), selected: season == s,
            onSelected: (v) => ref.read(seasonFilterProvider.notifier).state = v ? s : null,
          ),
      ]),
      const SizedBox(height: 12),
      Text('Max formality: ${maxF ?? 5}', style: t.titleSmall),
      Slider(
        min: 1, max: 5, divisions: 4, value: (maxF ?? 5).toDouble(),
        onChanged: (v) =>
            ref.read(maxFormalityProvider.notifier).state = v.round() == 5 ? null : v.round(),
      ),
    ]);
  }
}
