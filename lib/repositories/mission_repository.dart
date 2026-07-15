import '../core/constants/secret_missions_catalog.dart';
import '../models/secret_mission.dart';
import '../models/shared_moment.dart';
import '../services/mission_service.dart';

class MissionRepository {
  MissionRepository({MissionService? service})
    : _service = service ?? MissionService();
  final MissionService _service;
  static const activeStatuses = {
    SecretMissionStatus.available,
    SecretMissionStatus.accepted,
    SecretMissionStatus.completedByChild,
    SecretMissionStatus.awaitingParentValidation,
  };

  Future<SecretMission?> getOrCreateAvailable({
    required String familyId,
    required String childId,
    required String guardianId,
    DateTime? now,
  }) async {
    final date = now ?? DateTime.now();
    final missions = await _service.getMissions(
      familyId: familyId,
      childId: childId,
    );
    for (final mission in missions) {
      if (activeStatuses.contains(mission.status) &&
          !mission.expiresAt.isBefore(date)) {
        return mission;
      }
    }
    if (![
      DateTime.wednesday,
      DateTime.saturday,
      DateTime.sunday,
    ].contains(date.weekday)) {
      return null;
    }
    final weekKey = _weekKey(date);
    final id = 'mission_$weekKey';
    for (final mission in missions) {
      if (mission.id == id) {
        return mission;
      }
    }
    final seed = childId.codeUnits.fold<int>(
      date.year + _weekNumber(date),
      (sum, value) => sum + value,
    );
    final template = secretMissionsCatalog[seed % secretMissionsCatalog.length];
    final endOfWeek = DateTime(
      date.year,
      date.month,
      date.day + (DateTime.sunday - date.weekday),
      23,
      59,
      59,
    );
    final mission = SecretMission(
      id: id,
      childId: childId,
      catalogId: template.id,
      title: template.title,
      description: template.description,
      category: template.category,
      status: SecretMissionStatus.available,
      createdAt: date,
      expiresAt: endOfWeek,
      origin: SecretMissionOrigin.automatic,
      reward: 0,
      idempotencyKey: 'mission_$id',
      guardianId: guardianId,
    );
    await _service.createMission(familyId: familyId, mission: mission);
    return mission;
  }

  Future<List<SecretMission>> getMissions({
    required String familyId,
    required String childId,
  }) => _service.getMissions(familyId: familyId, childId: childId);
  Future<void> markAnnouncementDelivered({
    required String familyId,
    required SecretMission mission,
  }) => _service.markAnnouncementDelivered(
    familyId: familyId,
    childId: mission.childId,
    missionId: mission.id,
  );
  Future<List<SharedMoment>> getSharedMoments({
    required String familyId,
    required String childId,
  }) => _service.getSharedMoments(familyId: familyId, childId: childId);
  Future<void> accept({
    required String familyId,
    required SecretMission mission,
    required String guardianId,
  }) => _service.changeStatus(
    familyId: familyId,
    childId: mission.childId,
    missionId: mission.id,
    expected: SecretMissionStatus.available,
    next: SecretMissionStatus.accepted,
    guardianId: guardianId,
  );
  Future<void> complete({
    required String familyId,
    required SecretMission mission,
  }) => _service.changeStatus(
    familyId: familyId,
    childId: mission.childId,
    missionId: mission.id,
    expected: SecretMissionStatus.accepted,
    next: SecretMissionStatus.awaitingParentValidation,
  );

  Future<MissionValidationResult> validate({
    required String familyId,
    required SecretMission mission,
    required String parentId,
  }) {
    final template = missionTemplate(mission.catalogId);
    return _service.validate(
      familyId: familyId,
      childId: mission.childId,
      missionId: mission.id,
      parentId: parentId,
      reward: 0,
      iconId: template.iconId,
    );
  }

  Future<void> refuse({
    required String familyId,
    required SecretMission mission,
    required String parentId,
  }) => _service.refuse(
    familyId: familyId,
    childId: mission.childId,
    missionId: mission.id,
    parentId: parentId,
  );

  static String _weekKey(DateTime date) =>
      '${date.year}-W${_weekNumber(date).toString().padLeft(2, '0')}';
  static int _weekNumber(DateTime date) {
    final thursday = date.add(Duration(days: DateTime.thursday - date.weekday));
    final firstThursday = DateTime(thursday.year, 1, 4);
    return 1 +
        thursday
                .difference(
                  firstThursday.subtract(
                    Duration(days: firstThursday.weekday - DateTime.thursday),
                  ),
                )
                .inDays ~/
            7;
  }
}
