import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/day_exception_model.dart';
import 'family_action_notifier.dart';
import 'family_provider.dart';
import 'session_provider.dart';

final dayExceptionsProvider = FutureProvider<List<DayExceptionModel>>((
  ref,
) async {
  final session = ref.watch(sessionProvider);

  if (session == null || session.familyId.isEmpty) {
    return [];
  }

  final repository = ref.watch(familyRepositoryProvider);

  return repository.getDayExceptions(familyId: session.familyId);
});

final dayExceptionForDateProvider = FutureProvider.autoDispose
    .family<DayExceptionModel?, DateTime>((ref, date) async {
      final session = ref.watch(sessionProvider);

      if (session == null || session.familyId.isEmpty) {
        return null;
      }

      final repository = ref.watch(familyRepositoryProvider);

      return repository.getDayExceptionForDate(
        familyId: session.familyId,
        date: date,
      );
    });

class DayExceptionSaveNotifier extends FamilyActionNotifier {
  DayExceptionSaveNotifier(super.ref);

  Future<void> saveDayException({
    required DateTime date,
    required String dayTypeId,
    required List<String> momentIds,
  }) {
    return runFamilyAction((familyId) async {
      await ref
          .read(familyRepositoryProvider)
          .saveDayException(
            familyId: familyId,
            date: date,
            dayTypeId: dayTypeId,
            momentIds: momentIds,
          );

      ref.invalidate(dayExceptionsProvider);
      ref.invalidate(dayExceptionForDateProvider(date));
    });
  }
}

final dayExceptionSaveProvider =
    StateNotifierProvider<DayExceptionSaveNotifier, AsyncValue<void>>(
      (ref) => DayExceptionSaveNotifier(ref),
    );
