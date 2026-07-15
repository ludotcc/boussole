import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/celebration.dart';
import '../models/child_companion_profile.dart';
import '../models/child_model.dart';
import '../models/companion_child_experience.dart';
import '../models/companion_context.dart';
import '../models/companion_memory.dart';
import '../models/companion_observation.dart';
import '../models/companion_suggestion_result.dart';
import '../models/companion_suggestion_request.dart';
import '../models/planning_day_kind.dart';
import '../repositories/companion_repository.dart';
import '../services/companion_context_policy.dart';
import '../services/companion_dialogue_service.dart';
import 'children_provider.dart';
import 'family_provider.dart';
import 'moments_provider.dart';
import 'mission_provider.dart';
import 'rewards_provider.dart';
import 'session_provider.dart';

final companionRepositoryProvider = Provider<CompanionRepository>(
  (_) => CompanionRepository(),
);

final companionContextPolicyProvider = Provider<CompanionContextPolicy>(
  (_) => const CompanionContextPolicy(),
);

final companionDialogueServiceProvider = Provider<CompanionDialogueService>(
  (_) => const CompanionDialogueService(),
);

final companionContextClockProvider = StreamProvider<DateTime>((ref) async* {
  while (true) {
    final now = DateTime.now();
    yield now;
    final nextHour = DateTime(now.year, now.month, now.day, now.hour + 1);
    await Future<void>.delayed(nextHour.difference(now));
  }
});

class CompanionIdeaSessionState {
  const CompanionIdeaSessionState({
    this.recentMomentIds = const [],
    this.previousGroupIds = const [],
  });

  final List<String> recentMomentIds;
  final List<String> previousGroupIds;
}

class CompanionIdeaSessionNotifier
    extends StateNotifier<CompanionIdeaSessionState> {
  CompanionIdeaSessionNotifier(this.ref, this.childId)
    : super(const CompanionIdeaSessionState());

  final Ref ref;
  final String childId;

  void recordDisplayed(List<String> ids) {
    if (ids.isEmpty) return;
    state = CompanionIdeaSessionState(
      recentMomentIds: _prepend(ids, state.recentMomentIds),
      previousGroupIds: List.unmodifiable(ids),
    );
  }

  void requestMore(List<String> ids) {
    recordDisplayed(ids);
    ref.invalidate(childCompanionExperienceProvider(childId));
  }

  void choose(String id, List<String> displayedIds) {
    state = CompanionIdeaSessionState(
      recentMomentIds: _prepend([id, ...displayedIds], state.recentMomentIds),
      previousGroupIds: List.unmodifiable(displayedIds),
    );
    ref.invalidate(childCompanionExperienceProvider(childId));
  }

  List<String> _prepend(List<String> values, List<String> existing) =>
      List.unmodifiable({...values, ...existing}.take(30));
}

final companionIdeaSessionProvider =
    StateNotifierProvider.family<
      CompanionIdeaSessionNotifier,
      CompanionIdeaSessionState,
      String
    >((ref, childId) => CompanionIdeaSessionNotifier(ref, childId));

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

final parentAttentionCountProvider = FutureProvider<int>((ref) async {
  final children = await ref.watch(childrenProvider.future);
  final missions = await ref.watch(pendingMissionValidationsProvider.future);
  final memoriesByChild = await Future.wait([
    for (final child in children)
      ref.watch(companionMemoriesProvider(child.id).future),
  ]);
  return missions.length +
      memoriesByChild.fold<int>(
        0,
        (count, memories) =>
            count + memories.where((memory) => memory.isProposed).length,
      );
});

