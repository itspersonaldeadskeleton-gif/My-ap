import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fitmind/main.dart';

void main() {
  testWidgets('app builds', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: FitMindApp()));
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
