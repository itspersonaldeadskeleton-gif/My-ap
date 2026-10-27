import 'package:freezed_annotation/freezed_annotation.dart';

part 'recommendation_models.freezed.dart';
part 'recommendation_models.g.dart';

/// The four reasons shown on the back of an outfit card.
@freezed
class OutfitWhy with _$OutfitWhy {
  const factory OutfitWhy({
    @Default('') String colorTheory,
    @Default('') String proportions,
    @Default('') String weather,
    @Default('') String occasion,
  }) = _OutfitWhy;

  factory OutfitWhy.fromJson(Map<String, dynamic> json) => _$OutfitWhyFromJson(json);
}

@freezed
class OutfitRecommendation with _$OutfitRecommendation {
  @JsonSerializable(explicitToJson: true)
  const factory OutfitRecommendation({
    /// best_match | safe_choice | bold_choice
    required String label,
    @Default('') String title,
    /// Wardrobe item ids (validated against the real wardrobe when parsed).
    required List<int> itemIds,
    @Default(0) int matchScore,
    @Default(OutfitWhy()) OutfitWhy why,
    @Default(<String>[]) List<String> avoid,
  }) = _OutfitRecommendation;

  factory OutfitRecommendation.fromJson(Map<String, dynamic> json) =>
      _$OutfitRecommendationFromJson(json);
}

@freezed
class WardrobeGap with _$WardrobeGap {
  const factory WardrobeGap({
    required String item,
    @Default('') String reason,
    /// buy | borrow
    @Default('buy') String action,
  }) = _WardrobeGap;

  factory WardrobeGap.fromJson(Map<String, dynamic> json) => _$WardrobeGapFromJson(json);
}

@freezed
class RecommendationResult with _$RecommendationResult {
  @JsonSerializable(explicitToJson: true)
  const factory RecommendationResult({
    required List<OutfitRecommendation> outfits,
    @Default(<WardrobeGap>[]) List<WardrobeGap> gaps,
  }) = _RecommendationResult;

  factory RecommendationResult.fromJson(Map<String, dynamic> json) =>
      _$RecommendationResultFromJson(json);
}
