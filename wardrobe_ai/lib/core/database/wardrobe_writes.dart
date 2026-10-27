import 'package:drift/drift.dart';
import 'app_database.dart';

/// Extra write helpers (kept out of app_database.dart so Step 1 files stay untouched).
extension WardrobeWrites on AppDatabase {
  Future<void> updateItem(int id, WardrobeItemsCompanion c) =>
      (update(wardrobeItems)..where((t) => t.id.equals(id))).write(c);

  Future<void> deleteItem(int id) =>
      (delete(wardrobeItems)..where((t) => t.id.equals(id))).go();
}
