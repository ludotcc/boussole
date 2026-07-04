import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/moment_model.dart';
import 'day_types_provider.dart';
import 'family_action_notifier.dart';
import 'family_provider.dart';
import 'session_provider.dart';

final momentsProvider = FutureProvider<List<MomentModel>>((ref) async {
  final session = ref.watch(sessionProvider);

  if (session == null || session.familyId.isEmpty) {
    return [];
  }

  final repository = ref.watch(familyRepositoryProvider);

  return repository.getMoments(familyId: session.familyId);
});

class MomentCreationNotifier extends FamilyActionNotifier {
  MomentCreationNotifier(super.ref);

  Future<void> createMoment({required String type}) async {
    return runFamilyAction((familyId) async {
      await ref
          .read(familyRepositoryProvider)
          .createDefaultMoment(familyId: familyId, type: type);

      ref.invalidate(momentsProvider);
      ref.invalidate(familyPlanningsProvider);
    });
  }
}

final momentCreationProvider =
    StateNotifierProvider<MomentCreationNotifier, AsyncValue<void>>(
      (ref) => MomentCreationNotifier(ref),
    );

class MomentOrderNotifier extends FamilyActionNotifier {
  MomentOrderNotifier(super.ref);

  Future<void> reorderMoments(List<MomentModel> moments) async {
    return runFamilyAction((familyId) async {
      await ref
          .read(familyRepositoryProvider)
          .reorderMoments(familyId: familyId, moments: moments);

      ref.invalidate(momentsProvider);
      ref.invalidate(familyPlanningsProvider);
    });
  }
}

final momentOrderProvider =
    StateNotifierProvider<MomentOrderNotifier, AsyncValue<void>>(
      (ref) => MomentOrderNotifier(ref),
    );

class MomentUpdateNotifier extends FamilyActionNotifier {
  MomentUpdateNotifier(super.ref);

  Future<void> updateMoment(MomentModel moment) async {
    return runFamilyAction((familyId) async {
      await ref
          .read(familyRepositoryProvider)
          .updateMoment(familyId: familyId, moment: moment);

      ref.invalidate(momentsProvider);
    });
  }
}

final momentUpdateProvider =
    StateNotifierProvider<MomentUpdateNotifier, AsyncValue<void>>(
      (ref) => MomentUpdateNotifier(ref),
    );

class MomentDuplicationNotifier extends FamilyActionNotifier {
  MomentDuplicationNotifier(super.ref);

  Future<void> duplicateMoment(MomentModel moment) async {
    return runFamilyAction((familyId) async {
      await ref
          .read(familyRepositoryProvider)
          .duplicateMoment(familyId: familyId, moment: moment);

      ref.invalidate(momentsProvider);
      ref.invalidate(familyPlanningsProvider);
    });
  }
}

final momentDuplicationProvider =
    StateNotifierProvider<MomentDuplicationNotifier, AsyncValue<void>>(
      (ref) => MomentDuplicationNotifier(ref),
    );

class MomentDeletionNotifier extends FamilyActionNotifier {
  MomentDeletionNotifier(super.ref);

  Future<void> deleteMoment({required String momentId}) async {
    return runFamilyAction((familyId) async {
      await ref
          .read(familyRepositoryProvider)
          .deleteMoment(familyId: familyId, momentId: momentId);

      ref.invalidate(momentsProvider);
      ref.invalidate(familyPlanningsProvider);
    });
  }
}

final momentDeletionProvider =
    StateNotifierProvider<MomentDeletionNotifier, AsyncValue<void>>(
      (ref) => MomentDeletionNotifier(ref),
    );
