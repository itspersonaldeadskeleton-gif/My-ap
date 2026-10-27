import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/wardrobe_writes.dart';
import '../../../core/utils/color_utils.dart';
import '../data/image_store.dart';
import '../data/tagging_repository.dart';
import '../domain/clothing_tags.dart';
import 'widgets/skeleton.dart';
import 'wardrobe_services.dart';

enum _Phase { pick, working, review, error }

/// Add (camera/gallery -> background removal -> AI tags -> edit -> save)
/// or edit an existing item's tags.
class AddItemScreen extends ConsumerStatefulWidget {
  const AddItemScreen({super.key, this.existing});
  final WardrobeItem? existing;

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  static const _palette = [
    '#161616', '#F5F5F0', '#8E9196', '#1F2A44', '#2E4A7A', '#5E6B3F',
    '#B98B5A', '#5A3A25', '#B4442D', '#E8C547', '#7A4E9E', '#E58AA8',
  ];

  _Phase _phase = _Phase.pick;
  File? _orig, _cut;
  ClothingTags _tags = const ClothingTags();
  final _name = TextEditingController();
  final _fabric = TextEditingController();
  String _error = '';
  bool _canRetry = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _tags = ClothingTags(
        name: e.name, category: e.category, pattern: e.pattern,
        colors: (jsonDecode(e.colors) as List).cast<String>(),
        fabric: e.fabric, fit: e.fit, formality: e.formality, season: e.season,
      );
      _name.text = e.name;
      _fabric.text = e.fabric;
      final p = e.cutoutPath ?? e.imagePath;
      if (p != null) _cut = File(p);
      _phase = _Phase.review;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _fabric.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final x = await ImagePicker()
          .pickImage(source: source, maxWidth: 1280, imageQuality: 85);
      if (x == null) return;
      _orig = File(x.path);
      await _analyze();
    } on PlatformException catch (e) {
      // Denied camera / photo permission lands here.
      _fail(
        e.code.contains('denied')
            ? 'Camera or photo access was denied. Enable it in system Settings, or choose another source.'
            : 'Could not open the picker (${e.code}).',
        retry: false,
      );
    }
  }

  Future<void> _analyze() async {
    setState(() => _phase = _Phase.working);
    final cutting = ref.read(bgRemovalProvider).remove(_orig!); // runs in parallel
    try {
      final tags = await ref.read(taggingRepoProvider).analyze(_orig!);
      _cut = await cutting;
      if (!mounted) return;
      setState(() {
        _tags = tags;
        _name.text = tags.name;
        _fabric.text = tags.fabric;
        _phase = _Phase.review;
      });
      HapticFeedback.lightImpact();
    } on TaggingException catch (e) {
      _cut = await cutting;
      _fail(e.message, retry: e.kind != TaggingErrorKind.blurry);
    }
  }

  void _fail(String msg, {required bool retry}) {
    if (!mounted) return;
    setState(() {
      _error = msg;
      _canRetry = retry;
      _phase = _Phase.error;
    });
  }

  Future<void> _save() async {
    final db = ref.read(appDatabaseProvider);
    final old = widget.existing;
    var img = old?.imagePath, cut = old?.cutoutPath;
    if (_orig != null) {
      img = await persistImage(_orig!);
      if (_cut != null) cut = await persistImage(_cut!, suffix: '_cut');
    }
    final c = WardrobeItemsCompanion(
      name: Value(_name.text.trim().isEmpty ? 'New item' : _name.text.trim()),
      category: Value(_tags.category),
      imagePath: Value(img),
      cutoutPath: Value(cut),
      colors: Value(jsonEncode(_tags.colors)),
      pattern: Value(_tags.pattern),
      fabric: Value(_fabric.text.trim().isEmpty ? 'unknown' : _fabric.text.trim()),
      fit: Value(_tags.fit),
      formality: Value(_tags.formality),
      season: Value(_tags.season),
    );
    old == null ? await db.insertItem(c) : await db.updateItem(old.id, c);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Edit tags' : 'Add item'),
        actions: [
          if (editing)
            IconButton(
              tooltip: 'Delete item',
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                await ref.read(appDatabaseProvider).deleteItem(widget.existing!.id);
                if (mounted) context.pop();
              },
            ),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: switch (_phase) {
            _Phase.pick => _pickView(),
            _Phase.working => _workingView(),
            _Phase.error => _errorView(),
            _Phase.review => _reviewView(),
          },
        ),
      ),
    );
  }

  Widget _pickView() => Padding(
        key: const ValueKey('pick'),
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Text('Photograph one item on a plain surface, in good light.',
              style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 20),
          for (final o in [
            (Icons.photo_camera_outlined, 'Take a photo', ImageSource.camera),
            (Icons.photo_library_outlined, 'Choose from gallery', ImageSource.gallery),
          ])
            Card(
              child: ListTile(
                minVerticalPadding: 22,
                leading: Icon(o.$1, size: 30),
                title: Text(o.$2),
                onTap: () => _pick(o.$3),
              ),
            ),
        ]),
      );

  Widget _preview() => ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 200,
          width: double.infinity,
          color: Colors.black.withValues(alpha: 0.05),
          child: (_cut ?? _orig) == null
              ? const Icon(Icons.checkroom, size: 56)
              : Image.file((_cut ?? _orig)!, fit: BoxFit.contain),
        ),
      );

  Widget _workingView() => ListView(
        key: const ValueKey('work'),
        padding: const EdgeInsets.all(20),
        children: [
          _preview(),
          const SizedBox(height: 16),
          Text('Analyzing your item…', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          const FormSkeleton(),
        ],
      );

  Widget _errorView() => ListView(
        key: const ValueKey('err'),
        padding: const EdgeInsets.all(20),
        children: [
          if (_orig != null) _preview(),
          const SizedBox(height: 20),
          Icon(Icons.error_outline, size: 40, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(_error, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          if (_canRetry && _orig != null)
            FilledButton(onPressed: _analyze, child: const Text('Retry analysis')),
          const SizedBox(height: 10),
          OutlinedButton(
              onPressed: () => setState(() => _phase = _Phase.pick),
              child: const Text('Retake photo')),
          TextButton(
              onPressed: () => setState(() => _phase = _Phase.review),
              child: const Text('Enter tags manually')),
        ],
      );

  Widget _label(String s) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(s, style: Theme.of(context).textTheme.titleSmall),
      );

  Widget _choice(List<String> opts, String sel, ValueChanged<String> on) => Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (final o in opts)
            ChoiceChip(
              label: Text(o),
              selected: o == sel,
              onSelected: (_) => setState(() => on(o)),
            ),
        ],
      );

  Widget _reviewView() {
    final all = {..._palette, ..._tags.colors}.toList();
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      key: const ValueKey('review'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        _preview(),
        _label('Name'),
        TextField(controller: _name, decoration: const InputDecoration(border: OutlineInputBorder())),
        _label('Category'),
        _choice(AppConstants.categories, _tags.category,
            (v) => _tags = _tags.copyWith(category: v)),
        _label('Colours'),
        Wrap(spacing: 10, runSpacing: 10, children: [
          for (final h in all)
            Builder(builder: (_) {
              final on = _tags.colors.contains(h);
              final c = hexToColor(h);
              return Semantics(
                button: true,
                selected: on,
                label: 'Colour ${colorFamily(h)}',
                child: InkResponse(
                  onTap: () => setState(() => _tags = _tags.copyWith(
                      colors: on
                          ? (List.of(_tags.colors)..remove(h))
                          : [..._tags.colors, h])),
                  child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: c, shape: BoxShape.circle,
                      border: Border.all(
                          color: on ? scheme.primary : Colors.black26,
                          width: on ? 3 : 1),
                    ),
                    child: on
                        ? Icon(Icons.check,
                            color: c.computeLuminance() > .5 ? Colors.black : Colors.white)
                        : null,
                  ),
                ),
              );
            }),
        ]),
        _label('Pattern'),
        _choice(['solid', 'striped', 'checked', 'floral', 'graphic', 'textured', 'other'],
            _tags.pattern, (v) => _tags = _tags.copyWith(pattern: v)),
        _label('Fabric'),
        TextField(controller: _fabric, decoration: const InputDecoration(border: OutlineInputBorder())),
        _label('Fit'),
        _choice(['slim', 'regular', 'relaxed', 'oversized', 'tailored', 'straight'],
            _tags.fit, (v) => _tags = _tags.copyWith(fit: v)),
        _label('Formality: ${_tags.formality} / 5'),
        Slider(
          min: 1, max: 5, divisions: 4,
          label: '${_tags.formality}',
          value: _tags.formality.toDouble(),
          onChanged: (v) => setState(() => _tags = _tags.copyWith(formality: v.round())),
        ),
        _label('Season'),
        _choice(AppConstants.seasons, _tags.season,
            (v) => _tags = _tags.copyWith(season: v)),
        const SizedBox(height: 28),
        FilledButton(onPressed: _save, child: Text(widget.existing == null ? 'Save to wardrobe' : 'Save changes')),
      ],
    );
  }
}
