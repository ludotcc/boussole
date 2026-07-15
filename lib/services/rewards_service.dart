import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/inventory_entry.dart';
import '../models/parent_reward.dart';
import '../models/reward_announcement.dart';
import '../models/shard_transaction.dart';
import '../models/shard_wallet.dart';

enum CreditResult { credited, alreadyCredited }

enum PurchaseResult { purchased, alreadyOwned, insufficientBalance }

enum ParentRewardRedemptionResult {
  redeemed,
  alreadyProcessed,
  insufficientBalance,
  unavailable,
}

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

  CollectionReference<Map<String, dynamic>> _parentRewards(
    String familyId,
    String childId,
  ) => _child(familyId, childId).collection('parent_rewards');

  CollectionReference<Map<String, dynamic>> _rewardAnnouncements(
    String familyId,
    String childId,
  ) => _child(familyId, childId).collection('reward_announcements');

  String generateParentRewardId(String familyId, String childId) =>
      _parentRewards(familyId, childId).doc().id;

  String generateRedemptionId(String familyId, String childId) =>
      _rewardAnnouncements(familyId, childId).doc().id;

  Future<List<ParentReward>> getParentRewards({
    required String familyId,
    required String childId,
  }) async {
    final snapshot = await _parentRewards(familyId, childId).get();
    final rewards =
        snapshot.docs
            .map((doc) => ParentReward.fromMap(doc.id, doc.data()))
            .where((reward) => reward.isActive)
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return rewards.take(5).toList();
  }

  Future<void> saveParentReward({
    required String familyId,
    required ParentReward reward,
  }) async {
    if (!reward.isValid) throw ArgumentError('Récompense invalide.');
    final reference = _parentRewards(familyId, reward.childId).doc(reward.id);
    await _firestore.runTransaction((transaction) async {
      final existing = await transaction.get(reference);
      if (!existing.exists) {
        final active = await _parentRewards(
          familyId,
          reward.childId,
        ).where('isActive', isEqualTo: true).get();
        if (active.docs.length >= 5) {
          throw StateError('Maximum de 5 récompenses atteint.');
        }
      }
      transaction.set(reference, reward.toMap());
    });
  }

  Future<void> deleteParentReward({
    required String familyId,
    required String childId,
    required String rewardId,
  }) => _parentRewards(familyId, childId).doc(rewardId).delete();

  Future<ParentRewardRedemptionResult> redeemParentReward({
    required String familyId,
    required String childId,
    required String rewardId,
    required String redemptionId,
  }) {
    final rewardRef = _parentRewards(familyId, childId).doc(rewardId);
    final walletRef = _wallet(familyId, childId);
    final ledgerRef = _ledger(
      familyId,
      childId,
    ).doc('parent_reward_$redemptionId');
    final announcementRef = _rewardAnnouncements(
      familyId,
      childId,
    ).doc(redemptionId);
    return _firestore.runTransaction((transaction) async {
      if ((await transaction.get(ledgerRef)).exists) {
        return ParentRewardRedemptionResult.alreadyProcessed;
      }
      final rewardSnapshot = await transaction.get(rewardRef);
      if (!rewardSnapshot.exists) {
        return ParentRewardRedemptionResult.unavailable;
      }
      final reward = ParentReward.fromMap(
        rewardSnapshot.id,
        rewardSnapshot.data()!,
      );
      if (!reward.isActive || !reward.isValid) {
        return ParentRewardRedemptionResult.unavailable;
      }
      final walletSnapshot = await transaction.get(walletRef);
      final balance = ((walletSnapshot.data()?['balance'] as num?) ?? 0)
          .toInt();
      if (balance < reward.cost) {
        return ParentRewardRedemptionResult.insufficientBalance;
      }
      final now = DateTime.now();
      final remaining = balance - reward.cost;
      transaction.set(walletRef, {
        'balance': remaining,
        'updatedAt': Timestamp.fromDate(now),
      });
      transaction.set(
        ledgerRef,
        ShardTransaction(
          id: ledgerRef.id,
          childId: childId,
          type: ShardTransactionType.debit,
          source: ShardTransactionSource.parentRewardRedemption,
          amount: reward.cost,
          sourceKey: ledgerRef.id,
          createdAt: now,
        ).toMap(),
      );
      transaction.set(
        announcementRef,
        RewardAnnouncement(
          id: redemptionId,
          childId: childId,
          rewardName: reward.name,
          cost: reward.cost,
          remainingBalance: remaining,
          createdAt: now,
        ).toMap(),
      );
      return ParentRewardRedemptionResult.redeemed;
    });
  }

  Future<List<RewardAnnouncement>> getPendingRewardAnnouncements({
    required String familyId,
    required String childId,
  }) async {
    final snapshot = await _rewardAnnouncements(familyId, childId).get();
    final announcements =
        snapshot.docs
            .map((doc) => RewardAnnouncement.fromMap(doc.id, doc.data()))
            .where((announcement) => announcement.isPending)
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return announcements;
  }

  Future<void> markRewardAnnouncementDelivered({
    required String familyId,
    required String childId,
    required String announcementId,
  }) => _rewardAnnouncements(familyId, childId).doc(announcementId).update({
    'deliveredAt': Timestamp.fromDate(DateTime.now()),
  });

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
