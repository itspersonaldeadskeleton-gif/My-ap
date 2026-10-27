import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_ai/core/database/app_database.dart';
import 'package:wardrobe_ai/features/questionnaire/domain/occasion_answers.dart';
import 'package:wardrobe_ai/features/questionnaire/domain/weather_info.dart';
import 'package:wardrobe_ai/features/recommendation/domain/recommendation_models.dart';
import 'package:wardrobe_ai/features/styling_guide/domain/guide_args.dart';
import 'package:wardrobe_ai/features/styling_guide/domain/guide_steps.dart';
import 'package:wardrobe_ai/features/styling_guide/presentation/styling_guide_screen.dart';

WardrobeItem item(int id, String name, String cat,
        {String fit = 'regular', int formality = 3, String fabric = 'cotton'}) =>
    WardrobeItem(
      id: id, name: name, category: cat, imagePath: null, cutoutPath: null,
      colors: '["#1F2A44"]', pattern: 'solid', fabric: fabric, fit: fit,
      formality: formality, season: 'all', isFavorite: false, wearCount: 0,
      createdAt: DateTime(2026),
    );

void main() {
  final shirt = item(1, 'Oxford Shirt', 'top', fit: 'relaxed');
  final jeans = item(2, 'Indigo Jeans', 'bottom', fabric: 'denim');
  final coat = item(3, 'Camel Coat', 'outerwear', fit: 'tailored', formality: 4);
  final shoes = item(4, 'White Sneakers', 'shoes', formality: 2);
  final belt = item(5, 'Leather Belt', 'accessory');

  group('StylingStepsBuilder', () {
    test('orders steps base -> bottom -> top -> layering -> shoes -> accessories -> grooming -> final', () {
      final s = StylingStepsBuilder.build(
          items: [shirt, jeans, coat, shoes, belt], answers: const OccasionAnswers());
      expect(s.map((x) => x.id),
          ['base', 'bottom', 'top', 'layering', 'shoes', 'accessories', 'grooming', 'final']);
    });

    test('instructions follow item attributes', () {
      final s = StylingStepsBuilder.build(
          items: [shirt, jeans, coat, shoes], answers: const OccasionAnswers());
      expect(s.firstWhere((x) => x.id == 'bottom').instruction, contains('Cuff'));
      expect(s.firstWhere((x) => x.id == 'top').instruction.toLowerCase(), contains('half-tuck'));
      expect(s.firstWhere((x) => x.id == 'layering').instruction, contains('middle button'));
    });

    test('skips layering/accessories when absent; dress replaces top+bottom', () {
      final dress = item(9, 'Midi Dress', 'dress');
      final s = StylingStepsBuilder.build(items: [dress, shoes], answers: const OccasionAnswers());
      final ids = s.map((x) => x.id).toList();
      expect(ids, ['base', 'dress', 'shoes', 'grooming', 'final']);
    });

    test('cold weather changes the base layer advice', () {
      final s = StylingStepsBuilder.build(
        items: [shirt, jeans, shoes],
        answers: const OccasionAnswers(weather: WeatherInfo(tempC: 3, label: 'Cold')),
      );
      expect(s.first.instruction.toLowerCase(), contains('thermal'));
    });
  });

  test('confidenceMessage depends on score and mood', () {
    expect(confidenceMessage(92, null), contains('own the room'));
    expect(confidenceMessage(72, null), contains('Sharp'));
    expect(confidenceMessage(50, null), contains('Solid'));
    expect(confidenceMessage(92, 'Romantic'), contains('charm'));
  });

  testWidgets('guide advances from Base layer to Bottoms', (tester) async {
    final args = StylingGuideArgs(
      outfit: const OutfitRecommendation(label: 'best_match', itemIds: [1, 2, 4], matchScore: 88),
      items: [shirt, jeans, shoes],
    );
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(home: StylingGuideScreen(args: args)),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Base layer'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();
    expect(find.text('Bottoms'), findsOneWidget);
  });
}
