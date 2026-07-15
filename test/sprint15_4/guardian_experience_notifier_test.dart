import 'package:flutter_test/flutter_test.dart';

import 'package:boussole/models/guardian_experience_state.dart';
import 'package:boussole/models/guardian_model.dart';
import 'package:boussole/providers/guardian_experience_provider.dart';

void main() {
  group('Moteur des Repères', () {
    test('ouvre la Maison en welcome puis revient en idle', () async {
      final notifier = GuardianExperienceNotifier(
        guardianId: GuardianId.crystal,
        now: () => DateTime(2026, 7, 14, 10),
        transientDuration: const Duration(milliseconds: 10),
      );
      addTearDown(notifier.dispose);

      expect(notifier.state.pose, GuardianPose.welcome);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(notifier.state.pose, GuardianPose.idle);
    });

    test('un appui passe en talking puis propose deux choix', () async {
      final notifier = GuardianExperienceNotifier(
        guardianId: GuardianId.pixel,
        now: () => DateTime(2026, 7, 14, 10),
        transientDuration: const Duration(milliseconds: 10),
      );
      addTearDown(notifier.dispose);

      notifier.talk();
      expect(notifier.state.pose, GuardianPose.talking);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(notifier.state.pose, GuardianPose.choices);
      expect(notifier.state.showChoices, isTrue);
    });

    test('affiche exactement l’état choices puis le ferme', () {
      final notifier = GuardianExperienceNotifier(
        guardianId: GuardianId.gear,
        now: () => DateTime(2026, 7, 14, 10),
      );
      addTearDown(notifier.dispose);

      notifier.showChoices();
      expect(notifier.state.pose, GuardianPose.choices);
      expect(notifier.state.showChoices, isTrue);
      notifier.closeChoices();
      expect(notifier.state.pose, GuardianPose.idle);
      expect(notifier.state.showChoices, isFalse);
    });

    test('célèbre puis revient en idle', () async {
      final notifier = GuardianExperienceNotifier(
        guardianId: GuardianId.pyro,
        now: () => DateTime(2026, 7, 14, 10),
        transientDuration: const Duration(milliseconds: 10),
      );
      addTearDown(notifier.dispose);

      notifier.celebrate();
      expect(notifier.state.pose, GuardianPose.celebrate);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(notifier.state.pose, GuardianPose.idle);
    });

    for (final entry in {
      DateTime(2026, 7, 14, 23, 59): GuardianPose.welcome,
      DateTime(2026, 7, 15, 0): GuardianPose.sleeping,
      DateTime(2026, 7, 15, 4, 59): GuardianPose.sleeping,
      DateTime(2026, 7, 15, 5): GuardianPose.welcome,
    }.entries) {
      test('état du Compagnon à ${entry.key.hour}:${entry.key.minute}', () {
        final notifier = GuardianExperienceNotifier(
          guardianId: GuardianId.wave,
          now: () => entry.key,
        );
        addTearDown(notifier.dispose);
        expect(notifier.state.pose, entry.value);
      });
    }

    test('encourage et rassure avec les poses dédiées', () {
      final notifier = GuardianExperienceNotifier(
        guardianId: GuardianId.crystal,
        now: () => DateTime(2026, 7, 14, 10),
      );
      addTearDown(notifier.dispose);

      notifier.encourage();
      expect(notifier.state.pose, GuardianPose.encourage);
      notifier.reassure();
      expect(notifier.state.pose, GuardianPose.reassure);
    });
  });
}
