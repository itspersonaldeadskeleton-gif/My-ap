import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/outfit_log_writes.dart';
import '../../../core/database/providers.dart';
import '../../questionnaire/presentation/questionnaire_providers.dart';
import '../../wardrobe/presentation/wardrobe_services.dart';
import '../data/recommendation_repository.dart';
import '../domain/recommendation_models.dart';

final recommendationRepoProvider = Provider<RecommendationRepository>(
    (ref) => RecommendationRepository(ref.watch(llmClientProvider)));

/// Runs when the results screen opens. `ref.invalidate` = retry.
final recommendationProvider =
    FutureProvider.autoDispose<RecommendationResult>((ref) async {
  final answers = ref.read(questionnaireProvider);
  final db = ref.read(appDatabaseProvider);
  final List<WardrobeItem> items = await db.select(db.wardrobeItems).get();
  final feedback = await db.feedbackSummary();
  return ref
      .read(recommendationRepoProvider)
      .recommend(answers: answers, items: items, feedback: feedback);
});
