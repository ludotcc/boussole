import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/family_member_model.dart';
import '../models/child_companion_profile.dart';
import 'children_provider.dart';
import 'family_action_notifier.dart';
import 'family_provider.dart';
import 'session_provider.dart';

final familyMembersProvider = FutureProvider<List<FamilyMemberModel>>((
  ref,
) async {
  final session = ref.watch(sessionProvider);

  if (session == null || session.familyId.isEmpty) {
    return [];
  }

  return ref
      .watch(familyRepositoryProvider)
      .getFamilyMembers(familyId: session.familyId);
});

class FamilyMemberActionNotifier extends FamilyActionNotifier {
  FamilyMemberActionNotifier(super.ref);

  Future<void> updateMember({
    required FamilyMemberModel member,
    required String firstName,
    required int age,
    DateTime? birthDate,
    ChildCompanionProfile? companionProfile,
    required String avatar,
    required String profileType,
  }) {
    return runFamilyAction((familyId) async {
      if (firstName.trim().isEmpty ||
          (birthDate == null && age <= 0) ||
          avatar.isEmpty) {
        throw Exception('Merci de compléter correctement le membre.');
      }

      await ref
          .read(familyRepositoryProvider)
          .updateFamilyMember(
            member: member,
            firstName: firstName.trim(),
            age: age,
            birthDate: birthDate,
            companionProfile: companionProfile,
            avatar: avatar,
            profileType: profileType,
          );

      _refreshMembers();
    });
  }

  Future<void> updateAvatar({
    required FamilyMemberModel member,
    required String avatar,
  }) {
    return runFamilyAction((familyId) async {
      final age = member.age;

      if (avatar.trim().isEmpty) {
        throw Exception('Merci de choisir un avatar.');
      }

      if (age == null || age <= 0) {
        throw Exception(
          "Nous n'avons pas retrouvé les informations du profil.",
        );
      }

      await ref
          .read(familyRepositoryProvider)
          .updateFamilyMember(
            member: member,
            firstName: member.firstName,
            age: age,
            avatar: avatar.trim(),
            profileType: member.profileType,
          );

      _refreshMembers();
    });
  }

  Future<void> deleteMember(FamilyMemberModel member) {
    return runFamilyAction((familyId) async {
      await ref
          .read(familyRepositoryProvider)
          .deleteFamilyMember(member: member);

      _refreshMembers();
    });
  }

  void _refreshMembers() {
    ref.invalidate(familyMembersProvider);
    ref.invalidate(adultProfilesProvider);
    ref.invalidate(familyChildMembersProvider);
    ref.invalidate(childrenProvider);
  }
}

final familyMemberActionProvider =
    StateNotifierProvider<FamilyMemberActionNotifier, AsyncValue<void>>(
      (ref) => FamilyMemberActionNotifier(ref),
    );
