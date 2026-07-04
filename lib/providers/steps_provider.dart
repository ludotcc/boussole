import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/routine_model.dart';
import '../models/step_model.dart';
import 'family_action_notifier.dart';
import 'family_provider.dart';
import 'session_provider.dart';

final stepsForRoutineProvider = FutureProvider.autoDispose
    .family<List<StepModel>, RoutineModel>((ref, routine) async {
      final session = ref.watch(sessionProvider);

      if (session == null || session.familyId.isEmpty) {
        return [];
      }

      final repository = ref.watch(familyRepositoryProvider);

      return repository.getStepsForRoutine(
        familyId: session.familyId,
        routine: routine,
      );
    });

class StepCreationNotifier extends FamilyActionNotifier {
  StepCreationNotifier(super.ref);

  Future<void> createStep({
    required RoutineModel routine,
    required String title,
    required String description,
    required String icon,
  }) async {
    return runFamilyAction((familyId) async {
      await ref
          .read(familyRepositoryProvider)
          .createStepForRoutine(
            familyId: familyId,
            routine: routine,
            title: title,
            description: description,
            icon: icon,
          );

      ref.invalidate(stepsForRoutineProvider(routine));
    });
  }
}

final stepCreationProvider =
    StateNotifierProvider<StepCreationNotifier, AsyncValue<void>>(
      (ref) => StepCreationNotifier(ref),
    );

class StepUpdateNotifier extends FamilyActionNotifier {
  StepUpdateNotifier(super.ref);

  Future<void> updateStep({
    required RoutineModel routine,
    required StepModel step,
  }) async {
    return runFamilyAction((familyId) async {
      await ref
          .read(familyRepositoryProvider)
          .updateStep(familyId: familyId, step: step);

      ref.invalidate(stepsForRoutineProvider(routine));
    });
  }
}

final stepUpdateProvider =
    StateNotifierProvider<StepUpdateNotifier, AsyncValue<void>>(
      (ref) => StepUpdateNotifier(ref),
    );

class StepDeletionNotifier extends FamilyActionNotifier {
  StepDeletionNotifier(super.ref);

  Future<void> deleteStep({
    required RoutineModel routine,
    required String stepId,
  }) async {
    return runFamilyAction((familyId) async {
      await ref
          .read(familyRepositoryProvider)
          .deleteStep(
            familyId: familyId,
            routineId: routine.id,
            stepId: stepId,
          );

      ref.invalidate(stepsForRoutineProvider(routine));
    });
  }
}

final stepDeletionProvider =
    StateNotifierProvider<StepDeletionNotifier, AsyncValue<void>>(
      (ref) => StepDeletionNotifier(ref),
    );

class StepOrderNotifier extends FamilyActionNotifier {
  StepOrderNotifier(super.ref);

  Future<void> reorderSteps({
    required RoutineModel routine,
    required List<StepModel> steps,
  }) async {
    return runFamilyAction((familyId) async {
      await ref
          .read(familyRepositoryProvider)
          .reorderSteps(familyId: familyId, routine: routine, steps: steps);

      ref.invalidate(stepsForRoutineProvider(routine));
    });
  }
}

final stepOrderProvider =
    StateNotifierProvider<StepOrderNotifier, AsyncValue<void>>(
      (ref) => StepOrderNotifier(ref),
    );
