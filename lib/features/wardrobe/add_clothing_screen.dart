import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/wardrobe_item.dart';
import '../../data/repositories/local_store.dart';
import '../../data/repositories/wardrobe_repository.dart';

class AddClothingScreen extends StatefulWidget {
  const AddClothingScreen({super.key});

  @override
  State<AddClothingScreen> createState() => _AddClothingScreenState();
}

class _AddClothingScreenState extends State<AddClothingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _subCategory = TextEditingController();
  final _color = TextEditingController();
  final _brand = TextEditingController();
  final _size = TextEditingController();
  final _tags = TextEditingController();
  String _category = 'top';
  final List<String> _seasons = ['spring'];
  String? _imagePath;
  final _picker = ImagePicker();
  final _repo = WardrobeRepository(SharedPreferencesLocalStore());

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imagePath = picked.path);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await _repo.init();
    final now = DateTime.now();
    final item = WardrobeItem(
      id: '',
      name: _name.text.trim(),
      category: _category,
      subCategory: _subCategory.text.trim(),
      color: _color.text.trim(),
      brand: _brand.text.trim().isEmpty ? null : _brand.text.trim(),
      size: _size.text.trim().isEmpty ? null : _size.text.trim(),
      seasons: List<String>.from(_seasons),
      tags: _tags.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      images: _imagePath == null
          ? const []
          : [
              WardrobeItemImage(
                id: const Uuid().v4(),
                url: _imagePath!,
                localPath: _imagePath,
                isPrimary: true,
                uploadedAt: now,
              )
            ],
      createdAt: now,
      updatedAt: now,
    );
    await _repo.addItem(item);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Clothing')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 160,
                color: Colors.grey.shade200,
                child: _imagePath == null
                    ? const Center(child: Icon(Icons.add_a_photo, size: 40))
                    : Image.file(File(_imagePath!), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            DropdownButtonFormField<String>(
              value: _category,
              items: const [
                DropdownMenuItem(value: 'top', child: Text('Top')),
                DropdownMenuItem(value: 'bottom', child: Text('Bottom')),
                DropdownMenuItem(value: 'shoes', child: Text('Shoes')),
                DropdownMenuItem(value: 'outerwear', child: Text('Outerwear')),
                DropdownMenuItem(value: 'accessory', child: Text('Accessory')),
              ],
              onChanged: (v) => setState(() => _category = v ?? 'top'),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextFormField(controller: _subCategory, decoration: const InputDecoration(labelText: 'Subcategory')),
            TextFormField(controller: _color, decoration: const InputDecoration(labelText: 'Color')),
            TextFormField(controller: _brand, decoration: const InputDecoration(labelText: 'Brand')),
            TextFormField(controller: _size, decoration: const InputDecoration(labelText: 'Size')),
            TextFormField(controller: _tags, decoration: const InputDecoration(labelText: 'Tags (comma separated)')),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['spring', 'summer', 'autumn', 'winter'].map((s) {
                final selected = _seasons.contains(s);
                return FilterChip(
                  label: Text(s),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _seasons.add(s);
                      } else {
                        _seasons.remove(s);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
