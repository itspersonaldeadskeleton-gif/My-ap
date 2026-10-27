import 'dart:io';
import 'dart:ui' as ui;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';

import '../../../core/database/outfit_log_writes.dart';
import '../../../core/database/providers.dart';
import '../../questionnaire/presentation/questionnaire_providers.dart';
import '../../recommendation/presentation/widgets/outfit_card.dart';
import '../domain/guide_args.dart';
import '../domain/guide_steps.dart';
import 'widgets/outfit_canvas.dart';

/// Final Look: assembled outfit, confetti, confidence message, rating, share.
class FinalLookScreen extends ConsumerStatefulWidget {
  const FinalLookScreen({super.key, required this.args});
  final StylingGuideArgs args;

  @override
  ConsumerState<FinalLookScreen> createState() => _FinalLookScreenState();
}

class _FinalLookScreenState extends ConsumerState<FinalLookScreen> {
  final _confetti = ConfettiController(duration: const Duration(seconds: 3));
  final _boundary = GlobalKey();
  int _rating = 0;
  int? _logId;

  @override
  void initState() {
    super.initState();
    _logId = widget.args.loggedId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confetti.play();
      HapticFeedback.heavyImpact();
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  List<PlacedItem> get _placed {
    var acc = 0;
    return [
      for (final i in widget.args.items)
        PlacedItem(i, slotRect(i.category, i.category == 'accessory' ? acc++ : 0)),
    ];
  }

  Future<void> _rate(int stars) async {
    final db = ref.read(appDatabaseProvider);
    setState(() => _rating = stars);
    HapticFeedback.selectionClick();
    // Log first if the user never pressed "Wear this", then attach the rating.
    _logId ??= await db.logOutfit(
      occasion: ref.read(questionnaireProvider).destination ?? '',
      outfitJson: jsonEncode(widget.args.outfit.toJson()),
      itemIds: widget.args.outfit.itemIds,
    );
    await db.rateOutfit(_logId!, stars);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thanks! We will tune future picks.')));
    }
  }

  Future<void> _share() async {
    try {
      final b = _boundary.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final img = await b.toImage(pixelRatio: 3);
      final data = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = await getTemporaryDirectory();
      final f = File('${dir.path}/wardrobeai_look.png');
      await f.writeAsBytes(data!.buffer.asUint8List());
      await Share.shareXFiles([XFile(f.path)], text: 'My look, styled with WardrobeAI');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not share the image. Try again.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final o = widget.args.outfit;
    final msg = confidenceMessage(o.matchScore, ref.read(questionnaireProvider).mood);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back to outfits',
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/recommendation'),
        ),
        title: const Text('Final look'),
      ),
      body: Stack(children: [
        ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 32), children: [
          RepaintBoundary(
            key: _boundary,
            child: Container(
              color: t.colorScheme.surface,
              padding: const EdgeInsets.all(8),
              child: Column(children: [
                SizedBox(
                  height: 380,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: .8,
                      child: OutfitCanvas(placed: _placed, stagger: true),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(o.title.isEmpty ? outfitLabel(o.label) : o.title,
                    style: t.textTheme.titleLarge, textAlign: TextAlign.center),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Text(msg, textAlign: TextAlign.center, style: t.textTheme.headlineSmall)
              .animate(delay: 900.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: .2),
          const SizedBox(height: 20),
          Text('How does it feel?', textAlign: TextAlign.center, style: t.textTheme.titleSmall),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var s = 1; s <= 5; s++)
              IconButton(
                tooltip: 'Rate $s star${s == 1 ? '' : 's'}',
                iconSize: 34,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                onPressed: () => _rate(s),
                icon: Icon(s <= _rating ? Icons.star : Icons.star_border,
                    color: t.colorScheme.primary),
              ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _share,
                icon: const Icon(Icons.ios_share),
                label: const Text('Share image'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => context.go('/plan'),
                child: const Text('Done'),
              ),
            ),
          ]),
        ]),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 28,
            gravity: .25,
            colors: [t.colorScheme.primary, Colors.amber, Colors.teal, Colors.pinkAccent],
          ),
        ),
      ]),
    );
  }
}
