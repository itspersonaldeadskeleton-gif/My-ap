import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/color_utils.dart';

/// Grid tile for one wardrobe item. Shows the cutout if available,
/// otherwise a colour swatch + category icon (used for demo data).
class ItemCard extends StatelessWidget {
  const ItemCard({super.key, required this.item, this.onTap, this.onFavorite});
  final WardrobeItem item;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;

  IconData get _icon => switch (item.category) {
        'top' => Icons.dry_cleaning_outlined,
        'bottom' => Icons.straighten,
        'outerwear' => Icons.checkroom,
        'shoes' => Icons.hiking,
        'accessory' => Icons.watch_outlined,
        _ => Icons.checkroom_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final colors = (jsonDecode(item.colors) as List).cast<String>();
    final swatch = colors.isEmpty ? Colors.grey : hexToColor(colors.first);
    final path = item.cutoutPath ?? item.imagePath;

    return Semantics(
      button: true,
      label: '${item.name}, ${item.category}'
          '${item.isFavorite ? ', favorite' : ''}',
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Stack(children: [
            Positioned.fill(
              child: Hero(
                tag: 'item-${item.id}',
                child: path != null
                    ? Image.file(File(path), fit: BoxFit.cover)
                    : Container(
                        color: swatch.withValues(alpha: 0.9),
                        child: Icon(_icon,
                            size: 48,
                            color: swatch.computeLuminance() > 0.5
                                ? Colors.black54
                                : Colors.white70),
                      ),
              ),
            ),
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
                child: Text(item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge),
              ),
            ),
            Positioned(
              top: 0, right: 0,
              child: IconButton(
                tooltip: item.isFavorite ? 'Remove favorite' : 'Add favorite',
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                onPressed: onFavorite,
                icon: Icon(item.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: item.isFavorite
                        ? Theme.of(context).colorScheme.primary
                        : Colors.black45),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
