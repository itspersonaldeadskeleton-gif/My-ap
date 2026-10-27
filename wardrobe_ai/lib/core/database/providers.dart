import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_database.dart';
import 'seed_data.dart';

part 'providers.g.dart';

/// Single shared database instance for the whole app.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

@Riverpod(keepAlive: true)
SeedService seedService(Ref ref) => SeedService(ref.watch(appDatabaseProvider));
