import 'package:boussole/models/celebration.dart';
import 'package:boussole/models/child_companion_profile.dart';
import 'package:boussole/models/child_model.dart';
import 'package:boussole/models/companion_memory.dart';
import 'package:boussole/models/family_member_model.dart';
import 'package:boussole/pages/companion_memories_page.dart';
import 'package:boussole/providers/companion_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cree un profil avec date de naissance et calcule son age', () {
    final today = DateTime.now();
    final child = ChildModel(
      id: 'child',
      familyId: 'family',
      firstName: 'Lina',
      avatar: 'avatar',
      birthDate: DateTime(today.year - 9, today.month, today.day),
      createdAt: today,
    );

    expect(child.birthDate, isNotNull);
    expect(child.age, 9);
  });

  test('modifie et sauvegarde toutes les informations du profil', () {
    const profile = ChildCompanionProfile(
      interests: ['nature'],
      likedActivities: ['lire'],
      helpfulApproaches: ['parler'],
      difficultSituations: ['transitions'],
      parentGoals: ['autonomie', 'confiance'],
      specialNeeds: ['TDAH'],
      sensitiveSituations: ['bruit important'],
      activitiesToAvoid: ['musique'],
    );

    final restored = ChildCompanionProfile.fromMap(profile.toMap());
    expect(restored.interests, ['nature']);
    expect(restored.likedActivities, ['lire']);
    expect(restored.helpfulApproaches, ['parler']);
    expect(restored.difficultSituations, ['transitions']);
    expect(restored.parentGoals, ['autonomie', 'confiance']);
    expect(restored.specialNeeds, ['TDAH']);
    expect(restored.sensitiveSituations, ['bruit important']);
    expect(restored.activitiesToAvoid, ['musique']);
  });

  test('les donnees enfant sont serialisables pour Firestore', () {
    final child = ChildModel(
      id: 'child',
      familyId: 'family',
      firstName: 'Lina',
      avatar: 'avatar',
      birthDate: DateTime(2018, 4, 2),
      companionProfile: const ChildCompanionProfile(interests: ['animaux']),
      createdAt: DateTime(2026, 7, 15),
    );
    final map = child.toMap();

    expect(map['birthDate'], DateTime(2018, 4, 2).toIso8601String());
    expect((map['companionProfile'] as Map)['interests'], ['animaux']);
  });

  test('valide une memoire proposee', () {
    final memory = _memory();
    final decided = memory.decide(
      decision: CompanionMemoryStatus.validated,
      parentId: 'parent',
      decidedAt: DateTime(2026, 7, 15),
    );

    expect(decided.status, CompanionMemoryStatus.validated);
    expect(decided.decidedByParentId, 'parent');
    expect(decided.toMap()['decidedAt'], isA<Timestamp>());
  });

  test('refuse une memoire proposee', () {
    final decided = _memory().decide(
      decision: CompanionMemoryStatus.refused,
      parentId: 'parent',
      decidedAt: DateTime(2026, 7, 15),
    );

    expect(decided.status, CompanionMemoryStatus.refused);
  });

  test('cree une celebration parent persistable', () {
    final celebration = Celebration.parentCreated(
      id: 'celebration',
      childId: 'child',
      type: CelebrationType.courage,
      parentId: 'parent',
      createdAt: DateTime(2026, 7, 15),
      shardReward: 1,
    );
    final map = celebration.toMap();

    expect(celebration.createdByParentId, 'parent');
    expect(celebration.shardReward, 1);
    expect(map['createdAt'], isA<Timestamp>());
    expect(map['status'], CelebrationStatus.pending.name);
  });

  testWidgets('affiche les memoires proposees avec deux actions uniquement', (
    tester,
  ) async {
    final memory = _memory();
    final child = FamilyMemberModel(
      id: 'child',
      familyId: 'family',
      firstName: 'Lina',
      age: 8,
      birthDate: DateTime(2018),
      avatar: '',
      profileType: 'child',
      kind: FamilyMemberKind.child,
      createdAt: DateTime(2026),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          companionMemoriesProvider(
            child.id,
          ).overrideWith((ref) async => [memory]),
        ],
        child: MaterialApp(home: CompanionMemoriesPage(child: child)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('aime construire'), findsOneWidget);
    expect(find.text('Valider'), findsOneWidget);
    expect(find.text('Refuser'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  test('reste compatible avec un ancien profil sans date de naissance', () {
    final child = ChildModel.fromMap({
      'id': 'child',
      'familyId': 'family',
      'firstName': 'Lina',
      'avatar': 'avatar',
      'age': 7,
      'createdAt': DateTime(2025).toIso8601String(),
    });

    expect(child.birthDate, isNull);
    expect(child.age, 7);
  });
}

CompanionMemory _memory() {
  final now = DateTime(2026, 7, 15);
  return CompanionMemory(
    id: 'memory',
    childId: 'child',
    type: CompanionMemoryType.likedActivity,
    value: 'aime construire',
    status: CompanionMemoryStatus.proposed,
    priority: 2,
    reliability: .8,
    observationCount: 5,
    createdAt: now,
    updatedAt: now,
    lastObservedAt: now,
  );
}
