import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_ai/core/database/app_database.dart';
import 'package:wardrobe_ai/features/calendar/domain/logged_outfit.dart';
import 'package:wardrobe_ai/features/profile/domain/packing_list.dart';

WardrobeItem item(int id, String name, String cat,
        {int formality = 3, String season = 'all', bool fav = false, int worn = 0}) =>
    WardrobeItem(
      id: id, name: name, category: cat, imagePath: null, cutoutPath: null,
      colors: '["#1F2A44"]', pattern: 'solid', fabric: 'cotton', fit: 'regular',
      formality: formality, season: season, isFavorite: fav, wearCount: worn,
      createdAt: DateTime(2026),
    );

void main() {
  final wardrobe = [
    for (var i = 0; i < 6; i++) item(i, 'Top $i', 'top', fav: i == 5),
    item(10, 'Jeans', 'bottom', formality: 2),
    item(11, 'Suit Trousers', 'bottom', formality: 5),
    item(12, 'Chinos', 'bottom'),
    item(20, 'Wool Coat', 'outerwear', formality: 4, season: 'winter'),
    item(21, 'Sneakers', 'shoes', formality: 2),
    item(22, 'Oxfords', 'shoes', formality: 5),
    item(30, 'Belt', 'accessory'),
  ];

  group('PackingListBuilder', () {
    test('scales counts with trip length and adds essentials', () {
      final l = PackingListBuilder.build(items: wardrobe, days: 5, climate: 'Mild', style: TripStyle.mixed);
      expect(l.sections['Tops']!.length, 5);
      expect(l.essentials, contains('6 × socks'));
      expect(l.sections.containsKey('Outer layer'), isFalse); // mild: no coat
    });

    test('cold adds outerwear, hot excludes winter pieces', () {
      final cold = PackingListBuilder.build(items: wardrobe, days: 3, climate: 'Cold', style: TripStyle.mixed);
      expect(cold.sections['Outer layer']!.single.name, 'Wool Coat');
      expect(cold.essentials, contains('Gloves and a warm hat'));
      final hot = PackingListBuilder.build(items: wardrobe, days: 3, climate: 'Hot', style: TripStyle.mixed);
      expect(hot.sections.containsKey('Outer layer'), isFalse);
      expect(hot.essentials, contains('Sunscreen and sunglasses'));
    });

    test('style filters formality and favourites come first', () {
      final casual = PackingListBuilder.build(items: wardrobe, days: 2, climate: 'Mild', style: TripStyle.casual);
      expect(casual.sections['Bottoms']!.map((i) => i.name), isNot(contains('Suit Trousers')));
      expect(casual.sections['Shoes']!.map((i) => i.name), ['Sneakers']);
      final mixed = PackingListBuilder.build(items: wardrobe, days: 2, climate: 'Mild', style: TripStyle.mixed);
      expect(mixed.sections['Tops']!.first.name, 'Top 5'); // the favourite
    });

    test('toText renders a checklist', () {
      final l = PackingListBuilder.build(items: wardrobe, days: 2, climate: 'Mild', style: TripStyle.mixed);
      expect(l.toText(2, 'Mild'), contains('[ ] Toiletries'));
    });
  });

  group('calendar helpers', () {
    test('monthLeadingBlanks (Sunday-first)', () {
      expect(monthLeadingBlanks(DateTime(2026, 2)), 0); // 1 Feb 2026 is a Sunday
      expect(monthLeadingBlanks(DateTime(2026, 3)), 0); // 1 Mar 2026 is a Sunday
      expect(monthLeadingBlanks(DateTime(2026, 10)), 4); // 1 Oct 2026 is a Thursday
    });

    test('LoggedOutfit decodes payload and survives bad JSON', () {
      final ok = LoggedOutfit.from(OutfitLog(
        id: 1, date: DateTime(2026, 5, 1), occasion: 'Office',
        outfitJson: '{"label":"safe_choice","title":"","itemIds":[1,2]}', rating: 4,
      ));
      expect(ok.title, 'Safe Choice');
      expect(ok.itemIds, [1, 2]);
      final bad = LoggedOutfit.from(OutfitLog(
          id: 2, date: DateTime(2026, 5, 1), occasion: '', outfitJson: 'nope', rating: null));
      expect(bad.title, 'Outfit');
      expect(bad.itemIds, isEmpty);
    });

    test('dateOnly strips time', () {
      expect(dateOnly(DateTime(2026, 5, 1, 13, 45)), DateTime(2026, 5, 1));
    });
  });
}
