import 'dart:convert';
import 'dart:io';

import '../../../core/network/llm_client.dart';
import '../domain/clothing_tags.dart';

enum TaggingErrorKind { offline, api, parse, blurry, noKey }

class TaggingException implements Exception {
  const TaggingException(this.kind, this.message);
  final TaggingErrorKind kind;
  final String message;
  @override
  String toString() => message;
}

/// Sends a clothing photo to the vision LLM and parses structured JSON.
class TaggingRepository {
  TaggingRepository(this._llm);
  final LlmClient _llm;

  static const prompt = '''
You are a fashion cataloguer. Analyze the single clothing item in the photo.
Respond with ONLY a JSON object (no prose, no markdown) with these keys:
name (short, e.g. "Navy Slim Chinos"),
category (one of: top, bottom, outerwear, dress, shoes, accessory),
colors (array of up to 3 hex strings, dominant first),
pattern (solid, striped, checked, floral, graphic, textured, other),
fabric (best guess, e.g. cotton, denim, wool),
fit (slim, regular, relaxed, oversized, tailored, straight),
formality (integer 1 = very casual to 5 = black tie),
season (all, spring, summer, autumn, winter),
photoQuality (ok, blurry, no_clothing).
''';

  Future<ClothingTags> analyze(File image) async {
    final bytes = await image.readAsBytes();
    final mime =
        image.path.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
    try {
      final raw =
          await _llm.askWithImage(bytes: bytes, mime: mime, prompt: prompt);
      return parseResponse(raw);
    } on LlmException catch (e) {
      throw TaggingException(
        switch (e.kind) {
          LlmErrorKind.offline => TaggingErrorKind.offline,
          LlmErrorKind.noKey => TaggingErrorKind.noKey,
          LlmErrorKind.api => TaggingErrorKind.api,
        },
        e.message,
      );
    }
  }

  /// Pure function (unit-tested): raw LLM text -> [ClothingTags].
  static ClothingTags parseResponse(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'```(?:json)?'), '').trim();
    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');
    if (start < 0 || end <= start) {
      throw const TaggingException(
          TaggingErrorKind.parse, 'The AI reply could not be understood. Retry.');
    }
    final ClothingTags tags;
    try {
      final m = jsonDecode(cleaned.substring(start, end + 1))
          as Map<String, dynamic>;
      m['formality'] = ((m['formality'] as num?) ?? 3).round().clamp(1, 5).toInt();
      m['colors'] = ((m['colors'] as List?) ?? const []).map((e) => '$e').toList();
      tags = ClothingTags.fromJson(m);
    } catch (_) {
      throw const TaggingException(
          TaggingErrorKind.parse, 'The AI reply could not be understood. Retry.');
    }
    if (tags.photoQuality != 'ok') {
      throw TaggingException(
          TaggingErrorKind.blurry,
          tags.photoQuality == 'blurry'
              ? 'That photo is too blurry to read. Retake it in good light.'
              : 'No clothing item was found. Retake the photo closer up.');
    }
    return tags;
  }
}
