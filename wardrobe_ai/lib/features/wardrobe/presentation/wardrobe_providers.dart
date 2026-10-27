import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/providers.dart';

part 'wardrobe_providers.g.dart';

/// Live list of wardrobe items from the local DB.
@riverpod
Stream<List<WardrobeItem>> wardrobeItems(Ref ref) =>
    ref.watch(appDatabaseProvider).watchItems();
