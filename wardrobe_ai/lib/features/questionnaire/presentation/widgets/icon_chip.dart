import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../questionnaire_options.dart';

/// Large tappable chip with an icon. 56dp tall, semantic "selected" state.
class IconChip extends StatelessWidget {
  const IconChip({super.key, required this.opt, required this.selected, required this.onTap});
  final Opt opt;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: opt.label,
      excludeSemantics: true,
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        decoration: BoxDecoration(
          color: selected ? cs.primary.withValues(alpha: 0.16) : cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? cs.primary : cs.outlineVariant, width: selected ? 2 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56, minWidth: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(opt.icon, color: selected ? cs.primary : null),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(opt.label,
                      style: TextStyle(fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// Wrap of [IconChip]s with a staggered fade-in. Works for single or multi select.
class ChoiceWrap extends StatelessWidget {
  const ChoiceWrap({super.key, required this.options, required this.isSelected, required this.onTap});
  final List<Opt> options;
  final bool Function(String label) isSelected;
  final void Function(String label) onTap;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (var i = 0; i < options.length; i++)
            IconChip(
              opt: options[i],
              selected: isSelected(options[i].label),
              onTap: () => onTap(options[i].label),
            ).animate(delay: (50 * i).ms).fadeIn(duration: 300.ms).slideY(begin: 0.15),
        ],
      );
}
