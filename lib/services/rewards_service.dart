import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/inventory_entry.dart';
import '../models/shard_transaction.dart';
import '../models/shard_wallet.dart';

enum CreditResult { credited, alreadyCredited }

enum PurchaseResult { purchased, alreadyOwned, insufficientBalance }

class RewardsService {
  RewardsService({FirebaseFirestore? firestore})
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

  DocumentReference<Map<String, dynamic>> _wallet(
    String familyId,
    String childId,
  ) => _child(familyId, childId).collection('economy').doc('state');

  CollectionReference<Map<String, dynamic>> _ledger(
    String familyId,
    String childId,
  ) => _child(familyId, childId).collection('reward_ledger');

  CollectionReference<Map<String, dynamic>> _inventory(
    String familyId,
    String childId,
  ) => _child(familyId, childId).collection('inventory');

  Future<ShardWallet> getWallet({
    required String familyId,
    required String childId,
  }) async {
    final snapshot = await _wallet(familyId, childId).get();
    return ShardWallet.fromMap(childId, snapshot.data());
  }

  Future<List<ShardTransaction>> getRecentTransactions({
    required String familyId,
    required String childId,
    int limit = 20,
  }) async {
    final snapshot = await _ledger(
      familyId,
      childId,
    ).orderBy('createdAt', descending: true).limit(limit).get();
    return snapshot.docs
        .map((doc) => ShardTransaction.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<List<InventoryEntry>> getInventory({
    required String familyId,
    required String childId,
  }) async {
    final snapshot = await _inventory(
      familyId,
      childId,
    ).orderBy('acquiredAt', descending: true).get();
    return snapshot.docs
        .map((doc) => InventoryEntry.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<CreditResult> creditOnce({
    required String familyId,
    required String childId,
    required String sourceKey,
    required int amount,
  }) {
    final walletRef = _wallet(familyId, childId);
    final ledgerRef = _ledger(familyId, childId).doc(sourceKey);
    return _firestore.runTransaction((transaction) async {
      final ledgerSnapshot = await transaction.get(ledgerRef);
      if (ledgerSnapshot.exists) return CreditResult.alreadyCredited;
      final walletSnapshot = await transaction.get(walletRef);
      final balance = ((walletSnapshot.data()?['balance'] as num?) ?? 0)
          .toInt();
      final now = DateTime.now();
      transaction.set(walletRef, {
        'balance': balance + amount,
        'updatedAt': Timestamp.fromDate(now),
      });
      transaction.set(
        ledgerRef,
        ShardTransaction(
          id: sourceKey,
          childId: childId,
          type: ShardTransactionType.credit,
          source: ShardTransactionSource.dayCompletion,
          amount: amount,
          sourceKey: sourceKey,
          createdAt: now,
        ).toMap(),
      );
      return CreditResult.credited;
    });
  }

  Future<PurchaseResult> purchase({
    required String familyId,
    required String childId,
    required String findingId,
    required int price,
  }) {
    final walletRef = _wallet(familyId, childId);
    final inventoryRef = _inventory(familyId, childId).doc(findingId);
    final sourceKey = 'purchase_$findingId';
    final ledgerRef = _ledger(familyId, childId).doc(sourceKey);
    return _firestore.runTransaction((transaction) async {
      final inventorySnapshot = await transaction.get(inventoryRef);
      if (inventorySnapshot.exists) return PurchaseResult.alreadyOwned;
      final walletSnapshot = await transaction.get(walletRef);
      final balance = ((walletSnapshot.data()?['balance'] as num?) ?? 0)
          .toInt();
      if (balance < price) return PurchaseResult.insufficientBalance;
      final now = DateTime.now();
      transaction.set(walletRef, {
        'balance': balance - price,
        'updatedAt': Timestamp.fromDate(now),
      });
      transaction.set(
        ledgerRef,
        ShardTransaction(
          id: sourceKey,
          childId: childId,
          type: ShardTransactionType.debit,
          source: ShardTransactionSource.findingPurchase,
          amount: price,
          sourceKey: sourceKey,
          createdAt: now,
        ).toMap(),
      );
      transaction.set(
        inventoryRef,
        InventoryEntry(findingId: findingId, acquiredAt: now).toMap(),
      );
      return PurchaseResult.purchased;
    });
  }
}
