import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/child_day_item_model.dart';
import '../models/moment_model.dart';
import '../models/planning_day_kind.dart';
import 'family_action_notifier.dart';
import 'family_provider.dart';
import 'session_provider.dart';

class PlanningTarget {
  const PlanningTarget({this.childId, this.dayKind = PlanningDayKind.school});

  final String? childId;
  final PlanningDayKind dayKind;

  PlanningTarget copyWith({String? childId, PlanningDayKind? dayKind}) {
    return PlanningTarget(
      childId: childId ?? this.childId,
      dayKind: dayKind ?? this.dayKind,
    );
  }
}

final planningTargetProvider = StateProvider<PlanningTarget>((ref) {
  return const PlanningTarget();
});

final planningRhythmCopySourceProvider = StateProvider<PlanningDayKind>((ref) {
  return PlanningDayKind.weekend;
});

void _invalidateChildDayItems(Ref ref, PlanningTarget target) {
  final childId = target.childId;
  if (childId != null) {
    ref.invalidate(childDayItemsProvider(childId));
  }
}

final selectedPlanningMomentsProvider = FutureProvider<List<MomentModel>>((
  ref,
) async {
  final session = ref.watch(sessionProvider);
  final target = ref.watch(planningTargetProvider);

  if (session == null || session.familyId.isEmpty) {
    return [];
  }

  final repository = ref.watch(familyRepositoryProvider);
  final childId = target.childId;

  if (childId == null) {
    return [];
  }

  return repository.getMomentsForChildPlanning(
    familyId: session.familyId,
    childId: childId,
    dayKind: target.dayKind,
  );
});

final childDayItemsProvider =
    FutureProvider.family<List<ChildDayItemModel>, String>((
      ref,
      childId,
    ) async {
      final session = ref.watch(sessionProvider);

      if (session == null || session.familyId.isEmpty) {
        return [];
      }

      return ref
          .watch(familyRepositoryProvider)
          .getChildDayItemsForDate(
            familyId: session.familyId,
            childId: childId,
            date: DateTime.now(),
          );
    });

final childDayRhythmLabelProvider = FutureProvider.family<String, String>((
  ref,
  childId,
) async {
  final session = ref.watch(sessionProvider);

  if (session == null || session.familyId.isEmpty) {
    return PlanningDayKind.school.childDayText;
  }

  final dayKind = await ref
      .watch(familyRepositoryProvider)
      .getChildPlanningDayKindForDate(
        familyId: session.familyId,
        childId: childId,
        date: DateTime.now(),
      );

  return dayKind.childDayText;
});

class MomentCreationNotifier extends FamilyActionNotifier {
  MomentCreationNotifier(super.ref);

  Future<void> createMoment({
    required String presetKey,
    String? name,
    String? guidanceText,
    String? iconKey,
    int? orderMinutes,
    String childTimeDisplayType = 'none',
    int? timerMinutes,
    int? maxDurationMinutes,
    bool? hasRoutine,
    bool active = true,
    bool isMultiUse = false,
    int? maxDailyUses,
    String scheduleMode = MomentScheduleModes.daily,
    List<int> weekdays = const [],
    DateTime? singleDate,
  }) async {
    return runFamilyAction((familyId) async {
      final target = ref.read(planningTargetProvider);
      final childId = target.childId;
      if (childId == null) {
        throw Exception('Sélectionnez un enfant.');
      }

      await ref
          .read(familyRepositoryProvider)
          .createDefaultMoment(
            familyId: familyId,
            presetKey: presetKey,
            childId: childId,
            dayKind: target.dayKind,
            name: name,
            guidanceText: guidanceText,
            iconKey: iconKey,
            orderMinutes: orderMinutes,
            childTimeDisplayType: childTimeDisplayType,
            timerMinutes: timerMinutes,
            maxDurationMinutes: maxDurationMinutes,
            hasRoutine: hasRoutine,
            active: active,
            isMultiUse: isMultiUse,
            maxDailyUses: maxDailyUses,
            scheduleMode: scheduleMode,
            weekdays: weekdays,
            singleDate: singleDate,
          );

      ref.invalidate(selectedPlanningMomentsProvider);
      _invalidateChildDayItems(ref, target);
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
      final target = ref.read(planningTargetProvider);
      final childId = target.childId;
      if (childId == null) {
        throw Exception('Sélectionnez un enfant.');
      }

      await ref
          .read(familyRepositoryProvider)
          .reorderMoments(
            familyId: familyId,
            moments: moments,
            childId: childId,
            dayKind: target.dayKind,
          );

      ref.invalidate(selectedPlanningMomentsProvider);
      _invalidateChildDayItems(ref, target);
    });
  }
}

