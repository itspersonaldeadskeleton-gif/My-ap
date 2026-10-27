import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_ai/core/database/app_database.dart';
import 'package:wardrobe_ai/features/wardrobe/presentation/widgets/item_card.dart';

void main() {
  testWidgets('ItemCard shows name and exposes semantics', (tester) async {
    final item = WardrobeItem(
      id: 1, name: 'Navy Chinos', category: 'bottom',
      imagePath: null, cutoutPath: null, colors: '["#1F2A44"]',
      pattern: 'solid', fabric: 'cotton', fit: 'slim', formality: 3,
      season: 'all', isFavorite: true, wearCount: 0,
      createdAt: DateTime(2026, 1, 1),
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: SizedBox(width: 180, height: 220, child: ItemCard(item: item))),
    ));

    expect(find.text('Navy Chinos'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Navy Chinos, bottom, favorite')), findsOneWidget);
  });
}
