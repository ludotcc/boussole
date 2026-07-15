import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/secret_mission.dart';
import '../models/shared_moment.dart';

enum MissionValidationResult { validated, alreadyProcessed, expired }

class MissionService {
  MissionService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _child(
    String familyId,
    String childId,
  ) => _firestore
      .collection('families')
      .doc(familyId)
      .collection('children')
      .doc(childId);
  CollectionReference<Map<String, dynamic>> _missions(
    String familyId,
    String childId,
  ) => _child(familyId, childId).collection('secret_missions');
  CollectionReference<Map<String, dynamic>> _moments(
    String familyId,
    String childId,
  ) => _child(familyId, childId).collection('shared_moments');

  Future<List<SecretMission>> getMissions({
    required String familyId,
    required String childId,
  }) async {
    final snapshot = await _missions(
      familyId,
      childId,
    ).orderBy('createdAt', descending: true).get();
    return snapshot.docs
        .map((doc) => SecretMission.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> createMission({
    required String familyId,
    required SecretMission mission,
  }) => _missions(
    familyId,
    mission.childId,
  ).doc(mission.id).set(mission.toMap(), SetOptions(merge: false));

  Future<void> changeStatus({
    required String familyId,
    required String childId,
    required String missionId,
    required SecretMissionStatus expected,
    required SecretMissionStatus next,
    String? guardianId,
  }) {
    final ref = _missions(familyId, childId).doc(missionId);
    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) throw StateError('Mission introuvable');
      final mission = SecretMission.fromMap(snapshot.id, snapshot.data()!);
      if (mission.status != expected) return;
      final updates = <String, dynamic>{'status': next.name};
      if (guardianId != null) {
        updates['guardianId'] = guardianId;
      }
      transaction.update(ref, updates);
    });
  }

  Future<MissionValidationResult> validate({
    required String familyId,
    required String childId,
    required String missionId,
    required String parentId,
    required int reward,
    required String iconId,
  }) {
    final missionRef = _missions(familyId, childId).doc(missionId);
    final momentRef = _moments(familyId, childId).doc(missionId);
    return _firestore.runTransaction((transaction) async {
      final missionSnapshot = await transaction.get(missionRef);
      if (!missionSnapshot.exists) {
        return MissionValidationResult.alreadyProcessed;
      }
      final mission = SecretMission.fromMap(
        missionSnapshot.id,
        missionSnapshot.data()!,
      );
      if (mission.expiresAt.isBefore(DateTime.now())) {
        transaction.update(missionRef, {
          'status': SecretMissionStatus.expired.name,
        });
        return MissionValidationResult.expired;
      }
      if (!mission.isPending) return MissionValidationResult.alreadyProcessed;
      final now = DateTime.now();
      final moment = SharedMoment(
        id: mission.id,
        childId: childId,
        title: mission.title,
        description: mission.description,
        category: mission.category.name,
        date: now,
        guardianId: mission.guardianId ?? 'crystal',
        origin: 'secretMission',
        validatedByParent: true,
        iconId: iconId,
        missionId: mission.id,
      );
      transaction.update(missionRef, {
        'status': SecretMissionStatus.validated.name,
        'validatedAt': Timestamp.fromDate(now),
        'validatedBy': parentId,
        'announcementDeliveredAt': null,
        'announcementPending': true,
      });
      transaction.set(momentRef, moment.toMap());
      return MissionValidationResult.validated;
    });
  }

  Future<void> markAnnouncementDelivered({
    required String familyId,
    required String childId,
    required String missionId,
  }) {
    final missionRef = _missions(familyId, childId).doc(missionId);
    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(missionRef);
      if (!snapshot.exists) return;
      final mission = SecretMission.fromMap(snapshot.id, snapshot.data()!);
      if (!mission.hasPendingAnnouncement) return;
      transaction.update(missionRef, {
        'announcementDeliveredAt': Timestamp.fromDate(DateTime.now()),
        'announcementPending': false,
      });
    });
  }

  Future<void> refuse({
    required String familyId,
    required String childId,
    required String missionId,
    required String parentId,
  }) {
    final ref = _missions(familyId, childId).doc(missionId);
    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) return;
      final mission = SecretMission.fromMap(snapshot.id, snapshot.data()!);
      if (!mission.isPending) return;
      transaction.update(ref, {
        'status': SecretMissionStatus.refused.name,
        'validatedAt': Timestamp.fromDate(DateTime.now()),
        'validatedBy': parentId,
      });
    });
  }

  Future<List<SharedMoment>> getSharedMoments({
    required String familyId,
    required String childId,
  }) async {
    final snapshot = await _moments(
      familyId,
      childId,
    ).orderBy('date', descending: true).get();
    return snapshot.docs
        .map((doc) => SharedMoment.fromMap(doc.id, doc.data()))
        .toList();
  }
}
