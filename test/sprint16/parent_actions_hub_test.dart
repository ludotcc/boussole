import 'package:boussole/models/child_model.dart';
import 'package:boussole/models/companion_memory.dart';
import 'package:boussole/models/family_member_model.dart';
import 'package:boussole/models/secret_mission.dart';
import 'package:boussole/models/shard_wallet.dart';
import 'package:boussole/pages/dashboard_page.dart';
import 'package:boussole/pages/parent_mission_validations_page.dart';
import 'package:boussole/providers/children_provider.dart';
import 'package:boussole/providers/companion_provider.dart';
import 'package:boussole/providers/family_members_provider.dart';
import 'package:boussole/providers/mission_provider.dart';
import 'package:boussole/providers/rewards_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('la carte d accueil parent porte le titre Compagnon', () {
    expect(parentCompanionCardTitle, 'Compagnon');
  });

  testWidgets('regroupe les trois sections parent avec leurs etats vides', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          familyMembersProvider.overrideWith((ref) async => []),
          pendingMissionValidationsProvider.overrideWith((ref) async => []),
        ],
        child: const MaterialApp(home: ParentMissionValidationsPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Compagnon'), findsOneWidget);
    expect(find.text('Missions Secrètes'), findsOneWidget);
    expect(find.text('Mémoires'), findsOneWidget);
    expect(find.text('Célébrations'), findsOneWidget);
    expect(find.text('Aucune Mission n’attend de validation.'), findsOneWidget);
    expect(find.text('Aucun enfant disponible.'), findsNWidgets(2));
    expect(find.byKey(const ValueKey('missions-pending-badge')), findsNothing);
  });

  testWidgets('conserve les badges et actions lorsqu une validation attend', (
    tester,
  ) async {
    final child = FamilyMemberModel(
      id: 'child',
      familyId: 'family',
      firstName: 'Lina',
      age: 8,
      avatar: 'avatar',
      profileType: 'child',
      kind: FamilyMemberKind.child,
      createdAt: DateTime(2026),
    );
    final mission = _mission(child.id);
    final memory = _memory(child.id);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          familyMembersProvider.overrideWith((ref) async => [child]),
          pendingMissionValidationsProvider.overrideWith(
            (ref) async => [mission],
          ),
          companionMemoriesProvider.overrideWith(
            (ref, childId) async => [memory],
          ),
          parentRewardsProvider.overrideWith((ref, childId) async => []),
          shardWalletProvider.overrideWith(
            (ref, childId) async => ShardWallet(
              childId: childId,
              balance: 0,
              updatedAt: DateTime(2026),
            ),
          ),
        ],
        child: const MaterialApp(home: ParentMissionValidationsPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('missions-pending-badge')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('companion-child-avatar-child')),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, 'Valider'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Refuser'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Préparer une célébration'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Préparer une célébration'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('memories-pending-badge-child')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.byKey(const ValueKey('memories-pending-badge-child')),
      findsOneWidget,
    );
  });

  test(
    'indicateur parent suit missions et memoires reellement en attente',
    () async {
      final child = ChildModel(
        id: 'child',
        familyId: 'family',
        firstName: 'Lina',
        avatar: 'avatar',
        age: 8,
        createdAt: DateTime(2026),
      );
      final withActions = ProviderContainer(
        overrides: [
          childrenProvider.overrideWith((ref) async => [child]),
          pendingMissionValidationsProvider.overrideWith(
            (ref) async => [_mission(child.id)],
          ),
          companionMemoriesProvider.overrideWith(
            (ref, childId) async => [_memory(child.id)],
          ),
        ],
      );
      addTearDown(withActions.dispose);
      expect(await withActions.read(parentAttentionCountProvider.future), 2);

      final empty = ProviderContainer(
        overrides: [
          childrenProvider.overrideWith((ref) async => [child]),
          pendingMissionValidationsProvider.overrideWith((ref) async => []),
          companionMemoriesProvider.overrideWith((ref, childId) async => []),
        ],
      );
      addTearDown(empty.dispose);
      expect(await empty.read(parentAttentionCountProvider.future), 0);
    },
  );
}

SecretMission _mission(String childId) => SecretMission(
  id: 'mission',
  childId: childId,
  catalogId: 'catalog',
  title: 'Mission',
  description: 'Description',
  category: SecretMissionCategory.helping,
  status: SecretMissionStatus.awaitingParentValidation,
  createdAt: DateTime(2026),
  expiresAt: DateTime(2027),
  origin: SecretMissionOrigin.automatic,
  reward: 1,
  idempotencyKey: 'mission',
);

CompanionMemory _memory(String childId) {
  final now = DateTime(2026);
  return CompanionMemory(
    id: 'memory',
    childId: childId,
    type: CompanionMemoryType.likedActivity,
    value: 'construire',
    status: CompanionMemoryStatus.proposed,
    priority: 1,
    reliability: .5,
    observationCount: 3,
    createdAt: now,
    updatedAt: now,
    lastObservedAt: now,
  );
}
