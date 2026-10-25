import 'package:flutter/material.dart';

import '../../data/models/wardrobe_item.dart';
import '../../data/repositories/local_store.dart';
import '../../data/repositories/wardrobe_repository.dart';

class GarmentDetailScreen extends StatefulWidget {
  final WardrobeItem item;
  const GarmentDetailScreen({super.key, required this.item});

  @override
  State<GarmentDetailScreen> createState() => _GarmentDetailScreenState();
}

class _GarmentDetailScreenState extends State<GarmentDetailScreen> {
  late WardrobeItem _item;
  final _repo = WardrobeRepository(SharedPreferencesLocalStore());

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  Future<void> _toggleFavorite() async {
    await _repo.init();
    await _repo.toggleFavorite(_item.id);
    setState(() => _item = _item.copyWith(isFavorite: !_item.isFavorite));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_item.name),
        actions: [
          IconButton(
            icon: Icon(_item.isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_item.images.isNotEmpty)
            Image.network(
              _item.images.first.url,
              height: 240,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(height: 240, child: Center(child: Icon(Icons.image))),
            ),
          const SizedBox(height: 12),
          Text('Category: ${_item.category}'),
          Text('Subcategory: ${_item.subCategory}'),
          Text('Color: ${_item.color}'),
          if (_item.brand != null) Text('Brand: ${_item.brand}'),
          if (_item.size != null) Text('Size: ${_item.size}'),
          Text('Seasons: ${_item.seasons.join(', ')}'),
          Text('Tags: ${_item.tags.join(', ')}'),
        ],
      ),
    );
  }
}
