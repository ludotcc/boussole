import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/celebration.dart';
import '../models/child_companion_profile.dart';
import '../models/child_model.dart';
import '../models/companion_context.dart';
import '../models/companion_memory.dart';
import '../models/companion_moment.dart';
import '../models/companion_observation.dart';
import '../models/companion_suggestion_result.dart';
import '../models/planning_day_kind.dart';
import '../models/routine_model.dart';
import '../repositories/companion_repository.dart';
import 'children_provider.dart';
import 'family_provider.dart';
import 'session_provider.dart';

final companionRepositoryProvider = Provider<CompanionRepository>(
  (_) => CompanionRepository(),
);

final childCompanionProfileProvider =
    FutureProvider.family<ChildCompanionProfile, String>((ref, childId) async {
      final children = await ref.watch(familyChildMembersProvider.future);
      for (final child in children) {
        if (child.id == childId) return child.companionProfile;
      }
      throw StateError('Enfant introuvable');
    });

final companionMemoriesProvider =
    FutureProvider.family<List<CompanionMemory>, String>((ref, childId) async {
      final session = ref.watch(sessionProvider);
      if (session == null || childId.isEmpty) return [];
      return ref
          .read(companionRepositoryProvider)
          .getMemories(familyId: session.familyId, childId: childId);
    });

final celebrationsProvider = FutureProvider.family<List<Celebration>, String>((
  ref,
  childId,
) async {
  final session = ref.watch(sessionProvider);
  if (session == null || childId.isEmpty) return [];
  return ref
      .read(companionRepositoryProvider)
      .getCelebrations(familyId: session.familyId, childId: childId);
});

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

final companionSuggestionsProvider =
    FutureProvider.family<
      CompanionSuggestionResult,
      CompanionSuggestionRequest
    >((ref, request) async {
      final session = ref.watch(sessionProvider);
      if (session == null || request.childId.isEmpty) {
        return const CompanionSuggestionResult(ideas: []);
      }
      final children = await ref.watch(familyChildMembersProvider.future);
      ChildModel? child;
      for (final candidate in children) {
        if (candidate.id == request.childId) {
          child = candidate;
          break;
        }
      }
      if (child == null) return const CompanionSuggestionResult(ideas: []);

      final dateTime = request.dateTime ?? DateTime.now();
      final familyRepository = ref.read(familyRepositoryProvider);
      final dayKind = await familyRepository.getChildPlanningDayKindForDate(
        familyId: session.familyId,
        childId: request.childId,
        date: dateTime,
      );
      final events = await familyRepository.getEventsForChildOnDate(
        familyId: session.familyId,
        childId: request.childId,
        date: dateTime,
      );
      final repository = ref.read(companionRepositoryProvider);
      final memories = await repository.getMemories(
        familyId: session.familyId,
        childId: request.childId,
      );
      final celebrations = await repository.getCelebrations(
        familyId: session.familyId,
        childId: request.childId,
      );
      final observations = await repository.getRecentObservations(
        familyId: session.familyId,
        childId: request.childId,
      );
      final recentMomentIds = observations
          .where((observation) => observation.momentId != null)
          .map((observation) => observation.momentId!)
          .toSet()
          .toList();
      final contexts = {...request.availableContexts};
      if (dayKind == PlanningDayKind.school) contexts.add('school');
      if (dayKind == PlanningDayKind.vacation) contexts.add('vacation');
      Celebration? availableCelebration;
      for (final celebration in celebrations) {
        if (celebration.status == CelebrationStatus.pending) {
          availableCelebration = celebration;
          break;
        }
      }

      return repository.selectIdeas(
        CompanionContext(
          dateTime: dateTime,
          isSchoolDay: dayKind == PlanningDayKind.school,
          isVacation: dayKind == PlanningDayKind.vacation,
          mainMoment: request.mainMoment,
          availableContexts: contexts,
          availableDurationMinutes: request.availableDurationMinutes,
          primaryNeed: request.primaryNeed,
          currentRoutine: request.currentRoutine,
          nextRoutine: request.nextRoutine,
          familyEvent: events.isEmpty ? null : events.first,
          availableCelebration: availableCelebration,
          child: child,
          validatedMemories: memories
              .where((memory) => memory.isValidated)
              .toList(),
          availableMaterials: request.availableMaterials,
          availableParticipants: request.availableParticipants,
          recentMomentIds: recentMomentIds,
        ),
      );
    });

class CompanionObservationNotifier extends StateNotifier<AsyncValue<void>> {
  CompanionObservationNotifier(this.ref) : super(const AsyncData(null));

  final Ref ref;

  Future<void> record({
    required String childId,
    required String interactionSessionId,
    required CompanionObservationType type,
    String? momentId,
  }) async {
    final session = ref.read(sessionProvider);
    if (session == null || childId.isEmpty) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(companionRepositoryProvider);
      final observation = CompanionObservation(
        id: repository.generateObservationId(session.familyId, childId),
        childId: childId,
        sessionId: interactionSessionId,
        type: type,
        createdAt: DateTime.now(),
        momentId: momentId,
      );
      await repository.saveObservation(
        familyId: session.familyId,
        observation: observation,
      );
      ref.invalidate(companionSuggestionsProvider);
    });
  }
}

final companionObservationNotifierProvider =
    StateNotifierProvider<CompanionObservationNotifier, AsyncValue<void>>(
      (ref) => CompanionObservationNotifier(ref),
    );

class CompanionProfileNotifier extends StateNotifier<AsyncValue<void>> {
  CompanionProfileNotifier(this.ref) : super(const AsyncData(null));

  final Ref ref;

  Future<void> save(String childId, ChildCompanionProfile profile) async {
    final session = ref.read(sessionProvider);
    if (session == null || childId.isEmpty) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(companionRepositoryProvider)
          .saveProfile(
            familyId: session.familyId,
            childId: childId,
            profile: profile,
          );
      ref.invalidate(familyChildMembersProvider);
      ref.invalidate(childrenProvider);
      ref.invalidate(childCompanionProfileProvider(childId));
    });
  }
}

final companionProfileNotifierProvider =
    StateNotifierProvider<CompanionProfileNotifier, AsyncValue<void>>(
      (ref) => CompanionProfileNotifier(ref),
    );
