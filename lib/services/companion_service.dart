import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/celebration.dart';
import '../models/child_companion_profile.dart';
import '../models/companion_memory.dart';
import '../models/companion_observation.dart';
import '../models/shard_transaction.dart';

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

  Future<void> decideMemory({
    required String familyId,
    required String childId,
    required String memoryId,
    required CompanionMemoryStatus decision,
    required String parentId,
  }) {
    final reference = _memories(familyId, childId).doc(memoryId);
    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      if (!snapshot.exists) throw StateError('Mémoire introuvable.');
      final memory = CompanionMemory.fromMap(snapshot.id, snapshot.data()!);
      if (!memory.isProposed) return;
      final decidedMemory = memory.decide(
        decision: decision,
        parentId: parentId,
        decidedAt: DateTime.now(),
      );
      transaction.update(reference, decidedMemory.toMap());
    });
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

  Future<void> createParentCelebration({
    required String familyId,
    required Celebration celebration,
  }) {
    final childReference = _child(familyId, celebration.childId);
    final celebrationReference = _celebrations(
      familyId,
      celebration.childId,
    ).doc(celebration.id);
    if (celebration.shardReward == 0) {
      return celebrationReference.set(celebration.toMap());
    }
    final walletReference = childReference.collection('economy').doc('state');
    final sourceKey = 'celebration_${celebration.id}';
    final ledgerReference = childReference
        .collection('reward_ledger')
        .doc(sourceKey);
    return _firestore.runTransaction((transaction) async {
      final ledgerSnapshot = await transaction.get(ledgerReference);
      if (ledgerSnapshot.exists) return;
      final walletSnapshot = await transaction.get(walletReference);
      final balance = ((walletSnapshot.data()?['balance'] as num?) ?? 0)
          .toInt();
      transaction.set(celebrationReference, celebration.toMap());
      transaction.set(walletReference, {
        'balance': balance + celebration.shardReward,
        'updatedAt': Timestamp.fromDate(celebration.createdAt),
      });
      transaction.set(
        ledgerReference,
        ShardTransaction(
          id: sourceKey,
          childId: celebration.childId,
          type: ShardTransactionType.credit,
          source: ShardTransactionSource.celebration,
          amount: celebration.shardReward,
          sourceKey: sourceKey,
          createdAt: celebration.createdAt,
        ).toMap(),
      );
    });
  }

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
