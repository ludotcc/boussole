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

  Future<void> createParentCelebration({
    required String familyId,
    required Celebration celebration,
  }) {
    final celebrationReference = _celebrations(
      familyId,
      celebration.childId,
    ).doc(celebration.id);
    return celebrationReference.set(celebration.toMap());
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

  Future<void> markCelebrationDelivered({
    required String familyId,
    required String childId,
    required String celebrationId,
  }) {
    final reference = _celebrations(familyId, childId).doc(celebrationId);
    final childReference = _child(familyId, childId);
    final walletReference = childReference.collection('economy').doc('state');
    final sourceKey = 'celebration_$celebrationId';
    final ledgerReference = childReference
        .collection('reward_ledger')
        .doc(sourceKey);
    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      if (!snapshot.exists) return;
      final celebration = Celebration.fromMap(snapshot.id, snapshot.data()!);
      if (celebration.status != CelebrationStatus.pending) return;
      final now = DateTime.now();
      final updates = <String, dynamic>{
        'status': CelebrationStatus.delivered.name,
        'deliveredAt': Timestamp.fromDate(now),
      };
      if (celebration.shardReward > 0) {
        final safeReward = celebration.shardReward.clamp(0, 5);
        final ledgerSnapshot = await transaction.get(ledgerReference);
        if (celebration.shouldCreditReward(
          ledgerExists: ledgerSnapshot.exists,
        )) {
          final walletSnapshot = await transaction.get(walletReference);
          final balance = ((walletSnapshot.data()?['balance'] as num?) ?? 0)
              .toInt();
          transaction.set(walletReference, {
            'balance': balance + safeReward,
            'updatedAt': Timestamp.fromDate(now),
          });
          transaction.set(
            ledgerReference,
            ShardTransaction(
              id: sourceKey,
              childId: childId,
              type: ShardTransactionType.credit,
              source: ShardTransactionSource.celebration,
              amount: safeReward,
              sourceKey: sourceKey,
              createdAt: now,
            ).toMap(),
          );
        }
        updates['rewardDeliveredAt'] = Timestamp.fromDate(now);
      }
      transaction.update(reference, updates);
    });
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
