import '../core/constants/findings_catalog.dart';
import '../models/finding_catalog_item.dart';
import '../models/inventory_entry.dart';
import '../models/shard_transaction.dart';
import '../models/shard_wallet.dart';
import '../services/rewards_service.dart';

class RewardsRepository {
  RewardsRepository({RewardsService? service})
    : _service = service ?? RewardsService();

  static const dayCompletionAmount = 25;
  final RewardsService _service;

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
  }) => _service.creditOnce(
    familyId: familyId,
    childId: childId,
    sourceKey: daySourceKey(date),
    amount: dayCompletionAmount,
  );

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