final childCompanionExperienceProvider =
    FutureProvider.family<CompanionChildExperience, String>((
      ref,
      childId,
    ) async {
      final children = await ref.watch(childrenProvider.future);
      ChildModel? child;
      for (final candidate in children) {
        if (candidate.id == childId) {
          child = candidate;
          break;
        }
      }
      if (child == null) throw StateError('Enfant introuvable');
      final dayItems = await ref.watch(childDayItemsProvider(childId).future);
      final memories = await ref.watch(
        companionMemoriesProvider(childId).future,
      );
      final celebrations = await ref.watch(
        celebrationsProvider(childId).future,
      );
      final missionAnnouncements = await ref.watch(
        pendingMissionAnnouncementsProvider(childId).future,
      );
      Celebration? celebration;
      for (final candidate in celebrations) {
        if (candidate.status == CelebrationStatus.pending) {
          celebration = candidate;
          break;
        }
      }
      final contextTime =
          ref.watch(companionContextClockProvider).valueOrNull ??
          DateTime.now();
      final request = ref
          .read(companionContextPolicyProvider)
          .buildDefaultRequest(
            childId: childId,
            dateTime: contextTime,
            dayItems: dayItems,
          );
      final suggestions = await ref.watch(
        companionSuggestionsProvider(request).future,
      );
      final dialogues = ref.read(companionDialogueServiceProvider);
      final dialogue = celebration == null
          ? missionAnnouncements.isNotEmpty
                ? dialogues.missionValidatedDialogue(missionAnnouncements.first)
                : dialogues.suggestionDialogue(
                    child: child,
                    suggestions: suggestions,
                    validatedMemories: memories
                        .where((memory) => memory.isValidated)
                        .toList(),
                  )
          : dialogues.celebrationDialogue(celebration);
      return CompanionChildExperience(
        suggestions: suggestions,
        dialogue: dialogue,
        celebration: celebration,
        missionAnnouncement: missionAnnouncements.firstOrNull,
      );
    });

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
      final sessionIdeas = ref.read(
        companionIdeaSessionProvider(request.childId),
      );
      final combinedRecentIds = <String>{
        ...sessionIdeas.recentMomentIds,
        ...recentMomentIds,
      }.toList();
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
          recentMomentIds: combinedRecentIds,
          previousGroupIds: sessionIdeas.previousGroupIds,
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
    bool refreshSuggestions = false,
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
      if (refreshSuggestions) {
        ref.invalidate(companionSuggestionsProvider);
      }
    });
  }
}

final companionObservationNotifierProvider =
    StateNotifierProvider<CompanionObservationNotifier, AsyncValue<void>>(
      (ref) => CompanionObservationNotifier(ref),
    );

class CompanionMemoryDecisionNotifier extends StateNotifier<AsyncValue<void>> {
  CompanionMemoryDecisionNotifier(this.ref) : super(const AsyncData(null));

  final Ref ref;

  Future<void> validate(CompanionMemory memory) => _decide(memory, true);
  Future<void> refuse(CompanionMemory memory) => _decide(memory, false);

  Future<void> _decide(CompanionMemory memory, bool validate) async {
    final session = ref.read(sessionProvider);
    if (session == null || state.isLoading) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(companionRepositoryProvider);
      if (validate) {
        await repository.validateMemory(
          familyId: session.familyId,
          memory: memory,
          parentId: session.userId,
        );
      } else {
        await repository.refuseMemory(
          familyId: session.familyId,
          memory: memory,
          parentId: session.userId,
        );
      }
      ref.invalidate(companionMemoriesProvider(memory.childId));
      ref.invalidate(parentAttentionCountProvider);
    });
  }
}

final companionMemoryDecisionProvider =
    StateNotifierProvider<CompanionMemoryDecisionNotifier, AsyncValue<void>>(
      (ref) => CompanionMemoryDecisionNotifier(ref),
    );

class CelebrationCreationNotifier extends StateNotifier<AsyncValue<void>> {
  CelebrationCreationNotifier(this.ref) : super(const AsyncData(null));

  final Ref ref;

  Future<void> create({
    required String childId,
    required CelebrationType type,
    required int shardReward,
  }) async {
    final session = ref.read(sessionProvider);
    if (session == null || childId.isEmpty || state.isLoading) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(companionRepositoryProvider)
          .createCelebration(
            familyId: session.familyId,
            childId: childId,
            type: type,
            parentId: session.userId,
            shardReward: shardReward,
          );
      ref.invalidate(celebrationsProvider(childId));
    });
  }
}

final celebrationCreationProvider =
    StateNotifierProvider<CelebrationCreationNotifier, AsyncValue<void>>(
      (ref) => CelebrationCreationNotifier(ref),
    );

class CelebrationDeliveryNotifier extends StateNotifier<AsyncValue<void>> {
  CelebrationDeliveryNotifier(this.ref) : super(const AsyncData(null));

  final Ref ref;

  Future<void> markDelivered(Celebration celebration) async {
    final session = ref.read(sessionProvider);
    if (session == null || state.isLoading) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(companionRepositoryProvider)
          .markCelebrationDelivered(
            familyId: session.familyId,
            celebration: celebration,
          );
      ref.invalidate(celebrationsProvider(celebration.childId));
      ref.invalidate(childCompanionExperienceProvider(celebration.childId));
      ref.invalidate(shardWalletProvider(celebration.childId));
      ref.invalidate(recentShardTransactionsProvider(celebration.childId));
    });
  }
}

final celebrationDeliveryProvider =
    StateNotifierProvider<CelebrationDeliveryNotifier, AsyncValue<void>>(
      (ref) => CelebrationDeliveryNotifier(ref),
    );

class CompanionProfileNotifier extends StateNotifier<AsyncValue<void>> {
  CompanionProfileNotifier(this.ref) : super(const AsyncData(null));

  final Ref ref;

  Future<void> save(String childId, ChildCompanionProfile profile) async {
    final session = ref.read(sessionProvider);
    if (session == null || childId.isEmpty || state.isLoading) return;
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
