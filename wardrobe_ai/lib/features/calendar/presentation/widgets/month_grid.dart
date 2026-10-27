import 'package:flutter/material.dart';

import '../../domain/logged_outfit.dart';

/// Month view with a dot under days that have a logged outfit.
class MonthGrid extends StatelessWidget {
  const MonthGrid({
    super.key,
    required this.month,
    required this.selected,
    required this.daysWithOutfits,
    required this.onSelect,
  });
  final DateTime month;
  final DateTime selected;
  final Set<DateTime> daysWithOutfits;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final blanks = monthLeadingBlanks(month);
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    final today = dateOnly(DateTime.now());

    return Column(children: [
      Row(children: [
        for (final d in const ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
          Expanded(
              child: Center(
                  child: Text(d, style: Theme.of(context).textTheme.labelMedium))),
      ]),
      const SizedBox(height: 6),
      GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (var i = 0; i < blanks; i++) const SizedBox.shrink(),
          for (var d = 1; d <= days; d++)
            Builder(builder: (_) {
              final date = DateTime(month.year, month.month, d);
              final has = daysWithOutfits.contains(date);
              final sel = date == selected;
              return Semantics(
                button: true,
                selected: sel,
                label: '$d${has ? ', outfit logged' : ''}${date == today ? ', today' : ''}',
                excludeSemantics: true,
                onTap: () => onSelect(date),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => onSelect(date),
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: sel ? cs.primary : null,
                      borderRadius: BorderRadius.circular(14),
                      border: date == today && !sel ? Border.all(color: cs.primary) : null,
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('$d',
                          style: TextStyle(
                              color: sel ? cs.onPrimary : null,
                              fontWeight: has ? FontWeight.w800 : FontWeight.w500)),
                      const SizedBox(height: 2),
                      Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: has ? (sel ? cs.onPrimary : cs.primary) : Colors.transparent,
                        ),
                      ),
                    ]),
                  ),
                ),
              );
            }),
        ],
      ),
    ]);
  }
}
