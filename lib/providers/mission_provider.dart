import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/secret_mission.dart';
import '../repositories/mission_repository.dart';
import '../services/mission_service.dart';
import 'children_provider.dart';
import 'guardian_provider.dart';
import 'rewards_provider.dart';
import 'session_provider.dart';
import 'shared_moments_provider.dart';

final missionRepositoryProvider = Provider<MissionRepository>(
  (_) => MissionRepository(),
);

final childSecretMissionProvider =
    FutureProvider.family<SecretMission?, String>((ref, childId) async {
      final session = ref.watch(sessionProvider);
      if (session == null || childId.isEmpty) {
        throw StateError('Enfant invalide');
      }
      final guardian = await ref.watch(childGuardianProvider(childId).future);
      return ref
          .read(missionRepositoryProvider)
          .getOrCreateAvailable(
            familyId: session.familyId,
            childId: childId,
            guardianId: guardian.storageId,
          );
    });

final pendingMissionValidationsProvider = FutureProvider<List<SecretMission>>((
  ref,
) async {
  final session = ref.watch(sessionProvider);
  final children = await ref.watch(childrenProvider.future);
  if (session == null) return [];
  final repository = ref.read(missionRepositoryProvider);
  final missionsByChild = await Future.wait([
    for (final child in children)
      repository.getMissions(familyId: session.familyId, childId: child.id),
  ]);
  final pending = missionsByChild
      .expand((missions) => missions)
      .where((mission) => mission.isPending)
      .toList();
  pending.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return pending;
});

final pendingMissionAnnouncementsProvider =
    FutureProvider.family<List<SecretMission>, String>((ref, childId) async {
      final session = ref.watch(sessionProvider);
      if (session == null || childId.isEmpty) return [];
      final missions = await ref
          .read(missionRepositoryProvider)
          .getMissions(familyId: session.familyId, childId: childId);
      return missions
          .where((mission) => mission.hasPendingAnnouncement)
          .toList()
        ..sort((a, b) => a.validatedAt!.compareTo(b.validatedAt!));
    });

class MissionActionNotifier extends StateNotifier<AsyncValue<void>> {
  MissionActionNotifier(this.ref, this.childId) : super(const AsyncData(null));
  final Ref ref;
  final String childId;

  Future<void> accept(SecretMission mission, String guardianId) => _run(
    (repository, familyId) => repository.accept(
      familyId: familyId,
      mission: mission,
      guardianId: guardianId,
    ),
  );
  Future<void> complete(SecretMission mission) => _run(
    (repository, familyId) =>
        repository.complete(familyId: familyId, mission: mission),
  );

  Future<void> _run(
    Future<void> Function(MissionRepository, String) action,
  ) async {
    final session = ref.read(sessionProvider);
    if (session == null || childId.isEmpty) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await action(ref.read(missionRepositoryProvider), session.familyId);
      ref.invalidate(childSecretMissionProvider(childId));
      ref.invalidate(pendingMissionValidationsProvider);
    });
  }
}

final missionActionProvider =
    StateNotifierProvider.family<
      MissionActionNotifier,
      AsyncValue<void>,
      String
    >((ref, childId) => MissionActionNotifier(ref, childId));

class MissionValidationNotifier
    extends StateNotifier<AsyncValue<MissionValidationResult?>> {
  MissionValidationNotifier(this.ref) : super(const AsyncData(null));
  final Ref ref;

  Future<void> validate(SecretMission mission) => _run(mission, true);
  Future<void> refuse(SecretMission mission) => _run(mission, false);

  Future<void> _run(SecretMission mission, bool validate) async {
    if (state.isLoading) return;
    final session = ref.read(sessionProvider);
    if (session == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      MissionValidationResult? result;
      if (validate) {
        result = await ref
            .read(missionRepositoryProvider)
            .validate(
              familyId: session.familyId,
              mission: mission,
              parentId: session.userId,
            );
      } else {
        await ref
            .read(missionRepositoryProvider)
            .refuse(
              familyId: session.familyId,
              mission: mission,
              parentId: session.userId,
            );
      }
      ref.invalidate(pendingMissionValidationsProvider);
      ref.invalidate(childSecretMissionProvider(mission.childId));
      if (validate) {
        ref.invalidate(shardWalletProvider(mission.childId));
        ref.invalidate(recentShardTransactionsProvider(mission.childId));
        ref.invalidate(sharedMomentsProvider(mission.childId));
        ref.invalidate(pendingMissionAnnouncementsProvider(mission.childId));
      }
      return result;
    });
  }
}

final missionValidationProvider =
    StateNotifierProvider<
      MissionValidationNotifier,
      AsyncValue<MissionValidationResult?>
    >((ref) => MissionValidationNotifier(ref));

class MissionAnnouncementDeliveryNotifier
    extends StateNotifier<AsyncValue<void>> {
  MissionAnnouncementDeliveryNotifier(this.ref) : super(const AsyncData(null));
  final Ref ref;

  Future<void> markDelivered(SecretMission mission) async {
    if (state.isLoading) return;
    final session = ref.read(sessionProvider);
    if (session == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(missionRepositoryProvider)
          .markAnnouncementDelivered(
            familyId: session.familyId,
            mission: mission,
          );
      ref.invalidate(pendingMissionAnnouncementsProvider(mission.childId));
    });
  }
}

final missionAnnouncementDeliveryProvider =
    StateNotifierProvider<
      MissionAnnouncementDeliveryNotifier,
      AsyncValue<void>
    >((ref) => MissionAnnouncementDeliveryNotifier(ref));
