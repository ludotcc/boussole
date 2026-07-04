import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/moment_model.dart';
import '../models/routine_model.dart';
import 'family_action_notifier.dart';
import 'family_provider.dart';
import 'session_provider.dart';

final routinesForMomentProvider = FutureProvider.autoDispose
    .family<List<RoutineModel>, MomentModel>((ref, moment) async {
      final session = ref.watch(sessionProvider);

      if (session == null || session.familyId.isEmpty) {
        return [];
      }

      final repository = ref.watch(familyRepositoryProvider);

      return repository.getRoutinesForMoment(
        familyId: session.familyId,
        moment: moment,
      );
    });

class RoutineCreationNotifier extends FamilyActionNotifier {
  RoutineCreationNotifier(super.ref);

  Future<void> createRoutine({
    required MomentModel moment,
    required String name,
    required String icon,
  }) async {
    return runFamilyAction((familyId) async {
      await ref
          .read(familyRepositoryProvider)
          .createRoutineForMoment(
            familyId: familyId,
            moment: moment,
            name: name,
            icon: icon,
          );

      ref.invalidate(routinesForMomentProvider(moment));
    });
  }
}

final routineCreationProvider =
    StateNotifierProvider<RoutineCreationNotifier, AsyncValue<void>>(
      (ref) => RoutineCreationNotifier(ref),
    );

class RoutineUpdateNotifier extends FamilyActionNotifier {
  RoutineUpdateNotifier(super.ref);

  Future<void> updateRoutine({
    required MomentModel moment,
    required RoutineModel routine,
  }) async {
    return runFamilyAction((familyId) async {
      await ref
          .read(familyRepositoryProvider)
          .updateRoutine(familyId: familyId, routine: routine);

      ref.invalidate(routinesForMomentProvider(moment));
    });
  }
}

final routineUpdateProvider =
    StateNotifierProvider<RoutineUpdateNotifier, AsyncValue<void>>(
      (ref) => RoutineUpdateNotifier(ref),
    );

class RoutineDuplicationNotifier extends FamilyActionNotifier {
  RoutineDuplicationNotifier(super.ref);

  Future<void> duplicateRoutine({
    required MomentModel moment,
    required RoutineModel routine,
  }) async {
    return runFamilyAction((familyId) async {
      await ref
          .read(familyRepositoryProvider)
          .duplicateRoutine(familyId: familyId, routine: routine);

      ref.invalidate(routinesForMomentProvider(moment));
    });
  }
}

final routineDuplicationProvider =
    StateNotifierProvider<RoutineDuplicationNotifier, AsyncValue<void>>(
      (ref) => RoutineDuplicationNotifier(ref),
    );

class RoutineDeletionNotifier extends FamilyActionNotifier {
  RoutineDeletionNotifier(super.ref);

  Future<void> deleteRoutine({
    required MomentModel moment,
    required String routineId,
  }) async {
    return runFamilyAction((familyId) async {
      await ref
          .read(familyRepositoryProvider)
          .deleteRoutine(familyId: familyId, routineId: routineId);

      ref.invalidate(routinesForMomentProvider(moment));
    });
  }
}

final routineDeletionProvider =
    StateNotifierProvider<RoutineDeletionNotifier, AsyncValue<void>>(
      (ref) => RoutineDeletionNotifier(ref),
    );

class RoutineOrderNotifier extends FamilyActionNotifier {
  RoutineOrderNotifier(super.ref);

  Future<void> reorderRoutines({
    required MomentModel moment,
    required List<RoutineModel> routines,
  }) async {
    return runFamilyAction((familyId) async {
      await ref
          .read(familyRepositoryProvider)
          .reorderRoutines(familyId: familyId, routines: routines);

      ref.invalidate(routinesForMomentProvider(moment));
    });
  }
}

final routineOrderProvider =
    StateNotifierProvider<RoutineOrderNotifier, AsyncValue<void>>(
      (ref) => RoutineOrderNotifier(ref),
    );
