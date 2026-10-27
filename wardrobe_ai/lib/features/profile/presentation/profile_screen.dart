import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/outfit_log_writes.dart';
import '../../../core/database/providers.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../calendar/presentation/calendar_providers.dart';
import '../../wardrobe/presentation/wardrobe_providers.dart';

/// What the AI has learned from your ratings.
final tasteProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) {
  ref.watch(outfitLogsProvider); // refresh when ratings change
  return ref.read(appDatabaseProvider).feedbackSummary();
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _reset(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset to demo data?'),
        content: const Text('This deletes your wardrobe, photos and outfit history, then restores the demo wardrobe.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reset')),
        ],
      ),
    );
    if (ok != true) return;

    final db = ref.read(appDatabaseProvider);
    for (final i in await db.select(db.wardrobeItems).get()) {
      for (final p in [i.imagePath, i.cutoutPath]) {
        if (p != null) {
          try {
            await File(p).delete();
          } catch (_) {}
        }
      }
    }
    await db.delete(db.outfitLogs).go();
    await db.delete(db.wardrobeItems).go();
    await (await SharedPreferences.getInstance()).remove(AppConstants.seededPrefKey);
    await ref.read(seedServiceProvider).seedIfNeeded();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demo wardrobe restored.')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final mode = ref.watch(themeModeProvider);
    final items = ref.watch(wardrobeItemsProvider).valueOrNull ?? const [];
    final logs = ref.watch(outfitLogsProvider).valueOrNull ?? const [];
    final rated = logs.where((l) => l.log.rating != null).toList();
    final avg = rated.isEmpty
        ? '-'
        : (rated.map((l) => l.log.rating!).reduce((a, b) => a + b) / rated.length).toStringAsFixed(1);
    final taste = ref.watch(tasteProvider).valueOrNull;

    Widget stat(String v, String l) => Expanded(
          child: Semantics(
            label: '$l: $v',
            child: Column(children: [
              Text(v, style: t.textTheme.headlineMedium),
              Text(l, style: t.textTheme.labelMedium),
            ]),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text('Appearance', style: t.textTheme.titleMedium),
        const SizedBox(height: 10),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto), label: Text('System')),
            ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode), label: Text('Light')),
            ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode), label: Text('Dark')),
          ],
          selected: {mode},
          onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).set(s.first),
        ),
        const SizedBox(height: 28),
        Text('At a glance', style: t.textTheme.titleMedium),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(children: [
              stat('${items.length}', 'Items'),
              stat('${items.where((i) => i.isFavorite).length}', 'Favorites'),
              stat('${logs.length}', 'Outfits worn'),
              stat(avg, 'Avg rating'),
            ]),
          ),
        ),
        const SizedBox(height: 28),
        Text('Your taste', style: t.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(taste == null
            ? 'Loading…'
            : (taste['likedItemIds'] as List).isEmpty && (taste['dislikedItemIds'] as List).isEmpty
                ? 'Rate your outfits (4-5 stars to like, 1-2 to dislike) and recommendations will adapt.'
                : 'Liked ${(taste['likedItemIds'] as List).length} items, disliked ${(taste['dislikedItemIds'] as List).length}. '
                    'The AI uses this on every recommendation.'),
        const SizedBox(height: 20),
        Card(
          child: ListTile(
            minVerticalPadding: 14,
            leading: const Icon(Icons.luggage_outlined),
            title: const Text('Trip packing list'),
            subtitle: const Text('Build a packing list from your wardrobe'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/trip'),
          ),
        ),
        Card(
          child: ListTile(
            minVerticalPadding: 14,
            leading: Icon(Icons.restart_alt, color: t.colorScheme.error),
            title: const Text('Reset to demo data'),
            subtitle: const Text('Deletes your wardrobe and history'),
            onTap: () => _reset(context, ref),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'API keys in .env are for development only. In production, route AI and '
          'background-removal calls through your own backend.',
          style: t.textTheme.bodySmall,
        ),
      ]),
    );
  }
}
