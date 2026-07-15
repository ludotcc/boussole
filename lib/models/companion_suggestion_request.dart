import 'companion_moment.dart';
import 'routine_model.dart';

class CompanionSuggestionRequest {
  const CompanionSuggestionRequest({
    required this.childId,
    required this.primaryNeed,
    required this.mainMoment,
    required this.availableContexts,
    required this.availableDurationMinutes,
    required this.availableParticipants,
    this.availableMaterials = const {},
    this.currentRoutine,
    this.nextRoutine,
    this.dateTime,
  });

  final String childId;
  final CompanionNeed primaryNeed;
  final String mainMoment;
  final Set<String> availableContexts;
  final int availableDurationMinutes;
  final Set<CompanionParticipantContext> availableParticipants;
  final Set<String> availableMaterials;
  final RoutineModel? currentRoutine;
  final RoutineModel? nextRoutine;
  final DateTime? dateTime;
}
