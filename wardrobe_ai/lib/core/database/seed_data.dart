import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import 'app_database.dart';

/// Inserts a demo wardrobe on first launch so every screen has data.
class SeedService {
  SeedService(this._db);
  final AppDatabase _db;

  Future<void> seedIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(AppConstants.seededPrefKey) == true) return;
    if (await _db.itemCount() > 0) return;

    for (final d in _demo) {
      await _db.insertItem(WardrobeItemsCompanion.insert(
        name: d.$1,
        category: d.$2,
        colors: Value(jsonEncode([d.$3])),
        pattern: Value(d.$4),
        fabric: Value(d.$5),
        fit: Value(d.$6),
        formality: Value(d.$7),
        season: Value(d.$8),
      ));
    }
    await prefs.setBool(AppConstants.seededPrefKey, true);
  }

  // name, category, hex, pattern, fabric, fit, formality, season
  static const _demo = <(String, String, String, String, String, String, int, String)>[
    ('White Oxford Shirt', 'top', '#F5F5F0', 'solid', 'cotton', 'regular', 3, 'all'),
    ('Grey Crewneck Knit', 'top', '#8E9196', 'solid', 'wool', 'relaxed', 2, 'winter'),
    ('Navy Chinos', 'bottom', '#1F2A44', 'solid', 'cotton twill', 'slim', 3, 'all'),
    ('Indigo Straight Jeans', 'bottom', '#2E4A7A', 'solid', 'denim', 'straight', 2, 'all'),
    ('Camel Overcoat', 'outerwear', '#B98B5A', 'solid', 'wool', 'tailored', 4, 'winter'),
    ('Olive Bomber Jacket', 'outerwear', '#5E6B3F', 'solid', 'nylon', 'regular', 1, 'autumn'),
    ('White Leather Sneakers', 'shoes', '#FAFAFA', 'solid', 'leather', 'regular', 2, 'all'),
    ('Brown Chelsea Boots', 'shoes', '#5A3A25', 'solid', 'suede', 'regular', 4, 'autumn'),
    ('Black Leather Belt', 'accessory', '#151515', 'solid', 'leather', 'regular', 3, 'all'),
  ];
}
