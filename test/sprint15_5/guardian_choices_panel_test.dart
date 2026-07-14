import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boussole/widgets/child/guardian_choices_panel.dart';

void main() {
  testWidgets('le panneau affiche exactement deux choix et peut fermer', (
    tester,
  ) async {
    var closed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GuardianChoicesPanel(
            onFirstChoice: () {},
            onSecondChoice: () {},
            onClose: () => closed = true,
          ),
        ),
      ),
    );
    expect(find.byKey(const ValueKey('guardian-choice-first')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('guardian-choice-second')),
      findsOneWidget,
    );
    expect(find.text('Continuer ma journée'), findsOneWidget);
    expect(find.text('Découvrir mes Trouvailles'), findsOneWidget);
    await tester.tap(find.text('Fermer'));
    expect(closed, isTrue);
  });
}
