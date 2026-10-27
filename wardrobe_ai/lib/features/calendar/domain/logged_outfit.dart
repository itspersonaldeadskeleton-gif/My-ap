import 'dart:convert';

import '../../../core/database/app_database.dart';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Blank cells before the 1st so weeks start on Sunday (unit-tested).
int monthLeadingBlanks(DateTime month) =>
    DateTime(month.year, month.month, 1).weekday % 7;

/// An [OutfitLog] row with its JSON payload decoded.
class LoggedOutfit {
  const LoggedOutfit(this.log, this.title, this.itemIds);
  final OutfitLog log;
  final String title;
  final List<int> itemIds;

  factory LoggedOutfit.from(OutfitLog log) {
    try {
      final m = jsonDecode(log.outfitJson) as Map;
      final t = (m['title'] as String?)?.trim() ?? '';
      final label = switch (m['label']) {
        'best_match' => 'Best Match',
        'safe_choice' => 'Safe Choice',
        'bold_choice' => 'Bold Choice',
        _ => 'Outfit',
      };
      final ids = ((m['itemIds'] as List?) ?? const []).map((e) => (e as num).toInt()).toList();
      return LoggedOutfit(log, t.isEmpty ? label : t, ids);
    } catch (_) {
      return LoggedOutfit(log, 'Outfit', const []);
    }
  }
}
