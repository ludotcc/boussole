import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/celebration.dart';
import '../models/child_companion_profile.dart';
import '../models/companion_memory.dart';
import '../models/companion_observation.dart';

class CompanionService {
  CompanionService({FirebaseFirestore? firestore})
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

  CollectionReference<Map<String, dynamic>> _memories(
    String familyId,
    String childId,
  ) => _child(familyId, childId).collection('companion_memories');

  CollectionReference<Map<String, dynamic>> _celebrations(
    String familyId,
    String childId,
  ) => _child(familyId, childId).collection('celebrations');

  CollectionReference<Map<String, dynamic>> _observations(
    String familyId,
    String childId,
  ) => _child(familyId, childId).collection('companion_observations');

  Future<void> saveProfile({
    required String familyId,
    required String childId,
    required ChildCompanionProfile profile,
  }) => _child(familyId, childId).update({'companionProfile': profile.toMap()});

  String generateMemoryId(String familyId, String childId) =>
      _memories(familyId, childId).doc().id;

  Future<void> saveMemory({
    required String familyId,
    required CompanionMemory memory,
  }) => _memories(
    familyId,
    memory.childId,
  ).doc(memory.id).set(memory.toMap(), SetOptions(merge: true));

  Future<List<CompanionMemory>> getMemories({
    required String familyId,
    required String childId,
  }) async {
    final snapshot = await _memories(familyId, childId).get();
    final memories = snapshot.docs
        .map((doc) => CompanionMemory.fromMap(doc.id, doc.data()))
        .toList();
    memories.sort((a, b) {
      final priority = b.priority.compareTo(a.priority);
      return priority != 0 ? priority : b.updatedAt.compareTo(a.updatedAt);
    });
    return memories;
  }

  String generateCelebrationId(String familyId, String childId) =>
      _celebrations(familyId, childId).doc().id;

  Future<void> saveCelebration({
    required String familyId,
    required Celebration celebration,
  }) => _celebrations(
    familyId,
    celebration.childId,
  ).doc(celebration.id).set(celebration.toMap(), SetOptions(merge: true));

  Future<List<Celebration>> getCelebrations({
    required String familyId,
    required String childId,
  }) async {
    final snapshot = await _celebrations(
      familyId,
      childId,
    ).orderBy('createdAt', descending: true).get();
    return snapshot.docs
        .map((doc) => Celebration.fromMap(doc.id, doc.data()))
        .toList();
  }

  String generateObservationId(String familyId, String childId) =>
      _observations(familyId, childId).doc().id;

  Future<void> saveObservation({
    required String familyId,
    required CompanionObservation observation,
  }) => _observations(
    familyId,
    observation.childId,
  ).doc(observation.id).set(observation.toMap());

  Future<List<CompanionObservation>> getRecentObservations({
    required String familyId,
    required String childId,
    int limit = 30,
  }) async {
    final snapshot = await _observations(
      familyId,
      childId,
    ).orderBy('createdAt', descending: true).limit(limit).get();
    return snapshot.docs
        .map((doc) => CompanionObservation.fromMap(doc.id, doc.data()))
        .toList();
  }
}
