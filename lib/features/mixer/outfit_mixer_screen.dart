import 'package:flutter/material.dart';

class OutfitMixerScreen extends StatefulWidget {
  const OutfitMixerScreen({super.key});

  @override
  State<OutfitMixerScreen> createState() => _OutfitMixerScreenState();
}

class _OutfitMixerScreenState extends State<OutfitMixerScreen> {
  final Map<String, String?> _slots = {
    'top': null,
    'bottom': null,
    'shoes': null,
    'outerwear': null,
    'accessories': null,
  };

  final List<String> _topItems = ['T-Shirt', 'Blouse', 'Sweater'];
  final List<String> _bottomItems = ['Jeans', 'Skirt', 'Trousers'];
  final List<String> _shoeItems = ['Sneakers', 'Boots', 'Loafers'];
  final List<String> _outerwearItems = ['Jacket', 'Coat', 'Cardigan'];
  final List<String> _accessoryItems = ['Belt', 'Scarf', 'Bag'];

  void _saveCombination() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Combination saved')),
    );
  }

  Widget _buildSlot(String label, String key) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DragTarget<String>(
          onAcceptWithDetails: (details) {
            setState(() {
              _slots[key] = details.data;
            });
          },
          builder: (context, candidateData, rejectedData) {
            return Container(
              width: double.infinity,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(
                  color: candidateData.isNotEmpty ? Colors.blue : Colors.grey,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: Center(
                child: _slots[key] == null
                    ? const Text('Drop here')
                    : Text(
                        _slots[key]!,
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDraggableItem(String item) {
    return Draggable<String>(
      data: item,
      feedback: Material(
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(item, style: const TextStyle(color: Colors.white)),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(item),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfit Mixer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveCombination,
            tooltip: 'Save combination',
          ),
        ],
      ),
      body: Row(
        children: [
          // Left side - Slots
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mix Your Outfit',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildSlot('Top', 'top'),
                  const SizedBox(height: 12),
                  _buildSlot('Bottom', 'bottom'),
                  const SizedBox(height: 12),
                  _buildSlot('Shoes', 'shoes'),
                  const SizedBox(height: 12),
                  _buildSlot('Outerwear', 'outerwear'),
                  const SizedBox(height: 12),
                  _buildSlot('Accessories', 'accessories'),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _saveCombination,
                    child: const Text('Save Combination'),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(),
          // Right side - Items and Compare
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available Items',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text('Tops', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _topItems.map(_buildDraggableItem).toList(),
                  ),
                  const SizedBox(height: 12),
                  const Text('Bottoms', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _bottomItems.map(_buildDraggableItem).toList(),
                  ),
                  const SizedBox(height: 12),
                  const Text('Shoes', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _shoeItems.map(_buildDraggableItem).toList(),
                  ),
                  const SizedBox(height: 12),
                  const Text('Outerwear', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _outerwearItems.map(_buildDraggableItem).toList(),
                  ),
                  const SizedBox(height: 12),
                  const Text('Accessories', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _accessoryItems.map(_buildDraggableItem).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Compare',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Top: ${_slots['top'] ?? 'None'}'),
                        Text('Bottom: ${_slots['bottom'] ?? 'None'}'),
                        Text('Shoes: ${_slots['shoes'] ?? 'None'}'),
                        Text('Outerwear: ${_slots['outerwear'] ?? 'None'}'),
                        Text('Accessories: ${_slots['accessories'] ?? 'None'}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
