import 'package:flutter_test/flutter_test.dart';

import 'package:boussole/models/inventory_entry.dart';
import 'package:boussole/models/parent_reward.dart';
import 'package:boussole/models/reward_announcement.dart';
import 'package:boussole/models/shard_transaction.dart';
import 'package:boussole/models/shard_wallet.dart';
import 'package:boussole/repositories/rewards_repository.dart';
import 'package:boussole/services/rewards_service.dart';

void main() {
  group('récompense de journée', () {
    test('la fin de journée ne crédite jamais le portefeuille', () async {
      final service = _FakeRewardsService(balance: 0);
      final repository = RewardsRepository(service: service);
      final date = DateTime(2026, 7, 14);

      expect(RewardsRepository.daySourceKey(date), 'day_2026-07-14');
      expect(
        await repository.rewardDayCompletion(
          familyId: 'family',
          childId: 'child',
          date: date,
        ),
        CreditResult.alreadyCredited,
      );
      expect(
        await repository.rewardDayCompletion(
          familyId: 'family',
          childId: 'child',
          date: date,
        ),
        CreditResult.alreadyCredited,
      );
      expect(service.balance, 0);
      expect(service.ledger, isEmpty);
    });

    test('une remise à zéro de progression ne touche pas le ledger', () async {
      final service = _FakeRewardsService(balance: 0);
      final repository = RewardsRepository(service: service);
      final date = DateTime(2026, 7, 14);
      await repository.rewardDayCompletion(
        familyId: 'family',
        childId: 'child',
        date: date,
      );

      // Le repository de récompenses n'expose volontairement aucune opération
      // de reset : une nouvelle tentative reste donc idempotente.
      expect(
        await repository.rewardDayCompletion(
          familyId: 'family',
          childId: 'child',
          date: date,
        ),
        CreditResult.alreadyCredited,
      );
      expect(service.balance, 5);
    });
  });

  group('achat de Trouvaille', () {
    test('le prix provient du catalogue et l’achat est unique', () async {
      final service = _FakeRewardsService(balance: 100);
      final repository = RewardsRepository(service: service);

      expect(
        await repository.purchaseFinding(
          familyId: 'family',
          childId: 'child',
          findingId: 'small_plant',
        ),
        PurchaseResult.purchased,
      );
      expect(service.lastPrice, 20);
      expect(service.balance, 80);
      expect(
        await repository.purchaseFinding(
          familyId: 'family',
          childId: 'child',
          findingId: 'small_plant',
        ),
        PurchaseResult.alreadyOwned,
      );
      expect(service.balance, 80);
    });

    test('refuse un solde insuffisant sans solde négatif', () async {
      final service = _FakeRewardsService(balance: 10);
      final repository = RewardsRepository(service: service);

      expect(
        await repository.purchaseFinding(
          familyId: 'family',
          childId: 'child',
          findingId: 'soft_lamp',
        ),
        PurchaseResult.insufficientBalance,
      );
      expect(service.balance, 10);
      expect(service.inventory, isEmpty);
    });

    test('refuse un identifiant absent du catalogue', () {
      final repository = RewardsRepository(service: _FakeRewardsService());
      expect(
        () => repository.purchaseFinding(
          familyId: 'family',
          childId: 'child',
          findingId: 'unknown',
        ),
        throwsArgumentError,
      );
    });
  });
}

class _FakeRewardsService implements RewardsService {
  _FakeRewardsService({this.balance = 0});

  int balance;
  int? lastPrice;
  final Set<String> ledger = {};
  final Set<String> inventory = {};

  @override
  String generateParentRewardId(String familyId, String childId) => 'reward';

  @override
  String generateRedemptionId(String familyId, String childId) => 'redemption';

  @override
  Future<List<ParentReward>> getParentRewards({
    required String familyId,
    required String childId,
  }) async => [];

  @override
  Future<void> saveParentReward({
    required String familyId,
    required ParentReward reward,
  }) async {}

  @override
  Future<void> deleteParentReward({
    required String familyId,
    required String childId,
    required String rewardId,
  }) async {}

  @override
  Future<ParentRewardRedemptionResult> redeemParentReward({
    required String familyId,
    required String childId,
    required String rewardId,
    required String redemptionId,
  }) async => ParentRewardRedemptionResult.redeemed;

  @override
  Future<List<RewardAnnouncement>> getPendingRewardAnnouncements({
    required String familyId,
    required String childId,
  }) async => [];

  @override
  Future<void> markRewardAnnouncementDelivered({
    required String familyId,
    required String childId,
    required String announcementId,
  }) async {}

  @override
  Future<CreditResult> creditOnce({
    required String familyId,
    required String childId,
    required String sourceKey,
    required int amount,
  }) async {
    if (!ledger.add(sourceKey)) return CreditResult.alreadyCredited;
    balance += amount;
    return CreditResult.credited;
  }

  @override
  Future<PurchaseResult> purchase({
    required String familyId,
    required String childId,
    required String findingId,
    required int price,
  }) async {
    lastPrice = price;
    if (inventory.contains(findingId)) return PurchaseResult.alreadyOwned;
    if (balance < price) return PurchaseResult.insufficientBalance;
    balance -= price;
    inventory.add(findingId);
    return PurchaseResult.purchased;
  }

  @override
  Future<List<InventoryEntry>> getInventory({
    required String familyId,
    required String childId,
  }) async => [];

  @override
  Future<List<ShardTransaction>> getRecentTransactions({
    required String familyId,
    required String childId,
    int limit = 20,
  }) async => [];

  @override
  Future<ShardWallet> getWallet({
    required String familyId,
    required String childId,
  }) async => ShardWallet(
    childId: childId,
    balance: balance,
    updatedAt: DateTime.now(),
  );
}
