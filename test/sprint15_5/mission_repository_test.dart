import 'package:flutter_test/flutter_test.dart';

import 'package:boussole/models/secret_mission.dart';
import 'package:boussole/models/shared_moment.dart';
import 'package:boussole/repositories/mission_repository.dart';
import 'package:boussole/services/mission_service.dart';

void main() {
  group('Missions Secrètes', () {
    test('une seule mission active est créée pour la semaine', () async {
      final service = _FakeMissionService();
      final repository = MissionRepository(service: service);
      final date = DateTime(2026, 7, 15);
      final first = await repository.getOrCreateAvailable(
        familyId: 'family',
        childId: 'child',
        guardianId: 'wave',
        now: date,
      );
      final second = await repository.getOrCreateAvailable(
        familyId: 'family',
        childId: 'child',
        guardianId: 'wave',
        now: date,
      );
      expect(first, isNotNull);
      expect(second?.id, first?.id);
      expect(service.missions, hasLength(1));
      service.missions[0] = _copy(
        service.missions.single,
        status: SecretMissionStatus.validated,
      );
      final reopened = await repository.getOrCreateAvailable(
        familyId: 'family',
        childId: 'child',
        guardianId: 'wave',
        now: date,
      );
      expect(reopened?.status, SecretMissionStatus.validated);
      expect(service.missions, hasLength(1));
    });

    test('acceptation et fin enfant ne donnent aucun Éclat', () async {
      final service = _FakeMissionService();
      final repository = MissionRepository(service: service);
      final mission = (await repository.getOrCreateAvailable(
        familyId: 'family',
        childId: 'child',
        guardianId: 'crystal',
        now: DateTime(2026, 7, 15),
      ))!;
      await repository.accept(
        familyId: 'family',
        mission: mission,
        guardianId: 'crystal',
      );
      await repository.complete(
        familyId: 'family',
        mission: service.missions.single,
      );
      expect(
        service.missions.single.status,
        SecretMissionStatus.awaitingParentValidation,
      );
      expect(service.balance, 0);
      expect(service.moments, isEmpty);
    });

    test('validation crédite une fois et crée un souvenir', () async {
      final service = _FakeMissionService();
      final repository = MissionRepository(service: service);
      final mission = await _pendingMission(repository, service);
      expect(
        await repository.validate(
          familyId: 'family',
          mission: mission,
          parentId: 'parent',
        ),
        MissionValidationResult.validated,
      );
      final credited = service.balance;
      expect(credited, inInclusiveRange(5, 15));
      expect(service.moments, hasLength(1));
      expect(service.moments.single.guardianId, 'pixel');
      expect(
        await repository.validate(
          familyId: 'family',
          mission: mission,
          parentId: 'parent',
        ),
        MissionValidationResult.alreadyProcessed,
      );
      expect(service.balance, credited);
      expect(service.moments, hasLength(1));
    });

    test('refus ne crédite pas et ne crée pas de souvenir', () async {
      final service = _FakeMissionService();
      final repository = MissionRepository(service: service);
      final mission = await _pendingMission(repository, service);
      await repository.refuse(
        familyId: 'family',
        mission: mission,
        parentId: 'parent',
      );
      expect(service.missions.single.status, SecretMissionStatus.refused);
      expect(service.balance, 0);
      expect(service.moments, isEmpty);
    });

    test('mission expirée non récompensée', () async {
      final service = _FakeMissionService();
      final repository = MissionRepository(service: service);
      final pending = await _pendingMission(repository, service);
      service.missions[0] = _copy(
        pending,
        status: SecretMissionStatus.awaitingParentValidation,
        expiresAt: DateTime(2020),
      );
      expect(
        await repository.validate(
          familyId: 'family',
          mission: service.missions.single,
          parentId: 'parent',
        ),
        MissionValidationResult.expired,
      );
      expect(service.balance, 0);
      expect(service.moments, isEmpty);
    });
  });
}

