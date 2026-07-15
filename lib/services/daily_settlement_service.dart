import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/daily_light_summary.dart';
import '../models/daily_settlement.dart';

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
    final settlementRef = childRef.collection('daily_settlements').doc(dateKey);
    return _firestore.runTransaction((transaction) async {
      if ((await transaction.get(settlementRef)).exists) return null;
      final now = DateTime.now();
      transaction.set(settlementRef, {
        ...summary.toMap(),
        'progressReward': 0,
        'gentleSupportBonus': 0,
        'totalReward': 0,
        'gentleEventIds': gentleEventIds,
        'settledAt': Timestamp.fromDate(now),
      });
      return DailySettlement(
        childId: summary.childId,
        date: summary.date,
        completedItems: summary.completedItems,
        totalItems: summary.totalItems,
        progressReward: 0,
        gentleSupportBonus: 0,
        totalReward: 0,
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
