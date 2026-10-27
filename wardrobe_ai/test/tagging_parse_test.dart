import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_ai/features/wardrobe/data/tagging_repository.dart';

void main() {
  group('TaggingRepository.parseResponse', () {
    test('parses clean JSON', () {
      final t = TaggingRepository.parseResponse(
          '{"name":"Navy Chinos","category":"bottom","colors":["#1F2A44"],'
          '"pattern":"solid","fabric":"cotton","fit":"slim","formality":3,'
          '"season":"all","photoQuality":"ok"}');
      expect(t.name, 'Navy Chinos');
      expect(t.colors, ['#1F2A44']);
      expect(t.formality, 3);
    });

    test('strips code fences and clamps formality', () {
      final t = TaggingRepository.parseResponse(
          '```json\n{"name":"Tux","category":"outerwear","formality":9.4}\n```');
      expect(t.formality, 5);
      expect(t.pattern, 'solid'); // default for missing key
    });

    test('blurry photo throws blurry', () {
      expect(
        () => TaggingRepository.parseResponse('{"photoQuality":"blurry"}'),
        throwsA(isA<TaggingException>()
            .having((e) => e.kind, 'kind', TaggingErrorKind.blurry)),
      );
    });

    test('garbage throws parse', () {
      expect(
        () => TaggingRepository.parseResponse('sorry, I cannot help'),
        throwsA(isA<TaggingException>()
            .having((e) => e.kind, 'kind', TaggingErrorKind.parse)),
      );
    });
  });
}
