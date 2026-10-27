import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_ai/core/database/app_database.dart';
import 'package:wardrobe_ai/features/questionnaire/domain/occasion_answers.dart';
import 'package:wardrobe_ai/features/recommendation/data/recommendation_repository.dart';

const _valid = {1, 2, 3, 4, 5};

String _outfit(String label, String ids, [String score = '85']) =>
    '{"label":"$label","title":"T","itemIds":$ids,"matchScore":$score,'
    '"why":{"colorTheory":"c","proportions":"p","weather":"w","occasion":"o"},'
    '"avoid":["x"]}';

void main() {
  group('RecommendationRepository.parse', () {
    test('parses three outfits plus gaps', () {
      final raw = '{"outfits":[${_outfit('best_match', '[1,2,3]')},'
          '${_outfit('safe_choice', '[2,3,4]')},${_outfit('bold_choice', '[1,4,5]')}],'
          '"gaps":[{"item":"Coat","reason":"Cold","action":"borrow"}]}';
      final r = RecommendationRepository.parse(raw, validIds: _valid);
      expect(r.outfits.map((o) => o.label), ['best_match', 'safe_choice', 'bold_choice']);
      expect(r.outfits.first.why.colorTheory, 'c');
      expect(r.gaps.single.action, 'borrow');
    });

    test('strips code fences and clamps score', () {
      final raw = '```json\n{"outfits":[${_outfit('best_match', '[1,2]', '140')}]}\n```';
      final r = RecommendationRepository.parse(raw, validIds: _valid);
      expect(r.outfits.single.matchScore, 100);
    });

    test('drops hallucinated ids and outfits left with < 2 items', () {
      final raw = '{"outfits":[${_outfit('best_match', '[1,2,99]')},'
          '${_outfit('safe_choice', '[3,98,97]')}]}';
      final r = RecommendationRepository.parse(raw, validIds: _valid);
      expect(r.outfits.length, 1);
      expect(r.outfits.single.itemIds, [1, 2]);
    });

    test('fixes duplicate or unknown labels', () {
      final raw = '{"outfits":[${_outfit('best_match', '[1,2]')},${_outfit('best_match', '[3,4]')},'
          '${_outfit('weird', '[2,5]')}]}';
      final r = RecommendationRepository.parse(raw, validIds: _valid);
      expect(r.outfits.map((o) => o.label).toSet().length, 3);
    });

    test('malformed gaps never fail the result', () {
      final raw = '{"outfits":[${_outfit('best_match', '[1,2]')}],"gaps":[42,{"nope":1}]}';
      expect(RecommendationRepository.parse(raw, validIds: _valid).gaps, isEmpty);
    });

    test('garbage or no valid outfits throws parse', () {
      for (final raw in ['sorry', '{"outfits":[]}', '{"outfits":[${_outfit('best_match', '[77,88]')}]}']) {
        expect(
          () => RecommendationRepository.parse(raw, validIds: _valid),
          throwsA(isA<RecommendationException>()
              .having((e) => e.kind, 'kind', RecommendationErrorKind.parse)),
        );
      }
    });
  });

  test('buildPrompt includes answers, wardrobe ids and rules', () {
    final item = WardrobeItem(
      id: 7, name: 'Navy Chinos', category: 'bottom', imagePath: null, cutoutPath: null,
      colors: '["#1F2A44"]', pattern: 'solid', fabric: 'cotton', fit: 'slim',
      formality: 3, season: 'all', isFavorite: false, wearCount: 0, createdAt: DateTime(2026),
    );
    final p = RecommendationRepository.buildPrompt(
      answers: const OccasionAnswers(mood: 'Confident', colorsAvoid: ['red']),
      items: [item],
    );
    expect(p, contains('"id":7'));
    expect(p, contains('"colorsAvoid":["red"]'));
    expect(p, contains('best_match'));
  });
}
