import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/family_model.dart';
import '../models/parent_model.dart';
import '../repositories/family_repository.dart';
import 'session_provider.dart';

final familyRepositoryProvider = Provider<FamilyRepository>((ref) {
  return FamilyRepository();
});

final currentFamilyProvider = FutureProvider<FamilyModel?>((ref) {
  final session = ref.watch(sessionProvider);

  if (session == null || session.familyId.isEmpty) {
    return null;
  }

  return ref
      .watch(familyRepositoryProvider)
      .getFamily(familyId: session.familyId);
});

final adultProfilesProvider = FutureProvider<List<ParentModel>>((ref) {
  final session = ref.watch(sessionProvider);

  if (session == null || session.familyId.isEmpty) {
    return [];
  }

  return ref
      .watch(familyRepositoryProvider)
      .getAdultProfiles(familyId: session.familyId);
});
