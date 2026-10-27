import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/color_utils.dart';
import 'wardrobe_providers.dart';

// Individual filter states (null = no filter).
final categoryFilterProvider = StateProvider<String?>((_) => null);
final colorFilterProvider = StateProvider<String?>((_) => null);
final seasonFilterProvider = StateProvider<String?>((_) => null);
final maxFormalityProvider = StateProvider<int?>((_) => null);
final favOnlyProvider = StateProvider<bool>((_) => false);
final queryProvider = StateProvider<String>((_) => '');

List<String> itemColors(WardrobeItem i) =>
    (jsonDecode(i.colors) as List).cast<String>();

/// Wardrobe items after search + filters are applied.
final filteredItemsProvider = Provider<AsyncValue<List<WardrobeItem>>>((ref) {
  final cat = ref.watch(categoryFilterProvider);
  final color = ref.watch(colorFilterProvider);
  final season = ref.watch(seasonFilterProvider);
  final maxF = ref.watch(maxFormalityProvider);
  final fav = ref.watch(favOnlyProvider);
  final q = ref.watch(queryProvider).trim().toLowerCase();

  return ref.watch(wardrobeItemsProvider).whenData((all) => all.where((i) {
        if (cat != null && i.category != cat) return false;
        if (fav && !i.isFavorite) return false;
        if (season != null && i.season != season && i.season != 'all') return false;
        if (maxF != null && i.formality > maxF) return false;
        if (color != null && !itemColors(i).any((h) => colorFamily(h) == color)) {
          return false;
        }
        if (q.isNotEmpty &&
            !'${i.name} ${i.fabric} ${i.pattern} ${i.category}'
                .toLowerCase()
                .contains(q)) {
          return false;
        }
        return true;
      }).toList());
});

class WardrobeStats {
  const WardrobeStats(this.mostWorn, this.neverWorn, this.colors);
  final List<WardrobeItem> mostWorn;
  final List<WardrobeItem> neverWorn;
  final Map<String, int> colors;
}

/// Most worn / never worn / colour breakdown across the whole wardrobe.
final statsProvider = Provider<AsyncValue<WardrobeStats>>((ref) {
  return ref.watch(wardrobeItemsProvider).whenData((all) {
    final worn = all.where((i) => i.wearCount > 0).toList()
      ..sort((a, b) => b.wearCount.compareTo(a.wearCount));
    final colors = <String, int>{};
    for (final i in all) {
      final c = itemColors(i);
      if (c.isNotEmpty) {
        colors.update(colorFamily(c.first), (v) => v + 1, ifAbsent: () => 1);
      }
    }
    final sorted = Map.fromEntries(
        colors.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
    return WardrobeStats(
        worn.take(3).toList(), all.where((i) => i.wearCount == 0).toList(), sorted);
  });
});
