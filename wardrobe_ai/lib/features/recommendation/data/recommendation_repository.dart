import 'dart:convert';

import '../../../core/database/app_database.dart';
import '../../../core/network/llm_client.dart';
import '../../questionnaire/domain/occasion_answers.dart';
import '../domain/recommendation_models.dart';

enum RecommendationErrorKind { offline, api, parse, noKey, tooFewItems }

class RecommendationException implements Exception {
  const RecommendationException(this.kind, this.message);
  final RecommendationErrorKind kind;
  final String message;
  @override
  String toString() => message;
}

const _labels = ['best_match', 'safe_choice', 'bold_choice'];

/// Builds the prompt, calls the LLM, parses + validates the JSON reply.
class RecommendationRepository {
  RecommendationRepository(this._llm);
  final LlmClient _llm;

  Future<RecommendationResult> recommend({
    required OccasionAnswers answers,
    required List<WardrobeItem> items,
    Map<String, dynamic> feedback = const {},
  }) async {
    if (items.length < 3) {
      throw const RecommendationException(RecommendationErrorKind.tooFewItems,
          'Add at least a top, a bottom and shoes to your wardrobe first.');
    }
    try {
      final raw = await _llm.askText(
          prompt: buildPrompt(answers: answers, items: items, feedback: feedback));
      return parse(raw, validIds: items.map((i) => i.id).toSet());
    } on LlmException catch (e) {
      throw RecommendationException(
        switch (e.kind) {
          LlmErrorKind.offline => RecommendationErrorKind.offline,
          LlmErrorKind.noKey => RecommendationErrorKind.noKey,
          LlmErrorKind.api => RecommendationErrorKind.api,
        },
        e.message,
      );
    }
  }

  /// Pure + unit-tested.
  static String buildPrompt({
    required OccasionAnswers answers,
    required List<WardrobeItem> items,
    Map<String, dynamic> feedback = const {},
  }) {
    final wardrobe = items
        .map((i) => {
              'id': i.id,
              'name': i.name,
              'category': i.category,
              'colors': jsonDecode(i.colors),
              'pattern': i.pattern,
              'fabric': i.fabric,
              'fit': i.fit,
              'formality': i.formality,
              'season': i.season,
              'favorite': i.isFavorite,
            })
        .toList();

    return '''
You are an expert personal stylist. Build outfits ONLY from the wardrobe below.

OCCASION (comfortStyle: 0 = comfort first, 1 = style first):
${jsonEncode(answers.toJson())}

WARDROBE:
${jsonEncode(wardrobe)}

PAST FEEDBACK (prefer liked items, avoid disliked ones):
${jsonEncode(feedback)}

RULES:
- Return exactly 3 outfits, labelled best_match, safe_choice, bold_choice.
- Use ONLY ids that exist in WARDROBE. Each outfit needs shoes plus either a top and bottom, or a dress. Add outerwear when the weather needs it. Accessories are optional.
- Never use a colour listed in colorsAvoid. Respect "cultural" needs and the dress code.
- The three outfits must differ by at least 2 items.
- safe_choice = reliable and low risk. bold_choice = more expressive but still appropriate.
- matchScore is an honest integer 0-100.
- If the wardrobe lacks something that would clearly improve the result, list it in "gaps" (action: buy or borrow).

Respond with ONLY JSON, no prose, in this shape:
{"outfits":[{"label":"best_match","title":"short name","itemIds":[1,2,3],"matchScore":88,
"why":{"colorTheory":"...","proportions":"...","weather":"...","occasion":"..."},
"avoid":["...","..."]}],
"gaps":[{"item":"...","reason":"...","action":"buy"}]}
''';
  }

  /// Raw LLM text -> validated [RecommendationResult]. Pure + unit-tested.
  static RecommendationResult parse(String raw, {required Set<int> validIds}) {
    const bad = RecommendationException(RecommendationErrorKind.parse,
        'The AI reply could not be understood. Please retry.');
    final cleaned = raw.replaceAll(RegExp(r'```(?:json)?'), '').trim();
    final a = cleaned.indexOf('{'), b = cleaned.lastIndexOf('}');
    if (a < 0 || b <= a) throw bad;

    try {
      final m = jsonDecode(cleaned.substring(a, b + 1)) as Map<String, dynamic>;
      final outfits = <OutfitRecommendation>[];
      for (final o in (m['outfits'] as List? ?? const [])) {
        final map = Map<String, dynamic>.from(o as Map);
        // Drop hallucinated ids; an outfit needs at least 2 real items.
        final ids = ((map['itemIds'] as List?) ?? const [])
            .map((e) => (e as num).toInt())
            .where(validIds.contains)
            .toSet()
            .toList();
        if (ids.length < 2) continue;
        map['itemIds'] = ids;
        map['matchScore'] = ((map['matchScore'] as num?) ?? 0).round().clamp(0, 100).toInt();
        final label = map['label'] as String?;
        if (!_labels.contains(label) || outfits.any((x) => x.label == label)) {
          map['label'] = _labels.firstWhere(
              (l) => !outfits.any((x) => x.label == l),
              orElse: () => _labels.last);
        }
        outfits.add(OutfitRecommendation.fromJson(map));
        if (outfits.length == 3) break;
      }
      if (outfits.isEmpty) throw bad;
      outfits.sort((x, y) => _labels.indexOf(x.label).compareTo(_labels.indexOf(y.label)));

      final gaps = <WardrobeGap>[];
      for (final g in (m['gaps'] as List? ?? const [])) {
        try {
          gaps.add(WardrobeGap.fromJson(Map<String, dynamic>.from(g as Map)));
        } catch (_) {} // a malformed gap should never fail the whole result
      }
      return RecommendationResult(outfits: outfits, gaps: gaps);
    } on RecommendationException {
      rethrow;
    } catch (_) {
      throw bad;
    }
  }
}
