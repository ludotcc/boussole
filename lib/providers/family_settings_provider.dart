import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'family_action_notifier.dart';
import 'family_provider.dart';

class FamilySettingsNotifier extends FamilyActionNotifier {
  FamilySettingsNotifier(super.ref);

  Future<void> updateSettings({
    required String familyName,
    required String email,
    required String password,
  }) {
    return runFamilyAction((familyId) async {
      await ref
          .read(familyRepositoryProvider)
          .updateFamilySettings(
            familyId: familyId,
            familyName: familyName,
            email: email,
            password: password,
          );

      ref.invalidate(currentFamilyProvider);
    });
  }
}

final familySettingsProvider =
    StateNotifierProvider<FamilySettingsNotifier, AsyncValue<void>>(
      (ref) => FamilySettingsNotifier(ref),
    );
