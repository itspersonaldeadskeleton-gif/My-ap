import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../questionnaire/presentation/questionnaire_providers.dart';
import '../../recommendation/presentation/widgets/outfit_card.dart';
import '../domain/guide_args.dart';
import '../domain/guide_steps.dart';
import 'widgets/outfit_canvas.dart';

/// Swipeable step-by-step guide. The canvas on top updates as you move:
/// each step's garment drops onto the board.
class StylingGuideScreen extends ConsumerStatefulWidget {
  const StylingGuideScreen({super.key, required this.args});
  final StylingGuideArgs args;

  @override
  ConsumerState<StylingGuideScreen> createState() => _StylingGuideScreenState();
}

class _StylingGuideScreenState extends ConsumerState<StylingGuideScreen> {
  late final List<GuideStep> _steps;
  final _pc = PageController();
  int _i = 0;

  @override
  void initState() {
    super.initState();
    _steps = StylingStepsBuilder.build(
      items: widget.args.items,
      answers: ref.read(questionnaireProvider),
    );
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  /// Everything placed on the canvas up to and including step [upTo].
  List<PlacedItem> _placed(int upTo) {
    final out = <PlacedItem>[];
    var acc = 0;
    for (var s = 0; s <= upTo; s++) {
      for (final it in _steps[s].items) {
        out.add(PlacedItem(it, slotRect(it.category, it.category == 'accessory' ? acc++ : 0)));
      }
    }
    return out;
  }

  void _next() {
    if (_i >= _steps.length - 1) {
      context.pushReplacement('/final-look', extra: widget.args);
    } else {
      _pc.nextPage(duration: const Duration(milliseconds: 380), curve: Curves.easeInOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_i];
    final cs = Theme.of(context).colorScheme;
    final last = _i == _steps.length - 1;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close guide',
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text('${outfitLabel(widget.args.outfit.label)} · Step ${_i + 1} of ${_steps.length}',
            style: Theme.of(context).textTheme.titleMedium),
      ),
      body: SafeArea(
        child: Column(children: [
          // Progress dots
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (var k = 0; k < _steps.length; k++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: k == _i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: k <= _i ? cs.primary : cs.outlineVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
            ]),
          ),
          // Canvas (Hero from the results collage)
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Center(
                child: AspectRatio(
                  aspectRatio: .8,
                  child: Hero(
                    tag: 'collage-${widget.args.outfit.label}',
                    child: OutfitCanvas(
                      placed: _placed(_i),
                      overlayIcon: step.items.isEmpty ? step.icon : null,
                      overlayKey: step.id,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Swipeable instruction cards
          SizedBox(
            height: 210,
            child: PageView.builder(
              controller: _pc,
              itemCount: _steps.length,
              onPageChanged: (i) {
                HapticFeedback.selectionClick();
                setState(() => _i = i);
              },
              itemBuilder: (_, i) => _StepCard(step: _steps[i], index: i),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
            child: Row(children: [
              OutlinedButton(
                onPressed: _i == 0
                    ? null
                    : () => _pc.previousPage(
                        duration: const Duration(milliseconds: 380), curve: Curves.easeInOutCubic),
                style: OutlinedButton.styleFrom(minimumSize: const Size(96, 48)),
                child: const Text('Back'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _next,
                  child: Text(last ? 'See final look' : 'Next'),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.step, required this.index});
  final GuideStep step;
  final int index;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('STEP ${index + 1}',
                  style: t.textTheme.labelMedium?.copyWith(
                      color: t.colorScheme.primary, letterSpacing: 1.2, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(step.title, style: t.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(step.instruction, style: t.textTheme.bodyLarge),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: t.colorScheme.primary.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.lightbulb_outline, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Pro tip: ${step.tip}')),
                ]),
              ),
            ]).animate().fadeIn(duration: 300.ms).slideY(begin: .08),
          ),
        ),
      ),
    );
  }
}
