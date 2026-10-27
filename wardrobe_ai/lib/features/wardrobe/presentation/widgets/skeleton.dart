import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Shimmering placeholder block, shown while the AI analyzes a photo.
class Skeleton extends StatelessWidget {
  const Skeleton({super.key, this.height = 18, this.width, this.radius = 12});
  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(radius),
        ),
      ).animate(onPlay: (c) => c.repeat()).shimmer(
          duration: 1200.ms, color: Colors.white.withValues(alpha: 0.35));
}

/// Skeleton shaped like the tag form.
class FormSkeleton extends StatelessWidget {
  const FormSkeleton({super.key});
  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Analyzing your photo',
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Skeleton(height: 52),
          SizedBox(height: 18),
          Skeleton(height: 18, width: 120),
          SizedBox(height: 10),
          Row(children: [
            Skeleton(height: 40, width: 80), SizedBox(width: 8),
            Skeleton(height: 40, width: 80), SizedBox(width: 8),
            Skeleton(height: 40, width: 80),
          ]),
          SizedBox(height: 18),
          Skeleton(height: 18, width: 90),
          SizedBox(height: 10),
          Row(children: [
            Skeleton(height: 40, width: 40, radius: 20), SizedBox(width: 10),
            Skeleton(height: 40, width: 40, radius: 20), SizedBox(width: 10),
            Skeleton(height: 40, width: 40, radius: 20),
          ]),
          SizedBox(height: 18),
          Skeleton(height: 18, width: 140),
          SizedBox(height: 10),
          Skeleton(height: 36),
        ]),
      );
}