Future<SecretMission> _pendingMission(
  MissionRepository repository,
  _FakeMissionService service,
) async {
  final mission = (await repository.getOrCreateAvailable(
    familyId: 'family',
    childId: 'child',
    guardianId: 'pixel',
    now: DateTime(2026, 7, 15),
  ))!;
  await repository.accept(
    familyId: 'family',
    mission: mission,
    guardianId: 'pixel',
  );
  await repository.complete(
    familyId: 'family',
    mission: service.missions.single,
  );
  return service.missions.single;
}

class _FakeMissionService implements MissionService {
  final List<SecretMission> missions = [];
  final List<SharedMoment> moments = [];
  final Set<String> ledger = {};
  int balance = 0;

  @override
  Future<void> createMission({
    required String familyId,
    required SecretMission mission,
  }) async {
    if (!missions.any((item) => item.id == mission.id)) missions.add(mission);
  }

  @override
  Future<List<SecretMission>> getMissions({
    required String familyId,
    required String childId,
  }) async => missions.where((item) => item.childId == childId).toList();

  @override
  Future<void> changeStatus({
    required String familyId,
    required String childId,
    required String missionId,
    required SecretMissionStatus expected,
    required SecretMissionStatus next,
    String? guardianId,
  }) async {
    final index = missions.indexWhere((item) => item.id == missionId);
    if (index < 0 || missions[index].status != expected) return;
    missions[index] = _copy(
      missions[index],
      status: next,
      guardianId: guardianId,
    );
  }

  @override
  Future<MissionValidationResult> validate({
    required String familyId,
    required String childId,
    required String missionId,
    required String parentId,
    required int reward,
    required String iconId,
  }) async {
    final index = missions.indexWhere((item) => item.id == missionId);
    if (index < 0 ||
        missions[index].status !=
            SecretMissionStatus.awaitingParentValidation ||
        ledger.contains('mission_$missionId')) {
      return MissionValidationResult.alreadyProcessed;
    }
    final mission = missions[index];
    if (mission.expiresAt.isBefore(DateTime.now())) {
      return MissionValidationResult.expired;
    }
    ledger.add('mission_$missionId');
    balance += reward;
    missions[index] = _copy(mission, status: SecretMissionStatus.validated);
    moments.add(
      SharedMoment(
        id: mission.id,
        childId: childId,
        title: mission.title,
        description: mission.description,
        category: mission.category.name,
        date: DateTime.now(),
        guardianId: mission.guardianId ?? 'crystal',
        origin: 'secretMission',
        validatedByParent: true,
        iconId: iconId,
        missionId: mission.id,
      ),
    );
    return MissionValidationResult.validated;
  }

  @override
  Future<void> refuse({
    required String familyId,
    required String childId,
    required String missionId,
    required String parentId,
  }) async {
    final index = missions.indexWhere((item) => item.id == missionId);
    if (index >= 0 &&
        missions[index].status ==
            SecretMissionStatus.awaitingParentValidation) {
      missions[index] = _copy(
        missions[index],
        status: SecretMissionStatus.refused,
      );
    }
  }

  @override
  Future<List<SharedMoment>> getSharedMoments({
    required String familyId,
    required String childId,
  }) async =>
      moments.where((item) => item.childId == childId).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
}

SecretMission _copy(
  SecretMission value, {
  SecretMissionStatus? status,
  DateTime? expiresAt,
  String? guardianId,
}) => SecretMission(
  id: value.id,
  childId: value.childId,
  catalogId: value.catalogId,
  title: value.title,
  description: value.description,
  category: value.category,
  status: status ?? value.status,
  createdAt: value.createdAt,
  expiresAt: expiresAt ?? value.expiresAt,
  origin: value.origin,
  reward: value.reward,
  idempotencyKey: value.idempotencyKey,
  guardianId: guardianId ?? value.guardianId,
  validatedAt: value.validatedAt,
  validatedBy: value.validatedBy,
);
