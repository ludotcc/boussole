import 'package:boussole/widgets/child/parent_access_gesture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('opens the parent PIN page only after the full hold', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/house',
      routes: [
        GoRoute(
          path: '/house',
          builder: (_, _) => const Scaffold(
            body: ParentAccessGesture(
              holdDuration: Duration(milliseconds: 100),
              child: SizedBox(width: 120, height: 80),
            ),
          ),
        ),
        GoRoute(
          path: '/parent-unlock',
          builder: (_, _) => const Scaffold(body: Text('PIN parent')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(ParentAccessGesture)),
    );
    await tester.pump(const Duration(milliseconds: 99));
    expect(find.text('PIN parent'), findsNothing);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('PIN parent'), findsOneWidget);
    await gesture.up();
  });
}
