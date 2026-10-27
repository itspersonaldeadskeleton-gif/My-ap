import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_ai/features/questionnaire/presentation/questionnaire_screen.dart';

void main() {
  testWidgets('Next unlocks after picking a mood and advances', (tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: QuestionnaireScreen()),
    ));
    await tester.pumpAndSettle();

    FilledButton next() =>
        tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Next'));

    expect(find.text('How are you feeling?'), findsOneWidget);
    expect(next().onPressed, isNull); // required question, nothing chosen

    await tester.tap(find.text('Confident'));
    await tester.pumpAndSettle();
    expect(next().onPressed, isNotNull);

    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();
    expect(find.text('What time of day?'), findsOneWidget);
  });
}
