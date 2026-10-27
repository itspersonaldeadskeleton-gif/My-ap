import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/database/app_database.dart';
import '../../../wardrobe/presentation/widgets/item_thumb.dart';

class PlacedItem {
  const PlacedItem(this.item, this.rect);
  final WardrobeItem item;
  /// Position as fractions of the canvas (left, top, width, height).
  final Rect rect;
}

/// Where each category sits on the canvas (fractions of width/height).
Rect slotRect(String category, [int accessoryIndex = 0]) => switch (category) {
      'outerwear' => const Rect.fromLTWH(.42, .02, .54, .46),
      'top' => const Rect.fromLTWH(.04, .04, .54, .44),
      'dress' => const Rect.fromLTWH(.18, .03, .6, .72),
      'bottom' => const Rect.fromLTWH(.22, .47, .5, .34),
      'shoes' => const Rect.fromLTWH(.28, .82, .44, .17),
      _ => Rect.fromLTWH(.76, .50 + accessoryIndex * .17, .2, .15),
    };

/// The "mannequin board" where items drop into place one step at a time.
/// New tiles animate in; tiles already placed keep their state (stable keys).
class OutfitCanvas extends StatelessWidget {
  const OutfitCanvas({super.key, required this.placed, this.overlayIcon, this.overlayKey, this.stagger = false});
  final List<PlacedItem> placed;
  /// Shown (pulsing) on steps that have no garment, e.g. grooming.
  final IconData? overlayIcon;
  final String? overlayKey;
  /// Final Look: stagger tiles so the outfit "assembles".
  final bool stagger;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [cs.surfaceContainerHighest.withValues(alpha: .6), cs.surface],
        ),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: LayoutBuilder(builder: (_, c) {
        final w = c.maxWidth, h = c.maxHeight;
        return Stack(children: [
          Center(
            child: Icon(Icons.accessibility_new,
                size: h * .8, color: cs.onSurface.withValues(alpha: .05)),
          ),
          if (overlayIcon != null && placed.isEmpty || (overlayIcon != null))
            Center(
              child: Icon(overlayIcon, size: 72, color: cs.primary.withValues(alpha: .55))
                  .animate(key: ValueKey(overlayKey), onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(.9, .9), end: const Offset(1.1, 1.1), duration: 900.ms),
            ),
          for (var i = 0; i < placed.length; i++)
            Positioned(
              key: ValueKey('placed-${placed[i].item.id}'),
              left: placed[i].rect.left * w,
              top: placed[i].rect.top * h,
              width: placed[i].rect.width * w,
              height: placed[i].rect.height * h,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .2), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Semantics(
                  label: placed[i].item.name,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: ItemThumb(item: placed[i].item),
                  ),
                ),
              )
                  .animate(delay: stagger ? (160 * i).ms : Duration.zero)
                  .fadeIn(duration: 350.ms)
                  .moveY(begin: -90, end: 0, duration: 650.ms, curve: Curves.easeOutBack)
                  .scale(begin: const Offset(.6, .6), end: const Offset(1, 1), duration: 650.ms, curve: Curves.easeOutBack)
                  .rotate(begin: -.04, end: 0, duration: 650.ms),
            ),
        ]);
      }),
    );
  }
}
