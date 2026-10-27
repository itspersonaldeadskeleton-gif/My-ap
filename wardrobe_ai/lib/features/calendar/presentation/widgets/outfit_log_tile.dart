import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/logged_outfit.dart';

/// One logged outfit: title, date, items, editable star rating, delete.
class OutfitLogTile extends StatelessWidget {
  const OutfitLogTile({
    super.key,
    required this.entry,
    required this.itemNames,
    required this.onRate,
    required this.onDelete,
    this.showDate = true,
  });
  final LoggedOutfit entry;
  final String itemNames;
  final ValueChanged<int> onRate;
  final VoidCallback onDelete;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final r = entry.log.rating ?? 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 4, 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (showDate)
                  Text(DateFormat.yMMMEd().format(entry.log.date),
                      style: t.textTheme.labelMedium?.copyWith(color: t.colorScheme.primary)),
                Text(entry.title, style: t.textTheme.titleMedium),
              ]),
            ),
            IconButton(
              tooltip: 'Delete this entry',
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
          ]),
          if (entry.log.occasion.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Chip(
                label: Text(entry.log.occasion),
                visualDensity: VisualDensity.compact,
              ),
            ),
          if (itemNames.isNotEmpty) Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text(itemNames, style: t.textTheme.bodySmall),
          ),
          Row(children: [
            for (var s = 1; s <= 5; s++)
              IconButton(
                tooltip: 'Rate $s star${s == 1 ? '' : 's'}',
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                onPressed: () => onRate(s),
                icon: Icon(s <= r ? Icons.star : Icons.star_border, color: t.colorScheme.primary),
              ),
          ]),
        ]),
      ),
    );
  }
}
