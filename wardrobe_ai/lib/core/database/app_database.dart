import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// One garment in the digital wardrobe.
/// List-like fields (colors) are stored as JSON strings for simplicity.
class WardrobeItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  /// top | bottom | outerwear | dress | shoes | accessory
  TextColumn get category => text()();
  /// Original photo path (app documents dir). Null for demo items.
  TextColumn get imagePath => text().nullable()();
  /// Background-removed PNG path, used for collages.
  TextColumn get cutoutPath => text().nullable()();
  /// JSON array of hex strings, e.g. ["#1F2A44"].
  TextColumn get colors => text().withDefault(const Constant('[]'))();
  TextColumn get pattern => text().withDefault(const Constant('solid'))();
  TextColumn get fabric => text().withDefault(const Constant('unknown'))();
  TextColumn get fit => text().withDefault(const Constant('regular'))();
  /// 1 (very casual) to 5 (black tie)
  IntColumn get formality => integer().withDefault(const Constant(3))();
  /// all | spring | summer | autumn | winter
  TextColumn get season => text().withDefault(const Constant('all'))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get wearCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// A worn / planned outfit, used by calendar, history and feedback.
class OutfitLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get occasion => text().withDefault(const Constant(''))();
  /// JSON: list of wardrobe item ids + the AI's explanation.
  TextColumn get outfitJson => text()();
  /// 1-5 stars, null until rated. Feeds personalization.
  IntColumn get rating => integer().nullable()();
}

@DriftDatabase(tables: [WardrobeItems, OutfitLogs])
class AppDatabase extends _$AppDatabase {
  /// Pass a custom executor in tests (e.g. NativeDatabase.memory()).
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'wardrobe_ai'));

  @override
  int get schemaVersion => 1;

  // ---- Wardrobe queries ----
  Stream<List<WardrobeItem>> watchItems() =>
      (select(wardrobeItems)..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Future<int> insertItem(WardrobeItemsCompanion c) =>
      into(wardrobeItems).insert(c);

  Future<void> toggleFavorite(int id, bool value) =>
      (update(wardrobeItems)..where((t) => t.id.equals(id)))
          .write(WardrobeItemsCompanion(isFavorite: Value(value)));

  Future<int> itemCount() async =>
      (await select(wardrobeItems).get()).length;
}
