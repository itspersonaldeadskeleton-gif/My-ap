import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/outfit_log_writes.dart';
import '../../../core/database/providers.dart';
import '../domain/logged_outfit.dart';

/// Every logged outfit, newest first.
final outfitLogsProvider = StreamProvider.autoDispose<List<LoggedOutfit>>((ref) =>
    ref.watch(appDatabaseProvider).watchLogs().map((l) => l.map(LoggedOutfit.from).toList()));
