import '../models/companion_moment.dart';
import '../models/companion_suggestion_request.dart';
import '../models/child_day_item_model.dart';

class CompanionContextPolicy {
  const CompanionContextPolicy();

  CompanionSuggestionRequest buildDefaultRequest({
    required String childId,
    required DateTime dateTime,
    List<ChildDayItemModel> dayItems = const [],
  }) {
    final (mainMoment, need) = switch (dateTime.hour) {
      < 9 => ('beforeSchool', CompanionNeed.findIdea),
      >= 12 && < 14 => ('beforeMeal', CompanionNeed.findIdea),
      >= 16 && < 18 => ('afterSchool', CompanionNeed.findIdea),
      >= 18 && < 20 => ('beforeMeal', CompanionNeed.findIdea),
      >= 20 => ('beforeBed', CompanionNeed.rest),
      _ => ('freeTime', CompanionNeed.findIdea),
    };
    return CompanionSuggestionRequest(
      childId: childId,
      primaryNeed: need,
      mainMoment: mainMoment,
      availableContexts: const {'home'},
      availableDurationMinutes: availableDuration(
        dateTime: dateTime,
        dayItems: dayItems,
      ),
      availableParticipants: const {CompanionParticipantContext.alone},
      dateTime: dateTime,
    );
  }

  int availableDuration({
    required DateTime dateTime,
    required List<ChildDayItemModel> dayItems,
  }) {
    final currentMinutes = dateTime.hour * 60 + dateTime.minute;
    final nextMinutes = dayItems
        .map((item) => item.orderMinutes)
        .whereType<int>()
        .where((minutes) => minutes > currentMinutes)
        .fold<int?>(null, (next, value) {
          if (next == null || value < next) return value;
          return next;
        });
    final endOfDayMinutes = 22 * 60;
    final available = (nextMinutes ?? endOfDayMinutes) - currentMinutes;
    return available.clamp(3, 60);
  }
}
