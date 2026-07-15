import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boussole/models/celebration.dart';
import 'package:boussole/models/child_companion_profile.dart';
import 'package:boussole/models/child_model.dart';
import 'package:boussole/models/companion_memory.dart';

void main() {
  group('ChildModel', () {
    test('calcule l age depuis la date de naissance', () {
      final now = DateTime.now();
      final child = ChildModel(
        id: 'child',
        familyId: 'family',
        firstName: 'Lina',
        avatar: 'avatar',
        birthDate: DateTime(now.year - 8, now.month, now.day),
        createdAt: now,
      );

      expect(child.age, 8);
    });

    test('reste compatible avec un document contenant uniquement age', () {
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
      expect(child.companionProfile.interests, isEmpty);
    });
  });

  test('le profil limite les objectifs parent a trois', () {
    final profile = ChildCompanionProfile.fromMap({
      'parentGoals': ['autonomie', 'confiance', 'patience', 'courage'],
      'specialNeeds': <String>[],
      'sensitiveSituations': ['bruit'],
    });

    expect(profile.parentGoals, hasLength(3));
    expect(profile.sensitiveSituations, isEmpty);
  });

  test('une memoire conserve son evolution et sa priorite', () {
    final now = DateTime(2026, 7, 15);
    final memory = CompanionMemory.fromMap('memory', {
      'childId': 'child',
      'type': 'habit',
      'value': 'aime construire',
      'status': 'validated',
      'priority': 4,
      'reliability': 0.8,
      'observationCount': 6,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
      'lastObservedAt': Timestamp.fromDate(now),
    });

    expect(memory.isValidated, isTrue);
    expect(memory.priority, 4);
    expect(memory.observationCount, 6);
  });

  test(
    'une celebration conserve son origine parent et son eclat optionnel',
    () {
      final celebration = Celebration.fromMap('celebration', {
        'childId': 'child',
        'type': 'perseverance',
        'createdByParentId': 'parent',
        'createdAt': Timestamp.fromDate(DateTime(2026, 7, 15)),
        'shardReward': 1,
      });

      expect(celebration.createdByParentId, 'parent');
      expect(celebration.shardReward, 1);
      expect(celebration.status, CelebrationStatus.pending);
    },
  );
}
