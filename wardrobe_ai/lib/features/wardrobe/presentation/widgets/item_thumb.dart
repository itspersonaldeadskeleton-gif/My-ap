import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/color_utils.dart';

/// Cutout/photo of an item, or a colour swatch + icon for demo items.
/// Reused by collages (Step 4) and the styling guide (Step 5).
class ItemThumb extends StatelessWidget {
  const ItemThumb({super.key, required this.item, this.fit = BoxFit.contain});
  final WardrobeItem item;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final path = item.cutoutPath ?? item.imagePath;
    final colors = (jsonDecode(item.colors) as List).cast<String>();
    final c = colors.isEmpty ? Colors.grey : hexToColor(colors.first);
    if (path != null) {
      return Container(
        color: c.withValues(alpha: 0.12),
        child: Image.file(File(path), fit: fit),
      );
    }
    final icon = switch (item.category) {
      'top' => Icons.dry_cleaning_outlined,
      'bottom' => Icons.straighten,
      'outerwear' => Icons.checkroom,
      'shoes' => Icons.hiking,
      'accessory' => Icons.watch_outlined,
      _ => Icons.checkroom_outlined,
    };
    return Container(
      color: c,
      child: Icon(icon,
          color: c.computeLuminance() > .5 ? Colors.black54 : Colors.white70),
    );
  }
}
