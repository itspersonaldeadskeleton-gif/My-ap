enum Occasion { casual, work, formal, gym, nightOut, date }

enum Weather { hot, warm, mild, cool, cold, rainy }

enum Color { black, white, grey, navy, blue, red, pink, orange, yellow, green, beige, brown, cream, burgundy, purple }

enum Category { top, bottom, outerwear, dress, footwear, accessory }

enum Style { minimal, classic, streetwear, sporty, boho, elegant }

class ClothingItem {
  final String id;
  final String name;
  final Category category;
  final Set<Color> colors;
  final Occasion suitableOccasions;
  final Set<Weather> suitableWeather;
  final Style style;
  final bool available;
  final bool clean;
  final double warmth; // 0-1
  final double formality; // 0-1
  final String? brand;

  const ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.colors,
    required this.suitableOccasions,
    required this.suitableWeather,
    required this.style,
    required this.available,
    required this.clean,
    this.warmth = 0.5,
    this.formality = 0.5,
    this.brand,
  });
}

class Outfit {
  final String id;
  final List<ClothingItem> items;
  final double score;
  final Map<String, double> scoreBreakdown;
  final List<String> explanations;

  const Outfit({
    required this.id,
    required this.items,
    required this.score,
    required this.scoreBreakdown,
    required this.explanations,
  });
}

class RecommendationContext {
  final Occasion occasion;
  final Weather weather;
  final Style preferredStyle;
  final Set<Color> preferredColors;
  final double noveltyPreference; // 0-1

  const RecommendationContext({
    required this.occasion,
    required this.weather,
    required this.preferredStyle,
    required this.preferredColors,
    this.noveltyPreference = 0.5,
  });
}
