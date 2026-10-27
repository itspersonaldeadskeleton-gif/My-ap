import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/database/outfit_log_writes.dart';
import '../../../core/database/providers.dart';
import '../../wardrobe/presentation/wardrobe_providers.dart';
import '../domain/logged_outfit.dart';
import 'calendar_providers.dart';
import 'widgets/month_grid.dart';
import 'widgets/outfit_log_tile.dart';

/// Outfit calendar + wear history (tabs). Ratings can be edited here too.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});
  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selected = dateOnly(DateTime.now());

  String _names(LoggedOutfit e, Map<int, String> byId) =>
      e.itemIds.map((i) => byId[i]).whereType<String>().join(' · ');

  Future<void> _delete(LoggedOutfit e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete this entry?'),
        content: const Text('Wear counts already added are not rolled back.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) await ref.read(appDatabaseProvider).deleteLog(e.log.id);
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(outfitLogsProvider);
    final wardrobe = ref.watch(wardrobeItemsProvider).valueOrNull ?? const [];
    final byId = {for (final i in wardrobe) i.id: i.name};
    final db = ref.read(appDatabaseProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Calendar'),
          bottom: const TabBar(tabs: [Tab(text: 'Calendar'), Tab(text: 'History')]),
        ),
        body: logs.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Could not load your outfit history.'),
              const SizedBox(height: 12),
              FilledButton(
                  onPressed: () => ref.invalidate(outfitLogsProvider),
                  child: const Text('Retry')),
            ]),
          ),
          data: (list) {
            final days = {for (final e in list) dateOnly(e.log.date)};
            final onDay = list.where((e) => dateOnly(e.log.date) == _selected).toList();
            return TabBarView(children: [
              // ---- Calendar tab ----
              ListView(padding: const EdgeInsets.all(16), children: [
                Row(children: [
                  IconButton(
                    tooltip: 'Previous month',
                    onPressed: () => setState(() => _month = DateTime(_month.year, _month.month - 1)),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Text(DateFormat.yMMMM().format(_month),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge),
                  ),
                  IconButton(
                    tooltip: 'Next month',
                    onPressed: () => setState(() => _month = DateTime(_month.year, _month.month + 1)),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ]),
                MonthGrid(
                  month: _month,
                  selected: _selected,
                  daysWithOutfits: days,
                  onSelect: (d) => setState(() => _selected = d),
                ),
                const SizedBox(height: 12),
                Text(DateFormat.yMMMMEEEEd().format(_selected),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (onDay.isEmpty)
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Nothing logged on this day.'),
                    TextButton.icon(
                      onPressed: () => context.go('/plan'),
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Plan an outfit'),
                    ),
                  ])
                else
                  for (final e in onDay)
                    OutfitLogTile(
                      entry: e,
                      showDate: false,
                      itemNames: _names(e, byId),
                      onRate: (r) => db.rateOutfit(e.log.id, r),
                      onDelete: () => _delete(e),
                    ),
              ]),
              // ---- History tab ----
              list.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                            'No outfits logged yet. Tap "Wear this" on a recommendation to start your history.',
                            textAlign: TextAlign.center),
                      ),
                    )
                  : ListView(padding: const EdgeInsets.all(16), children: [
                      for (final e in list)
                        OutfitLogTile(
                          entry: e,
                          itemNames: _names(e, byId),
                          onRate: (r) => db.rateOutfit(e.log.id, r),
                          onDelete: () => _delete(e),
                        ),
                    ]),
            ]);
          },
        ),
      ),
    );
  }
}
