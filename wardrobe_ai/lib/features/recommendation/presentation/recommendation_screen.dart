import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/outfit_log_writes.dart';
import '../../../core/database/providers.dart';
import '../../questionnaire/presentation/questionnaire_providers.dart';
import '../../wardrobe/presentation/widgets/skeleton.dart';
import '../../wardrobe/presentation/wardrobe_providers.dart';
import '../data/recommendation_repository.dart';
import '../domain/recommendation_models.dart';
import 'recommendation_providers.dart';
import '../../styling_guide/domain/guide_args.dart';
import 'widgets/outfit_card.dart';

/// Shows 3 AI outfits (Best Match / Safe / Bold) as flippable cards.
class RecommendationScreen extends ConsumerStatefulWidget {
  const RecommendationScreen({super.key});
  @override
  ConsumerState<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends ConsumerState<RecommendationScreen> {
  final _pc = PageController(viewportFraction: 0.92);
  int _page = 0;
  final _logged = <String, int>{};

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  Future<void> _wear(OutfitRecommendation o) async {
    final answers = ref.read(questionnaireProvider);
    final id = await ref.read(appDatabaseProvider).logOutfit(
          occasion: answers.destination ?? '',
          outfitJson: jsonEncode(o.toJson()),
          itemIds: o.itemIds,
        );
    HapticFeedback.mediumImpact();
    setState(() => _logged[o.label] = id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged. Have a great time!')));
    }
  }

  void _showGaps(List<WardrobeGap> gaps) => showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (_) => ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Text('Wardrobe gaps', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            for (final g in gaps)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(g.action == 'borrow' ? Icons.swap_horiz : Icons.shopping_bag_outlined),
                title: Text(g.item),
                subtitle: Text('${g.action == 'borrow' ? 'Borrow' : 'Buy'} · ${g.reason}'),
              ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(recommendationProvider);
    final wardrobe = ref.watch(wardrobeItemsProvider).valueOrNull ?? const [];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back to Plan',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/plan'),
        ),
        title: const Text('Your outfits'),
      ),
      body: SafeArea(
        child: result.when(
          loading: _loading,
          error: (e, _) => _error(e),
          data: (r) {
            final byId = {for (final i in wardrobe) i.id: i};
            final cur = r.outfits[_page.clamp(0, r.outfits.length - 1)];
            return Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  for (var i = 0; i < r.outfits.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _page ? 26 : 8, height: 8,
                      decoration: BoxDecoration(
                        color: i == _page
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                ]),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pc,
                  itemCount: r.outfits.length,
                  onPageChanged: (i) {
                    HapticFeedback.selectionClick();
                    setState(() => _page = i);
                  },
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    child: OutfitCard(
                      outfit: r.outfits[i],
                      items: [for (final id in r.outfits[i].itemIds) if (byId[id] != null) byId[id]!],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(children: [
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _logged.containsKey(cur.label) ? null : () => _wear(cur),
                        icon: Icon(_logged.containsKey(cur.label) ? Icons.check : Icons.event_available),
                        label: Text(_logged.containsKey(cur.label) ? 'Logged' : 'Wear this'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => context.push('/styling', extra: StylingGuideArgs(
                              outfit: cur,
                              items: [for (final id in cur.itemIds) if (byId[id] != null) byId[id]!],
                              loggedId: _logged[cur.label],
                            )),
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('Style me'),
                      ),
                    ),
                  ]),
                  if (r.gaps.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => _showGaps(r.gaps),
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: Text('Wardrobe gaps (${r.gaps.length})'),
                    ),
                ]),
              ),
            ]);
          },
        ),
      ),
    );
  }

  Widget _loading() => ListView(padding: const EdgeInsets.all(20), children: const [
        Text('Matching your wardrobe to the occasion…'),
        SizedBox(height: 16),
        Skeleton(height: 380, radius: 24),
        SizedBox(height: 16),
        Skeleton(height: 20, width: 200),
        SizedBox(height: 10),
        Skeleton(height: 20),
      ]);

  Widget _error(Object e) {
    final kind = e is RecommendationException ? e.kind : null;
    final msg = e is RecommendationException ? e.message : 'Something went wrong. Please retry.';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(kind == RecommendationErrorKind.offline ? Icons.wifi_off : Icons.error_outline, size: 48),
          const SizedBox(height: 12),
          Text(msg, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          if (kind != RecommendationErrorKind.tooFewItems && kind != RecommendationErrorKind.noKey)
            FilledButton(
                onPressed: () => ref.invalidate(recommendationProvider),
                child: const Text('Retry')),
          TextButton(
              onPressed: () => context.go(kind == RecommendationErrorKind.tooFewItems ? '/wardrobe' : '/plan'),
              child: Text(kind == RecommendationErrorKind.tooFewItems ? 'Go to wardrobe' : 'Change my answers')),
        ]),
      ),
    );
  }
}
