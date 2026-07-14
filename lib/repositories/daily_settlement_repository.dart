import '../models/daily_light_summary.dart';
import '../models/daily_settlement.dart';
import '../services/daily_settlement_service.dart';

class DailyLightPolicy {
  const DailyLightPolicy();

  static const gentleEventReward = 3;
  static const maximumGentleReward = 6;

  DailyLightSummary summarize({
    required String childId,
    required DateTime date,
    required Iterable<String> relevantItemIds,
    required Set<String> completedItemIds,
  }) {
    final relevant = relevantItemIds.toSet();
    return DailyLightSummary(
      childId: childId,
      date: date,
      completedItems: completedItemIds.intersection(relevant).length,
      totalItems: relevant.length,
    );
  }

  int calculateDailyShardReward(double progressRatio) {
    final ratio = progressRatio.clamp(0.0, 1.0);
    if (ratio >= 1) return 25;
    if (ratio >= .75) return 18;
    if (ratio >= .50) return 10;
    if (ratio >= .25) return 5;
    return 0;
  }

  int calculateGentleSupportBonus(int eligibleEventCount) =>
      (eligibleEventCount * gentleEventReward).clamp(0, maximumGentleReward);
}

class DailySettlementRepository {
  DailySettlementRepository({
    DailySettlementService? service,
    this._policy = const DailyLightPolicy(),
  }) : _service = service ?? DailySettlementService();

  final DailySettlementService _service;
  final DailyLightPolicy _policy;

  Future<void> saveCurrentLight({
    required String familyId,
    required DailyLightSummary summary,
  }) => _service.saveLightSnapshot(familyId: familyId, summary: summary);

  Future<List<DailySettlement>> settlePendingDays({
    required String familyId,
    required String childId,
    DateTime? now,
  }) async {
    final today = now ?? DateTime.now();
    final pending = await _service.getPastLightSnapshots(
      familyId: familyId,
      childId: childId,
      before: DateTime(today.year, today.month, today.day),
    );
    final settlements = <DailySettlement>[];
    for (final summary in pending) {
      if (summary.totalItems == 0) continue;
      final gentleIds = await _service.getEligibleGentleEventIds(
        familyId: familyId,
        childId: childId,
        date: summary.date,
      );
      final progressReward = _policy.calculateDailyShardReward(summary.ratio);
      final gentleBonus = _policy.calculateGentleSupportBonus(gentleIds.length);
      final result = await _service.settleDay(
        familyId: familyId,
        summary: summary,
        progressReward: progressReward,
        gentleSupportBonus: gentleBonus,
        gentleEventIds: gentleIds.take(2).toList(),
      );
      if (result != null) settlements.add(result);
    }
    return settlements;
  }
}
