import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../models/wardrobe_item.dart';
import '../models/wardrobe_item_image.dart';
import 'local_store.dart';

class WardrobeRepository {
  WardrobeRepository(this._store);
  final LocalStore _store;
  final _uuid = const Uuid();

  Future<void> init() => _store.init();

  Future<List<WardrobeItem>> getItems() async {
    final raw = await _store.readString(StoreKeys.wardrobeItems);
    if (raw == null) return const [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map((e) => WardrobeItem.fromJson(e)).toList();
  }

  Future<WardrobeItem> addItem(WardrobeItem item) async {
    final items = await getItems();
    final newItem = item.copyWith(
      id: item.id.isNotEmpty ? item.id : _uuid.v4(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    items.add(newItem);
    await _persist(items);
    return newItem;
  }

  Future<WardrobeItem> updateItem(WardrobeItem item) async {
    final items = await getItems();
    final index = items.indexWhere((e) => e.id == item.id);
    if (index == -1) throw StateError('Wardrobe item not found: ${item.id}');
    items[index] = item.copyWith(updatedAt: DateTime.now());
    await _persist(items);
    return items[index];
  }

  Future<void> deleteItem(String id) async {
    final items = await getItems()..removeWhere((e) => e.id == id);
    await _persist(items);
  }

  Future<void> toggleFavorite(String id) async {
    final items = await getItems();
    final index = items.indexWhere((e) => e.id == id);
    if (index == -1) return;
    items[index] = items[index].copyWith(isFavorite: !items[index].isFavorite);
    await _persist(items);
  }

  Future<void> addImage(String itemId, WardrobeItemImage image) async {
    final items = await getItems();
    final index = items.indexWhere((e) => e.id == itemId);
    if (index == -1) throw StateError('Wardrobe item not found: $itemId');
    final updated = items[index].copyWith(
      images: [...items[index].images, image],
      updatedAt: DateTime.now(),
    );
    items[index] = updated;
    await _persist(items);
  }

  Future<List<WardrobeItem>> getFavorites() async {
    final items = await getItems();
    return items.where((e) => e.isFavorite).toList();
  }

  Future<void> _persist(List<WardrobeItem> items) async {
    await _store.writeString(
      StoreKeys.wardrobeItems,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }
}
