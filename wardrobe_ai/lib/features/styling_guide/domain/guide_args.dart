import '../../../core/database/app_database.dart';
import '../../recommendation/domain/recommendation_models.dart';

/// Passed (as go_router `extra`) from the results screen into the guide.
class StylingGuideArgs {
  const StylingGuideArgs({required this.outfit, required this.items, this.loggedId});
  final OutfitRecommendation outfit;
  final List<WardrobeItem> items;
  /// Set when the user already pressed "Wear this" (avoids double-counting).
  final int? loggedId;
}
