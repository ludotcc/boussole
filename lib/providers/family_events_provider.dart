import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/family_event_model.dart';
import 'family_action_notifier.dart';
import 'family_provider.dart';
import 'moments_provider.dart';
import 'session_provider.dart';

final familyEventsProvider = FutureProvider<List<FamilyEventModel>>((
  ref,
) async {
  final session = ref.watch(sessionProvider);

  if (session == null || session.familyId.isEmpty) {
    return [];
  }

  return ref
      .watch(familyRepositoryProvider)
      .getEvents(familyId: session.familyId);
});

final upcomingFamilyEventsProvider = FutureProvider<List<FamilyEventModel>>((
  ref,
) async {
  final events = await ref.watch(familyEventsProvider.future);
  final today = DateTime.now();
  final date = DateTime(today.year, today.month, today.day);

  return events.where((event) => !event.date.isBefore(date)).toList();
});

class FamilyEventActionNotifier extends FamilyActionNotifier {
  FamilyEventActionNotifier(super.ref);

  Future<void> createEvent({
    required String title,
    required String? description,
    required String type,
    required DateTime date,
    required String? time,
    required bool isAllDay,
    required bool isSensitiveMoment,
    required List<String> memberIds,
    required String recurrenceType,
    required String childTimeDisplayType,
    required int? timerMinutes,
    required int? maxDurationMinutes,
  }) {
    return runFamilyAction((familyId) async {
      await ref
          .read(familyRepositoryProvider)
          .createEvent(
            familyId: familyId,
            title: title,
            description: description,
            type: type,
            date: date,
            time: time,
            isAllDay: isAllDay,
            isSensitiveMoment: isSensitiveMoment,
            memberIds: memberIds,
            recurrenceType: recurrenceType,
            childTimeDisplayType: childTimeDisplayType,
            timerMinutes: timerMinutes,
            maxDurationMinutes: maxDurationMinutes,
          );

      ref.invalidate(familyEventsProvider);
      ref.invalidate(upcomingFamilyEventsProvider);
      ref.invalidate(childDayItemsProvider);
    });
  }

  Future<void> updateEvent(FamilyEventModel event) {
    return runFamilyAction((familyId) async {
      await ref.read(familyRepositoryProvider).updateEvent(event);

      ref.invalidate(familyEventsProvider);
      ref.invalidate(upcomingFamilyEventsProvider);
      ref.invalidate(childDayItemsProvider);
    });
  }

  Future<void> deleteEvent(FamilyEventModel event) {
    return runFamilyAction((familyId) async {
      await ref
          .read(familyRepositoryProvider)
          .deleteEvent(familyId: familyId, eventId: event.id);

      ref.invalidate(familyEventsProvider);
      ref.invalidate(upcomingFamilyEventsProvider);
      ref.invalidate(childDayItemsProvider);
    });
  }
}

final familyEventActionProvider =
    StateNotifierProvider<FamilyEventActionNotifier, AsyncValue<void>>(
      (ref) => FamilyEventActionNotifier(ref),
    );
