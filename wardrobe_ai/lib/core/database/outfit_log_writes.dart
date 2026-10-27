import 'dart:convert';

import 'package:drift/drift.dart';

import 'app_database.dart';

extension OutfitLogWrites on AppDatabase {
  /// Saves "I wore this", bumps each item's wear count and returns the log id.
  Future<int> logOutfit({
    required String occasion,
    required String outfitJson,
    required List<int> itemIds,
  }) async {
    final logId = await into(outfitLogs).insert(OutfitLogsCompanion.insert(
      date: DateTime.now(),
      outfitJson: outfitJson,
      occasion: Value(occasion),
    ));
    for (final id in itemIds) {
      await customUpdate(
        'UPDATE wardrobe_items SET wear_count = wear_count + 1 WHERE id = ?',
        variables: [Variable.withInt(id)],
        updates: {wardrobeItems},
      );
    }
    return logId;
  }

  /// 1-5 stars; feeds [feedbackSummary] for personalization.
  Future<void> rateOutfit(int logId, int rating) =>
      (update(outfitLogs)..where((t) => t.id.equals(logId)))
          .write(OutfitLogsCompanion(rating: Value(rating)));

  /// Items from recently rated outfits, used to personalize the LLM prompt.
  Future<Map<String, dynamic>> feedbackSummary() async {
    final rows = await (select(outfitLogs)
          ..where((t) => t.rating.isNotNull())
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(20))
        .get();
    final liked = <int>{}, disliked = <int>{};
    for (final r in rows) {
      try {
        final ids = ((jsonDecode(r.outfitJson) as Map)['itemIds'] as List)
            .map((e) => (e as num).toInt());
        if (r.rating! >= 4) liked.addAll(ids);
        if (r.rating! <= 2) disliked.addAll(ids);
      } catch (_) {}
    }
    return {'likedItemIds': liked.toList(), 'dislikedItemIds': disliked.toList()};
  }

  /// All logged outfits, newest first (calendar + history).
  Stream<List<OutfitLog>> watchLogs() =>
      (select(outfitLogs)..orderBy([(t) => OrderingTerm.desc(t.date)])).watch();

  Future<void> deleteLog(int id) =>
      (delete(outfitLogs)..where((t) => t.id.equals(id))).go();
}
