import 'dart:math' as math;
import 'models.dart';

class ScoringWeights {
  final double occasion;
  final double weather;
  final double colorHarmony;
  final double silhouette;
  final double personalStyle;
  final double footwearAccessory;
  final double novelty;

  const ScoringWeights({
    this.occasion = 0.25,
    this.weather = 0.20,
    this.colorHarmony = 0.15,
    this.silhouette = 0.10,
    this.personalStyle = 0.10,
    this.footwearAccessory = 0.10,
    this.novelty = 0.10,
  });

  double get total => occasion + weather + colorHarmony + silhouette + personalStyle + footwearAccessory + novelty;
}

class OutfitScorer {
  final ScoringWeights weights;

  const OutfitScorer({this.weights = const ScoringWeights()});

  Map<String, double> scoreOutfit(Outfit outfit, RecommendationContext context) {
    final breakdown = <String, double>{};
    
    breakdown['occasion'] = _scoreOccasion(outfit, context) * weights.occasion;
    breakdown['weather'] = _scoreWeather(outfit, context) * weights.weather;
    breakdown['colorHarmony'] = _scoreColorHarmony(outfit, context) * weights.colorHarmony;
    breakdown['silhouette'] = _scoreSilhouette(outfit) * weights.silhouette;
    breakdown['personalStyle'] = _scorePersonalStyle(outfit, context) * weights.personalStyle;
    breakdown['footwearAccessory'] = _scoreFootwearAccessory(outfit) * weights.footwearAccessory;
    breakdown['novelty'] = _scoreNovelty(outfit, context) * weights.novelty;
    
    return breakdown;
  }

  double _scoreOccasion(Outfit outfit, RecommendationContext context) {
    if (outfit.items.isEmpty) return 0.0;
    int matches = 0;
    for (final item in outfit.items) {
      if (_occasionMatches(item, context.occasion)) matches++;
    }
    return matches / outfit.items.length;
  }

  bool _occasionMatches(ClothingItem item, Occasion occasion) {
    // Map suitable occasions - simplified
    if (occasion == Occasion.work) {
      return item.formality >= 0.4;
    } else if (occasion == Occasion.formal) {
      return item.formality >= 0.7;
    } else if (occasion == Occasion.gym) {
      return item.category == Category.footwear || item.name.toLowerCase().contains('athletic') || item.style == Style.sporty;
    } else if (occasion == Occasion.nightOut || occasion == Occasion.date) {
      return item.formality >= 0.3;
    }
    return item.formality < 0.8; // casual is more flexible
  }

  double _scoreWeather(Outfit outfit, RecommendationContext context) {
    if (outfit.items.isEmpty) return 0.0;
    double score = 0.0;
    for (final item in outfit.items) {
      if (item.suitableWeather.contains(context.weather)) {
        score += 1.0;
      } else {
        // Check temperature appropriateness
        if (context.weather == Weather.cold && item.warmth >= 0.6) score += 0.8;
        else if (context.weather == Weather.hot && item.warmth < 0.4) score += 0.8;
        else if (context.weather == Weather.rainy && item.category == Category.outerwear) score += 0.6;
        else score += 0.3;
      }
    }
    return score / outfit.items.length;
  }

  double _scoreColorHarmony(Outfit outfit, RecommendationContext context) {
    if (outfit.items.isEmpty) return 0.0;
    final allColors = <Color>[];
    for (final item in outfit.items) {
      allColors.addAll(item.colors);
    }
    if (allColors.isEmpty) return 0.5;
    
    // Prefer neutral base with accent colors
    int neutralCount = allColors.where((c) => _isNeutral(c)).length;
    int preferredCount = allColors.where((c) => context.preferredColors.contains(c)).length;
    
    double harmony = (neutralCount / allColors.length) * 0.5 + (preferredCount / allColors.length) * 0.5;
    // Bonus for having 2-3 colors max (coherent)
    if (allColors.toSet().length <= 3) harmony = math.min(1.0, harmony + 0.2);
    return harmony;
  }

  bool _isNeutral(Color color) {
    return [Color.black, Color.white, Color.grey, Color.beige, Color.cream, Color.navy, Color.brown].contains(color);
  }

  double _scoreSilhouette(Outfit outfit) {
    if (outfit.items.isEmpty) return 0.0;
    // Check for balanced silhouette - top/bottom/footwear
    bool hasTop = outfit.items.any((i) => i.category == Category.top || i.category == Category.dress);
    bool hasBottom = outfit.items.any((i) => i.category == Category.bottom);
    bool hasFootwear = outfit.items.any((i) => i.category == Category.footwear);
    
    double score = 0.0;
    if (hasTop) score += 0.33;
    if (hasBottom || outfit.items.any((i) => i.category == Category.dress)) score += 0.33;
    if (hasFootwear) score += 0.34;
    return score;
  }

  double _scorePersonalStyle(Outfit outfit, RecommendationContext context) {
    if (outfit.items.isEmpty) return 0.0;
    int matches = 0;
    for (final item in outfit.items) {
      if (item.style == context.preferredStyle) matches++;
    }
    return matches / outfit.items.length;
  }

  double _scoreFootwearAccessory(Outfit outfit) {
    if (outfit.items.isEmpty) return 0.0;
    bool hasFootwear = outfit.items.any((i) => i.category == Category.footwear);
    bool hasAccessory = outfit.items.any((i) => i.category == Category.accessory);
    
    double score = 0.0;
    if (hasFootwear) score += 0.6;
    if (hasAccessory) score += 0.4;
    return score;
  }

  double _scoreNovelty(Outfit outfit, RecommendationContext context) {
    // Simplified - in real app would track wear history
    // Higher novelty preference rewards less common combinations
    double base = 0.5 + context.noveltyPreference * 0.3;
    return math.min(1.0, base);
  }
}
