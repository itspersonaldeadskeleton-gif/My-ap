import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/recommendation_models.dart';
import 'flip_card.dart';
import 'outfit_collage.dart';

String outfitLabel(String l) => switch (l) {
      'best_match' => 'Best Match',
      'safe_choice' => 'Safe Choice',
      'bold_choice' => 'Bold Choice',
      _ => l,
    };

/// Front: collage + score. Back: why it works + what to avoid.
class OutfitCard extends StatelessWidget {
  const OutfitCard({super.key, required this.outfit, required this.items});
  final OutfitRecommendation outfit;
  final List<WardrobeItem> items;

  @override
  Widget build(BuildContext context) => FlipCard(
        semanticLabel:
            '${outfitLabel(outfit.label)}, score ${outfit.matchScore} out of 100',
        front: _front(context),
        back: _back(context),
      );

  Widget _front(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(outfitLabel(outfit.label).toUpperCase(),
                    style: t.textTheme.labelMedium?.copyWith(
                        color: t.colorScheme.primary, letterSpacing: 1.2, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(outfit.title.isEmpty ? outfitLabel(outfit.label) : outfit.title,
                    style: t.textTheme.titleLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
              ]),
            ),
            ScoreRing(score: outfit.matchScore),
          ]),
          const SizedBox(height: 12),
          Expanded(child: Hero(tag: 'collage-${outfit.label}', child: OutfitCollage(items: items))),
          const SizedBox(height: 8),
          Center(child: Text('Tap to see why it works', style: t.textTheme.labelMedium)),
        ]),
      ),
    );
  }

  Widget _back(BuildContext context) {
    final t = Theme.of(context);
    final w = outfit.why;
    Widget row(IconData i, String title, String text) => text.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(i, size: 22, color: t.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: t.textTheme.titleSmall),
                  Text(text),
                ]),
              ),
            ]),
          );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Why it works', style: t.textTheme.titleLarge),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(children: [
              row(Icons.palette_outlined, 'Colour theory', w.colorTheory),
              row(Icons.straighten, 'Proportions', w.proportions),
              row(Icons.cloud_outlined, 'Weather', w.weather),
              row(Icons.event_available_outlined, 'Occasion', w.occasion),
              if (outfit.avoid.isNotEmpty) ...[
                const Divider(),
                Text('What to avoid', style: t.textTheme.titleSmall),
                const SizedBox(height: 6),
                for (final a in outfit.avoid)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Icon(Icons.block, size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text(a)),
                    ]),
                  ),
              ],
            ]),
          ),
          Center(child: Text('Tap to flip back', style: t.textTheme.labelMedium)),
        ]),
      ),
    );
  }
}

/// Animated circular match score.
class ScoreRing extends StatelessWidget {
  const ScoreRing({super.key, required this.score});
  final int score;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(end: score / 100),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (_, v, __) => SizedBox(
          width: 64, height: 64,
          child: Stack(alignment: Alignment.center, children: [
            SizedBox(
              width: 64, height: 64,
              child: CircularProgressIndicator(value: v, strokeWidth: 6, strokeCap: StrokeCap.round),
            ),
            Text('${(v * 100).round()}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          ]),
        ),
      );
}
