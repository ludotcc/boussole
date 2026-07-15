import 'celebration.dart';
import 'child_model.dart';
import 'companion_memory.dart';
import 'companion_moment.dart';
import 'family_event_model.dart';
import 'routine_model.dart';

class CompanionContext {
  const CompanionContext({
    required this.dateTime,
    required this.isSchoolDay,
    required this.isVacation,
    required this.mainMoment,
    required this.availableContexts,
    required this.availableDurationMinutes,
    required this.primaryNeed,
    required this.child,
    this.currentRoutine,
    this.nextRoutine,
    this.familyEvent,
    this.availableCelebration,
    this.validatedMemories = const [],
    this.availableMaterials = const {},
    this.availableParticipants = const {CompanionParticipantContext.alone},
    this.recentMomentIds = const [],
  });

  final DateTime dateTime;
  int get weekday => dateTime.weekday;
  final bool isSchoolDay;
  final bool isVacation;
  final String mainMoment;
  final Set<String> availableContexts;
  final int availableDurationMinutes;
  final CompanionNeed primaryNeed;
  final RoutineModel? currentRoutine;
  final RoutineModel? nextRoutine;
  final FamilyEventModel? familyEvent;
  final Celebration? availableCelebration;
  final ChildModel child;
  final List<CompanionMemory> validatedMemories;
  final Set<String> availableMaterials;
  final Set<CompanionParticipantContext> availableParticipants;
  final List<String> recentMomentIds;
}
