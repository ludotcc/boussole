import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/child_creation_model.dart';
import 'family_action_notifier.dart';
import 'family_provider.dart';

class ChildCreationNotifier extends StateNotifier<ChildCreationModel?> {
  ChildCreationNotifier() : super(null);

  void createDraft({required String firstName, required int age}) {
    state = ChildCreationModel(firstName: firstName, age: age, avatar: '');
  }

  void updateAvatar(String avatar) {
    if (state == null) return;

    state = state!.copyWith(avatar: avatar);
  }

  void clear() {
    state = null;
  }
}

final childCreationProvider =
    StateNotifierProvider<ChildCreationNotifier, ChildCreationModel?>(
      (ref) => ChildCreationNotifier(),
    );

class ChildRegistrationNotifier extends FamilyActionNotifier {
  ChildRegistrationNotifier(super.ref);

  Future<void> finishRegistration({required String avatar}) {
    return runFamilyAction((familyId) async {
      final draft = ref.read(childCreationProvider);

      if (draft == null) {
        throw Exception("Impossible de terminer l'inscription.");
      }

      await ref
          .read(familyRepositoryProvider)
          .createChildProfile(
            familyId: familyId,
            firstName: draft.firstName,
            age: draft.age,
            avatar: avatar,
          );

      ref.read(childCreationProvider.notifier).clear();
    });
  }
}

final childRegistrationProvider =
    StateNotifierProvider<ChildRegistrationNotifier, AsyncValue<void>>(
      (ref) => ChildRegistrationNotifier(ref),
    );
