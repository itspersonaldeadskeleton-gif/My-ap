import 'package:flutter_test/flutter_test.dart';
import 'package:fitmind/features/recommendations/engine.dart';
import 'package:fitmind/features/recommendations/models.dart';
import 'package:fitmind/features/recommendations/scoring.dart';

void main() {
  group('OutfitRecommendationEngine', () {
    late OutfitRecommendationEngine engine;
    late List<ClothingItem> wardrobe;
    late RecommendationContext context;

    setUp(() {
      engine = OutfitRecommendationEngine();
      wardrobe = [
        ClothingItem(
          id: '1',
          name: 'White T-Shirt',
          category: Category.top,
          colors: {Color.white},
          suitableOccasions: Occasion.casual,
          suitableWeather: {Weather.warm, Weather.hot},
          style: Style.minimal,
          available: true,
          clean: true,
          warmth: 0.2,
          formality: 0.2,
        ),
        ClothingItem(
          id: '2',
          name: 'Blue Jeans',
          category: Category.bottom,
          colors: {Color.blue},
          suitableOccasions: Occasion.casual,
          suitableWeather: {Weather.warm, Weather.mild, Weather.cool},
          style: Style.classic,
          available: true,
          clean: true,
          warmth: 0.4,
          formality: 0.3,
        ),
        ClothingItem(
          id: '3',
          name: 'Sneakers',
          category: Category.footwear,
          colors: {Color.white},
          suitableOccasions: Occasion.casual,
          suitableWeather: {Weather.warm, Weather.mild, Weather.hot},
          style: Style.sporty,
          available: true,
          clean: true,
          warmth: 0.1,
          formality: 0.1,
        ),
        ClothingItem(
          id: '4',
          name: 'Black Blazer',
          category: Category.outerwear,
          colors: {Color.black},
          suitableOccasions: Occasion.work,
          suitableWeather: {Weather.mild, Weather.cool},
          style: Style.classic,
          available: true,
          clean: true,
          warmth: 0.6,
          formality: 0.8,
        ),
        ClothingItem(
          id: '5',
          name: 'Dress Shirt',
          category: Category.top,
          colors: {Color.white},
          suitableOccasions: Occasion.work,
          suitableWeather: {Weather.mild, Weather.cool, Weather.warm},
          style: Style.classic,
          available: true,
          clean: true,
          warmth: 0.3,
          formality: 0.7,
        ),
        ClothingItem(
          id: '6',
          name: 'Trousers',
          category: Category.bottom,
          colors: {Color.navy},
          suitableOccasions: Occasion.work,
          suitableWeather: {Weather.mild, Weather.cool},
          style: Style.classic,
          available: true,
          clean: true,
          warmth: 0.5,
          formality: 0.7,
        ),
      ];
      context = const RecommendationContext(
        occasion: Occasion.casual,
        weather: Weather.warm,
        preferredStyle: Style.minimal,
        preferredColors: {Color.white, Color.blue},
        noveltyPreference: 0.5,
      );
    });

    test('returns 3-5 outfits', () {
      final results = engine.recommend(
        wardrobe: wardrobe,
        context: context,
      );
      expect(results.length, greaterThanOrEqualTo(3));
      expect(results.length, lessThanOrEqualTo(5));
    });

    test('respects hard constraints for availability', () {
      final unavailableWardrobe = [
        ClothingItem(
          id: '1',
          name: 'Shirt',
          category: Category.top,
          colors: {Color.white},
          suitableOccasions: Occasion.casual,
          suitableWeather: {Weather.warm},
          style: Style.minimal,
          available: false,
          clean: true,
          warmth: 0.2,
          formality: 0.2,
        ),
      ];
      final results = engine.recommend(
        wardrobe: unavailableWardrobe,
        context: context,
      );
      expect(results.isEmpty, true);
    });

    test('respects hard constraints for cleanliness', () {
      final dirtyWardrobe = [
        ClothingItem(
          id: '1',
          name: 'Shirt',
          category: Category.top,
          colors: {Color.white},
          suitableOccasions: Occasion.casual,
          suitableWeather: {Weather.warm},
          style: Style.minimal,
          available: true,
          clean: false,
          warmth: 0.2,
          formality: 0.2,
        ),
        ClothingItem(
          id: '2',
          name: 'Jeans',
          category: Category.bottom,
          colors: {Color.blue},
          suitableOccasions: Occasion.casual,
          suitableWeather: {Weather.warm},
          style: Style.classic,
          available: true,
          clean: true,
          warmth: 0.4,
          formality: 0.3,
        ),
        ClothingItem(
          id: '3',
          name: 'Shoes',
          category: Category.footwear,
          colors: {Color.white},
          suitableOccasions: Occasion.casual,
          suitableWeather: {Weather.warm},
          style: Style.sporty,
          available: true,
          clean: true,
          warmth: 0.1,
          formality: 0.1,
        ),
      ];
      final results = engine.recommend(
        wardrobe: dirtyWardrobe,
        context: context,
      );
      // Should not use dirty items
      for (final outfit in results) {
        for (final item in outfit.items) {
          expect(item.clean, true);
          expect(item.available, true);
        }
      }
    });

    test('outfits have explanations', () {
      final results = engine.recommend(
        wardrobe: wardrobe,
        context: context,
      );
      for (final outfit in results) {
        expect(outfit.explanations.isNotEmpty, true);
      }
    });

    test('outfits have score breakdown', () {
      final results = engine.recommend(
        wardrobe: wardrobe,
        context: context,
      );
      for (final outfit in results) {
        expect(outfit.scoreBreakdown.isNotEmpty, true);
        expect(outfit.score, greaterThan(0));
      }
    });

    test('uses weighted scoring', () {
      final customWeights = const ScoringWeights(
        occasion: 0.5,
        weather: 0.1,
        colorHarmony: 0.1,
        silhouette: 0.1,
        personalStyle: 0.1,
        footwearAccessory: 0.05,
        novelty: 0.05,
      );
      final customEngine = OutfitRecommendationEngine(weights: customWeights);
      expect(customEngine.weights.occasion, 0.5);
    });
  });
}
