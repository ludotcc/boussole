import '../core/constants/findings_catalog.dart';
import '../models/finding_catalog_item.dart';
import '../models/inventory_entry.dart';
import '../models/parent_reward.dart';
import '../models/reward_announcement.dart';
import '../models/shard_transaction.dart';
import '../models/shard_wallet.dart';
import '../services/rewards_service.dart';

class RewardsRepository {
  RewardsRepository({RewardsService? service})
    : _service = service ?? RewardsService();

  static const dayCompletionAmount = 0;
  final RewardsService _service;

  String generateParentRewardId(String familyId, String childId) =>
      _service.generateParentRewardId(familyId, childId);

  String generateRedemptionId(String familyId, String childId) =>
      _service.generateRedemptionId(familyId, childId);

  Future<List<ParentReward>> getParentRewards({
    required String familyId,
    required String childId,
  }) => _service.getParentRewards(familyId: familyId, childId: childId);

  Future<void> saveParentReward({
    required String familyId,
    required ParentReward reward,
  }) => _service.saveParentReward(familyId: familyId, reward: reward);

  Future<void> deleteParentReward({
    required String familyId,
    required String childId,
    required String rewardId,
  }) => _service.deleteParentReward(
    familyId: familyId,
    childId: childId,
    rewardId: rewardId,
  );

  Future<ParentRewardRedemptionResult> redeemParentReward({
    required String familyId,
    required String childId,
    required String rewardId,
    required String redemptionId,
  }) => _service.redeemParentReward(
    familyId: familyId,
    childId: childId,
    rewardId: rewardId,
    redemptionId: redemptionId,
  );

  Future<List<RewardAnnouncement>> getPendingRewardAnnouncements({
    required String familyId,
    required String childId,
  }) => _service.getPendingRewardAnnouncements(
    familyId: familyId,
    childId: childId,
  );

  Future<void> markRewardAnnouncementDelivered({
    required String familyId,
    required String childId,
    required String announcementId,
  }) => _service.markRewardAnnouncementDelivered(
    familyId: familyId,
    childId: childId,
    announcementId: announcementId,
  );

  Future<ShardWallet> getWallet({
    required String familyId,
    required String childId,
  }) => _service.getWallet(familyId: familyId, childId: childId);

  Future<List<ShardTransaction>> getRecentTransactions({
    required String familyId,
    required String childId,
  }) => _service.getRecentTransactions(familyId: familyId, childId: childId);

  Future<List<InventoryEntry>> getInventory({
    required String familyId,
    required String childId,
  }) => _service.getInventory(familyId: familyId, childId: childId);

  Future<CreditResult> rewardDayCompletion({
    required String familyId,
    required String childId,
    required DateTime date,
  }) async => CreditResult.alreadyCredited;

  Future<PurchaseResult> purchaseFinding({
    required String familyId,
    required String childId,
    required String findingId,
  }) {
    final FindingCatalogItem? item = findingById(findingId);
    if (item == null) {
      throw ArgumentError.value(findingId, 'findingId', 'Trouvaille inconnue');
    }
    return _service.purchase(
      familyId: familyId,
      childId: childId,
      findingId: item.id,
      price: item.price,
    );
  }

  static String daySourceKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return 'day_$year-$month-$day';
  }
}
