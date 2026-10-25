import 'package:flutter/material.dart';

import '../../data/models/wardrobe_item.dart';
import 'garment_detail_screen.dart';

class WardrobeGrid extends StatefulWidget {
  final List<WardrobeItem> items;
  const WardrobeGrid({super.key, required this.items});

  @override
  State<WardrobeGrid> createState() => _WardrobeGridState();
}

class _WardrobeGridState extends State<WardrobeGrid> {
  String _query = '';
  String? _category;

  List<WardrobeItem> get _filtered {
    return widget.items.where((e) {
      final matchesQuery = _query.isEmpty ||
          e.name.toLowerCase().contains(_query.toLowerCase()) ||
          e.tags.any((t) => t.toLowerCase().contains(_query.toLowerCase()));
      final matchesCategory = _category == null || e.category == _category;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.items.map((e) => e.category).toSet().toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search',
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: const Text('All'),
                selected: _category == null,
                onSelected: (_) => setState(() => _category = null),
              ),
              ...categories.map((c) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilterChip(
                      label: Text(c),
                      selected: _category == c,
                      onSelected: (_) => setState(() => _category = c),
                    ),
                  )),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
            ),
            itemCount: _filtered.length,
            itemBuilder: (context, i) {
              final item = _filtered[i];
              return GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => GarmentDetailScreen(item: item)),
                ),
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: item.images.isNotEmpty
                            ? Image.network(item.images.first.url, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.image))
                            : const Icon(Icons.checkroom),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
