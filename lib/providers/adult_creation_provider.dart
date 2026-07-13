import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'family_action_notifier.dart';
import 'family_provider.dart';

class AdultRegistrationNotifier extends FamilyActionNotifier {
  AdultRegistrationNotifier(super.ref);

  Future<void> createAdultProfile({
    required String firstName,
    required int age,
    required String profileType,
    required String avatar,
  }) {
    return runFamilyAction((familyId) {
      if (firstName.trim().isEmpty || age <= 0 || avatar.isEmpty) {
        throw Exception("Merci de compléter correctement le profil adulte.");
      }

      return ref
          .read(familyRepositoryProvider)
          .createAdultProfile(
            familyId: familyId,
            firstName: firstName.trim(),
            age: age,
            profileType: profileType,
            avatar: avatar,
          );
    });
  }
}

final adultRegistrationProvider =
    StateNotifierProvider<AdultRegistrationNotifier, AsyncValue<void>>(
      (ref) => AdultRegistrationNotifier(ref),
    );
