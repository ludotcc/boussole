import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/child_model.dart';
import 'family_action_notifier.dart';
import '../providers/family_provider.dart';
import '../providers/moments_provider.dart';
import '../providers/session_provider.dart';

final familyChildMembersProvider = FutureProvider<List<ChildModel>>((
  ref,
) async {
  final session = ref.watch(sessionProvider);

  if (session == null) {
    return [];
  }

  return ref
      .read(familyRepositoryProvider)
      .getChildren(familyId: session.familyId);
});

final childrenProvider = FutureProvider<List<ChildModel>>((ref) async {
  final session = ref.watch(sessionProvider);

  if (session == null) {
    return [];
  }

  return ref
      .read(familyRepositoryProvider)
      .getChildProfiles(familyId: session.familyId);
});

class ChildWeeklyRhythmNotifier extends FamilyActionNotifier {
  ChildWeeklyRhythmNotifier(super.ref);

  Future<void> updateWeeklyRhythm({
    required String childId,
    required Map<int, String> weeklyRhythmByWeekday,
    String? academyId,
  }) {
    return runFamilyAction((familyId) async {
      await ref
          .read(familyRepositoryProvider)
          .updateChildWeeklyRhythm(
            familyId: familyId,
            childId: childId,
            weeklyRhythmByWeekday: weeklyRhythmByWeekday,
            academyId: academyId,
          );

      ref.invalidate(childrenProvider);
      ref.invalidate(familyChildMembersProvider);
      ref.invalidate(childDayItemsProvider);
      ref.invalidate(childDayRhythmLabelProvider);
    });
  }
}

final childWeeklyRhythmProvider =
    StateNotifierProvider<ChildWeeklyRhythmNotifier, AsyncValue<void>>(
      (ref) => ChildWeeklyRhythmNotifier(ref),
    );
