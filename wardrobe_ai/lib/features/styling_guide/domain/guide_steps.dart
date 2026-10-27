import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../questionnaire/domain/occasion_answers.dart';

/// One screen of the styling guide.
class GuideStep {
  const GuideStep({
    required this.id,
    required this.title,
    required this.instruction,
    required this.tip,
    this.items = const [],
    this.icon = Icons.checkroom,
  });
  final String id, title, instruction, tip;
  final List<WardrobeItem> items;
  final IconData icon;
}

/// Turns an outfit into the ordered steps (pure, unit-tested).
/// Instructions come from item attributes (fit, fabric, formality), so the
/// guide works offline and instantly.
class StylingStepsBuilder {
  static List<GuideStep> build({
    required List<WardrobeItem> items,
    required OccasionAnswers answers,
  }) {
    WardrobeItem? first(String c) {
      for (final i in items) {
        if (i.category == c) return i;
      }
      return null;
    }

    final top = first('top'), bottom = first('bottom'), dress = first('dress');
    final outer = first('outerwear'), shoes = first('shoes');
    final accs = items.where((i) => i.category == 'accessory').take(3).toList();

    final temp = answers.weather?.tempC ?? 20;
    final cold = temp <= 12, hot = temp >= 27;
    final evening = answers.timeOfDay == 'Evening' || answers.timeOfDay == 'Night';

    final steps = <GuideStep>[
      GuideStep(
        id: 'base',
        title: 'Base layer',
        icon: Icons.layers_outlined,
        instruction: cold
            ? 'Start with a thin merino or thermal base layer.'
            : hot
                ? 'Wear a light, breathable cotton or linen undershirt.'
                : 'Start with a fresh, well-fitting undershirt.',
        tip: cold
            ? 'Thin layers trap heat better than one thick one.'
            : 'Choose a colour close to your skin tone so it never shows through.',
      ),
    ];

    if (dress != null) {
      steps.add(GuideStep(
        id: 'dress',
        title: 'The dress',
        items: [dress],
        instruction: 'Step in, zip up, and let the hem fall evenly all round.',
        tip: 'Steam it for 30 seconds: it hangs better and looks sharper.',
      ));
    } else {
      if (bottom != null) {
        steps.add(GuideStep(
          id: 'bottom',
          title: 'Bottoms',
          items: [bottom],
          instruction: _bottom(bottom),
          tip: 'A crisp crease reads as effort. Steam or press before you leave.',
        ));
      }
      if (top != null) {
        steps.add(GuideStep(
          id: 'top',
          title: 'Top',
          items: [top],
          instruction: _top(top),
          tip: 'The shoulder seam should sit right on your shoulder bone.',
        ));
      }
    }

    if (outer != null) {
      steps.add(GuideStep(
        id: 'layering',
        title: 'Layering',
        items: [outer],
        instruction: _outer(outer),
        tip: 'Sleeves should end at the wrist bone, with a hint of cuff showing.',
      ));
    }

    if (shoes != null) {
      steps.add(GuideStep(
        id: 'shoes',
        title: 'Shoes',
        items: [shoes],
        instruction: _shoes(shoes),
        tip: 'Match belt and shoe tones for a cohesive line.',
      ));
    }

    if (accs.isNotEmpty) {
      steps.add(GuideStep(
        id: 'accessories',
        title: 'Accessories',
        items: accs,
        icon: Icons.watch_outlined,
        instruction: accs.map(_acc).join(' '),
        tip: 'Two accessories max. Let one be the statement.',
      ));
    }

    steps.add(GuideStep(
      id: 'grooming',
      title: 'Grooming & fragrance',
      icon: Icons.auto_awesome,
      instruction:
          'Tidy your hair, moisturise and check your nails. Then add fragrance: two sprays on pulse points, not on clothes.',
      tip: evening || cold
          ? 'Deeper woody or amber scents suit evenings and cold weather.'
          : 'Fresh citrus or aquatic scents suit daytime and warmth.',
    ));

    steps.add(const GuideStep(
      id: 'final',
      title: 'Final check',
      icon: Icons.check_circle_outline,
      instruction:
          'Mirror check: collar flat, hems even, no lint, zips closed, shoes clean.',
      tip: 'Drop your shoulders and smile. Confidence is the last accessory.',
    ));
    return steps;
  }

  static String _bottom(WardrobeItem b) {
    final n = b.name.toLowerCase(), f = b.fabric.toLowerCase();
    if (n.contains('short')) {
      return 'Check the hem sits around mid-thigh; roll it once if it feels too long.';
    }
    if (n.contains('jean') || f.contains('denim')) {
      return 'Cuff the jeans once, about 3 cm, so the shoe shows.';
    }
    if (b.fit == 'slim' || b.fit == 'tailored') {
      return 'Button and zip up, then check the hem: it should just skim the top of your shoes.';
    }
    return 'Pull them on and settle the waistband flat at your natural waist.';
  }

  static String _top(WardrobeItem t) {
    final n = t.name.toLowerCase(), f = t.fabric.toLowerCase();
    if (t.fit == 'relaxed' || t.fit == 'oversized') {
      return 'Half-tuck the shirt: tuck only the front, just past the belt line.';
    }
    if (f.contains('wool') || n.contains('knit') || n.contains('sweater')) {
      return 'Let it hang over the waistband with no tuck, and smooth the hem.';
    }
    if (t.formality >= 3) {
      return 'Tuck in cleanly, then pull up slightly for a soft blouse.';
    }
    return 'Leave it untucked; the hem should land around mid-fly.';
  }

  static String _outer(WardrobeItem o) => (o.fit == 'tailored' || o.formality >= 4)
      ? 'Fasten only the middle button, or wear it open. Never all of them.'
      : 'Zip or button it halfway so the layer underneath shows.';

  static String _shoes(WardrobeItem s) {
    final n = s.name.toLowerCase();
    if (s.formality >= 4) return 'Wipe or polish them and tie the laces flat and even.';
    if (n.contains('sneaker')) return 'Clean the soles, lace snugly and tuck loose laces in.';
    if (n.contains('boot')) return 'Let the trouser hem fall over the boot with no bunching.';
    return 'Slip them on, check the laces and wipe off any scuffs.';
  }

  static String _acc(WardrobeItem a) {
    final n = a.name.toLowerCase();
    if (n.contains('belt')) {
      return 'Thread the belt through every loop and match its leather to your shoes.';
    }
    if (n.contains('watch')) return 'Slide the watch just above your wrist bone.';
    return 'Add the ${a.name}.';
  }
}

/// Short confidence message for the Final Look screen (unit-tested).
String confidenceMessage(int score, String? mood) {
  if (mood == 'Romantic') return 'Effortless charm. They will not know what hit them.';
  if (mood == 'Playful') return 'Fun, fresh and totally you. Go enjoy it.';
  if (score >= 85) return 'You look unreasonably good. Walk in like you own the room.';
  if (score >= 70) return 'Sharp, comfortable and put together. You have got this.';
  return 'Solid and wearable. Add a confident smile and you are set.';
}