final momentOrderProvider =
    StateNotifierProvider<MomentOrderNotifier, AsyncValue<void>>(
      (ref) => MomentOrderNotifier(ref),
    );

class PlanningResetNotifier extends FamilyActionNotifier {
  PlanningResetNotifier(super.ref);

  Future<void> reset() {
    return runFamilyAction((familyId) async {
      final target = ref.read(planningTargetProvider);
      final childId = target.childId;
      if (childId == null) {
        throw Exception('Sélectionnez un enfant.');
      }
      await ref
          .read(familyRepositoryProvider)
          .clearPlanning(
            familyId: familyId,
            childId: childId,
            dayKind: target.dayKind,
          );

      ref.invalidate(selectedPlanningMomentsProvider);
      _invalidateChildDayItems(ref, target);
    });
  }
}

final planningResetProvider =
    StateNotifierProvider<PlanningResetNotifier, AsyncValue<void>>(
      (ref) => PlanningResetNotifier(ref),
    );

class MomentUpdateNotifier extends FamilyActionNotifier {
  MomentUpdateNotifier(super.ref);

  Future<void> updateMoment(MomentModel moment) async {
    return runFamilyAction((familyId) async {
      final target = ref.read(planningTargetProvider);
      if (target.childId == null) {
        throw Exception('Sélectionnez un enfant.');
      }
      await ref
          .read(familyRepositoryProvider)
          .updateMoment(familyId: familyId, moment: moment);

      ref.invalidate(selectedPlanningMomentsProvider);
      _invalidateChildDayItems(ref, target);
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
      final target = ref.read(planningTargetProvider);
      final childId = target.childId;
      if (childId == null) {
        throw Exception('Sélectionnez un enfant.');
      }

      await ref
          .read(familyRepositoryProvider)
          .duplicateMoment(
            familyId: familyId,
            moment: moment,
            childId: childId,
            dayKind: target.dayKind,
          );

      ref.invalidate(selectedPlanningMomentsProvider);
      _invalidateChildDayItems(ref, target);
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
      final target = ref.read(planningTargetProvider);
      final childId = target.childId;
      if (childId == null) {
        throw Exception('Sélectionnez un enfant.');
      }

      await ref
          .read(familyRepositoryProvider)
          .deleteMoment(
            familyId: familyId,
            momentId: momentId,
            childId: childId,
            dayKind: target.dayKind,
          );

      ref.invalidate(selectedPlanningMomentsProvider);
      _invalidateChildDayItems(ref, target);
    });
  }
}

final momentDeletionProvider =
    StateNotifierProvider<MomentDeletionNotifier, AsyncValue<void>>(
      (ref) => MomentDeletionNotifier(ref),
    );

class PlanningRhythmDuplicationNotifier extends FamilyActionNotifier {
  PlanningRhythmDuplicationNotifier(super.ref);

  Future<void> duplicateFrom(PlanningDayKind sourceDayKind) async {
    return runFamilyAction((familyId) async {
      final target = ref.read(planningTargetProvider);
      final childId = target.childId;
      if (childId == null) {
        throw Exception('Sélectionnez un enfant.');
      }

      await ref
          .read(familyRepositoryProvider)
          .duplicatePlanningRhythm(
            familyId: familyId,
            sourceDayKind: sourceDayKind,
            targetDayKind: target.dayKind,
            childId: childId,
          );

      ref.invalidate(selectedPlanningMomentsProvider);
      _invalidateChildDayItems(ref, target);
      ref.invalidate(childDayRhythmLabelProvider);
    });
  }
}

final planningRhythmDuplicationProvider =
    StateNotifierProvider<PlanningRhythmDuplicationNotifier, AsyncValue<void>>(
      (ref) => PlanningRhythmDuplicationNotifier(ref),
    );

class TodayMomentRemovalNotifier extends FamilyActionNotifier {
  TodayMomentRemovalNotifier(super.ref);

  Future<void> remove({required String childId, required String momentId}) {
    return runFamilyAction((familyId) async {
      await ref
          .read(familyRepositoryProvider)
          .removeMomentOccurrenceForDate(
            familyId: familyId,
            childId: childId,
            date: DateTime.now(),
            momentId: momentId,
          );

      ref.invalidate(childDayItemsProvider(childId));
    });
  }
}

final todayMomentRemovalProvider =
    StateNotifierProvider<TodayMomentRemovalNotifier, AsyncValue<void>>(
      (ref) => TodayMomentRemovalNotifier(ref),
    );
