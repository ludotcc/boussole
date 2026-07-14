import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/daily_light_summary.dart';
import '../models/daily_settlement.dart';
import '../models/shard_transaction.dart';
import '../repositories/rewards_repository.dart';

class DailySettlementService {
  DailySettlementService({FirebaseFirestore? firestore})
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

  Future<void> saveLightSnapshot({
    required String familyId,
    required DailyLightSummary summary,
  }) => _child(familyId, summary.childId)
      .collection('daily_light')
      .doc(_dateKey(summary.date))
      .set({...summary.toMap(), 'updatedAt': FieldValue.serverTimestamp()});

  Future<List<DailyLightSummary>> getPastLightSnapshots({
    required String familyId,
    required String childId,
    required DateTime before,
  }) async {
    final snapshot = await _child(familyId, childId)
        .collection('daily_light')
        .where(FieldPath.documentId, isLessThan: _dateKey(before))
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return DailyLightSummary(
        childId: childId,
        date: DateTime.parse(doc.id),
        completedItems: ((data['completedItems'] as num?) ?? 0).toInt(),
        totalItems: ((data['totalItems'] as num?) ?? 0).toInt(),
      );
    }).toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<List<String>> getEligibleGentleEventIds({
    required String familyId,
    required String childId,
    required DateTime date,
  }) async {
    final snapshot = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('events')
        .get();
    return snapshot.docs
        .where((doc) {
          final data = doc.data();
          final rawDate = data['date'];
          final eventDate = rawDate is Timestamp
              ? rawDate.toDate()
              : DateTime.tryParse(rawDate?.toString() ?? '');
          final members = List<String>.from(
            data['memberIds'] as List? ?? const [],
          );
          return data['isSensitiveMoment'] == true &&
              members.contains(childId) &&
              eventDate != null &&
              _dateKey(eventDate) == _dateKey(date);
        })
        .map((doc) => doc.id)
        .toList();
  }

  Future<DailySettlement?> settleDay({
    required String familyId,
    required DailyLightSummary summary,
    required int progressReward,
    required int gentleSupportBonus,
    required List<String> gentleEventIds,
  }) {
    final childRef = _child(familyId, summary.childId);
    final dateKey = _dateKey(summary.date);
    final ledgerRef = childRef
        .collection('reward_ledger')
        .doc(RewardsRepository.daySourceKey(summary.date));
    final walletRef = childRef.collection('economy').doc('state');
    final settlementRef = childRef.collection('daily_settlements').doc(dateKey);
    return _firestore.runTransaction((transaction) async {
      if ((await transaction.get(ledgerRef)).exists) return null;
      final wallet = await transaction.get(walletRef);
      final balance = ((wallet.data()?['balance'] as num?) ?? 0).toInt();
      final now = DateTime.now();
      final total = progressReward + gentleSupportBonus;
      transaction.set(walletRef, {
        'balance': balance + total,
        'updatedAt': Timestamp.fromDate(now),
      });
      transaction.set(
        ledgerRef,
        ShardTransaction(
          id: ledgerRef.id,
          childId: summary.childId,
          type: ShardTransactionType.credit,
          source: ShardTransactionSource.dayCompletion,
          amount: total,
          sourceKey: ledgerRef.id,
          createdAt: now,
        ).toMap(),
      );
      transaction.set(settlementRef, {
        ...summary.toMap(),
        'progressReward': progressReward,
        'gentleSupportBonus': gentleSupportBonus,
        'totalReward': total,
        'gentleEventIds': gentleEventIds,
        'settledAt': Timestamp.fromDate(now),
      });
      return DailySettlement(
        childId: summary.childId,
        date: summary.date,
        completedItems: summary.completedItems,
        totalItems: summary.totalItems,
        progressReward: progressReward,
        gentleSupportBonus: gentleSupportBonus,
        totalReward: total,
        settledAt: now,
        gentleEventIds: gentleEventIds,
      );
    });
  }

  String _dateKey(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
