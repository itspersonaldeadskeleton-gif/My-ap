import '../../../core/database/app_database.dart';

enum TripStyle { casual, business, mixed, formal }

class PackingList {
  const PackingList(this.sections, this.essentials);
  final Map<String, List<WardrobeItem>> sections;
  final List<String> essentials;

  String toText(int days, String climate) {
    final b = StringBuffer('Packing list: $days days, $climate\n');
    sections.forEach((k, v) {
      b.writeln('\n$k');
      for (final i in v) {
        b.writeln('[ ] ${i.name}');
      }
    });
    b.writeln('\nEssentials');
    for (final e in essentials) {
      b.writeln('[ ] $e');
    }
    return b.toString();
  }
}

/// Picks pieces from the wardrobe for a trip (pure, unit-tested).
class PackingListBuilder {
  static PackingList build({
    required List<WardrobeItem> items,
    required int days,
    required String climate, // Hot | Mild | Cool | Cold | Rainy
    required TripStyle style,
  }) {
    bool seasonOk(WardrobeItem i) {
      if (i.season == 'all') return true;
      return switch (climate) {
        'Hot' => i.season == 'summer' || i.season == 'spring',
        'Cold' => i.season == 'winter' || i.season == 'autumn',
        'Cool' || 'Rainy' => i.season != 'summer',
        _ => true,
      };
    }

    bool styleOk(WardrobeItem i) => switch (style) {
          TripStyle.casual => i.formality <= 3,
          TripStyle.business => i.formality >= 3,
          TripStyle.formal => i.formality >= 4,
          TripStyle.mixed => true,
        };

    List<WardrobeItem> pick(String cat, int n, {bool filterStyle = true}) {
      final all = items.where((i) => i.category == cat).toList();
      var c = all.where((i) => seasonOk(i) && (!filterStyle || styleOk(i))).toList();
      if (c.isEmpty) c = all.where(seasonOk).toList();
      if (c.isEmpty) c = all;
      // Prefer favourites, then what you actually wear.
      c.sort((a, b) {
        final f = (b.isFavorite ? 1 : 0) - (a.isFavorite ? 1 : 0);
        if (f != 0) return f;
        final w = b.wearCount - a.wearCount;
        return w != 0 ? w : a.name.compareTo(b.name);
      });
      return c.take(n).toList();
    }

    final tops = days <= 1 ? 1 : ((days * 0.7).ceil() + 1).clamp(1, days);
    final sections = <String, List<WardrobeItem>>{
      'Tops': pick('top', tops),
      'Bottoms': pick('bottom', (days / 3).ceil() + 1),
      'Dresses': pick('dress', (days / 3).ceil()),
      if (climate == 'Cool' || climate == 'Cold' || climate == 'Rainy')
        'Outer layer': pick('outerwear', climate == 'Cold' && days > 7 ? 2 : 1),
      'Shoes': pick('shoes', days > 4 ? 3 : 2),
      'Accessories': pick('accessory', 2, filterStyle: false),
    }..removeWhere((_, v) => v.isEmpty);

    return PackingList(sections, [
      '${days + 1} × underwear',
      '${days + 1} × socks',
      'Toiletries',
      'Phone charger',
      if (climate == 'Rainy') 'Compact umbrella',
      if (climate == 'Hot') 'Sunscreen and sunglasses',
      if (climate == 'Cold') 'Gloves and a warm hat',
    ]);
  }
}
