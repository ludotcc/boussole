import 'package:boussole/models/daily_light_summary.dart';
import 'package:boussole/widgets/child/progress_light_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('affiche Ma Lumière avec la progression calculée', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProgressLightBar(
            summary: DailyLightSummary(
              childId: 'child',
              date: DateTime(2026, 7, 14),
              completedItems: 1,
              totalItems: 4,
            ),
          ),
        ),
      ),
    );
    expect(find.text('Ma Lumière'), findsOneWidget);
    final indicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(indicator.value, .25);
  });
}
