import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../../wardrobe/presentation/widgets/item_thumb.dart';

/// Overlapping collage of the outfit's items (uses background-removed cutouts).
class OutfitCollage extends StatelessWidget {
  const OutfitCollage({super.key, required this.items});
  final List<WardrobeItem> items;

  WardrobeItem? _first(String cat) {
    for (final i in items) {
      if (i.category == cat) return i;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final outer = _first('outerwear');
    final top = _first('top') ?? _first('dress');
    final bottom = _first('bottom');
    final shoes = _first('shoes');
    final accs = items.where((i) => i.category == 'accessory').take(3).toList();

    return LayoutBuilder(builder: (_, c) {
      final w = c.maxWidth, h = c.maxHeight;
      Widget tile(WardrobeItem i, double l, double t, double tw, double th) =>
          Positioned(
            left: l * w, top: t * h, width: tw * w, height: th * h,
            child: Semantics(
              label: i.name,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .18), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: ClipRRect(borderRadius: BorderRadius.circular(14), child: ItemThumb(item: i)),
              ),
            ),
          );

      return Stack(children: [
        if (outer != null) tile(outer, .42, .02, .54, .46),
        if (top != null) tile(top, .04, .04, .54, .44),
        if (bottom != null) tile(bottom, .22, .47, .5, .34),
        if (shoes != null) tile(shoes, .28, .82, .44, .17),
        for (var k = 0; k < accs.length; k++) tile(accs[k], .76, .50 + k * .17, .2, .15),
      ]);
    });
  }
}
