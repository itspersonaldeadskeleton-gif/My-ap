import 'dart:math' as math;
import 'models.dart';
import 'scoring.dart';

class OutfitRecommendationEngine {
  final ScoringWeights weights;
  final OutfitScorer scorer;

  OutfitRecommendationEngine({ScoringWeights? weights})
      : weights = weights ?? const ScoringWeights(),
        scorer = OutfitScorer(weights: weights ?? const ScoringWeights());

  List<Outfit> recommend({
    required List<ClothingItem> wardrobe,
    required RecommendationContext context,
    int maxResults = 5,
    int minResults = 3,
  }) {
    // Apply hard constraints
    final availableItems = wardrobe.where((item) => 
      item.available && item.clean
    ).toList();

    if (availableItems.isEmpty) {
      return [];
    }

    // Generate candidate outfits
    final candidates = _generateCandidates(availableItems);
    
    // Score each candidate
    final scoredOutfits = <Outfit>[];
    for (final candidate in candidates) {
      final breakdown = scorer.scoreOutfit(candidate, context);
      final totalScore = breakdown.values.fold(0.0, (sum, v) => sum + v);
      final explanations = _generateExplanations(candidate, context, breakdown);
      
      scoredOutfits.add(Outfit(
        id: candidate.id,
        items: candidate.items,
        score: totalScore,
        scoreBreakdown: breakdown,
        explanations: explanations,
      ));
    }

    // Sort by score descending
    scoredOutfits.sort((a, b) => b.score.compareTo(a.score));

    // Return 3-5 results
    final resultCount = math.max(minResults, math.min(maxResults, scoredOutfits.length));
    return scoredOutfits.take(resultCount).toList();
  }

  List<Outfit> _generateCandidates(List<ClothingItem> items) {
    final candidates = <Outfit>[];
    final tops = items.where((i) => i.category == Category.top).toList();
    final bottoms = items.where((i) => i.category == Category.bottom).toList();
    final dresses = items.where((i) => i.category == Category.dress).toList();
    final footwear = items.where((i) => i.category == Category.footwear).toList();
    final outerwear = items.where((i) => i.category == Category.outerwear).toList();
    final accessories = items.where((i) => i.category == Category.accessory).toList();

    int outfitId = 0;

    // Dress-based outfits
    for (final dress in dresses) {
      for (final shoe in footwear) {
        final outfitItems = <ClothingItem>[dress, shoe];
        if (outerwear.isNotEmpty && math.Random(outfitId).nextBool()) {
          outfitItems.add(outerwear[math.Random(outfitId++).nextInt(outerwear.length)]);
        }
        if (accessories.isNotEmpty && math.Random(outfitId).nextBool()) {
          outfitItems.add(accessories[math.Random(outfitId++).nextInt(accessories.length)]);
        }
        candidates.add(Outfit(
          id: 'outfit_$outfitId',
          items: outfitItems,
          score: 0,
          scoreBreakdown: {},
          explanations: [],
        ));
        outfitId++;
      }
    }

    // Top + bottom combinations
    for (final top in tops) {
      for (final bottom in bottoms) {
        for (final shoe in footwear) {
          final outfitItems = <ClothingItem>[top, bottom, shoe];
          if (outerwear.isNotEmpty && math.Random(outfitId).nextDouble() > 0.3) {
            outfitItems.add(outerwear[math.Random(outfitId).nextInt(outerwear.length)]);
          }
          if (accessories.isNotEmpty && math.Random(outfitId).nextDouble() > 0.4) {
            outfitItems.add(accessories[math.Random(outfitId).nextInt(accessories.length)]);
          }
          candidates.add(Outfit(
            id: 'outfit_$outfitId',
            items: outfitItems,
            score: 0,
            scoreBreakdown: {},
            explanations: [],
          ));
          outfitId++;
          if (outfitId > 100) break; // Limit combinations
        }
        if (outfitId > 100) break;
      }
      if (outfitId > 100) break;
    }

    return candidates;
  }

  List<String> _generateExplanations(Outfit outfit, RecommendationContext context, Map<String, double> breakdown) {
    final explanations = <String>[];
    
    if ((breakdown['occasion'] ?? 0) > 0.2) {
      explanations.add('Well-suited for ${context.occasion.name} occasions');
    }
    if ((breakdown['weather'] ?? 0) > 0.15) {
      explanations.add('Appropriate for ${context.weather.name} weather');
    }
    if ((breakdown['colorHarmony'] ?? 0) > 0.12) {
      explanations.add('Cohesive color palette');
    }
    if ((breakdown['personalStyle'] ?? 0) > 0.08) {
      explanations.add('Matches your ${context.preferredStyle.name} style');
    }
    if (outfit.items.any((i) => i.category == Category.footwear)) {
      explanations.add('Complete with proper footwear');
    }
    
    if (explanations.isEmpty) {
      explanations.add('Balanced and versatile outfit');
    }
    
    return explanations;
  }
}
