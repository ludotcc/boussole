import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/child_creation_model.dart';
import 'family_action_notifier.dart';
import 'family_provider.dart';

class ChildCreationNotifier extends StateNotifier<ChildCreationModel?> {
  ChildCreationNotifier() : super(null);

  void createAvatarDraft({required String avatar}) {
    state = ChildCreationModel(firstName: '', age: 0, avatar: avatar);
  }

  void createDraft({
    required String firstName,
    required int age,
    DateTime? birthDate,
  }) {
    state = ChildCreationModel(
      firstName: firstName,
      age: age,
      birthDate: birthDate,
      avatar: '',
    );
  }

  void updateInfo({
    required String firstName,
    required int age,
    DateTime? birthDate,
    required String profileType,
  }) {
    if (state == null) return;

    state = state!.copyWith(
      firstName: firstName,
      age: age,
      birthDate: birthDate,
      profileType: profileType,
    );
  }

  void updateAvatar(String avatar) {
    if (state == null) return;

    state = state!.copyWith(avatar: avatar);
  }

  void updateAcademy(String academyId) {
    if (state == null) return;

    state = state!.copyWith(academyId: academyId);
  }

  void updateWeeklyRhythm(Map<int, String> weeklyRhythmByWeekday) {
    if (state == null) return;

    state = state!.copyWith(weeklyRhythmByWeekday: weeklyRhythmByWeekday);
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

  Future<void> createChildProfile({
    required String firstName,
    required int age,
    DateTime? birthDate,
    required String avatar,
    required String profileType,
    String? academyId,
    Map<int, String>? weeklyRhythmByWeekday,
  }) {
    return runFamilyAction((familyId) {
      if (firstName.trim().isEmpty ||
          (birthDate == null && age <= 0) ||
          avatar.isEmpty) {
        throw Exception("Merci de compléter correctement le profil enfant.");
      }

      return ref
          .read(familyRepositoryProvider)
          .createChildProfile(
            familyId: familyId,
            firstName: firstName.trim(),
            age: age,
            birthDate: birthDate,
            avatar: avatar,
            profileType: profileType,
            academyId: academyId,
            weeklyRhythmByWeekday: weeklyRhythmByWeekday,
          );
    });
  }

  Future<void> finishRegistration() {
    return runFamilyAction((familyId) async {
      final draft = ref.read(childCreationProvider);

      if (draft == null) {
        throw Exception("Impossible de terminer l'inscription.");
      }

      if (draft.firstName.trim().isEmpty ||
          (draft.birthDate == null && draft.age <= 0) ||
          draft.avatar.isEmpty) {
        throw Exception("Merci de compléter correctement le profil enfant.");
      }

      await ref
          .read(familyRepositoryProvider)
          .createChildProfile(
            familyId: familyId,
            firstName: draft.firstName,
            age: draft.age,
            birthDate: draft.birthDate,
            avatar: draft.avatar,
            profileType: draft.profileType,
            academyId: draft.academyId,
            weeklyRhythmByWeekday: draft.weeklyRhythmByWeekday,
          );

      ref.read(childCreationProvider.notifier).clear();
    });
  }
}

final childRegistrationProvider =
    StateNotifierProvider<ChildRegistrationNotifier, AsyncValue<void>>(
      (ref) => ChildRegistrationNotifier(ref),
    );
