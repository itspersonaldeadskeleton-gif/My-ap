import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Tap to flip between [front] and [back] with a 3D rotation.
class FlipCard extends StatefulWidget {
  const FlipCard({super.key, required this.front, required this.back, this.semanticLabel = 'Outfit card'});
  final Widget front, back;
  final String semanticLabel;

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 550));
  bool _flipped = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    _flipped ? _c.reverse() : _c.forward();
    _flipped = !_flipped;
  }

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: '${widget.semanticLabel}. Double tap to flip.',
        child: GestureDetector(
          onTap: _toggle,
          child: AnimatedBuilder(
            animation: CurvedAnimation(parent: _c, curve: Curves.easeInOut),
            builder: (_, __) {
              final angle = Curves.easeInOut.transform(_c.value) * math.pi;
              final showBack = angle > math.pi / 2;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(angle),
                child: showBack
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(math.pi),
                        child: widget.back)
                    : widget.front,
              );
            },
          ),
        ),
      );
}
