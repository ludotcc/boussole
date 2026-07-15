import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/guardian_model.dart';
import '../models/guardian_ownership.dart';
import '../models/shard_transaction.dart';

enum GuardianPurchaseResult { purchased, alreadyOwned, insufficientBalance }

enum GuardianSelectionResult { selected, notOwned }

class GuardianService {
  GuardianService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _child({
    required String familyId,
    required String childId,
  }) => _firestore
      .collection('families')
      .doc(familyId)
      .collection('children')
      .doc(childId);

  Future<GuardianOwnership> getOwnership({
    required String familyId,
    required String childId,
  }) async {
    final snapshot = await _child(familyId: familyId, childId: childId).get();
    return GuardianOwnership.fromChildData(snapshot.data());
  }

  Future<GuardianSelectionResult> selectGuardian({
    required String familyId,
    required String childId,
    required String guardianId,
  }) {
    final childRef = _child(familyId: familyId, childId: childId);
    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(childRef);
      final ownership = GuardianOwnership.fromChildData(snapshot.data());
      final guardian = GuardianModel.fromStorageId(
        guardianId,
        fallback: GuardianId.wave,
      );
      if (!ownership.owns(guardian.id)) return GuardianSelectionResult.notOwned;
      transaction.update(childRef, {
        'guardianId': guardian.storageId,
        'ownedGuardianIds': ownership.ownedIds.map((id) => id.name).toList(),
      });
      return GuardianSelectionResult.selected;
    });
  }

  Future<GuardianPurchaseResult> purchaseGuardian({
    required String familyId,
    required String childId,
    required GuardianModel guardian,
    bool selectAfterPurchase = true,
  }) {
    final childRef = _child(familyId: familyId, childId: childId);
    final walletRef = childRef.collection('economy').doc('state');
    final sourceKey = 'guardian_purchase_${guardian.storageId}';
    final ledgerRef = childRef.collection('reward_ledger').doc(sourceKey);
    return _firestore.runTransaction((transaction) async {
      final childSnapshot = await transaction.get(childRef);
      final ownership = GuardianOwnership.fromChildData(childSnapshot.data());
      if (ownership.owns(guardian.id)) {
        return GuardianPurchaseResult.alreadyOwned;
      }
      final walletSnapshot = await transaction.get(walletRef);
      final balance = ((walletSnapshot.data()?['balance'] as num?) ?? 0)
          .toInt();
      if (balance < guardian.price) {
        return GuardianPurchaseResult.insufficientBalance;
      }
      final now = DateTime.now();
      final owned = {...ownership.ownedIds, guardian.id};
      transaction.set(walletRef, {
        'balance': balance - guardian.price,
        'updatedAt': Timestamp.fromDate(now),
      });
      transaction.set(
        ledgerRef,
        ShardTransaction(
          id: sourceKey,
          childId: childId,
          type: ShardTransactionType.debit,
          source: ShardTransactionSource.guardianPurchase,
          amount: guardian.price,
          sourceKey: sourceKey,
          createdAt: now,
        ).toMap(),
      );
      transaction.update(childRef, {
        'ownedGuardianIds': owned.map((id) => id.name).toList(),
        'guardianPurchases.${guardian.storageId}': {
          'purchasedAt': Timestamp.fromDate(now),
          'pricePaid': guardian.price,
        },
        if (selectAfterPurchase) 'guardianId': guardian.storageId,
      });
      return GuardianPurchaseResult.purchased;
    });
  }
}
